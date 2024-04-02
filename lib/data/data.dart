// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:math';
import 'package:fml/data/dotnotation.dart';
import 'package:fml/helpers/json.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';

class Data with ListMixin<dynamic> {
  List<dynamic> _list = [];

  String? root;

  Data({dynamic data}) {
    _list = [];
    if (data is List) {
      _list = data;
    } else if (data != null) {
      _list.add(data);
    }
  }

  @override
  void add(dynamic element) => _list.add(element);

  @override
  void addAll(Iterable<dynamic> iterable) => _list.addAll(iterable);

  @override
  void operator []=(int index, dynamic value) => _list[index] = value;

  @override
  dynamic operator [](int index) => _list[index];

  @override
  set length(int newLength) => _list.length = newLength;

  @override
  int get length => _list.length;

  // shallow copy clone of the list
  Data clone() => Data(data: Json.copy(_list));

  static Data from(dynamic value, {String? root}) {
    Data? data;

    if (value is List) data = Data(data: value);
    if (value is Data) data = value;
    if (value is String) {
      var isXml = value.trim().startsWith('<');
      data = isXml ? Data.fromXml(value) : Data.fromJson(value);
    }

    // default
    data ??= Data(data: data);

    // root should be supplied
    root ??= data.findRoot(root);

    // select sub-list
    if (root != null) {
      // convert root to dot notation
      DotNotation? dotnotation = DotNotation.fromString(root);

      // get sublist
      if (dotnotation != null) data = fromDotNotation(data, dotnotation);
    }

    // build default data set
    data ??= Data(data: null);

    // save root name
    data.root = root;

    return data;
  }

  static Data? fromJson(String json) => Data(data: Json.decode(json) ?? []);

  static String toJson(Data? data) => Json.encode(data);

  static Data? fromXml(String xml) => Data.fromJson(Json.fromXml(xml) ?? "{}");

  static String toXml(Data? data,
          {String? defaultRootName, String? defaultNodeName}) =>
      Json.toXml(data,
          defaultRootName: defaultRootName ?? data?.root?.split(".").first,
          defaultNodeName: defaultNodeName ?? data?.root?.split(".").last);

  static Data? fromDotNotation(Data data, DotNotation dotnotation) {
    try {
      if (data.isEmpty) return null;

      dynamic myData = data;
      if (dotnotation.isEmpty) return myData;

      // parse list
      for (NotationSegment? property in dotnotation) {
        if (property != null) {
          if (myData is Map) {
            if (!myData.containsKey(property.name)) {
              myData = null;
              break;
            }
            myData = myData[property.name];
          } else if (myData is List) {
            if (myData.length < property.offset) {
              myData = null;
              break;
            }
            myData = myData[property.offset];
            if ((myData is Map) && (myData.containsKey(property.name))) {
              myData = myData[property.name];
            }
          } else {
            myData = null;
            break;
          }
        }
      }

      return Data(data: myData);
    } catch (e) {
      return null;
    }
  }

  // legacy support pre version 0.9.0
  String? findRoot(String? name) {
    String? root;
    if (_list.isNotEmpty) {
      // find first repeat instance in the tree
      if (name == null) {
        bool done = false;
        dynamic node = _list.first;
        while (!done) {
          if (node is Map) {
            if (node.entries.isEmpty) done = true;
            if (node.entries.length > 1) done = true;
            if (node.entries.length == 1) {
              var name = node.keys.first;
              root = (root == null) ? name : "$root.$name";
              node = node.values.first;
              if ((node is Map) &&
                  (node.entries.isNotEmpty) &&
                  (node.values.first is String)) done = true;
            }
          } else {
            done = true;
          }
        }
        return root;
      }

      // find named map entry
      else {
        bool done = false;
        dynamic node = _list.first;
        while (!done) {
          if (node is Map) {
            var nodename = node.keys.first;
            root = (root == null) ? nodename : "$root.$nodename";
            if (node.containsKey(name)) done = true;
            node = node.values.first;
          } else {
            done = true;
          }
        }
        return root;
      }
    }
    return null;
  }

  static Future<String> toCsv(Data data) async {
    final buffer = StringBuffer();
    String string = "";

    int i = 0;
    try {
      // Build Header
      List<String> header = [];
      List<String> columns = [];
      if (data.isNotEmpty) {
        if (data.first is Map) {
          (data.first as Map).forEach((key, value) {
            columns.add(key);
            String h = key.toString();
            h.replaceAll('"', '""');
            h = h.contains(',') ? '"$h"' : h;
            header.add(h);
          });
        }
      }

      // Output Header
      buffer.write('${header.join(", ")}\n');

      // Output Data
      if (columns.isNotEmpty) {
        for (var map in data) {
          i++;
          List<String> row = [];
          for (var column in columns) {
            String value =
                map.containsKey(column) ? map[column].toString() : '';
            value.replaceAll('"', '""');
            value = value.contains(',') ? '"$value"' : value;
            row.add(value);
          }
          buffer.write('${row.join(", ")}\n');
        }
      }

      // eof
      string = buffer.toString();
      string = string.replaceFirst('\n', '\r\n', string.lastIndexOf('\n'));
    } catch (e) {
      Log().debug('Error - Creating CSV column[$i]');
      Log().exception(e);
    }
    return string;
  }

  // reads a value from the data list
  static void write(dynamic data, String? tag, dynamic value) =>
      Json.write(data, tag, value);

  // reads a value from the data list
  static dynamic read(dynamic data, String? tag) => Json.read(data, tag);

  static Map<String?, dynamic> find(List<Binding>? bindings, dynamic data) {
    Map<String?, dynamic> values = <String?, dynamic>{};
    List<String?> processed = [];
    if (bindings != null) {
      for (Binding binding in bindings) {
        // fully qualified data binding name (datasource.data.field1.field2.field3...fieldn)
        if ((binding.source == 'data')) {
          String? signature = binding.property +
              (binding.dotnotation?.signature != null
                  ? ".${binding.dotnotation!.signature}"
                  : "");
          if (!processed.contains(binding.signature)) {
            processed.add(binding.signature);
            var value = read(data, signature) ?? "";
            values[binding.signature] = value;
          }
        }
      }
    }

    return values;
  }

  static Data testData(int rows) {
    Data data = Data();
    for (int i = 0; i < rows; i++) {
      var first = names[Random().nextInt(names.length)];
      var last = surnames[Random().nextInt(surnames.length)];
      var user = "$first.$last${Random().nextInt(100)}".toUpperCase();

      var row = <String, dynamic>{};
      row["index"] = "$i";
      row["rights"] = Random().nextInt(16);
      row["user"] = user;
      row["first"] = first;
      row["last"] = last;
      row["age"] = Random().nextInt(100);
      row["city"] = cities[Random().nextInt(cities.length)];
      row["occupation"] = jobs[Random().nextInt(jobs.length)];
      row["company"] = companies[Random().nextInt(companies.length)];
      row["email"] = "$user@gmail.com".toLowerCase();
      data.add(row);
    }
    return data;
  }

  static List<String> cities = [
    "Tokyo",
    "Japan",
    "Jakarta",
    "Delhi",
    "Guangzhou",
    "Guangdong",
    "Mumbai",
    "Mahārāshtra",
    "Manila",
    "Shanghai",
    "São Paulo",
    "Seoul",
    "Mexico City",
    "Cairo",
    "New York",
    "Dhaka",
    "Beijing",
    "Bangkok",
    "Shenzhen",
    "Moscow",
    "Buenos Aires",
    "Lagos",
    "Istanbul",
    "Karachi",
    "Bangalore",
    "Ho Chi Minh City",
    "Ōsaka",
    "Chengdu",
    "Sichuan",
    "Tehran",
    "Rio de Janeiro",
    "Toronto",
    "Montreal"
  ];
  static List<String> names = [
    "John",
    "William",
    "James",
    "Charles",
    "George",
    "Frank",
    "Joseph",
    "Thomas",
    "Henry",
    "Robert",
    "Edward",
    "Harry",
    "Walter",
    "Arthur",
    "Fred",
    "Albert",
    "Samuel",
    "David",
    "Louis",
    "Joe",
    "Charlie",
    "Clarence",
    "Richard",
    "Andrew",
    "Daniel",
    "Ernest",
    "Will",
    "Jesse",
    "Oscar",
    "Lewis",
    "Peter",
    "Benjamin",
    "Frederick",
    "Willie",
    "Alfred",
    "Sam",
    "Roy",
    "Herbert",
    "Jacob",
    "Tom",
    "Elmer",
    "Carl",
    "Lee",
    "Howard",
    "Martin",
    "Michael",
    "Bert",
    "Herman",
    "Jim",
    "Francis",
    "Harvey",
    "Earl",
    "Eugene",
    "Ralph",
    "Ed",
    "Claude",
    "Edwin",
    "Ben",
    "Charley",
    "Paul",
    "Edgar",
    "Isaac",
    "Otto",
    "Luther",
    "Lawrence",
    "Ira",
    "Patrick",
    "Guy",
    "Oliver",
    "Theodore",
    "Hugh",
    "Clyde",
    "Alexander",
    "August",
    "Floyd",
    "Homer",
    "Jack",
    "Leonard",
    "Horace",
    "Marion",
    "Philip",
    "Allen",
    "Archie",
    "Stephen",
    "Chester",
    "Willis",
    "Raymond",
    "Rufus",
    "Warren",
    "Jessie",
    "Milton",
    "Alex",
    "Leo",
    "Julius",
    "Ray",
    "Sidney",
    "Bernard",
    "Dan",
    "Jerry",
    "Calvin",
    "Perry",
    "Dave",
    "Anthony",
    "Eddie",
    "Amos",
    "Dennis",
    "Clifford",
    "Leroy",
    "Wesley",
    "Alonzo",
    "Garfield",
    "Franklin",
    "Emil",
    "Leon",
    "Nathan",
    "Harold",
    "Matthew",
    "Levi",
    "Moses",
    "Everett",
    "Lester",
    "Winfield",
    "Adam",
    "Lloyd",
    "Mack",
    "Fredrick",
    "Jay",
    "Jess",
    "Melvin",
    "Noah",
    "Aaron",
    "Alvin",
    "Norman",
    "Gilbert",
    "Elijah",
    "Victor",
    "Gus",
    "Nelson",
    "Jasper",
    "Silas",
    "Christopher",
    "Jake",
    "Mike",
    "Percy",
    "Adolph",
    "Maurice",
    "Cornelius",
    "Felix",
    "Reuben",
    "Wallace",
    "Claud",
    "Roscoe",
    "Sylvester",
    "Earnest",
    "Hiram",
    "Otis",
    "Simon",
    "Willard",
    "Irvin",
    "Mark",
    "Jose",
    "Wilbur",
    "Abraham",
    "Virgil",
    "Clinton",
    "Elbert",
    "Leslie",
    "Marshall",
    "Owen",
    "Wiley",
    "Anton",
    "Morris",
    "Manuel",
    "Phillip",
    "Augustus",
    "Emmett",
    "Eli"
  ];
  static List<String> surnames = [
    "Smith",
    "Johnson",
    "Williams",
    "Brown",
    "Jones",
    "Miller",
    "Davis",
    "Garcia",
    "Rodriguez",
    "Wilson",
    "Martinez",
    "Anderson",
    "Taylor",
    "Thomas",
    "Hernandez",
    "Moore",
    "Martin",
    "Jackson",
    "Thompson",
    "White",
    "Lopez",
    "Lee",
    "Gonzalez",
    "Harris",
    "Clark",
    "Lewis",
    "Robinson",
    "Walker",
    "Perez",
    "Hall",
    "Young",
    "Allen",
    "Sanchez",
    "Wright",
    "King",
    "Scott",
    "Green",
    "Baker",
    "Adams",
    "Nelson",
    "Hill",
    "Ramirez",
    "Campbell",
    "Mitchell",
    "Roberts",
    "Carter",
    "Phillips",
    "Evans",
    "Turner",
    "Torres",
    "Parker",
    "Collins",
    "Edwards",
    "Stewart",
    "Flores",
    "Morris",
    "Nguyen",
    "Murphy",
    "Rivera",
    "Cook",
    "Rogers",
    "Morgan",
    "Peterson",
    "Cooper",
    "Reed",
    "Bailey",
    "Bell",
    "Gomez",
    "Kelly",
    "Howard",
    "Ward",
    "Cox",
    "Diaz",
    "Richardson",
    "Wood",
    "Watson",
    "Brooks",
    "Bennett",
    "Gray",
    "James",
    "Reyes",
    "Cruz",
    "Hughes",
    "Price",
    "Myers",
    "Long",
    "Foster",
    "Sanders",
    "Ross",
    "Morales",
    "Powell",
    "Sullivan",
    "Russell",
    "Ortiz",
    "Jenkins",
    "Gutierrez",
    "Perry",
    "Butler",
    "Barnes",
    "Fisher",
    "Henderson",
    "Coleman",
    "Simmons",
    "Patterson",
    "Jordan",
    "Reynolds"
  ];
  static List<String> jobs = [
    "Veterinarian",
    "Firefighter",
    "Software Developer",
    "Registered Nurse",
    "Physician",
    "Dentist",
    "Engineer",
    "Financial Manager",
    "Lawyer",
    "Electrician",
    "Physician Assistant",
    "Police Officer",
    "Pharmacist",
    "Civil Engineer",
    "Nurse Practitioner",
    "Actuary",
    "Doctor",
    "Architect",
    "Accountant",
    "Air Traffic Controller",
    "Pilot",
    "Plumber",
    "Psychologist",
    "Physical Therapist",
    "Engineer",
    "Manager",
    "Hair Dresser",
    "Realtor"
  ];
  static List<String> companies = [
    "Apple",
    "Microsoft",
    "Saudi Aramco",
    "Alphabet (Google)",
    "Amazon",
    "Berkshire Hathaway",
    "NVIDIA",
    "Meta Platforms (Facebook)",
    "Tesla",
    "Johnson & Johnson",
    "Visa",
    "Exxon Mobil",
    "LVMH",
    "UnitedHealth",
    "TSMC",
    "Tencent",
    "Walmart",
    "JPMorgan Chase",
    "Eli Lilly",
    "Novo Nordisk",
    "Procter & Gamble",
    "Mastercard",
    "Nestlé",
    "Samsung",
    "Kweichow Moutai",
    "Chevron",
    "Home Depot",
    "Merck",
    "Coca-Cola",
    "AbbVie",
    "Pepsico",
    "Broadcom",
    "Oracle",
    "L'Oréal",
    "Roche",
    "ASML",
    "AstraZeneca",
    "International Holding Company",
    "Bank of America",
    "ICBC",
    "Hermès",
    "Alibaba",
    "Costco",
    "Pfizer",
    "Novartis",
    "McDonald",
    "Thermo Fisher Scientific",
    "Shell",
    "Reliance Industries",
    "PetroChina",
    "Salesforce",
    "Nike",
    "Cisco",
    "Abbott Laboratories",
    "China Mobile",
    "Walt Disney",
    "Toyota",
    "Linde",
    "Accenture",
    "Danaher",
    "Comcast",
    "T-Mobile US",
    "Adobe",
    "Agricultural Bank of China",
    "China Construction Bank",
    "Dior",
    "Verizon",
    "SAP",
    "TotalEnergies",
    "Philip Morris",
    "Nextera Energy",
    "United Parcel Service",
    "Wells Fargo",
    "Texas Instruments",
    "Morgan Stanley",
    "Prosus",
    "BHP Group",
    "CATL",
    "Netflix",
    "Raytheon Technologies",
    "Bank of China",
    "AMD",
    "HSBC",
    "Tata Consultancy Services",
    "Bristol-Myers Squibb",
    "Unilever",
    "Royal Bank Of Canada",
    "Ping An Insurance",
    "Sanofi",
    "Honeywell",
    "China Life Insurance",
    "Starbucks",
    "QUALCOMM",
    "Siemens",
    "HDFC Bank",
    "Intel",
    "Anheuser-Busch Inbev",
    "Amgen",
    "AT&T",
    "AIA"
  ];
}
