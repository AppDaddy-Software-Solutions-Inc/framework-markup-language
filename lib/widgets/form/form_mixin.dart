import 'package:collection/collection.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:fml/widgets/form/form_interface.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';

mixin FormMixin on Model {

  // list of all sub forms
  List<IForm> forms = [];

  // list of all form fields
  List<IFormField> fields = [];

  BooleanObservable? _dirty;
  BooleanObservable? get dirtyObservable => _dirty;
  set dirty(dynamic v) {
    if (_dirty != null) {
      _dirty!.set(v);
    } else if (v != null) {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v, scope: scope);
    }
  }
  bool get dirty => _dirty?.get() ?? false;

  void onDirtyListener(Observable property) {
    // set form dirty
    bool isDirty = false;
    for (var field in fields) {
      if (field.dirty == true) isDirty = true;
    }
    dirty = isDirty;
  }

  // gets a list of the forms contained in the specified model
  List<IForm> formsOf(Model model) {
    List<IForm> forms = [];
    for (var child in model.children ?? []) {
      if (child is IForm) forms.add(child);
      if (child is! IForm) forms.addAll(formsOf(child));
    }
    return forms;
  }

  // gets a list of the form fields contained in the specified model
  List<IFormField> formFieldsOf(Model model) {
    List<IFormField> fields = [];
    for (var child in model.children ?? []) {
      if (child is IFormField) fields.add(child);
      if (child is! IForm) fields.addAll(formFieldsOf(child));
    }
    return fields;
  }

  @override
  void notifyAncestorsOfDescendantChange() {

    // get list of sub-forms
    var forms = formsOf(this);

    // remove dirty listeners from forms that are no longer in the form list
    for (var form in this.forms) {
      if (!forms.contains(form)) {
        form.dirtyObservable?.removeListener(onDirtyListener);
      }
    }

    // add dirty listeners to new forms
    for (var form in forms) {
      if (!this.forms.contains(form)) {
        form.dirtyObservable?.registerListener(onDirtyListener);
      }
    }

    // set forms list
    this.forms = forms;

    // get list of form fields
    var fields = formFieldsOf(this);

    // remove dirty listeners from fields that are no longer in the field list
    for (var field in this.fields) {
      if (!fields.contains(field)) {
        field.removeDirtyListener(onDirtyListener);
      }
    }

    // add dirty listeners to new fields
    for (var field in fields) {
      if (!this.fields.contains(field)) {
        field.registerDirtyListener(onDirtyListener);
      }
    }

    // set forms list
    this.fields = fields;

    // notify parent
    parent?.notifyAncestorsOfDescendantChange();
  }

  static bool isPostable(IForm form, IFormField field) {
    if (field.post != null) return field.post!;
    if (form.post != null) return form.post!;
    if (field.value == null) return false;
    if (field is List && (field as List).isEmpty) return false;
    return true;
  }

  static Future<String?> buildPostingBody(IForm form, List<IFormField>? fields,
      {String rootname = "FORM"}) async {
    try {
      // build xml document
      XmlDocument document = XmlDocument();
      XmlElement root =
      XmlElement(XmlName(isNullOrEmpty(rootname) ? "FORM" : rootname));
      document.children.add(root);

      if (fields != null) {
        for (var field in fields) {
          // postable?
          if (isPostable(form, field) == true) {
            if (field.values != null) {
              field.values?.forEach((value) {
                XmlElement node;
                String name = field.field ?? field.id ?? "";
                try {
                  // valid element name?
                  if (!isNumeric(name.substring(0, 1))) {
                    node = XmlElement(XmlName(name));
                  } else {
                    node = XmlElement(XmlName("FIELD"));
                    node.attributes.add(XmlAttribute(XmlName('id'), name));
                  }
                } catch (e) {
                  node = XmlElement(XmlName("FIELD"));
                  node.attributes.add(XmlAttribute(XmlName('id'), name));
                }

                // add field type
                if (!isNullOrEmpty(field.elementName)) {
                  node.attributes
                      .add(XmlAttribute(XmlName('type'), field.elementName));
                }

                /// GeoCode for each [iFormField] which is set on answer
                if (field.geocode != null) field.geocode!.serialize(node);

                // add meta data
                field.metaData.forEach((key, value) {
                  bool exists = node.attributes.firstWhereOrNull((a) => a.name.local == key) != null;
                  if (!exists) node.attributes.add(XmlAttribute(XmlName(key), value));
                });

                // value
                try {
                  // Xml Data
                  if (field is InputModel && field.formatType == "xml") {
                    var document = XmlDocument.parse(value);
                    var e = document.rootElement;
                    document.children.remove(e);
                    node.children.add(e);
                  }

                  // Non-XML? Wrap in CDATA
                  else if (Xml.hasIllegalCharacters(value)) {
                    node.children.add(XmlCDATA(value));
                  } else {
                    node.children.add(XmlText(value));
                  }
                } on XmlException catch (e) {
                  node.children.add(XmlCDATA(e.message));
                }

                // Add Node
                root.children.add(node);
              });
            } else {
              // Build Element
              XmlElement node;
              String name = field.field ?? field.id ?? "";
              try {
                // Valid Element Name
                if (!isNumeric(name.substring(0, 1))) {
                  node = XmlElement(XmlName(name));
                }

                // In-Valid Element Name
                else {
                  node = XmlElement(XmlName("FIELD"));
                  node.attributes.add(XmlAttribute(XmlName('id'), name));
                }
              } catch (e) {
                // In-Valid Element Name
                node = XmlElement(XmlName("FIELD"));
                node.attributes.add(XmlAttribute(XmlName('id'), name));
              }

              // Add Field Type
              if (!isNullOrEmpty(field.elementName)) {
                node.attributes
                    .add(XmlAttribute(XmlName('type'), field.elementName));
              }

              // Add Node
              root.children.add(node);
            }
          }
        }
      }

      // Set Body
      return document.toXmlString(pretty: true);
    } catch (e) {
      Log().error(
          "Error serializing posting document. Error is ${e.toString()}");
      return null;
    }
  }
}