// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/button/button_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/helper/helper_barrel.dart';

/// Button View
///
/// Builds the Button View from [ButtonModel] properties
class ButtonView extends StatefulWidget
{
  final ButtonModel model;
  final Widget? child;

  ButtonView(this.model, {this.child});

  @override
  _ButtonViewState createState() => _ButtonViewState();
}

class _ButtonViewState extends State<ButtonView> implements IModelListener
{
  
  
  @override
  void initState()
  {
    super.initState();

    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
   widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  
  @override
  void didUpdateWidget(ButtonView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);

    super.dispose();
  }
  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    // Set Build Constraints in the [WidgetModel]
    ButtonModel wm = widget.model;
    widget.model.minwidth = constraints.minWidth;
    widget.model.maxwidth = constraints.maxWidth;
    widget.model.minheight = constraints.minHeight;
    widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //////////////////
    /* Add Children */
    //////////////////
    List<Widget> children = [];
    if ((widget.model.contents != null)) {
      widget.model.contents!.forEach((model) {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    }
    if (widget.child != null) children.add(widget.child!);

    Widget view;



    // Button Type Styling
    var foregroundColorStyle = (!S.isNullOrEmpty(wm.color) &&
        wm.buttontype != 'elevated') ? MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled))
          return Theme.of(context).colorScheme.surfaceVariant;
        return wm.color ?? null;// not sure if this is the correct color scheme for text.
      }) : null;

    var backgroundColorStyle = (!S.isNullOrEmpty(wm.color) &&
        wm.buttontype == 'elevated') ? MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered))
          return wm.color!.withOpacity(0.85);
        if (states.contains(MaterialState.focused) ||
            states.contains(MaterialState.pressed))
          return wm.color!.withOpacity(0.2);
        if (states.contains(MaterialState.disabled))
          return Theme.of(context).colorScheme.shadow;
        return wm.color;}) : null; // Defer to the widget's default;

    // var overlayColorStyle = wm.color != null ? MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
    //     if (wm.buttontype != 'elevated' &&
    //         states.contains(MaterialState.hovered))
    //       return wm.color.withOpacity(0.1);
    //     if (states.contains(MaterialState.focused) ||
    //         states.contains(MaterialState.pressed))
    //       return Theme.of(context).colorScheme.onPrimary.withOpacity(0.2);
    //     return wm.color ?? null; // Defer to the widget's default.
    //   }) : null;

    var borderSideStyle = wm.buttontype == 'outlined' ? MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled))
        return BorderSide(style: BorderStyle.solid, color: Theme.of(context).colorScheme.surfaceVariant, width: 2);
      return BorderSide(style: BorderStyle.solid, color: wm.color ?? Theme.of(context).colorScheme.primary, width: 2);
    }) : null;

    var paddingStyle = (wm.buttontype != 'outlined' &&
        wm.buttontype != 'elevated') ? MaterialStateProperty.all(
        EdgeInsets.only(top: 14,
            bottom: 14,
            left: 14,
            right: 14)) : null;

    var elevationStyle = wm.buttontype == 'elevated' ? MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.hovered))
        return 8.0;
      if (states.contains(MaterialState.focused) ||
          states.contains(MaterialState.pressed))
        return 3.0;
      return 5.0;
    }) : null;
    var constr = widget.model.getConstraints();

    if(constr.minWidth == null || constr.minWidth == 0.0) {constr.minWidth = (S.isNullOrEmpty(wm.label)) ? 36 : 72.0;} //if the button should size itself, the min width needs to be set if not defined.

    var style = ButtonStyle(
      minimumSize: MaterialStateProperty.all(
          Size( constr.minWidth ?? 72, (constr.minHeight?? 0) + 36)), //add 36 to the constraint as the width is offset by 40
      foregroundColor: foregroundColorStyle,
      backgroundColor: backgroundColorStyle,
      // overlayColor: overlayColorStyle,
      padding: paddingStyle,
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: wm.radius > 0 ? BorderRadius.all(
              Radius.circular(wm.radius)) : BorderRadius.zero)),
      side: borderSideStyle,
      elevation: elevationStyle,
    );

    // Add a text child if label is set
    if (!S.isNullOrEmpty(wm.label)) children.add(Text(wm.label!));
    view = Center(child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [...children],));
      
    view = UnconstrainedBox(child: view);

    // Build the Button Types
    if (wm.buttontype == 'outlined') {
      view = OutlinedButton(
          style: style,
          onPressed: (wm.onclick != null && wm.enabled != false) ? () => wm.onPress(context) : null,
          child: view);
    } else if (wm.buttontype == 'elevated') {
      // I had to override the MaterialStateProperties on ElevatedButton because the theme didn't play well with it
      view = ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize:  Size(constr.minWidth ?? 72, (constr.minHeight?? 0) + 40), //add 40 to the constraint as the width is offset by 40
              backgroundColor: wm.color ?? Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              disabledForegroundColor: Theme.of(context).colorScheme.onSurface,
              shadowColor: Theme.of(context).colorScheme.shadow,
              shape: RoundedRectangleBorder(borderRadius: wm.radius > 0 ? BorderRadius.all(Radius.circular(wm.radius)) : BorderRadius.zero),
              elevation: 3,
          ),
          onPressed: (wm.onclick != null && wm.enabled != false) ? () => wm.onPress(context) : null,
          child: view);
    } else {
      view = TextButton(
          style: style,
          onPressed: (wm.onclick != null && wm.enabled != false) ? () => wm.onPress(context) : null,
          child: view);
    }


    // If onclick is null or enabled is false we fade the button
    if (wm.onclick == null || wm.enabled == false) {
      view = Opacity(opacity: 0.9, child: view); // Disabled
    }

    //unsure how to make this work with maxwidth/maxheight, as it should yet constraints always come in. What should it do? same with minwidth/minheight...
    if (widget.model.height != null && widget.model.width != null ) {
      view = ConstrainedBox(
          child: Container(child:view) ,
          constraints: BoxConstraints(
              minHeight: constr['minheight']!,
              maxHeight: constr['maxheight']!,
              minWidth: constr['minwidth']!,
              maxWidth: constr['maxwidth']!));
    } else if (widget.model.width != null) {
      view = UnconstrainedBox(
        child: LimitedBox(
          child: view,
          maxWidth: constr['maxwidth']!,
        ),
      );
    } else if (widget.model.height != null) {
      view = UnconstrainedBox(
        child: LimitedBox(
          child: view,
          maxHeight: constr['maxheight']!,
        ),
      );
    }
    return view;
  }

  // Rebuild the view when the listener hears a model change
  onViewModelChange({String? property, dynamic value})
  {
    try
    {
      if (this.mounted)
      {
        setState((){});
      }
    }
    catch(e)
    {
      Log().exception(e, caller: 'button.View -> onViewModelChange()');
    }
  }
}
