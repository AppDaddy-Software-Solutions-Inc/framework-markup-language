// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/dialog/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:fml/widgets/goback/goback.dart';
import 'package:fml/widgets/pager/page/page_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/datasources/gps/payload.dart';
import 'package:fml/datasources/gps/gps_listener_interface.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:fml/widgets/pager/pager_model.dart';

class FormView extends StatefulWidget implements ViewableWidgetView {
  @override
  final FormModel model;
  FormView(this.model) : super(key: ObjectKey(model));

  @override
  FormViewState createState() => FormViewState();
}

class FormViewState extends ViewableWidgetState<FormView> implements IGpsListener {
  Widget? busy;

  @override
  onGpsData({Payload? payload}) {
    // Save Current Location
    if (payload != null) System().currentLocation = payload;
  }

  @override
  void initState() {
    super.initState();

    // Listen to GPS
    if (widget.model.geocode == true) System().gps.registerListener(this);

    // do form initialization
    widget.model.initialize();
  }

  @override
  void dispose() {
    // Stop Listening to GPS
    System().gps.removeListener(this);

    super.dispose();
  }

  Future<bool> quit() async {
    Model.unfocus();
    bool exit = true;

    // model is dirty?
    if (widget.model.dirty) {
      //var color = Theme.of(context).buttonTheme.colorScheme?.inversePrimary ?? Theme.of(context).colorScheme.inversePrimary;
      var color = Colors.black87;
      var no = Text(phrase.no,
          style: TextStyle(
              fontSize: 14, color: color, fontWeight: FontWeight.w500));
      var yes = Text(phrase.yes,
          style: TextStyle(
              fontSize: 14, color: color, fontWeight: FontWeight.w500));
      int? response = await widget.model.framework?.show(
          type: DialogType.info,
          title: phrase.continueQuitting,
          buttons: [no, yes]);
      exit = (response == 1);
    }
    return exit;
  }

  void show(IFormField model) {
    try {
      bool found = false;

      for (IFormField field in widget.model.formFields) {
        if (field == model) {
          found = true;
          try {
            List<dynamic>? pagers =
                (field as Model).findAncestorsOfExactType(PageModel);
            if (pagers != null) {
              Log().debug('found ${pagers.length} page(s)');
              for (PageModel page in pagers as Iterable<PageModel>) {
                // ensure we can handle pagers within pagers, probably a bit extreme
                PagerModel pageParent = page.parent
                    as PagerModel; // (parent as PAGER.PagerModel).View();
                int? index;
                for (int i = 0; i < pageParent.pages.length; i++) {
                  if (pageParent.pages[i] == page) {
                    index = i;
                    i = pageParent.pages.length;
                  }
                }
                if (index != null && pageParent.controller != null) {
                  // found page with field to go to within pager
                  pageParent.controller!.jumpToPage(index);
                }
              }
            }
          } catch (e) {
            Log().debug('$e');
          }
          break;
        }
      }
      if (found == false) {
        Log().debug('Unable to find field');
      }
    } catch (e) {
      Log().error('Error scrolling to form field. eror is $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // Center
    Widget view = BoxView(widget.model);

    // Close Keyboard
    //final gesture = GestureDetector(onTap: () => WidgetModel.unfocus(), child: view);

    /// Busy / Loading Indicator
    busy ??= BusyModel(widget.model,
            visible: widget.model.busy, observable: widget.model.busyObservable)
        .getView();

    // stack gets the same size as the view when busy is positioned rather than center
    view = GoBack(
        canGoBack: quit,
        child: Stack(children: [
          view,
          Positioned(left: 0, right: 0, top: 0, bottom: 0, child: busy!)
        ]));

    // apply user defined constraints
    return view;
  }
}
