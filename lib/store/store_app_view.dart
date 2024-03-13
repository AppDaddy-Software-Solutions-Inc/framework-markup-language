import 'package:flutter/material.dart';
import 'package:fml/application/application_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/phrase.dart';
import 'package:fml/store/store_model.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/busy/busy_model.dart';

class AppForm extends StatefulWidget
{
  AppForm();

  @override
  AppFormState createState()
  {
    return AppFormState();
  }
}

class AppFormState extends State<AppForm>
{
  final   _formKey  = GlobalKey<FormState>();
  String  errorText = '';
  String? title;
  String? url;
  bool unreachable = false;

  var urlController = TextEditingController();

  // busy
  BooleanObservable busy = BooleanObservable(null, false);

  String? _validateTitle(title)
  {
    this.title = null;
    errorText = '';

    // missing title
    if (isNullOrEmpty(title))
    {
      errorText = "Title must be supplied";
      return errorText;
    }

    // assign url
    this.title = title;

    return null;
  }

  String? _validateUrl(url)
  {
    this.url = null;
    errorText = '';

    // missing url
    if (unreachable)
    {
      errorText = "Site unreachable or is missing config.xml";
      return errorText;
    }

    // missing url
    if (isNullOrEmpty(url))
    {
      errorText = phrase.missingURL;
      return errorText;
    }

    var uri = Uri.tryParse(url);

    // invalid url
    if (uri == null)
    {
      errorText = 'The address in not a valid web address';
      return errorText;
    }

    // missing scheme
    if (!uri.hasScheme)
    {
      uri = Uri.parse('https://${uri.url}');
      urlController.text = uri.toString();
    }

    // missing host
    if (isNullOrEmpty(uri.authority))
    {
      errorText = 'Missing host in address';
      return errorText;
    }

    // already defined
    if (Store().find(url: uri.toString()) != null)
    {
      errorText = 'You are already connected to this application';
      return errorText;
    }

    // assign url
    this.url = url;

    return null;
  }

  Future _addApp() async
  {
    // validate the form
    unreachable = false;
    busy.set(true);
    bool ok = _formKey.currentState!.validate();
    if (ok)
    {
      ApplicationModel app = ApplicationModel(System(),url: url!, title: title);
      await app.initialized;
      if (app.hasConfig)
      {
        Store().add(app);
        Navigator.of(context).pop();
      }
      else
      {
        unreachable = true;
        _formKey.currentState!.validate();
      }
    }
    busy.set(false);
  }

  @override
  Widget build(BuildContext context)
  {
    var nameDecoration = InputDecoration(labelText: "Application Name",
        labelStyle: TextStyle(fontSize: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide()));

    var style = TextStyle(color: Theme.of(context).colorScheme.onBackground);

    var name = TextFormField(validator: _validateTitle, decoration: nameDecoration, style: style);

    var addressDecoration = InputDecoration(
        labelText: "Application Address (https://mysite.com)",
        labelStyle: TextStyle(fontSize: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide()));

    var url = TextFormField(controller: urlController, validator: _validateUrl, keyboardType: TextInputType.url, decoration: addressDecoration, style: style);

    var cancel = TextButton(child: Text(phrase.cancel),  onPressed: () => Navigator.of(context).pop());

    var connect =  TextButton(child: Text(phrase.connect), onPressed: _addApp);

    List<Widget> layout = [];

    // form fields
    layout.add(Padding(padding: EdgeInsets.only(top: 10)));
    layout.add(url);
    layout.add(Padding(padding: EdgeInsets.only(top: 10)));
    layout.add(name);

    // buttons
    var buttons = Padding(padding: const EdgeInsets.only(top: 10.0, bottom: 10),child: Align(alignment: Alignment.bottomCenter, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [cancel,connect])));
    layout.add(buttons);

    var b = BusyModel(Store(), visible: (busy.get() ?? false), observable: busy, modal: false).getView();
    var form = Form(key: _formKey, child: Column(children: layout, mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start));

    return Stack(fit: StackFit.passthrough, children: [form,b]);
  }
}