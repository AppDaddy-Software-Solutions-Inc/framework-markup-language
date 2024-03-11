
import 'package:jiffy/jiffy.dart';

enum TimeUnit {
  millisecond, second, minute, hour, day, week, month, year;
  const TimeUnit();

  /// Returns [TimeUnit]s as milliseconds (except month/year)
  double asMs() {
    switch(this) {
      case TimeUnit.millisecond:
        return 1;
      case TimeUnit.second:
        return 1000;
      case TimeUnit.minute:
        return 60000;
      case TimeUnit.hour:
        return 3600000;
      case TimeUnit.day:
        return 86400000;
      case TimeUnit.week:
        return 604800000;
      default: // Unable to give precise values for month/year
        return 0;
    }
  }

  Unit asUnit() {
    switch(this) {
      case TimeUnit.millisecond:
        return Unit.millisecond;
      case TimeUnit.second:
        return Unit.second;
      case TimeUnit.minute:
        return Unit.minute;
      case TimeUnit.hour:
        return Unit.hour;
      case TimeUnit.day:
        return Unit.day;
      case TimeUnit.week:
        return Unit.week;
      case TimeUnit.month:
        return Unit.month;
      case TimeUnit.year:
        return Unit.year;
    }
  }

}

/// Time Helper Class
class DT {

  /// Given a string such as '100ms' or '10 years' this function returns a
  /// [TimeUnitDuration] object
  static TimeUnitDuration getTUDurationFromString(String str) {
    return TimeUnitDuration.fromString(str);
  }

  /// Formats a date/time string
  static String formatString(String datetime, String inputFormat, String outputFormat) =>
      Jiffy.parse(datetime, pattern: inputFormat).format(pattern: outputFormat);

  /// Formats a [DateTime] into a String
  static String formatDateTime(DateTime datetime, String outputFormat) =>
      Jiffy.parseFromDateTime(datetime).format(pattern: outputFormat);

  /// Returns a human readable string of the time between 2 [DateTime]s
  /// ex: '1 minute ago' or 'in 2 days'
  static String timeBetween(DateTime a, DateTime b) =>
      Jiffy.parseFromDateTime(a).from(Jiffy.parseFromDateTime(b));

  /// Compare if DateTime a is before DateTime b
  static bool isBefore(DateTime a, DateTime b) =>
      Jiffy.parseFromDateTime(a).isBefore(Jiffy.parseFromDateTime(b));

  /// Compare if DateTime a is after DateTime b
  static bool isAfter(DateTime a, DateTime b) =>
      Jiffy.parseFromDateTime(a).isAfter(Jiffy.parseFromDateTime(b));

  /// Compare if DateTime a is before DateTime b or the same
  static bool isSameOrBefore(DateTime a, DateTime b) =>
      Jiffy.parseFromDateTime(a).isSameOrBefore(Jiffy.parseFromDateTime(b));

  /// Compare if DateTime a is after DateTime b or the same
  static bool isSameOrAfter(DateTime a, DateTime b) =>
      Jiffy.parseFromDateTime(a).isSameOrAfter(Jiffy.parseFromDateTime(b));

  /// Compare if DateTime a the same as DateTime b
  static bool isSame(DateTime a, DateTime b) =>
      Jiffy.parseFromDateTime(a).isSame(Jiffy.parseFromDateTime(b));

  /// Adds a [TimeUnitDuration] to a [DateTime]
  static DateTime add(DateTime dateTime, TimeUnitDuration tud) =>
      Jiffy.parseFromDateTime(dateTime).add(
          milliseconds: tud.timeUnit == TimeUnit.millisecond ? tud.amount : 0,
          seconds: tud.timeUnit == TimeUnit.second ? tud.amount : 0,
          minutes: tud.timeUnit == TimeUnit.minute ? tud.amount : 0,
          hours: tud.timeUnit == TimeUnit.hour ? tud.amount : 0,
          days: tud.timeUnit == TimeUnit.day ? tud.amount : 0,
          months: tud.timeUnit == TimeUnit.month ? tud.amount : 0,
          years: tud.timeUnit == TimeUnit.year ? tud.amount : 0
      ).dateTime;

  /// Subtracts a [TimeUnitDuration] from a [DateTime]
  static DateTime subtract(DateTime dateTime, TimeUnitDuration tud) =>
      Jiffy.parseFromDateTime(dateTime).subtract(
          milliseconds: tud.timeUnit == TimeUnit.millisecond ? tud.amount : 0,
          seconds: tud.timeUnit == TimeUnit.second ? tud.amount : 0,
          minutes: tud.timeUnit == TimeUnit.minute ? tud.amount : 0,
          hours: tud.timeUnit == TimeUnit.hour ? tud.amount : 0,
          days: tud.timeUnit == TimeUnit.day ? tud.amount : 0,
          months: tud.timeUnit == TimeUnit.month ? tud.amount : 0,
          years: tud.timeUnit == TimeUnit.year ? tud.amount : 0
      ).dateTime;

  /// Rounds the DateTime to the closest past [TimeUnitDuration]
  static DateTime floor(DateTime dateTime, TimeUnit tu) =>
    Jiffy.parseFromDateTime(dateTime).startOf(tu.asUnit()).dateTime;

  /// Rounds the DateTime to the closest future [TimeUnitDuration]
  static DateTime ceil(DateTime dateTime, TimeUnit tu) =>
      Jiffy.parseFromDateTime(Jiffy.parseFromDateTime(dateTime).startOf(tu.asUnit()).dateTime.isBefore(dateTime)
          ? add(dateTime, TimeUnitDuration(1, tu))
          : dateTime)
          .startOf(tu.asUnit()).dateTime;
}

/// Specifies a custom time unit using familiar [TimeUnit]s and an amount to
/// establish the duration period.
/// Returns 0 [TimeUnit.millisecond]s if the parsing fails
class TimeUnitDuration {
  late int amount;
  late TimeUnit timeUnit;

  TimeUnitDuration(this.amount, this.timeUnit);

  TimeUnitDuration.fromString(String str) {
    String tudString = str.toString().trim();
    List<dynamic> matches = [
      ...RegExp(r'\d+|[A-Za-z]+')
          .allMatches(tudString).map((match) => match[0]!)
          .map((string) => int.tryParse(string) ?? string)
    ];
    int? amt;
    String? time;
    if (matches.length >= 2 && matches[0].runtimeType == int && matches[1].runtimeType == String) {
      amt = matches[0]!;
      time = matches[1]!;
    }
    if (amt == null || time == null) {
      amount = 0;
      timeUnit = TimeUnit.millisecond;
    }
    else {
      switch (time.trim().toLowerCase()) {
        case 'ms':
        case 'millisecond':
        case 'milliseconds':
        amount = amt;
        timeUnit = TimeUnit.millisecond;
          break;
        case 's':
        case 'sec':
        case 'second':
        case 'seconds':
        amount = amt;
        timeUnit = TimeUnit.second;
          break;
        case 'm':
        case 'min':
        case 'minute':
        case 'minutes':
        amount = amt;
        timeUnit = TimeUnit.minute;
          break;
        case 'h':
        case 'hr':
        case 'hour':
        case 'hours':
        amount = amt;
        timeUnit = TimeUnit.hour;
          break;
        case 'd':
        case 'day':
        case 'days':
        amount = amt;
        timeUnit = TimeUnit.day;
          break;
        case 'w':
        case 'week':
        case 'weeks':
        amount = amt;
        timeUnit = TimeUnit.week;
          break;
        case 'mo':
        case 'month':
        case 'months':
        amount = amt;
        timeUnit = TimeUnit.month;
          break;
        case 'y':
        case 'yr':
        case 'year':
        case 'years':
        amount = amt;
        timeUnit = TimeUnit.year;
          break;
        default:
          amount = 0;
          timeUnit = TimeUnit.millisecond;
          break;
      }
    }
  }

  /// Returns the [TimeUnitDuration] in milliseconds
  double asMs() {
    return amount * timeUnit.asMs();
  }

  /// Check if the [TimeUnitDuration] is 0
  bool isZero() {
    return amount == 0;
  }

  /// Returns the [TimeUnitDuration] as a string
  @override
  String toString() {
    return '${amount.toString()} ${timeUnit.name}${amount > 0 ? 's' : ''}';
  }

}