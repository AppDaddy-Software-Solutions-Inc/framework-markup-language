// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:camera/camera.dart' show CameraLensDirection;
import 'package:camera/camera.dart' show XFile;
import 'package:fml/datasources/camera/model.dart' as CAMERA;
import 'package:fml/widgets/camera/camera_view.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/handler.dart' ;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:fml/datasources/detectors/detector_model.dart' ;
import 'package:image/image.dart' as IMAGE;
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

class CameraModel extends CAMERA.CameraImageModel implements IViewableWidget
{
  bool fullscreen = true;
  bool stream = false;

  CameraViewState? camera;

  // camera name
  StringObservable? _name;
  set name (dynamic v)
  {
    if (_name != null)
    {
      _name!.set(v);
    }
    else if (v != null)
    {
      _name = StringObservable(Binding.toKey(id, 'name'), v, scope: scope);
    }
  }
  String? get name => _name?.get();

  // camera index
  IntegerObservable? _index;
  set index (dynamic v)
  {
    if (_index != null)
    {
      _index!.set(v);
    }
    else if (v != null)
    {
      // the odd means of adding onPropertyChange is on purpose. It triggers too soon and the view sets it on initialize()
      _index = IntegerObservable(Binding.toKey(id, 'index'), v, scope: scope);
      _index!.registerListener(onPropertyChange);
      _index!.notifyListeners();
    }
  }
  int? get index => _index?.get();

  //////////////////
  /* Render Width */
  //////////////////
  DoubleObservable? _renderwidth;
  set renderwidth (dynamic v)
  {
    if (_renderwidth != null)
    {
      _renderwidth!.set(v);
    }
    else if (v != null)
    {
      _renderwidth = DoubleObservable(Binding.toKey(id, 'renderwidth'), v, scope: scope);
    }
  }
  double get renderwidth => _renderwidth?.get() ?? 0;

  ///////////////////
  /* Render Height */
  ///////////////////
  DoubleObservable? _renderheight;
  set renderheight (dynamic v)
  {
    if (_renderheight != null)
    {
      _renderheight!.set(v);
    }
    else if (v != null)
    {
      _renderheight = DoubleObservable(Binding.toKey(id, 'renderheight'), v, scope: scope);
    }
  }
  double get renderheight => _renderheight?.get() ?? 0;

  //////////////////
  /* Stream Width */
  //////////////////
  DoubleObservable? _streamwidth;
  set streamwidth (dynamic v)
  {
    if (_streamwidth != null)
    {
      _streamwidth!.set(v);
    }
    else if (v != null)
    {
      _streamwidth = DoubleObservable(Binding.toKey(id, 'streamwidth'), v, scope: scope);
    }
  }
  double? get streamwidth => _streamwidth?.get() ?? 0;

  ///////////////////
  /* Stream Height */
  ///////////////////
  DoubleObservable? _streamheight;
  set streamheight (dynamic v)
  {
    if (_streamheight != null)
    {
      _streamheight!.set(v);
    }
    else if (v != null)
    {
      _streamheight = DoubleObservable(Binding.toKey(id, 'streamheight'), v, scope: scope);
    }
  }
  double? get streamheight => _streamheight?.get() ?? 0;

  ///////////////////
  /* Display Width */
  ///////////////////
  DoubleObservable? _displaywidth;
  set displaywidth (dynamic v)
  {
    if (_displaywidth != null)
    {
      _displaywidth!.set(v);
    }
    else if (v != null)
    {
      _displaywidth = DoubleObservable(Binding.toKey(id, 'displaywidth'), v, scope: scope);
    }
  }
  double? get displaywidth => _displaywidth?.get() ?? 0;

  ////////////////////
  /* Display Height */
  ////////////////////
  DoubleObservable? _displayheight;
  set displayheight (dynamic v)
  {
    if (_displayheight != null)
    {
      _displayheight!.set(v);
    }
    else if (v != null)
    {
      _displayheight = DoubleObservable(Binding.toKey(id, 'displayheight'), v, scope: scope);
    }
  }
  double? get displayheight => _displayheight?.get() ?? 0;

  ///////////
  /* scale */
  ///////////
  BooleanObservable? _scale;
  set scale(dynamic v)
  {
    if (_scale != null)
    {
      _scale!.set(v);
    }
    else if (v != null)
    {
      _scale = BooleanObservable(Binding.toKey(id, 'scale'), v, scope: scope);
    }
  }
  bool get scale => _scale?.get() ?? false;

  // facing camera direction
  StringObservable? _direction;
  set direction(dynamic v)
  {
    if (_direction != null)
    {
      _direction!.set(v);
    }
    else if (v != null)
    {
      _direction = StringObservable(Binding.toKey(id, 'direction'), v, scope: scope);
    }
  }
  String? get direction => _direction?.get();

  // camera orientation
  StringObservable? _orientation;
  set orientation(dynamic v)
  {
    if (_orientation != null)
    {
      _orientation!.set(v);
    }
    else if (v != null)
    {
      _orientation = StringObservable(Binding.toKey(id, 'orientation'), v, scope: scope);
    }
  }
  String? get orientation => _orientation?.get();

  // camera resolution
  StringObservable? _resolution;
  set resolution(dynamic v)
  {
    if (_resolution != null)
    {
      _resolution!.set(v);
    }
    else if (v != null)
    {
      _resolution = StringObservable(Binding.toKey(id, 'resolution'), v, scope: scope);
    }
  }
  String get resolution => _resolution?.get() ?? "medium";

  /////////////
  /* controls */
  /////////////
  BooleanObservable? _controls;
  set controls(dynamic v)
  {
    if (_controls != null)
    {
      _controls!.set(v);
    }
    else if (v != null)
    {
      _controls = BooleanObservable(Binding.toKey(id, 'controls'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get controls => _controls?.get() ?? true;

  BooleanObservable? _togglevisible;
  set togglevisible(dynamic v)
  {
    if (_togglevisible != null)
    {
      _togglevisible!.set(v);
    }
    else if (v != null)
    {
      _togglevisible = BooleanObservable(Binding.toKey(id, 'togglevisible'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get togglevisible => _togglevisible?.get() ?? false;

  // on initialized event
  StringObservable? _oninitialized;
  set oninitialized(dynamic v)
  {
    if (_oninitialized != null)
    {
      _oninitialized!.set(v);
    }
    else if (v != null)
    {
      _oninitialized = StringObservable(Binding.toKey(id, 'oninitialized'), v, scope: scope, lazyEval: true);
    }
  }
  String? get oninitialized => _oninitialized?.get();
  
  CameraModel(WidgetModel parent, String?  id) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;
  }

  static CameraModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    CameraModel? model;
    try
    {
      /////////////////
      /* Build Model */
      /////////////////
      model = CameraModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'webcam.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    onfail        = Xml.get(node: xml, tag: 'onfail');
    oninitialized = Xml.get(node: xml, tag: 'oninitialized');
    enabled       = Xml.get(node: xml, tag: 'enabled');
    controls      = Xml.get(node: xml, tag: 'controls');
    scale         = Xml.get(node: xml, tag: 'scale');
    togglevisible = Xml.get(node: xml, tag: 'togglevisible');

    // enable streaming
    if (detectors != null) detectors!.forEach((detector) => ((detector.source == DetectorSources.stream) || (detector.source == DetectorSources.any)) ? stream = true : null);
  }

  bool popDialog = true;
  bool runonce = true;
  int i=0;

  @override
  void dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Future<bool> start({bool force = false, bool refresh = false, String? key}) async
  {
    camera?.start();
    return true;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    if (camera != null)
    switch (function)
    {
      case "start" : return await camera!.start();
      case "stop"  : return await camera!.stop();
      case "snapshot" : return await camera!.snapshot();
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  Future<bool> onInitialized(BuildContext context) async
  {
    if (this.oninitialized == null) return true;
    return await EventHandler(this).execute(_oninitialized);
  }
  
  Future<bool> detectInStream(DetectableImage image) async
  {
    if (detectors == null) return true;
    detectors!.forEach((detector)
    {
      if ((detector.source == DetectorSources.stream) || (detector.source == DetectorSources.any)) detector.detect(image, true);
    });
    return true;
  }

  Future<bool> detectInImage(DetectableImage image) async
  {
    if (detectors == null) return true;
    detectors!.forEach((detector)
    {
      if ((detector.source == DetectorSources.image) || (detector.source == DetectorSources.any)) detector.detect(image, false);
    });
    return true;
  }

  Future<FILE.File> applyTransforms(XFile file) async
  {
    busy = true;

    IMAGE.Image? image;

    //  image is mirrored. this is a stop gap measure. should be a transform
    if ((direction ?? "") == S.fromEnum(CameraLensDirection.front))
    {
      image = IMAGE.decodeJpg(await file.readAsBytes());
      image = IMAGE.flipHorizontal(image!);

      // encode back to jpg
      var bytes = IMAGE.encodeJpg(image);

      var name = basename(S.isNullOrEmpty(file.name) ? "${Uuid().v4().toString()}.jpg" : file.name);
      var uri  = UriData.fromBytes(bytes, mimeType: await S.mimetype(name));
      var url  = uri.toString();
      var type = await S.mimetype(name);
      var size = bytes.length;

      // save the image
      busy = false;
      return FILE.File(uri, url, name, type, size);
    }

    // no transformation applied
    else
    {
      // set file - 'file:' required so image widget will decode as a file path.
      var url  = file.path.startsWith("blob:") ? file.path : "file:${file.path}";
      var name = basename(S.isNullOrEmpty(file.name) ? "${Uuid().v4().toString()}.jpg" : file.name);
      var type = await S.mimetype(name);
      var size = await file.length();

      // save the image
      busy = false;
      return FILE.File(file, url, name, type, size);
    }
  }

  Widget getView({Key? key}) => getReactiveView(CameraView(this));
}