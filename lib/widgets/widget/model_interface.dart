import 'package:fml/widgets/widget/model.dart';

abstract class IModelListener {
  onModelChange(Model model, {String? property, dynamic value});
}
