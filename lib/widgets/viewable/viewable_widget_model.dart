// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/viewable/viewable_widget_mixin.dart';

class ViewableWidgetModel extends Model with ViewableWidgetMixin {

  ViewableWidgetModel(super.parent, super.id, {super.scope, super.data});
}