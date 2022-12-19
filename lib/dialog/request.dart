// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/dialog/service.dart';
import 'package:flutter/material.dart';

class DialogRequest
{
  DialogType?          type;
  final Image?         image;
  final String?        title;
  final String?        description;
  final Widget?        content;
  final List<Widget>?  buttons;

  DialogRequest({this.type, this.image, this.title, this.description, this.content, this.buttons});
}