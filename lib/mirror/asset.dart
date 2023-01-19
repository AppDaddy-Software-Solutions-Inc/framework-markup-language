// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:xml/xml.dart';
import 'package:fml/datasources/http/http.dart';
import 'package:fml/helper/common_helpers.dart';

class Asset
{
  String? uri;
  String? type;

  String? _name;
  String? get name
  {
    return _name;
  }
  set name (String? s)
  {
    if (s != null) s = s.toLowerCase();
    if (s != _name)
    {
      _name = s;
    }
  }
  double? _epoch;
  double? get epoch
  {
    return _epoch;
  }
  set epoch (double? e)
  {
    if (e != _epoch)
    {
      _epoch = e;
    }
  }

  deserialize(XmlElement xml)
  {
    String tag = 'uri';
    uri = Xml.get(node: xml, tag: tag);

    tag = 'type';
    type = Xml.get(node: xml, tag: tag);

    tag = 'name';
    name = Xml.get(node: xml, tag: tag);

    tag = 'updated';
    String? updated = Xml.get(node: xml, tag: tag);
    if (S.isNumber(updated)) epoch = S.toDouble(updated);
  }
}

class Assets
{
  List<Asset> list = [];

  deserialize(XmlElement xml)
  {
      Iterable<XmlElement> assetNodes = xml.findElements("Asset", namespace: "*");
      for (XmlElement assetNode in assetNodes)
      {
        Asset asset = Asset();
        asset.deserialize(assetNode);
        list.add(asset);
      }
  }

  load(String url) async
  {
    list.clear();

    // perform inventory
    final response = await Http.get(url);

    // error?
    if (!response.ok)
    {
      Log().error('Error getting asset from $url. Error is $response', caller: "Mirror");
      return;
    }

    // parse
    XmlDocument? document = Xml.tryParse(response.body);
    if (document != null) deserialize(document.rootElement);
  }
}