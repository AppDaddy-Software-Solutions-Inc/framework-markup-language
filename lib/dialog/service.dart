// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/dialog/request.dart';
import 'package:fml/dialog/response.dart';
import 'package:fml/system.dart';

enum DialogType{ error, success, info, modal, warning, none }

class DialogService
{
  static final DialogService _singleton = DialogService._init();
  factory DialogService()
  {
    return _singleton;
  }
  DialogService._init();

  late Function(DialogRequest) _showDialogListener;
  Completer<AlertResponse>? _dialogCompleter;

  ///////////////////////////////////////
  //** Registers a callback function **//
  ///////////////////////////////////////
  void registerDialogListener(Function(DialogRequest) showDialogListener)
  {
    _showDialogListener = showDialogListener;
  }

  Future<AlertResponse> _show(DialogType? type, Image? image, String? title, String? description, Widget? content, List<Widget>? buttons) async
  {
    _dialogCompleter = Completer<AlertResponse>();
    _showDialogListener(DialogRequest(type: type, image: image, title: title, description: description, content: content, buttons: buttons));
    return _dialogCompleter!.future;
  }

  Future<int?> show({DialogType? type, Image? image, String? title, String? description, Widget? content, List<Widget>? buttons}) async
  {
    _dialogCompleter = Completer<AlertResponse>();
    AlertResponse result = await _show(type, image, title, description, content, buttons);
    return result.pressed;
  }

  open(BuildContext context, Widget content, {RouteSettings? settings, dynamic title, double? width, double? height}) async // Works with android back button and multiple stacked modals
  {
   ///////////////////////////////////////
   /* Hack to Ensure Close Button Works */
   ///////////////////////////////////////
   NavigatorState navigator = Navigator.of(context);

   /////////////////////
    /* Default Padding */
    /////////////////////
    double paddingV = isMobile ? 64 : 128;
    double paddingH = isMobile ? 10 : 128;

   double paddingTop    = 0;
   double paddingBottom = 10;
   double paddingLeft   = 10;
   double paddingRight  = 10;

   double screenWidth  = MediaQuery.of(context).size.width;
   double screenHeight = MediaQuery.of(context).size.height;

   if (height == null) height = MediaQuery.of(context).size.height;
   if (width == null)  width  = MediaQuery.of(context).size.width;

   height = height - paddingTop  - paddingBottom;
   width  = width  - paddingLeft - paddingRight;

   if (width  > (screenWidth  - (paddingH * 2))) width  = (screenWidth  - (paddingH * 2));
   if (height > (screenHeight - (paddingV * 2))) height = (screenHeight - (paddingV * 2));
   //if (width  < 200)  width = 200;
   //if (height < 200) height = 200;

   //////////////////
   /* Close Button */
   //////////////////
   // Widget header = Container(child: Stack(fit: StackFit.passthrough, children: [
   //   SizedBox(height: 50, child: Align(alignment: Alignment.center, child: Text(title ?? ''))),
   //   Align(alignment: Alignment.topRight, child: SizedBox(height: 50, width: 50, child: IconButton(onPressed: () => (navigator != null ? navigator.pop() : null), icon: Icon(Icons.cancel, size: 24, color: Theme.of(context).primaryColorDark,)))),
   // ]));
   Widget? header;
   if (title is Widget)
        header = title;
   else header = Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Expanded(child: SizedBox(height: 50, width: width-50, child: Align(alignment: Alignment.center, child: Text(title ?? '', style: TextStyle(fontSize: 12))))),
         SizedBox(height: 50, width: 50, child: IconButton(onPressed: () => ( navigator.pop()), icon: Icon(Icons.cancel, size: 24, color: Theme.of(context).primaryColorDark,)))
   ]);

   var box = UnconstrainedBox(child: SizedBox(width: width, height: height, child: content));

   ///////////////////
    /* Build Dialog */
   ///////////////////
    AlertDialog alert = AlertDialog(
      title: header,
      insetPadding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      titlePadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom, left: paddingLeft, right: paddingRight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3.0))),
      content: box,
    );

    ////////////////////
    /* Display Dialog */
    ////////////////////
    await showDialog(context: context, useRootNavigator: false, routeSettings: settings, builder: (BuildContext context)
    { // turn root navigation off for back button functionality to close modal.
      return WillPopScope(onWillPop: () => Future.value(true), child: alert);
    });
  }

  //////////////////////////////////////////////////////////////////////////////
  //** Completes the _dialogCompleter to resume the Future's execution call **//
  //////////////////////////////////////////////////////////////////////////////
  void dialogComplete(AlertResponse response)
  {
    if (_dialogCompleter != null) _dialogCompleter!.complete(response);
    _dialogCompleter = null;
  }
}