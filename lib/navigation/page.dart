// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

class PageConfiguration
{
  String? title;

  final String? url;
  final String? transition;

  Uri? uri;

  Route? route;

  String get breadcrumb
  {
    String text = title ?? url ?? "";
    return text.toLowerCase().split('/').last.split('.xml').first;
  }

  PageConfiguration({required this.url, this.title, this.transition})
  {
    if (url != null) uri = Uri.tryParse(url!);
  }
}