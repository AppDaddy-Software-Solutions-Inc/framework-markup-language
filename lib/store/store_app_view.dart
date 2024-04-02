import 'package:flutter/material.dart';
import 'package:fml/application/application_model.dart';
import 'package:fml/fml.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/phrase.dart';
import 'package:fml/store/store_model.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/busy/busy_model.dart';

class StoreApp extends StatefulWidget {

  final bool popOnExit;

  const StoreApp({super.key, required this.popOnExit});

  @override
  StoreAppState createState() {
    return StoreAppState();
  }
}

class StoreAppState extends State<StoreApp> {
  final _formKey = GlobalKey<FormState>();
  String errorText = '';
  String? title;
  String? url;
  bool unreachable = false;

  var urlController = TextEditingController();

  // busy
  BooleanObservable busy = BooleanObservable(null, false);

  String? _validateTitle(title) {
    this.title = null;
    errorText = '';

    // missing title
    if (isNullOrEmpty(title)) {
      errorText = "Title must be supplied";
      return errorText;
    }

    // assign url
    this.title = title;

    return null;
  }

  String? _validateUrl(url) {
    this.url = null;
    errorText = '';

    // missing url
    if (unreachable) {
      errorText = "Site unreachable or is missing config.xml";
      return errorText;
    }

    // missing url
    if (isNullOrEmpty(url)) {
      errorText = phrase.missingURL;
      return errorText;
    }

    var uri = Uri.tryParse(url);

    // invalid url
    if (uri == null) {
      errorText = 'The address in not a valid web address';
      return errorText;
    }

    // missing scheme
    if (!uri.hasScheme) {
      uri = Uri.parse('https://${uri.url}');
      urlController.text = uri.toString();
    }

    // missing host
    if (isNullOrEmpty(uri.authority)) {
      errorText = 'Missing host in address';
      return errorText;
    }

    // already defined
    if (StoreModel().findApp(url: uri.toString()) != null) {
      errorText = 'You are already connected to this application';
      return errorText;
    }

    // assign url
    this.url = url;

    return null;
  }

  Future _addApp() async {

    // set busy
    busy.set(true);

    // validate the form
    unreachable = false;

    // validate the form
    var ok = _formKey.currentState?.validate() ?? true;

    // supplied data valid?
    if (!ok) {

      // force form validation to show errors
      _formKey.currentState!.validate();

      // clear busy
      busy.set(false);

      return;
    }

    // create application
    ApplicationModel app = ApplicationModel(System(), url: url!, title: title);

    // wait for it to initialize
    await app.initialized;

    // site is reachable?
    ok = app.configured;

    // site not reachable?
    if (!ok) {

      // site unreachable
      unreachable = true;

      // force form validation to show errors
      _formKey.currentState!.validate();

      // clear busy
      busy.set(false);

      return;
    }

    // add the app - if branded, we need to wait
    FmlEngine.type == ApplicationType.branded ? await StoreModel().addApp(app) : StoreModel().addApp(app);

    // pop the dialog
    if (mounted && widget.popOnExit) Navigator.of(context).pop();

    // launch the app if branded
    if (FmlEngine.type == ApplicationType.branded) System.launchApplication(app);

    // clear busy
    busy.set(false);
  }

  @override
  Widget build(BuildContext context) {

    var nameDecoration = InputDecoration(
        labelText: phrase.appName,
        labelStyle: const TextStyle(fontSize: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide()));

    var style = TextStyle(color: Theme.of(context).colorScheme.onBackground);

    var name = TextFormField(
        validator: _validateTitle, decoration: nameDecoration, style: style);

    var addressDecoration = InputDecoration(
        labelText: phrase.appUrl,
        labelStyle: const TextStyle(fontSize: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide()));

    var url = TextFormField(
        controller: urlController,
        validator: _validateUrl,
        keyboardType: TextInputType.url,
        decoration: addressDecoration,
        style: style);

    var cancel = FmlEngine.type == ApplicationType.branded ? const Offstage() : TextButton(
        child: Text(phrase.cancel),
        onPressed: () => Navigator.of(context).pop());

    var connect = TextButton(onPressed: _addApp, child: Text(phrase.connect));

    List<Widget> layout = [];

    // form fields
    layout.add(const Padding(padding: EdgeInsets.only(top: 10)));
    layout.add(url);
    layout.add(const Padding(padding: EdgeInsets.only(top: 10)));
    layout.add(name);

    // buttons
    var buttons = Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [cancel, connect])));
    layout.add(buttons);

    var b = BusyModel(StoreModel(),
            visible: (busy.get() ?? false), observable: busy, modal: false)
        .getView();

    var form = Form(
        key: _formKey,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: layout));

    return Stack(fit: StackFit.passthrough, children: [form, b]);
  }
}
