import 'package:fml/widgets/widget/widget_model.dart';

abstract class IModelListener {
  onModelChange(WidgetModel model, {String? property, dynamic value});
}
