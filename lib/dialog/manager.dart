// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'alert.dart';

enum DialogType{ error, success, info, modal, warning, none }

class DialogManager
{
  static void _showDialog(BuildContext context, Completer<AlertResponse> completer, DialogRequest request)
  {
    // build buttons
    List<OutlinedButton> buttons = [];

    int i = 0;

    if (request.buttons != null){
    for (final button in request.buttons!)
    {
      final idx = i;
      var b = OutlinedButton(child: button, onPressed: ()
      {
        completer.complete(AlertResponse(pressed: idx));
        Navigator.of(context).pop();
      });
      buttons.add(b);
      i++;
    }}

    if (request.type == DialogType.modal)
    {
      // close button
      dynamic closeButton = Column(crossAxisAlignment: CrossAxisAlignment.end, children: [SizedBox(width: 35, child: IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.cancel, size: 24)))]);
      if (request.title != null && request.title != '')
      {
        closeButton = Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Container(child: Text(request.title!, style: TextStyle(fontSize: 16)))),
          closeButton,
        ]);
      }

      // title
      var title = Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: closeButton);

      // dialog
      AlertDialog dialog = AlertDialog(
          title: title,
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 128, vertical: isMobile ? 64 : 128),
          titlePadding: EdgeInsets.all(0),
          content: request.content,
          contentPadding: EdgeInsets.only(top: 0, bottom: 10, left: isMobile ? 2 : 10, right: isMobile ? 2 : 10));

      // show the dialog
      showDialog(context: context, useRootNavigator: true, builder: (BuildContext context) => dialog);
    }

    else
    {
      // style
      AlertStyle style = AlertStyle(
        isCloseButton: true,
        isOverlayTapDismiss: buttons.isNotEmpty ? false : true,
        animationDuration: Duration(milliseconds: 400),
        alertBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.transparent, width: 0.0)),
        backgroundColor: Colors.white,
        alertElevation: 25,
      );

      // build dialog
      Types type = Types.none;
      if (request.type == DialogType.none)    type = Types.none;
      if (request.type == DialogType.info)    type = Types.info;
      if (request.type == DialogType.warning) type = Types.warning;
      if (request.type == DialogType.error)   type = Types.error;
      if (request.type == DialogType.success) type = Types.success;
      if (request.type == DialogType.modal)   type = Types.none;

      Alert dialog = Alert(context: context, type: type, style: style, image: request.image, title: request.title ?? '', desc: request.description, content: request.content, buttons: buttons, closeFunction: () {completer.complete(AlertResponse(pressed: -1)); Navigator.of(context).pop();});

      // display dialog
      dialog.show();
    }
  }

  static Future<AlertResponse> _show(BuildContext context, DialogType? type, Image? image, String? title, String? description, Widget? content, List<Widget>? buttons) async
  {
    Completer<AlertResponse> completer = Completer<AlertResponse>();
    _showDialog(context, completer, DialogRequest(type: type, image: image, title: title, description: description, content: content, buttons: buttons));
    return completer.future;
  }

  static Future<int?> show(BuildContext context, {DialogType? type, Image? image, String? title, String? description, Widget? content, List<Widget>? buttons}) async
  {
    AlertResponse result = await _show(context, type, image, title, description, content, buttons);
    return result.pressed;
  }
}

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

class AlertResponse
{
  final int? pressed;
  AlertResponse({this.pressed});
}