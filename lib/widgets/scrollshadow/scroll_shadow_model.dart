// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'         ;
import 'package:fml/observable/observable_barrel.dart';

class ScrollShadowModel extends ViewableWidgetModel
{
  //////////
  /* left */
  //////////
  BooleanObservable? _left;
  set left (dynamic v)
  {
    if (_left != null)
    {
      _left!.set(v);
    }
    else if (v != null)
    {
      _left = BooleanObservable(Binding.toKey(id, 'left'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get left => _left?.get() ?? false;

  ///////////
  /* right */
  ///////////
  BooleanObservable? _right;
  set right (dynamic v)
  {
    if (_right != null)
    {
      _right!.set(v);
    }
    else if (v != null)
    {
      _right = BooleanObservable(Binding.toKey(id, 'right'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get right => _right?.get() ?? false;

  /////////
  /* up */
  /////////
  BooleanObservable? _up;
  set up (dynamic v)
  {
    if (_up != null)
    {
      _up!.set(v);
    }
    else if (v != null)
    {
      _up = BooleanObservable(Binding.toKey(id, 'up'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get up => _up?.get() ?? false;

  ////////////
  /* down */
  ////////////
  BooleanObservable? _down;
  set down (dynamic v)
  {
    if (_down != null)
    {
      _down!.set(v);
    }
    else if (v != null)
    {
      _down = BooleanObservable(Binding.toKey(id, 'down'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get down => _down?.get() ?? false;


  ScrollShadowModel(WidgetModel parent, {String? id, dynamic left, dynamic right, dynamic up, dynamic down}) : super(parent, id)
  {
    this.left       = left;
    this.right      = right;
    this.up        = up;
    this.down     = down;
  }
}
