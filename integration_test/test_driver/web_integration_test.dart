// /// Runs test in web using the chrome driver.
// ///
// /// Download chromedriver: https://chromedriver.chromium.org/downloads
// /// Place the .exe in your project folder
// /// Run this command from there:
// /// $ .\chromedriver --port=4444
// /// From the root of FML run:
// /// $ flutter drive \ --driver=integration_test/test_driver/web_integration_test.dart \ --target=integration_test/app_test.dart \ -d chrome
// /// The test can also be ran headless so a chrome instance doesn't open by replacing `chrome` with `web-server` in the command.
//
// import 'package:integration_test/integration_test_driver.dart';
//
// Future<void> main() => integrationDriver();