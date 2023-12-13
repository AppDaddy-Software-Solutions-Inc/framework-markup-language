// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

class PageConfiguration
{
  String? title;
  final String? transition;

  Uri? uri;
  Route? route;

  String get breadcrumb
  {
    String text = title ?? uri?.toString() ?? "";
    return text.toLowerCase().split('/').last.split('.xml').first;
  }

  PageConfiguration({required this.uri, this.title, this.transition});
}