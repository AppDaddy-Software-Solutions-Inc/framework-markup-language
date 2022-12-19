// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
Phrases phrase = Phrases();
class Phrases
{
  static final Phrases _singleton =  Phrases._init();
  factory Phrases()
  {
    return _singleton;
  }
  Phrases._init();

  static final String english = 'EN';
  static final String french  = 'FR';
  List<String> languages = [english, french];

  String _language = english;
  String get language
  {
    return _language;
  }
  set language (String? language)
  {
    if (language == null) return;
    if (languages.contains(language.toUpperCase()))_language = language;
  }

  String get empty
  {
    return '';
  }

  String get ok
  {
    if (language == french) return '(FR) Ok';
    return 'Ok';
  }

  String get reset
  {
    if (language == french) return '(FR) Reset';
    return 'Reset';
  }

  String get close
  {
    if (language == french) return '(FR) Close';
    return 'Close';
  }

  String get minimize
  {
    if (language == french) return '(FR) Minimize';
    return 'Minimize';
  }

  String get maximize
  {
    if (language == french) return '(FR) Maximize';
    return 'Maximize';
  }

  String get restoreToLast
  {
    if (language == french) return '(FR) Restore to Last';
    return 'Restore to Last';
  }

  String get restoreToOriginal
  {
    if (language == french) return '(FR) Restore to Original';
    return 'Restore to Original';
  }

  String get error
  {
    if (language == french) return '(FR) Error';
    return 'Error';
  }

  String get yes
  {
    if (language == french) return 'Oui';
    return 'Yes';
  }

  String get no
  {
    if (language == french) return 'Non';
    return 'No';
  }

  String get v
  {
    if (language == french) return '(FR) v.'; // version shorthand
    return 'v.';
  }

  String get version
  {
    if (language == french) return '(FR) Version';
    return 'Version';
  }

  String get client
  {
    if (language == french) return '(FR) Client';
    return 'Client';
  }

  String get user
  {
    if (language == french) return '(FR) User';
    return 'User';
  }

  String get username
  {
    if (language == french) return '(FR) Username';
    return 'Username';
  }

  String get password
  {
    if (language == french) return '(FR) Password';
    return 'Password';
  }

  String get pin
  {
    if (language == french) return '(FR) Pin';
    return 'Pin';
  }

  String get oldPassword
  {
    if (language == french) return '(FR) Old Password';
    return 'Old Password';
  }

  String get newPassword
  {
    if (language == french) return '(FR) New Password';
    return 'New Password';
  }

  String get createAccount
  {
    if (language == french) return '(FR) Create Account';
    return 'Create Account';
  }

  String get recoverPassword
  {
    if (language == french) return '(FR) Recover Password';
    return 'Recover Password';
  }

  String get rememberMe
  {
    if (language == french) return '(FR) Remember Me';
    return 'Remember Me';
  }

  String get application
  {
    if (language == french) return '(FR) Application';
    return 'Application';
  }

  String get store
  {
    if (language == french) return '(FR) Application Link';
    return 'Application Link';
  }

  String get home
  {
    if (language == french) return '(FR) Home';
    return 'Home';
  }

  String get back
  {
    if (language == french) return '(FR) Back';
    return 'Back';
  }

  String get log
  {
    if (language == french) return '(FR) Log';
    return 'Log';
  }

  String get logs
  {
    if (language == french) return '(FR) Logs';
    return 'Logs';
  }

  String get debugLog
  {
    if (language == french) return '(FR) Show Debug Log';
    return 'Show Debug Log';
  }

  String get logOut
  {
    if (language == french) return '(FR) Log Out';
    return 'Log Out';
  }

  String get cancel
  {
    if (language == french) return '(FR) Cancel';
    return 'Cancel';
  }

  String get exit
  {
    if (language == french) return '(FR) Exit';
    return 'Exit';
  }

  String get browse
  {
    if (language == french) return '(FR) Browse';
    return 'Browse';
  }

  String get addAttachment
  {
    if (language == french) return '(FR) Add Attachment';
    return 'Add Attachment';
  }

  String get tapToSelectAttachment
  {
    if (language == french) return '(FR) Tap to select attachment';
    return 'Tap to select attachment';
  }

  String get takeAPicture
  {
    if (language == french) return '(FR) Take a Picture';
    return 'Take a Picture';
  }

  String get save
  {
    if (language == french) return '(FR) Save';
    return 'Save';
  }

  String get clear
  {
    if (language == french) return '(FR) Clear';
    return 'Clear';
  }

  String get retry
  {
    if (language == french) return '(FR) Retry';
    return 'Retry';
  }

  String get formSaved
  {
    if (language == french) return '(FR) Form Saved';
    return 'Form Saved';
  }

  String get copy
  {
    if (language == french) return '(FR) Copy';
    return 'Copy';
  }

  String get missingURL
  {
    if (language == french) return '(FR) Missing URL';
    return 'Missing URL';
  }

  String get cannotLaunchURL
  {
    if (language == french) return '(FR) Cannot Launch URL';
    return 'Cannot Launch URL';
  }

  String get cannotFindForm
  {
    if (language == french) return '(FR) Cannot Find Form';
    return 'Cannot Find Form';
  }

  String get missingTemplate
  {
    if (language == french) return '(FR) Missing Template';
    return 'Missing Template';
  }

  String get invalidTransaction
  {
    if (language == french) return '(FR) Missing or Invalid Transaction';
    return 'Missing or Invalid Transaction';
  }

  String get copiedToClipboard
  {
    if (language == french) return '(FR) Copied to Clipboard';
    return 'Copied to Clipboard';
  }

  String get templateReloading
  {
    if (language == french) return '(FR) Template Reloading';
    return 'Template Reloading';
  }

  String get templateReloaded
  {
    if (language == french) return '(FR) Template Reloaded';
    return 'Template Reloaded';
  }

  String get clearSpeech
  {
    if (language == french) return '(FR) Speech to Text Cleared';
    return 'Speech to Text Cleared';
  }

  String get zoomReset
  {
    if (language == french) return '(FR) Zoom Reset';
    return 'Zoom Reset';
  }

  String get exportingData
  {
    if (language == french) return '(FR) Exporting data ...';
    return 'Exporting data ...';
  }

  String get fileName
  {
    if (language == french) return '(FR) File Name';
    return 'File Name';
  }

  String get fileSize
  {
    if (language == french) return '(FR) Size';
    return 'Size';
  }

  String get fileProgress
  {
    if (language == french) return '(FR) File Progress';
    return 'File Progress';
  }

  String get passwordEmpty
  {
    if (language == french) return '(FR) Password cannot be empty';
    return 'Password cannot be empty';
  }

  String get passwordLength
  {
    if (language == french) return '(FR) Password must be at least 6 characters';
    return 'Password must be at least 6 characters';
  }

  String get passwordNoLower
  {
    if (language == french) return '(FR) Password must contain 1 lower case character';
    return 'Password must contain 1 lowercase character';
  }

  String get passwordNoUpper
  {
    if (language == french) return '(FR) Password must contain 1 upper case character';
    return 'Password must contain 1 uppercase character';
  }

  String get passwordNoNumber
  {
    if (language == french) return '(FR) Password must contain a number';
    return 'Password must contain a number';
  }

  String get passwordNoSpecial
  {
    if (language == french) return '(FR) Password must contain a special character';
    return 'Password must contain a special character';
  }

  String get emailInvalid
  {
    if (language == french) return '(FR) Invalid Email Address';
    return 'Invalid Email Address';
  }

  String get isRequired
  {
    if (language == french) return '(FR) Required Field';
    return 'Required Field';
  }

  String get saveBeforeExit
  {
    if (language == french) return '(FR) Save before exiting?';
    return 'Save before exiting?';
  }

  String get confirmFormComplete
  {
    if (language == french) return '(FR) Complete the form?';
    return 'Complete the form?';
  }

  String get confirmRemoveAttachment
  {
    if (language == french) return '(FR) Remove Attachment?';
    return 'Remove Attachment?';
  }

  String get removeAttachment
  {
    if (language == french) return '(FR) Remove Attachment';
    return 'Remove Attachment';
  }

  String get confirmTableComplete
  {
    if (language == french) return '(FR) Complete the table?';
    return 'Complete the table?';
  }

  String get logIn
  {
    if (language == french) return '(FR) Log In';
    return 'Log In';
  }

  String get loadApp
  {
    if (language == french) return '(FR) Load App';
    return 'Load App';
  }

  String get enterYourClient
  {
    if (language == french) return '(FR) Enter your client';
    return 'Enter your client';
  }

  String get enterYourUsername
  {
    if (language == french) return '(FR) Enter your username';
    return 'Enter your username';
  }

  String get dontHaveAnAccount
  {
    if (language == french) return '(FR) Don\'t have an account\?';
    return 'Don\'t have an account\?';
  }


  String get enterYourPassword
  {
    if (language == french) return '(FR) Enter your password';
    return 'Enter your password';
  }

  String get forgotYourPassword
  {
    if (language == french) return '(FR) Forgot your password';
    return 'Forgot your password';
  }

  String get create
  {
    if (language == french) return '(FR) Create';
    return 'Create';
  }

  String get quit
  {
    if (language == french) return '(FR) Quit';
    return 'Quit';
  }

  String get enterYourName
  {
    if (language == french) return '(FR) Please Enter Your Name';
    return 'Please Enter Your Name';
  }

  String get chooseAPassword
  {
    if (language == french) return '(FR) Please Enter A Password';
    return 'Please Enter A Password';
  }

  String get success
  {
    if (language == french) return '(FR) Success';
    return 'Success';
  }

  String get warning
  {
    if (language == french) return '(FR) Warning';
    return 'Warning';
  }

  String get warningMandatory
  {
    if (language == french) return '(FR) There are {#} mandatory fields missing';
    return 'There are {#} mandatory fields missing';
  }

  String get warningAlarms
  {
    if (language == french) return '(FR) There are {#} fields alarming';
    return 'There are {#} fields alarming';
  }

  String get requestResetLink
  {
    if (language == french) return '(FR) Request Password Reset';
    return 'Request Password Reset';
  }

  String get clickHere
  {
    if (language == french) return '(FR) Click Here';
    return 'Request Password Reset';
  }

  String get pleaseEnterEmailOrUsername
  {
    if (language == french) return '(FR) Please enter the email address or username associated with your account to recover a lost password.';
    return 'Please enter the email address or username associated with your account to recover a lost password.';
  }

  String get alreadyAMember
  {
    if (language == french) return '(FR) Already a Member?';
    return 'Already a Member?';
  }

  String get done
  {
    if (language == french) return '(FR) Done';
    return 'Done';
  }

  String get resent
  {
    if (language == french) return '(FR) Resent';
    return 'Resent';
  }

  String get join
  {
    if (language == french) return '(FR) Join';
    return 'Join';
  }

  String get next
  {
    if (language == french) return '(FR) Next';
    return 'Next';
  }

  String get confirm
  {
    if (language == french) return '(FR) Confirm';
    return 'Confirm';
  }

  String get confirmYourEmail
  {
    if (language == french) return '(FR) Confirm Your Email';
    return 'Confirm Your Email';
  }

  String get authenticate
  {
    if (language == french) return '(FR) Authenticate';
    return 'Authenticate';
  }

  String get notRobot
  {
    if (language == french) return '(FR) So we know you are not a Robot';
    return 'So we know you are not a Robot';
  }

  String get confirmationCode
  {
    if (language == french) return '(FR) Confirmation Code';
    return 'Confirmation Code';
  }

  String get confirmationPhrase0013
  {
    if (language == french) return "(FR) A confirmation code has been sent to {email}. Please check your spam or junk folder if you don't see it.";
    return "A confirmation code has been sent to {email}. Please check your spam or junk folder if you don't see it.";
  }

  String get confirmationPhrase0014
  {
    if (language == french) return '(FR) "Your confirmation code has been resent. Please check your email."';
    return '"Your confirmation code has been resent. Please check your email."';
  }

  String get passwordResetPhrase001
  {
    if (language == french) return "(FR) A link to reset your password has been sent to {email}. Please check your spam or junk folder if you don't see it.";
    return "A link to reset your password has been sent to {email}. Please check your spam or junk folder if you don't see it.";
  }

  String get email
  {
    if (language == french) return '(FR) Email';
    return 'Email';
  }

  String get role
  {
    if (language == french) return '(FR) Roll';
    return 'Roll';
  }

  String get send
  {
    if (language == french) return '(FR) Send';
    return 'Send';
  }

  String get search
  {
    if (language == french) return '(FR) Search';
    return 'Search';
  }

  String get displayNameLength
  {
    if (language == french) return '(FR) Display name must be at least 5 characters';
    return 'Display name must be at least 5 characters';
  }

  String get notNumeric
  {
    if (language == french) return '(FR) Field must be numeric';
    return 'Field must be numeric';
  }

  String get phoneEmpty
  {
    if (language == french) return '(FR) Phone number cannot be empty';
    return 'Phone# cannot be empty';
  }

  String get phoneInvalid
  {
    if (language == french) return '(FR) Phone number is not valid. Must be include area code';
    return 'Phone# is not valid. Must be include area code';
  }

  String get readOnly
  {
    if (language == french) return '(FR) Read Only';
    return 'Read Only';
  }

  String get resend
  {
    if (language == french) return '(FR) Send Again';
    return 'Send Again';
  }

  String get passwordInvalid
  {
    if (language == french) return '(FR) Password must be at least 8 characters in length with at least 1 upper, 1 lower, 1 number and 1 special character';
    return 'Password must be at least 8 characters in length with at least 1 upper, 1 lower, 1 number and 1 special character';
  }

  String get credentialsInvalid
  {
    if (language == french) return '(FR) Invalid credentials';
    return 'Invalid credentials';
  }

  String get confirmPassword
  {
    if (language == french) return '(FR) Confirm Password';
    return 'Confirm Password';
  }

  String get confirmNewPassword
  {
    if (language == french) return '(FR) Confirm New Password';
    return 'Confirm New Password';
  }


  String get passwordMismatch
  {
    if (language == french) return "(FR) Passwords don't match";
    return "Passwords don't match";
  }


  String get signUp
  {
    if (language == french) return '(FR) Sign Up';
    return 'Sign Up';
  }

  String get enterPin
  {
    if (language == french) return '(FR) Enter the security pin sent to your email';
    return 'Enter the security pin sent to your email';
  }

  String get passwordChange
  {
    if (language == french) return '(FR) Change Password';
    return 'Change Password';
  }

  String get passwordChanged
  {
    if (language == french) return '(FR) Your password has been changed';
    return 'Your password has been changed';
  }

  String get passwordReset
  {
    if (language == french) return '(FR) Password Reset';
    return 'Password Reset';
  }

  String get passwordResetFailed
  {
    if (language == french) return '(FR) Password Reset Failed';
    return 'Password Reset Failed';
  }

  String get passwordChangeFailed
  {
    if (language == french) return '(FR) Password Change Failed';
    return 'Password Change Failed';
  }

  String get invalidCode
  {
    if (language == french) return '(FR) Invalid Code';
    return 'Invalid Code';
  }

  String get usernameInvalid
  {
    if (language == french) return '(FR) Invalid Username';
    return 'Invalid Username';
  }

  String get passwordForgotten
  {
    if (language == french) return '(FR) Forgot Password?';
    return 'Forgot Password?';
  }

  String get newUser
  {
    if (language == french) return '(FR) New?';
    return 'New?';
  }

  String get signIn
  {
    if (language == french) return '(FR) Sign in';
    return 'Sign in';
  }

  String get welcomeBack
  {
    if (language == french) return '(FR) Welcome back! Please login to continue.';
    return 'Welcome back! Please login to continue.';
  }

  String get heyThere
  {
    if (language == french) return "(FR) Hey there! Let's get started.";
    return "Hey there! Let's get started.";
  }

  String get areYouSure
  {
    if (language == french) return '(FR) Are you sure?';
    return 'Are you sure?';
  }

  String get goBack
  {
    if (language == french) return '(FR) Go back?';
    return 'Go Back?';
  }

  String get continueQuitting
  {
    if (language == french) return '(FR) Continue Quitting?';
    return 'Continue Quitting?';
  }

  String get logonFailed
  {
    if (language == french) return '(FR) Logon Failed';
    return 'Logon Failed';
  }

  String get storeFailed
  {
    if (language == french) return '(FR) App Link Failed';
    return 'App Link Failed';
  }

  String get alreadyLinked
  {
    if (language == french) return '(FR) is already linked';
    return 'is already linked';
  }

  String get alreadyInUse
  {
    if (language == french) return '(FR) already in use';
    return 'already in use';
  }

  String get saveFailed
  {
    if (language == french) return '(FR) Save Failed';
    return 'Save Failed';
  }

  String get showTemplate
  {
    if (language == french) return '(FR) Show Template';
    return 'Show Template';
  }

  String get reloadTemplate
  {
    if (language == french) return '(FR) Reload Template';
    return 'Reload Template';
  }

  String get refreshTemplates
  {
    if (language == french) return '(FR) Template Refresh On/Off';
    return 'Template Refresh On/Off';
  }

  String get debugMode
  {
    if (language == french) return '(FR) Debug Mode On/Off';
    return 'Debug Mode On/Off';
  }

  String get duplicateIds
  {
    if (language == french) return '(FR) There are duplicate ID values ({ID}) in the template';
    return '(FR) There are duplicate ID values ({ID}) in the template';
  }

  String get deleteItems
  {
    if (language == french) return '(FR) Delete Items';
    return 'Delete Items';
  }

  String get deleteItemsPhrase
  {
    if (language == french) return '(FR) Delete the {COUNT} selected items?';
    return 'Delete the {COUNT} selected items?';
  }

  String get administrationPanel
  {
    if (language == french) return '(FR) Administration Panel';
    return 'Administration Panel';
  }

  String get template
  {
    if (language == french) return '(FR) Template';
    return 'Template';
  }

  String get templateVersion
  {
    if (language == french) return '(FR) Template version';
    return 'Template version';
  }

  String get file
  {
    if (language == french) return '(FR) File';
    return 'File';
  }

  String get camera
  {
    if (language == french) return '(FR) Camera';
    return 'Camera';
  }

  String get saveLogs
  {
    if (language == french) return '(FR) Save Logs';
    return 'Save Logs';
  }

  String get rowsperpage
  {
    if (language == french) return '(FR) Rows per page';
    return 'Rows per page';
  }

  String get of
  {
    if (language == french) return '(FR) of';
    return 'of';
  }

  String get pagesize
  {
    if (language == french) return '(FR) Page size';
    return 'Page size';
  }

  String get records
  {
    if (language == french) return '(FR) Records';
    return 'Records';
  }

  String get connect {
    if (language == french) return "(FR) Connect";
    return "Connect";
  }

  String get clickToConnect {
    if (language == french) return "(FR) Click the + button to connect an application";
    return "Click the + button to connect an application";
  }

  String get connectAnApplication {
    if (language == french) return "(FR) Connect an Application";
    return "Connect an Application";
  }

  String get checkConnection
  {
    if (language == french) return '(FR) Check your connection';
    return 'Check your connection';
  }

  String get disconnected
  {
    if (language == french) return '(FR) Your network connection had been lost';
    return 'Your network connection had been lost';
  }

  String get reconnected
  {
    if (language == french) return '(FR) Your network connection has been restored';
    return 'Your network connection has been restored';
  }

  String get postmasterPhrase001
  {
    if (language == french) return '(FR) Background posting service started';
    return 'Background posting service started';
  }

  String get postmasterPhrase002
  {
    if (language == french) return '(FR) There are {jobs} pending posts';
    return 'There are {jobs} pending posts';
  }

  String get invalidFML {
    if (language == french) return '(FR) Invalid FML';
    return 'Invalid FML';
  }

  String get unableToReachServer {
    if (language == french) return '(FR) Unable to reach server';
    return 'Unable to reach server';
  }

  String get somethingWentWrong {
    if (language == french) return '(FR) Something went wrong.\n Try going back or restarting the application.\n If this problem persists please contact us.';
    return 'Something went wrong.\n Try going back or restarting the application.\n If this problem persists please contact us.';
  }
}



