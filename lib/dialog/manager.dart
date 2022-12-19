// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/dialog/request.dart';
import 'package:fml/dialog/response.dart';
import 'package:fml/dialog/service.dart';
import 'package:fml/system.dart';
import 'alert.dart';

class DialogManager extends StatefulWidget
{
  final Widget? child;
  DialogManager({Key? key, this.child}) : super(key: key);

  _DialogManagerState createState() => _DialogManagerState();
}

class _DialogManagerState extends State<DialogManager>
{
  DialogService _service = DialogService();

  @override
  void initState()
  {
    super.initState();
    _service.registerDialogListener(_showDialog);
  }

  @override
  Widget build(BuildContext context)
  {
    return widget.child!;
  }

  void _showDialog(DialogRequest request)
  {
    /////////////////////
    //* Build Buttons *//
    /////////////////////
    List<DialogButton> buttons = [];

    int i = 0;

    if (request.buttons != null)
    for (final button in request.buttons!)
    {
      final idx = i;
      DialogButton b = DialogButton(child: button, onPressed: () {_service.dialogComplete(AlertResponse(pressed: idx)); Navigator.of(context).pop();});
      buttons.add(b);
      i++;
    }

    if (request.type == DialogType.modal)
    {
      dynamic closeButton = Column(crossAxisAlignment: CrossAxisAlignment.end, children: [SizedBox(width: 35, child: IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.cancel, size: 24)))]);
      if (request.title != null && request.title != '')
        closeButton = Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Container(child: Text(request.title!, style: TextStyle(fontSize: 16)))),
          closeButton,
        ],);


      double paddingV = isMobile ? 64 : 128;
      double paddingH = isMobile ? 10 : 128;

      AlertDialog modalWindow = AlertDialog(title: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: closeButton), insetPadding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
          titlePadding: EdgeInsets.all(0),
          content: request.content,
          contentPadding: EdgeInsets.only(top: 0, bottom: 10, left: isMobile ? 2 : 10, right: isMobile ? 2 : 10)
      );
      showDialog(context: context, useRootNavigator: true, builder: (BuildContext context)
      { // turn root navigation off for back button functionality to close modal.
        return modalWindow;
      });
    }

    else
    {

      ///////////////
      //** Style **//
      ///////////////
      AlertStyle style = AlertStyle(
        animationType: Animations.grow,
        isCloseButton: true,
        isOverlayTapDismiss: buttons.isNotEmpty ? false : true,
        animationDuration: Duration(milliseconds: 400),
        alertBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.transparent, width: 0.0)),
        backgroundColor: Colors.white,
        alertElevation: 25,
      );

      ////////////////////
      //* Build Dialog *//
      ////////////////////
      Types type = Types.none;
      if (request.type == DialogType.none)    type = Types.none;
      if (request.type == DialogType.info)    type = Types.info;
      if (request.type == DialogType.warning) type = Types.warning;
      if (request.type == DialogType.error)   type = Types.error;
      if (request.type == DialogType.success) type = Types.success;
      if (request.type == DialogType.modal)   type = Types.none;
      Alert dialog = Alert(context: context, type: type, style: style, image: request.image, title: request.title ?? '', desc: request.description, content: request.content, buttons: buttons, closeFunction: () {_service.dialogComplete(AlertResponse(pressed: -1)); Navigator.of(context).pop();});

      //////////////////////
      //* Display Dialog *//
      //////////////////////
      dialog.show();
    }
  }
}