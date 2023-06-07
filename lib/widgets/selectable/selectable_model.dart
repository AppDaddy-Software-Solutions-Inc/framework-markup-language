// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'     ;
import 'package:fml/observable/observable_barrel.dart';

class SelectableModel extends DecoratedWidgetModel
{
  IntegerObservable? _selectedIndex;
  set selectedIndex (dynamic v)
  {
    if (_selectedIndex != null)
    {
      _selectedIndex!.set(v);
    }
    else if (v != null)
    {
      _selectedIndex = IntegerObservable(Binding.toKey(id, 'selectedindex'), v, scope: scope);
    }
  }
  int? get selectedIndex => _selectedIndex?.get();

  // selected selected element
  ListObservable? _selected;
  set selected(dynamic v)
  {
    if (_selected != null)
    {
      _selected!.set(v);
    }
    else if (v != null)
    {
      _selected = ListObservable(Binding.toKey(id, 'selected'), null, scope: scope);
      _selected!.set(v);
    }
  }
  get selected => _selected?.get();

  SelectableModel(WidgetModel? parent, String? id) : super(parent, id);

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);
  }
}
