import 'package:flutter/material.dart';
import 'package:fml/application/application_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/phrase.dart';
import 'package:fml/store/store_model.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/busy/busy_model.dart';

class StoreApp extends StatefulWidget {

  final bool showMakeDefaultOption;
  const StoreApp({super.key, required this.showMakeDefaultOption});

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
  bool isDefaultAppChecked = false;

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
    if (Store().findApp(url: uri.toString()) != null) {
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

    // supplied data valid?
    if (!(_formKey.currentState?.validate() ?? true)) {

      // site unreachable
      unreachable = true;

      // force form validation to show errors
      _formKey.currentState!.validate();

      // clear busy
      busy.set(false);

      return;
    }

    // create application
    ApplicationModel app = ApplicationModel(System(), url: url!, title: title, isDefault: isDefaultAppChecked);

    // wait for it to initialize
    await app.initialized.future;

    // site is reachable?
    unreachable = app.config == null;

    // app reachable?
    if (!unreachable) {

      // pop the dialog
      if (mounted) Navigator.of(context).pop();

      // add the app - if default, we need to wait until it is added
      app.isDefault ? await Store().addApp(app) : Store().addApp(app);

      // launch the app if default
      if (app.isDefault) System.launchApplication(app);
    }

    // clear busy
    busy.set(false);
  }

  _onSetDefaultApplication(bool? checked)
  {
    setState(() {
      isDefaultAppChecked = checked!;
    });
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

    var cancel = TextButton(
        child: Text(phrase.cancel),
        onPressed: () => Navigator.of(context).pop());

    var connect = TextButton(onPressed: _addApp, child: Text(phrase.connect));

    List<Widget> layout = [];

    // form fields
    layout.add(const Padding(padding: EdgeInsets.only(top: 10)));
    layout.add(url);
    layout.add(const Padding(padding: EdgeInsets.only(top: 10)));
    layout.add(name);

    // show make default app?
    if (widget.showMakeDefaultOption){

      var tx = Text(phrase.makeDefaultApp, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16));
      var cb = Checkbox(value: isDefaultAppChecked, onChanged: _onSetDefaultApplication);
      var note = isDefaultAppChecked ? SizedBox(width: 300, child: Text(softWrap: true, phrase.makeDefaultAppDisclaimer, style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 12))) : null;

      layout.add(const Padding(padding: EdgeInsets.only(top: 10)));
      layout.add(Row(mainAxisSize: MainAxisSize.min, children: [tx,cb]));
      if (note != null) layout.add(note);
      layout.add(const Padding(padding: EdgeInsets.only(top: 10)));
    }

    // buttons
    var buttons = Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [cancel, connect])));
    layout.add(buttons);

    var b = BusyModel(Store(),
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
