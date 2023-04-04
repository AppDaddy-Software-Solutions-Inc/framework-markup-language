// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/beacon/beacon_model.dart';
import 'package:fml/datasources/detectors/biometrics/biometrics_detector_model.dart';
import 'package:fml/datasources/sse/model.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/datasources/iDataSourceListener.dart';
import 'package:fml/datasources/log/log_model.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector_model.dart';
import 'package:fml/datasources/detectors/text/text_detector_model.dart';
import 'package:fml/datasources/data/model.dart';
import 'package:fml/datasources/gps/model.dart';
import 'package:fml/datasources/http/model.dart';
import 'package:fml/datasources/mqtt/mqtt_model.dart';
import 'package:fml/datasources/nfc/nfc_model.dart';
import 'package:fml/datasources/socket/socket_model.dart';
import 'package:fml/datasources/zebra/model.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/alarm/alarm_model.dart';
import 'package:fml/widgets/animation/animation_child/flip/flip_card_model.dart';
import 'package:fml/widgets/animation/animation_child/transform/transform_model.dart';
import 'package:fml/widgets/animation/animation_child/tween/tween_model.dart';
import 'package:fml/widgets/animation/animation_model.dart';
import 'package:fml/widgets/animation/animation_child/fade/fade_transition_model.dart';
import 'package:fml/widgets/animation/animation_child/rotate/rotate_transition_model.dart';
import 'package:fml/widgets/animation/animation_child/scale/scale_transition_model.dart';
import 'package:fml/widgets/animation/animation_child/size/size_transition_model.dart';
import 'package:fml/widgets/animation/animation_child/slide/slide_transition_model.dart';
import 'package:fml/widgets/breadcrumb/breadcrumb_model.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/button/button_model.dart';
import 'package:fml/widgets/camera/camera_model.dart';
import 'package:fml/widgets/card/card_model.dart';
import 'package:fml/widgets/center/center_model.dart';
import 'package:fml/widgets/chart/chart_model.dart';
import 'package:fml/widgets/chart/axis/chart_axis_model.dart';
import 'package:fml/widgets/chart/series/chart_series_model.dart';

// import 'package:fml/widgets/chart_syncfusion/chart_model.dart' as SFCHART;
// import 'package:fml/widgets/chart_syncfusion/axis/chart_axis_model.dart' as SFCHART;
// import 'package:fml/widgets/chart_syncfusion/series/chart_series_model.dart' as SFCHART;
import 'package:fml/widgets/checkbox/checkbox_model.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/datepicker/datepicker_model.dart';
import 'package:fml/datasources/http/delete/model.dart';
import 'package:fml/widgets/draggable/draggable_model.dart';
import 'package:fml/widgets/droppable/droppable_model.dart';
import 'package:fml/widgets/editor/editor_model.dart';
import 'package:fml/widgets/filepicker/filepicker_model.dart';
import 'package:fml/widgets/footer/footer_model.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/gesture/gesture_model.dart';
import 'package:fml/datasources/http/get/model.dart';
import 'package:fml/widgets/grid/item/grid_item_model.dart';
import 'package:fml/widgets/grid/grid_model.dart';
import 'package:fml/widgets/header/header_model.dart';
import 'package:fml/widgets/icon/icon_model.dart';
import 'package:fml/widgets/iframe/inline_frame_model.dart';
import 'package:fml/widgets/image/image_model.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/link/link_model.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/list/list_model.dart';
import 'package:fml/widgets/map/marker/map_marker_model.dart';
import 'package:fml/widgets/map/map_model.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:fml/widgets/menu/menu_model.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/padding/padding_model.dart';
import 'package:fml/widgets/pager/pager_model.dart';
import 'package:fml/widgets/pager/page/pager_page_model.dart';
import 'package:fml/widgets/popover/item/popover_item_model.dart';
import 'package:fml/widgets/popover/popover_model.dart';
import 'package:fml/widgets/positioned/positioned_model.dart';
import 'package:fml/datasources/http/put/model.dart';
import 'package:fml/datasources/http/post/model.dart';
import 'package:fml/widgets/radio/radio_model.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/scope/scope_model.dart';
import 'package:fml/widgets/scribble/scribble_model.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/select/select_model.dart';
import 'package:fml/widgets/slider/slider_model.dart';
import 'package:fml/widgets/splitview/split_model.dart';
import 'package:fml/widgets/stack/stack_model.dart';
import 'package:fml/widgets/switch/switch_model.dart';
import 'package:fml/widgets/table/footer/table_footer_model.dart';
import 'package:fml/widgets/table/header/cell/table_header_cell_model.dart';
import 'package:fml/widgets/table/header/table_header_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/row/cell/table_row_cell_model.dart';
import 'package:fml/widgets/table/row/table_row_model.dart';
import 'package:fml/widgets/tabview/tab_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/widgets/timer/timer_model.dart';
import 'package:fml/widgets/tooltip/v1/tooltip_model.dart' as v1;
import 'package:fml/widgets/tooltip/v2/tooltip_model.dart' as v2;
import 'package:fml/datasources/transforms/calc.dart';
import 'package:fml/datasources/transforms/distinct.dart';
import 'package:fml/datasources/transforms/sort.dart';
import 'package:fml/datasources/transforms/eval.dart';
import 'package:fml/datasources/transforms/filter.dart';
import 'package:fml/datasources/transforms/pivot.dart';
import 'package:fml/datasources/transforms/format.dart';
import 'package:fml/datasources/transforms/flip.dart';
import 'package:fml/datasources/transforms/resize.dart';
import 'package:fml/datasources/transforms/crop.dart';
import 'package:fml/datasources/transforms/grayscale.dart';
import 'package:fml/widgets/treeview/tree_model.dart';
import 'package:fml/widgets/treeview/node/tree_node_model.dart';
import 'package:fml/widgets/trigger/condition/trigger_condition_model.dart';
import 'package:fml/widgets/trigger/trigger_model.dart';
import 'package:fml/widgets/typeahead/typeahead_model.dart';
import 'package:fml/widgets/variable/variable_model.dart';
import 'package:fml/widgets/html/html_model.dart';
import 'package:fml/widgets/span/span_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/view/view_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

abstract class IModelListener {
  onModelChange(WidgetModel model, {String? property, dynamic value});
}

abstract class IScrolling {
  bool? moreUp;
  bool? moreDown;
  bool? moreLeft;
  bool? moreRight;
}

class WidgetModel implements IDataSourceListener
{
  // primary identifier
  late final String id;

  // returns pointer to itself
  WidgetModel get model => this;

  // framework
  FrameworkModel? framework;

  // xml node
  XmlElement? element;
  String  get elementName => element != null ? element!.localName.toUpperCase() : '$runtimeType';
  String? get elementNamespace => element != null ? element!.namespacePrefix!.toLowerCase() : null;

  // datasource
  List<IDataSource>? datasources;
  String? datasource;

  // data element
  ListObservable? _data;
  set data(dynamic v)
  {
    if (_data != null)
    {
      _data!.set(v);
    }
    else if (v != null)
    {
      _data = ListObservable(Binding.toKey(id, 'data'), null, scope: scope, listener: onPropertyChange);
      _data!.set(v);
    }
  }
  get data => _data?.get();

  // listeners
  List<IModelListener>? _listeners;

  // debug
  BooleanObservable? _debug;
  set debug(dynamic v)
  {
    if (_debug != null)
    {
      _debug!.set(v);
    }
    else if (v != null)
    {
      _debug = BooleanObservable(Binding.toKey(id, 'debug'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get debug => _debug?.get() ?? false;

  // parent model
  WidgetModel? parent;

  // children
  List<WidgetModel>? children;

  // scope
  Scope? scope;

  // context
  BuildContext? get context
  {
    if (this._listeners != null)
    for (IModelListener listener in this._listeners!)
    {
      if (listener is State && (listener as State).mounted == true) return (listener as State).context;
    }
    if (this.parent != null) return this.parent!.context;
    return applicationKey.currentContext;
  }

  // context
  BuildContext? get statelessContext
  {
    if (this._listeners != null)
      for (IModelListener listener in this._listeners!)
      {
        if (listener is State) return (listener as State).context;
      }
    if (this.parent != null) return this.parent!.statelessContext;
    return null;
  }

  // State
  StringObservable? _state;

  set state(dynamic v) {
    if (_state != null) {
      _state!.set(v);
    } else if (v != null) {
      _state = StringObservable(Binding.toKey(id, 'state'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get state => _state?.get();

  // Depth
  DoubleObservable? _depth;

  set depth(dynamic v) {
    if (_depth != null) {
      _depth!.set(v);
    } else if (v != null) {
      _depth = DoubleObservable(Binding.toKey(id, 'depth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get depth => _depth?.get();

  // busy
  BooleanObservable? get busyObservable => _busy;
  BooleanObservable? _busy;
  set busy(dynamic v) {
    if (_busy != null) {
      _busy!.set(v);
    } else {
      _busy = BooleanObservable(Binding.toKey(id, 'busy'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get busy => _busy?.get() ?? false;

  WidgetModel(WidgetModel? parent, String? id, {Scope? scope})
  {
    // default id
    if (S.isNullOrEmpty(id)) id = S.newId();
    this.id = id!;

    // set the parent
    this.parent = parent;

    // set the scope
    this.scope = scope ?? Scope.of(this);

    // set the framework
    this.framework = findAncestorOfExactType(FrameworkModel);

    // register the model with the scope
    if (!S.isNullOrEmpty(id) && this.scope != null) this.scope!.registerModel(this);
  }

  static WidgetModel? fromXml(WidgetModel parent, XmlElement node)
  {
    // clone node?
    node = cloneNode(node, parent.scope);

    // exclude this element?
    if (excludeFromTemplate(node, parent.scope)) return null;

    // element local name is the element name without the namespace prefix (if one exists)
    String elementLocalName = node.localName.toLowerCase();

    // build the element model
    WidgetModel? model;
    switch (elementLocalName) {
      case "alarm":
        model = AlarmModel.fromXml(parent, node);
        break;

      case "animate": // Preferred Case
      case "animation": // Animation may be deprecated
        model = AnimationModel.fromXml(parent, node);
        break;

      case "autocomplete":
        model = InputModel.fromXml(parent, node, type: "autocomplete");
        break;

      case "barcode":

        model = BarcodeDetectorModel.fromXml(parent, node);
        break;

      case "beacon":
        model = BeaconModel.fromXml(parent, node);
        break;

      case "biometic":
        model = BiometricsDetectorModel.fromXml(parent, node);
        break;

      case "box": // Preferred Case
      case "container": // Container may be deprecated
        model = BoxModel.fromXml(parent, node);
        break;

      case "breadcrumb":
        model = BreadcrumbModel.fromXml(parent, node);
        break;

      case "busy":
        model = BusyModel.fromXml(parent, node);
        break;

      case "button":
      case "btn":
        model = ButtonModel.fromXml(parent, node);
        break;

      case "buttonstate":
        model = ButtonModel.fromXml(parent, node);
        break;

      case "calc":
        if (parent is IDataSource) model = Calc.fromXml(model, node);
        break;

      case "camera":
        model = CameraModel.fromXml(parent, node);
        break;

      case "card":
        model = CardModel.fromXml(parent, node);
        break;

      case "center":
        model = CenterModel.fromXml(parent, node);
        break;

      case "chart":
        model = ChartModel.fromXml(parent, node);
        break;

      // case "sfchart":
      //   model = SFCHART.ChartModel.fromXml(parent, node);
      //   break;

      case "html":
        model = HtmlModel.fromXml(parent, node);
        break;

      case "checkbox":
      case "check":
        model = CheckboxModel.fromXml(parent, node);
        break;

      case "const":
      case "constant":
        model = VariableModel.fromXml(parent, node, constant: true);
        break;

      case "crop":
        if (parent is IDataSource) model = Crop.fromXml(parent, node);
        break;

      case "column":
      case "col": //shorthand case
        model = ColumnModel.fromXml(parent, node);
        break;

      case "condition":
      case "case":
        if (parent is TriggerModel)
          model = TriggerConditionModel.fromXml(parent, node);
        break;

      case "data":
        model = DataModel.fromXml(parent, node);
        break;

      case "datepicker":
        model = DatepickerModel.fromXml(parent, node);
        break;

      case "delete":
        model = HttpDeleteModel.fromXml(parent, node);
        break;

      case "distinct":
        if (parent is IDataSource) model = Distinct.fromXml(model, node);
        break;

      case "drag": // Preferred case.
      case "draggable": // draggable may be deprecated
        model = DraggableModel.fromXml(parent, node);
        break;

      case "drop": // Preferred case.
      case "droppable": // droppable may be deprecated.
        model = DroppableModel.fromXml(parent, node);
        break;

      case "editor":
        model = EditorModel.fromXml(parent, node);
        break;

        // deprecated. use row/column/box with %sizing or flex
      case "expand":
      case "expanded":
        model = ColumnModel.fromXml(parent, node);
        if (model is ColumnModel && model.flex == null) model.flex = "1";
        break;

      case "eval":
        if (parent is IDataSource) model = Eval.fromXml(model, node);
        break;

      case "filepicker":
        model = FilepickerModel.fromXml(parent, node);
        break;

      case "filter":
        if (parent is IDataSource)
          model = Filter.fromXml(model, node);
        break;

      case "flip":
        if (parent is IDataSource) model = Flip.fromXml(parent, node);
        else if (parent is AnimationModel) model = FlipCardModel.fromXml(parent, node);
        else  model = FlipCardModel.fromXml(parent, node);
        break;

      case "fml":
          model = FrameworkModel.fromXml(parent, node);
        break;

      case "footer":
        if (parent is FrameworkModel)
          model = FooterModel.fromXml(parent, node);
        break;

      case "form":
        model = FormModel.fromXml(parent, node);
        break;

      case "format":
        if (parent is IDataSource)
          model = Format.fromXml(parent, node);
        break;

      case "gesture":
        model = GestureModel.fromXml(parent, node);
        break;

      case "get":
        model = HttpGetModel.fromXml(parent, node);
        break;

      case "greyscale":
      case "grayscale":
         if (parent is IDataSource)
           model = Grayscale.fromXml(parent, node);
        break;

      case "gps":
        model = GpsModel.fromXml(parent, node);
        break;

      case "grid":
        model = GridModel.fromXml(parent, node);
        break;

      case "header":
        if (parent is FrameworkModel)
          model = HeaderModel.fromXml(parent, node);
        break;

      case "http":
        model = HttpModel.fromXml(parent, node);
        break;

      case "icon":
        model = IconModel.fromXml(parent, node);
        break;

      case "iframe":
        model = InlineFrameModel.fromXml(parent, node);
        break;

      case "image":
      case "img":
        model = ImageModel.fromXml(parent, node);
        break;

      case "item":
        if (parent is MenuModel)
          model = MenuItemModel.fromXml(parent, node);
        if (parent is ListModel)
          model = ListItemModel.fromXml(parent, node);
        if (parent is GridModel)
          model = GridItemModel.fromXml(parent, node);
        break;

      case "input":
        model = InputModel.fromXml(parent, node);
        break;

      case "link":
        model = LinkModel.fromXml(parent, node);
        break;

      case "list":
        model = ListModel.fromXml(parent, node);
        break;

      case "log":
        model = LogModel.fromXml(parent, node);
        break;

      case "map":
        model = MapModel.fromXml(parent, node);
        break;

      case "menu":
        model = MenuModel.fromXml(parent, node);
        break;

      case "modal":
        model = ModalModel.fromXml(parent, node);
        break;

      case "mqtt":
        model = MqttModel.fromXml(parent, node);
        break;

      case "nfc":
        model = NcfModel.fromXml(parent, node);
        break;

      case "node":
        model = TreeNodeModel.fromXml(parent, node);
        break;

      case "ocr":
        model = TextDetectorModel.fromXml(parent, node);
        break;

      case "option":
        if (parent is SelectModel || parent is CheckboxModel || parent is RadioModel || parent is TypeaheadModel) model = OptionModel.fromXml(parent, node);
        break;

        case "fade":
         if (parent is AnimationModel) model = FadeTransitionModel.fromXml(parent, node);
         else model =  FadeTransitionModel.fromXml(parent, node);
         break;

      case "rotate":
        if (parent is AnimationModel) model = RotateTransitionModel.fromXml(parent, node);
          else model = RotateTransitionModel.fromXml(parent, node);
        break;

        case "size":
          if (parent is AnimationModel) model = SizeTransitionModel.fromXml(parent, node);
          else model = SizeTransitionModel.fromXml(parent, node);
          break;

      case "slide":
        if (parent is AnimationModel) model = SlideTransitionModel.fromXml(parent, node,);
        else model = SlideTransitionModel.fromXml(parent, node);
        break;

      case "scale":
        if (parent is AnimationModel) model = ScaleTransitionModel.fromXml(parent, node);
        else model = ScaleTransitionModel.fromXml(parent, node);
        break;

      case "transform":
        if (parent is AnimationModel) model = TransformModel.fromXml(parent, node);
        else model = TransformModel.fromXml(parent, node);
        break;

      case "tween":
        if (parent is AnimationModel) model = TweenModel.fromXml(parent, node);
        else model = TweenModel.fromXml(parent, node);
        break;

      case "pad": // Preferred Case.
      case "padding": // Padding could be deprecated.
        model = PaddingModel.fromXml(parent, node);
        break;

      case "page":
        if (parent is PagerModel)
          model = PagerPageModel.fromXml(parent, node);
        break;

      case "pager":
        model = PagerModel.fromXml(parent, node);
        break;

      case "pivot":
        if (parent is IDataSource) model = Pivot.fromXml(model, node);
        break;

      case "put":
        model = HttpPutModel.fromXml(parent, node);
        break;

      case "popover":
        model = PopoverModel.fromXml(parent, node);
        break;

      case "popoveritem":
        model = PopoverItemModel.fromXml(parent, node);
        break;

      case "position": // Preferred case
      case "pos": // Shorthand case
      case "positioned": // Positioned may be deprecated
        model = PositionedModel.fromXml(parent, node);
        break;

      case "marker":
        if (parent is MapModel)
          model = MapMarkerModel.fromXml(parent, node);
        break;

      case "post":
        model = HttpPostModel.fromXml(parent, node);
        break;

      case "radio":
        model = RadioModel.fromXml(parent, node);
        break;

      case "resize":
        if (parent is IDataSource) model = Resize.fromXml(parent, node);
        break;

      case "row":
        model = RowModel.fromXml(parent, node);
        break;

      case "scope":
        model = ScopeModel.fromXml(parent, node);
        break;

      case "scribble":
        model = ScribbleModel.fromXml(parent, node);
        break;

      case "scroll": // Preferred Case
      case "scroller": // Scroller may be deprecated.
        model = ScrollerModel.fromXml(parent, node);
        break;

      case "select":
        model = SelectModel.fromXml(parent, node);
        break;

      case "series":
        if (parent is ChartModel) model = ChartSeriesModel.fromXml(parent, node);
        // else if (parent is SFCHART.ChartModel) model = SFCHART.ChartSeriesModel.fromXml(parent, node);
        break;

      case "slider":
        model = SliderModel.fromXml(parent, node);
        break;

      case "socket":
        model = SocketModel.fromXml(parent, node);
        break;

      case "sort":
        if (parent is IDataSource) model = Sort.fromXml(model, node);
        break;

      case "span":
        model = SpanModel.fromXml(parent, node);
        break;

      case "sse":
        model = SseModel.fromXml(parent, node);
        break;

      case "stack":
        model = StackModel.fromXml(parent, node);
        break;

      case "splitview":
        model = SplitModel.fromXml(parent, node);
        break;

      case "table":
        model = TableModel.fromXml(parent, node);
        break;

      case "th":
      case "tableheader":
        model = TableHeaderModel.fromXml(parent, node);
        break;

      case "tr":
      case "tablerow":
        model = TableRowModel.fromXml(parent, node);
        break;

      case "tf":
      case "tablefooter":
        model = TableFooterModel.fromXml(parent, node);
        break;

      case "td":
      case "tabledata":
      case "cell":
        if (parent is TableHeaderModel)
          model = TableHeaderCellModel.fromXml(parent, node);
        if (parent is TableRowModel)
          model = TableRowCellModel.fromXml(parent, node);
        break;

      case "tabview":
        model = TabModel.fromXml(parent, node);
        break;

      case "text":
      case "txt":
        model = TextModel.fromXml(parent, node);
        break;

      case "theme":
        model = ThemeModel.fromXml(parent, node);
        break;

      case "timer":
        model = TimerModel.fromXml(parent, node);
        break;

      case "toggle":
      case "switch":
        model = SwitchModel.fromXml(parent, node);
        break;

      case "tip":
      case "tooltip":
        if (Xml.attribute(node: node, tag: "label") != null || Xml.attribute(node: node, tag: "text") != null)
             model = v1.TooltipModel.fromXml(parent, node);
        else model = v2.TooltipModel.fromXml(parent, node);
        break;

      case "treeview":
        model = TreeModel.fromXml(parent, node);
        break;

      case "trigger":
        model = TriggerModel.fromXml(parent, node);
        break;

      case "typeahead":
        model = TypeaheadModel.fromXml(parent, node);
        break;


      case "variable":
      case "var":
        model = VariableModel.fromXml(parent, node);
        break;

      // case "video":
      //   model = VideoModel.fromXml(parent, node);
      //   break;

      case "view":
        if (parent is SplitModel)
        model = ViewModel.fromXml(parent, node);
        break;

      case "window":
        model = FrameworkModel.fromXml(parent, node);
        break;

      case "xaxis":
        if (parent is ChartModel)
          model = ChartAxisModel.fromXml(parent, node, ChartAxis.X);
        // else if (parent is SFCHART.ChartModel) model = SFCHART.ChartAxisModel.fromXml(parent, node, SFCHART.Axis.X);
        break;

      case "yaxis":
        if (parent is ChartModel)
                model = ChartAxisModel.fromXml(parent, node, ChartAxis.Y);
        // else if (parent is SFCHART.ChartModel) model = SFCHART.ChartAxisModel.fromXml(parent, node, SFCHART.Axis.Y);
        break;

      case "zebra":
        model = ZebraModel.fromXml(parent, node);
        break;

      default:
        break;
    }

    return model;
  }

  void deserialize(XmlElement xml)
  {
    // Busy
    busy = true;

    // retain the xml node
    element = xml;

    // Global Properties
    datasource = Xml.attribute(node: xml, tag: 'data');
    debug = Xml.get(node: xml, tag: 'debug');
    depth = Xml.get(node: xml, tag: 'depth');
    state = Xml.get(node: xml, tag: 'state');

    // register as datasource
    if ((this is IDataSource) && (scope != null)) scope!.registerDataSource(this as IDataSource);

    // Deserialize Children

    if (this.children != null) this.children!.clear();
    _deserializeDataSources(xml);
    _deserialize(xml);

    // register listener
    if ((this.datasource != null) && (scope != null))
    {
      IDataSource? source = scope!.getDataSource(this.datasource);
      if (source != null) source.register(this);
    }

    // Busy
    busy = false;
  }

  void _deserializeDataSources(XmlElement xml)
  {
    // find and deserialize all datasources
    for (XmlNode node in xml.children)
    if (node is XmlElement && isDataSource(node.localName))
    {
      // build the data source model
      dynamic model = WidgetModel.fromXml(this, node);
      if (model is IDataSource)
      {
        if (this.datasources == null) this.datasources = [];
        this.datasources!.add(model);
      }
    }
  }

  void _deserialize(XmlElement xml)
  {
    // deserialize all non-datasource children
    for (XmlNode node in xml.children)
    if (node is XmlElement && !isDataSource(node.localName))
    {
      // build the model
      dynamic model = WidgetModel.fromXml(this, node);
      if (model is WidgetModel)
      {
        if (this.children == null) this.children = [];
        this.children!.add(model);
      }
    }
  }

  void dispose()
  {
    // remove listeners
    removeAllListeners();

    // dispose of datasources
    if (datasources != null)
    for (var datasource in datasources!) if (datasource.parent == this) datasource.dispose();
    datasources?.clear();

    // remove model and all of its bindables from the scope
    scope?.unregisterModel(this);

    // dispose of children
    if (children != null)
    {
      children!.forEach((child) => child.dispose());
      children!.clear();
    }
  }

  registerListener(IModelListener listener)
  {
    if (_listeners == null) _listeners = [];
    if (!_listeners!.contains(listener)) _listeners!.add(listener);
  }

  removeListener(IModelListener listener) {
    if ((_listeners != null) && (_listeners!.contains(listener))) {
      _listeners!.remove(listener);
      if (_listeners!.isEmpty) _listeners = null;
    }
  }

  removeAllListeners() {
    if (_listeners != null) _listeners!.clear();
  }

  notifyListeners(String? property, dynamic value) {
    if (_listeners != null)
      _listeners!.forEach((listener) {
        listener.onModelChange(this, property: property, value: value);
      });
  }

  void onPropertyChange(Observable observable) {
    notifyListeners(observable.key, observable.get());
  }

  void initialize()
  {
    // start datasources
    if (datasources != null)
      datasources!.forEach((datasource)
      {
        // already started?
        if (!datasource.initialized!)
        {
          // mark as started
          datasource.initialized = true;

          // announce data for late binding
          if ((datasource.data != null) && (datasource.data!.isNotEmpty)) datasource.notify();

          // start the datasource if autoexecute = true
          if (datasource.autoexecute == true) datasource.start();
        }
      });
  }

  static void unfocus() {
    try {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    } catch(e) {
      Log().exception(e);
    }
  }

  /// Returns true if the template references observable => key
  static bool isBound(WidgetModel model, String? key) {
    if ((model.framework == null) || (S.isNullOrEmpty(key))) return false;
    return model.framework!.bindables!.contains(key);
  }

  dynamic findAncestorOfExactType(Type T, {String? id, bool includeSiblings = false})
  {
    List<dynamic>? list = findAncestorsOfExactType(T, id: id, includeSiblings: includeSiblings);
    return ((list != null) && (list.length > 0)) ? list.first : null;
  }

  List<dynamic>? findAncestorsOfExactType(Type T, {String? id, bool includeSiblings = false})
  {
    if (parent == null) return null;
    return parent!._findAncestorsOfExactType(T, id, includeSiblings);
  }

  List<dynamic> _findAncestorsOfExactType(Type T, String? id, bool includeSiblings)
  {
    List<dynamic> list = [];

    // evaluate me
    if ((this.runtimeType == T) && (this.id == (id ?? this.id))) list.add(this);

    // evaluate my siblings
    if ((includeSiblings) && (children != null))
      children!.forEach((child) => ((child.runtimeType == T) && (child.id == (id ?? child.id))) ? list.add(child) : null);

    // evaluate my ancestors
    if (parent != null) list.addAll(parent!._findAncestorsOfExactType(T, id, includeSiblings));

    return list;
  }

  dynamic findDescendantOfExactType(Type? T, {String? id}) {
    List<dynamic>? list = findDescendantsOfExactType(T, id: id);
    return ((list != null) && (list.length > 0)) ? list.first : null;
  }

  List<dynamic>? findDescendantsOfExactType(Type? T, {String? id}) {
    List<dynamic> list = [];
    if (children == null) return null;
    children!.forEach(
        (child) => list.addAll(child._findDescendantsOfExactType(T, id)));
    return list;
  }

  List<dynamic> _findDescendantsOfExactType(Type? T, String? id) {
    List<dynamic> list = [];

    // evaluate me
    if ((this.runtimeType == (T ?? this.runtimeType)) &&
        (this.id == (id ?? this.id))) list.add(this);

    // evaluate my children
    if (children != null)
      for (WidgetModel child in children!)
        list.addAll(child._findDescendantsOfExactType(T, id));

    return list;
  }

  dynamic findParentOfExactType(Type T, {String? id}) {
    if ((parent != null) &&
        (parent.runtimeType == (T)) &&
        (parent!.id == (id ?? parent!.id))) return parent;
    return null;
  }

  dynamic findChildOfExactType(Type T, {String? id}) {
    if (children != null)
      return children!.firstWhereOrNull((child) => child.runtimeType == T && (child.id == (id ?? child.id)));
  }

  List<dynamic> findChildrenOfExactType(Type T, {String? id}) {
    List<dynamic> list = [];
    if (children != null)
      for (WidgetModel child in children!)
        if ((child.runtimeType == (T)) && (child.id == (id ?? child.id)))
          list.add(child);
    return list;
  }

  void removeChildrenOfExactType(Type T) {
    if (children != null) children!.removeWhere((child) => (child.runtimeType == (T)));
  }

  dynamic findListenerOfExactType(Type T)
  {
    if (_listeners != null)
    for (dynamic listener in _listeners!) if (listener.runtimeType == T) return listener;
    return null;
  }

  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    this.busy = false;
    //notifyListeners('list', list);
    return true;
  }

  onDataSourceException(IDataSource source, Exception exception) {
    this.busy = false;
    //notifyListeners('error', exception);
  }

  onDataSourceBusy(IDataSource source, bool busy)
  {
    this.busy = busy;
    //notifyListeners('busy', this.busy);
  }

  /// This will be overridden for more complex widgets such as TABLE
  /// where children may actually be header or footer declarations that require
  /// a complete restructuring/rebuild of the parent
  Future<bool> _appendChild(XmlElement element, int? index) async
  {
      WidgetModel? model = fromXml(this, element);
      if (model != null)
      {
        // model is a datasource
        if (model is IDataSource)
        {
          // add it to the datasource list
          if (this.datasources == null) this.datasources = [];
          this.datasources!.add(model as IDataSource);

          // start brokers
          this.initialize();
        }

        // model is widget
        else
        {
          // add it to the child list
          if (this.children == null) this.children = [];

          // position specified?
          if (index != null && index < this.children!.length)
               this.children!.insert(index, model);
          else this.children!.add(model);
        }
      }
      return (model != null);
  }

  Future<bool> _appendXml(String xml, int? index, [bool silent = true]) async
  {
    List<XmlElement> nodes = [];

    Exception? exception;

    // parse the xml
    var document = Xml.tryParseException(xml);

    // failed parse
    if (document is Exception)
    {
      exception = document;

      // try parsing xml wrapped in a root tag
      // this allows the user to send a list of elements
      // and not have top wrap in a root tag
      document = Xml.tryParseException("<ROOT>$xml</ROOT>");
      if (document is XmlDocument)
      {
        nodes = document.rootElement.childElements.toList();
        exception = null;
      }
    }

    // successfully parsed the xml
    else if (document is XmlDocument) nodes = document.childElements.toList();

    // build error node
    if (exception != null && !silent)
    {
      var text   = XmlElement(XmlName("TEXT"),[XmlAttribute(XmlName("size"), '18'), XmlAttribute(XmlName("color"), '#EF5858'), XmlAttribute(XmlName("value"), exception.toString())]);
      var center = XmlElement(XmlName("CENTER"));
      center.children.add(text);
      nodes.add(center);
    }

    // valid fml?
    nodes.forEach((element) => _appendChild(element, index));

    return exception != null && nodes.length > 0;
  }

  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case 'set':
        // value
        var value = S.item(arguments, 0);

        // property - default is value
        // we can now use dot notation to specify the property
        // rather than pass it as an attribute
        var property = S.item(arguments, 1);
        if (property == null) property = Binding.fromString(caller)?.key ?? property;

        Scope? scope = Scope.of(this);
        if (scope == null) return false;

        // set the variable
        scope.setObservable(property, value != null ? value.toString() : null);
        return true;

      case 'addchild':

        // fml
        var xml = S.item(arguments, 0);

        // if index is null, add to end of list.
        int? index = S.toInt(S.item(arguments, 1));

        // silent
        bool silent = S.toBool(S.item(arguments, 2)) ?? true;

        if (xml == null || !(xml is String)) return true;

        // append
        await _appendXml(xml, index, silent);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;

      case 'removechild':

        // if index is null, remove all children before replacement.
        int? index = S.toInt(S.item(arguments, 0));

        // check for children then remove them
        if (this.children != null && index == null)
        {
          // dispose of the last item
          this.children!.last.dispose();

          // check if the list is greater than 0, remove at the final index.
          if (this.children!.length > 0) this.children!.removeLast();
        }

        else if (this.children != null && index != null)
        {
          // check if index is in range, then dispose of the child at that index.
          if (index >= 0 && this.children!.length > index) {
            this.children![index].dispose();
            this.children!.removeAt(index);
          }
          // Could add handling for negative index removing from the end?
        }

        // force rebuild
        notifyListeners("rebuild", "true");
        return true;

      case 'removechildren':

        // dispose of existing children
        this.children?.forEach((child) => child.dispose());
        this.children = [];

        // force parent rebuild
        parent?.notifyListeners("rebuild", "true");
        return true;

      case 'replacechild':

        // fml
        var xml = S.item(arguments, 0);

        // if index is null, remove last child before replacement.
        int? index = S.toInt(S.item(arguments, 1));

        // silent
        bool silent = S.toBool(S.item(arguments, 2)) ?? true;

        if (xml == null || !(xml is String)) return true;

        // check for children then remove them
        if (this.children != null && index == null)
        {
          // dispose of the last item
          this.children!.last.dispose();

          // check if the list is greater than 0, remove at the final index.
          if(this.children!.length > 0) this.children!.removeAt(children!.length - 1);
          print(index.toString());
        }

        else if (this.children != null && index != null)
        {
          // check if index is in range, then dispose of the child at that index.
          if (index >= 0 && this.children!.length > index)
          {
            this.children![index].dispose();
            this.children!.removeAt(index);
          }
          // Could add handling for negative index removing from the end?
        }

        // add elements
        await _appendXml(xml, index, silent);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;

      case 'replacechildren':

        // fml
        var xml = S.item(arguments, 0);

        // silent
        bool silent = S.toBool(S.item(arguments, 1)) ?? true;

        if (xml == null || !(xml is String)) return true;

        // check for children then remove them
        if (this.children != null)
        {
          this.children!.forEach((child)
          {
            child.dispose();
          });
          this.children = [];
        }

        // add elements
        await _appendXml(xml, null, silent);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;

      case 'removewidget':

        // ineex
        int? index = (parent?.children?.contains(this) ?? false) ? parent?.children?.indexOf(this) : null;

        // index should never be null
        if (index != null)
        {
          // dispose of this model
          this.dispose();
          parent?.children?.removeAt(index);
        }

        // force parent rebuild
        parent?.notifyListeners("rebuild", "true");
        return true;

      case 'replacewidget':

        // fml
        var xml = S.item(arguments, 0);

        // get my position in my parents child list
        int? index = (parent?.children?.contains(this) ?? false) ? parent?.children?.indexOf(this) : null;

        // silent
        bool silent = S.toBool(S.item(arguments, 1)) ?? true;

        if (xml == null || !(xml is String)) return true;

        // index should never be null
        if (index != null)
        {
          // dispose of myself
          this.dispose();

          // remove myself from the list
          parent?.children?.removeAt(index);

          // add new fml
          await _appendXml(xml, index, silent);
        }

        // force parent rebuild
        parent?.notifyListeners("rebuild", "true");
        return true;
    }

    return false;
  }

  static XmlElement cloneNode(XmlElement node, Scope? scope)
  {
    if (Xml.hasAttribute(node: node, tag: "clone"))
    {
      var id = Xml.attribute(node: node, tag: "clone");
      var model = Scope.findWidgetModel(id, scope);
      if (model != null)
      {
        if (model.element != null)
        {
          var n1 = model.element!.localName.trim();
          var n2 = node.localName.trim();

          if (n1.toLowerCase() == n2.toLowerCase())
          {
            // copy element
            var element = model.element!.copy();
            node.attributes.forEach((attribute) => Xml.setAttribute(element, attribute.localName, attribute.value));
            node.replace(element);
            node = element;
          }
          else Log().exception("A model of type <$n2/> cannot be cloned from a model of type <$n1/>");
        }
        else Log().exception("Model $id has no element to copy from");
      }
      else Log().exception("Error attempting to clone model $id. Model not found.");
    }
    return node;
  }

  static bool excludeFromTemplate(XmlElement node, Scope? scope) {
    bool exclude = false;

    // exclude node from template?
    var value = node.getAttribute('exclude');
    if (value != null) {
      var bindable = BooleanObservable(null, value, scope: scope);
      exclude = bindable.get() ?? false;
      bindable.dispose();
    }
    return exclude;
  }

  static bool isDataSource(String element)
  {
    switch (element.toLowerCase())
    {
      case "barcode":
        return true;
      case "beacon":
        return true;
      case "biometric":
        return true;
      case "data":
        return true;
      case "delete":
        return true;
      case "detector":
        return true;
      case "filepicker":
        return true;
      case "get":
        return true;
      case "gps":
        return true;
      case "http":
        return true;
      case 'log':
        return true;
      case "mqtt":
        return true;
      case "nfc":
        return true;
      case "ocr":
        return true;
      case "post":
        return true;
      case "put":
        return true;
      case "socket":
        return true;
      case "sse":
        return true;
      case "zebra":
        return true;
      default:
        return false;
    }
  }
}
