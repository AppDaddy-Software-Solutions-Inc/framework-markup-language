// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
Phrases phrase = Phrases();

class Phrases {
  static final Phrases _singleton = Phrases._init();
  factory Phrases() {
    return _singleton;
  }
  Phrases._init();

  static const String english = 'EN';
  static const String french = 'FR';
  List<String> languages = [english, french];

  String _language = english;
  String get language {
    return _language;
  }

  set language(String? language) {
    if (language == null) return;
    if (languages.contains(language.toUpperCase())) _language = language;
  }

  String get reset {
    if (language == french) return '(FR) Reset';
    return 'Reset';
  }

  String get close {
    if (language == french) return '(FR) Close';
    return 'Close';
  }

  String get yes {
    if (language == french) return 'Oui';
    return 'Yes';
  }

  String get no {
    if (language == french) return 'Non';
    return 'No';
  }

  String get version {
    if (language == french) return '(FR) Version';
    return 'Version';
  }

  String get privacyPolicy {
    if (language == french) return '(FR) Privacy Policy';
    return 'Privacy Policy';
  }

  String get application {
    if (language == french) return '(FR) Application';
    return 'Application';
  }

  String get store {
    if (language == french) return '(FR) Application Link';
    return 'Application Link';
  }

  String get cancel {
    if (language == french) return '(FR) Cancel';
    return 'Cancel';
  }

  String get save {
    if (language == french) return '(FR) Save';
    return 'Save';
  }

  String get clear {
    if (language == french) return '(FR) Clear';
    return 'Clear';
  }

  String get missingURL {
    if (language == french) return '(FR) Missing URL';
    return 'Missing URL';
  }

  String get missingOrInvalidURL {
    if (language == french) return '(FR) Missing or Invalid URL';
    return 'Missing or Invalid URL';
  }

  String get siteUnreachable {
    if (language == french) return '(FR) This site can’t be reached';
    return 'This site can’t be reached';
  }

  String get unauthorizedAccess {
    if (language == french)
      return '(FR) You are not authorized to access this page';
    return 'You are not authorized to access this page';
  }

  String get errorParsingTemplate {
    if (language == french) return '(FR) Error parsing template';
    return 'Error parsing template';
  }

  String get formNotFound {
    if (language == french) return '(FR) Form Not Found';
    return 'Form Not Found';
  }

  String get assetNotFound {
    if (language == french) return '(FR) Asset Not Found';
    return 'Asset Not Found';
  }

  String get pageNotFound {
    if (language == french) return '(FR) Page Not Found';
    return 'Page Not Found';
  }

  String get fileNotFound {
    if (language == french) return '(FR) File Not Found';
    return 'File Not Found';
  }

  String get notConnected {
    if (language == french) return '(FR) Not Connected';
    return 'Not Connected';
  }

  String get cannotLaunchURL {
    if (language == french) return '(FR) Cannot Launch URL';
    return 'Cannot Launch URL';
  }

  String get missingTemplate {
    if (language == french) return '(FR) Missing Template';
    return 'Missing Template';
  }

  String get copiedToClipboard {
    if (language == french) return '(FR) Copied to Clipboard';
    return 'Copied to Clipboard';
  }

  String get exportingData {
    if (language == french) return '(FR) Exporting data ...';
    return 'Exporting data ...';
  }

  String get continueQuitting {
    if (language == french)
      return '(FR) You have unsaved changes. Continue quitting?';
    return 'You have unsaved changes. Continue quitting?';
  }

  String get confirmFormComplete {
    if (language == french) return '(FR) Complete the form?';
    return 'Complete the form?';
  }

  String get confirmExit {
    if (language == french)
      return '(FR) Are you sure you want to exit the app?';
    return 'Are you sure you want to exit the app?';
  }

  String get addApp {
    if (language == french) return '(FR) Add App';
    return 'Add App';
  }

  String get loadApp {
    if (language == french) return '(FR) Load App';
    return 'Load App';
  }

  String get removeApp {
    if (language == french) return '(FR) Remove App?';
    return 'Remove App?';
  }

  String get appName {
    if (language == french) return '(FR) Application Name';
    return 'Application Name';
  }

  String get appUrl {
    if (language == french)
      return '(FR) Application URL (https://yoursite.com)';
    return 'Application URL (https://yoursite.com)';
  }

  String get remove {
    if (language == french) return '(FR) Remove';
    return 'Remove';
  }

  String get fieldMandatory {
    if (language == french) return '(FR) Mandatory field';
    return 'Mandatory field';
  }

  String get warningAlarms {
    if (language == french) return '(FR) There are {#} fields alarming';
    return 'There are {#} fields alarming';
  }

  String get of {
    if (language == french) return '(FR) of';
    return 'of';
  }

  String get pagesize {
    if (language == french) return '(FR) Page size';
    return 'Page size';
  }

  String get records {
    if (language == french) return '(FR) Records';
    return 'Records';
  }

  String get connect {
    if (language == french) return "(FR) Connect";
    return "Connect";
  }

  String get clickToConnect {
    if (language == french)
      return "(FR) Click the + button to connect an application";
    return "Click the + button to connect an application";
  }

  String get connectAnApplication {
    if (language == french) return "(FR) Connect an Application";
    return "Connect an Application";
  }

  String get checkConnection {
    if (language == french) return '(FR) Check your connection';
    return 'Check your connection';
  }

  String get postmasterPhrase001 {
    if (language == french) return '(FR) Background posting service started';
    return 'Background posting service started';
  }

  String get postmasterPhrase002 {
    if (language == french) return '(FR) There are {jobs} pending posts';
    return 'There are {jobs} pending posts';
  }

  String get somethingWentWrong {
    if (language == french)
      return '(FR) Something went wrong.\n Try going back or restarting the application.\n If this problem persists please contact us.';
    return 'Something went wrong.\n Try going back or restarting the application.\n If this problem persists please contact us.';
  }

  String get noData {
    if (language == french) return '(FR) No data';
    return 'No Data';
  }

  String get noMatchFound {
    if (language == french) return '(FR) No match found';
    return 'No match found';
  }
}
