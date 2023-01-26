// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/dialog/service.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/event/event.dart' ;
import 'package:fml/widgets/form/iFormField.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/busy/busy_view.dart' as BUSY;
import 'package:fml/widgets/busy/busy_model.dart' as BUSY;
import 'package:fml/datasources/gps/payload.dart'       as GPS;
import 'package:fml/datasources/gps/iGpsListener.dart'  as GPS;
import 'package:fml/widgets/form/form_model.dart' as FORM;
import 'package:fml/widgets/pager/page/pager_page_model.dart' as PAGE;
import 'package:fml/widgets/pager/pager_model.dart' as PAGER;
import 'package:fml/helper/common_helpers.dart';

class FormView extends StatefulWidget
{
  final FORM.FormModel model;
  FormView(this.model) : super(key: ObjectKey(model));

  @override
  _FormViewState createState() => _FormViewState();
}

class _FormViewState extends State<FormView> implements IModelListener,  GPS.IGpsListener
{
  BUSY.BusyView? busy;

  onGpsData({GPS.Payload? payload})
  {
    ///////////////////////////
    /* Save Current Location */
    ///////////////////////////
    if (payload != null) System().currentLocation = payload;
  }

  @override
  void initState()
  {
    super.initState();

    // Listen to GPS
    if (widget.model.geocode == true) System().gps.registerListener(this);

    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.save,     onSave);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.complete, onComplete);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.validate, onValidate);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.clear,    onClear);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FormView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.save,     onSave);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.complete, onComplete);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.validate, onValidate);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.clear,    onClear);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.save,     onSave);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.complete, onComplete);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.validate, onValidate);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.clear,    onClear);

      // remove old model listener
      oldWidget.model.removeListener(this);

      // register new model listener
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);

    // remove event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.save,     onSave);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.complete, onComplete);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.validate, onValidate);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.clear,    onClear);

    // Stop Listening to GPS
    System().gps.removeListener(this);

    super.dispose();
  }
  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  Future<bool> quit() async
  {
    WidgetModel.unfocus();
    bool exit = true;
    bool dirty = widget.model.dirty!;

    if (dirty)
    {
      int? response = await DialogService().show(type: DialogType.info, title: phrase.saveBeforeExit, buttons: [Text(phrase.yes, style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.outline)),Text(phrase.no, style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.outline))]);
      exit = (response == 1);
    }
    return exit;
  }

  void flipToPage(IFormField model)
  {
    bool found = false;

    for (IFormField field in widget.model.fields)
    {
      if (field == model)
      {
        found = true;
        try {
          List<dynamic>? pagers = (field as WidgetModel).findAncestorsOfExactType(PAGE.PagerPageModel);
          if (pagers != null) {
            Log().debug('found ${pagers.length} page(s)');
            for (PAGE.PagerPageModel page in pagers as Iterable<PAGE.PagerPageModel>) { // ensure we can handle pagers within pagers, probably a bit extreme
              PAGER.PagerModel pageParent = page.parent as PAGER.PagerModel; // (parent as PAGER.PagerModel).View();
              int? index;
              for (int i = 0; i < pageParent.pages.length; i++) {
                if (pageParent.pages[i] == page) {
                  index = i;
                  i = pageParent.pages.length;
                }
              }
              if (index != null && pageParent.controller != null) { // found page with field to go to within pager
                pageParent.controller!.jumpToPage(index);
              }
            }
          }
        } catch(e) {}
        break;
      }
    }
    if (found == false)
      Log().debug('Unable to find field');
  }

  void uncollapseList(IFormField model)
  {
    bool found = false;

    for (IFormField field in widget.model.fields)
    {
      if (field == model)
      {
        found = true;
        try {
          List<dynamic>? pagers = (field as WidgetModel).findAncestorsOfExactType(PAGE.PagerPageModel);
          if (pagers != null) {
            Log().debug('found ${pagers.length} page(s)');
            for (PAGE.PagerPageModel page in pagers as Iterable<PAGE.PagerPageModel>) { // ensure we can handle pagers within pagers, probably a bit extreme
              PAGER.PagerModel pageParent = page.parent as PAGER.PagerModel; // (parent as PAGER.PagerModel).View();
              int? index;
              for (int i = 0; i < pageParent.pages.length; i++) {
                if (pageParent.pages[i] == page) {
                  index = i;
                  i = pageParent.pages.length;
                }
              }
              if (index != null && pageParent.controller != null) { // found page with field to go to within pager
                pageParent.controller!.jumpToPage(index);
              }
            }
          }
        } catch(e) {}
        break;
      }
    }
    if (found == false)
      Log().debug('Unable to find field');
  }

  Future<bool> validate() async
  {
    ///////////////////
    /* Check Missing */
    ///////////////////
    List<IFormField>? missing = await widget.model.missing();
    if (missing != null)
    {
      String msg = phrase.warningMandatory.replaceAll('{#}', missing.length.toString());
      try {
        flipToPage(missing[0]);
      } catch(e) {
        Log().debug('Unable to flipToPage to mandatory field');
      }
      try {
        // uncollapseList(missing[0]);
      } catch(e) {
        Log().debug('Unable to uncollapseList to mandatory field');
      }
      try {
        // scrollTo(missing[0]);
      } catch(e) {
        Log().debug('Unable to scrollTo mandatory field');
      }
      await DialogService().show(type: DialogType.warning, title: phrase.warning, description: msg);
      return false;
    }

    //////////////////
    /* Check Alarms */
    //////////////////
    List<IFormField>? alarming;// = await widget.model.alarming();
    if (alarming != null)
    {
      String msg = phrase.warningAlarms.replaceAll('{#}', alarming.length.toString());
      try {
        flipToPage(missing![0]);
      } catch(e) {
        Log().debug('Unable to flipToPage to mandatory field');
      }
      try {
        // uncollapseList(missing[0]);
      } catch(e) {
        Log().debug('Unable to uncollapseList to mandatory field');
      }
      try {
        // scrollTo(missing[0]);
      } catch(e) {
        Log().debug('Unable to scrollTo mandatory field');
      }
      await DialogService().show(type: DialogType.warning, title: phrase.warning, description: msg);
      return false;
    }

    return true;
  }

  Future<bool> onSave(Event event) async
  {
    bool ok = true;

    ///////////////////////////
    /* Mark Event as Handled */
    ///////////////////////////
    event.handled = true;

    /////////////////
    /* Force Close */
    /////////////////
    WidgetModel.unfocus();

    ///////////////////////
    /* Validate the Data */
    ///////////////////////
    if (ok) ok = await validate();

    ///////////////////
    /* Save the Data */
    ///////////////////
    if (ok) ok = await widget.model.save();

    //////////////////
    /* Show Success */
    //////////////////
    if (ok)
    {
       final snackbar = SnackBar(content: Text(phrase.formSaved), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating, elevation: 5);
       ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }

    return ok;
  }

  Future<bool> onValidate(Event event) async
  {
    bool ok = true;

    ////////////////////////
    /* Specific Complete? */
    ////////////////////////
    if ((event.parameters != null) && (!S.isNullOrEmpty(event.parameters!['id'])) && (event.parameters!['id'] != widget.model.id)) return ok;

    ///////////////////////////
    /* Mark Event as Handled */
    ///////////////////////////
    event.handled = true;

    /////////////////
    /* Force Close */
    /////////////////
    WidgetModel.unfocus();

    /////////////////////
    /* Commit the Form */
    /////////////////////
    if (ok) ok = await widget.model.commit();

    return ok;
  }

  Future<bool> onComplete(Event event) async
  {
    bool ok = true;

    ////////////////////////
    /* Specific Complete? */
    ////////////////////////
    if ((event.parameters != null) && (!S.isNullOrEmpty(event.parameters!['id'])) && (event.parameters!['id'] != widget.model.id)) return ok;

    ///////////////////////////
    /* Mark Event as Handled */
    ///////////////////////////
    event.handled = true;

    /////////////////
    /* Force Close */
    /////////////////
    WidgetModel.unfocus();

    /////////////
    /* Confirm */
    /////////////
    int response = 0;//await DialogService().show(type: DialogType.info, title: phrase.confirmFormComplete, buttons: [Text(phrase.yes, style: TextStyle(fontSize: 18, color: Colors.white)),Text(phrase.no, style: TextStyle(fontSize: 18, color: Colors.white))]);
    ok = (response == 0);

    ///////////////////////
    /* Validate the Data */
    ///////////////////////
    if (ok) ok = await validate();

    ///////////////////////
    /* Complete the Form */
    ///////////////////////
    if (ok) ok = await widget.model.complete();

    /////////////////////
    /* Fire OnComplete */
    /////////////////////
    if (ok) widget.model.onComplete(context);

    return ok;
  }

  Future<bool> onClear(Event event) async
  {
    bool ok = true;

    ///////////////////////////
    /* Mark Event as Handled */
    ///////////////////////////
    event.handled = true;

    ////////////////////
    /* Clear the Form */
    ////////////////////
    if (ok) ok = await widget.model.clear();

    return ok;
  }

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Set Build Constraints in the [WidgetModel]
      widget.model.minwidth  = constraints.minWidth;
      widget.model.maxwidth  = constraints.maxWidth;
      widget.model.minheight = constraints.minHeight;
      widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if ((widget.model.children == null) || ((!widget.model.visible))) return Offstage();

    List<Widget> children = [];
    widget.model.children!.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });
    if (children.isEmpty) children.add(Container());

    ////////////
    /* Center */
    ////////////
    dynamic view = children.length == 1 ? children[0] : Column(children: children, crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max);

    ////////////////////
    /* Close Keyboard */
    ////////////////////
    //final gesture = GestureDetector(onTap: () => WidgetModel.unfocus(), child: view);

    /////////////////
    /* Detect Exit */
    /////////////////
    final willpop = WillPopScope(onWillPop: quit, child: view);

    /// Busy / Loading Indicator
    if (busy == null) busy = BUSY.BusyView(BUSY.BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    view = Stack(children: [willpop, Center(child: busy)]);

    /////////////////
    /* Constrained */
    /////////////////
    if (widget.model.constrained)
    {
      var constraints = widget.model.getConstraints();
      view = ConstrainedBox(child: view, constraints: BoxConstraints(
      minHeight: constraints.minHeight!, maxHeight: constraints.maxHeight!,
          minWidth: constraints.minWidth!, maxWidth: constraints.maxWidth!));
    }

    return view;
  }
}