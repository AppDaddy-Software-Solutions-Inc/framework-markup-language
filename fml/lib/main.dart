import 'package:fml/fml.dart';
void main()
{
  String domain = 'https://test.appdaddy.co';
  // String domain = 'http://10.69.4.245:81';
  // String domain = 'http://10.67.130.75:8081';
  // String domain = 'http://10.69.4.149:81';
  // String domain = 'http://hbrapsweb.goodyear.com:8081';
  // String domain = 'http://ludapsweb.ec.goodyear.com:8081';
  // String domain = 'http://tpkapsweb.tpk.goodyear.com:8081';

  // launch the FML engine
  FmlEngine(domain: domain, type: ApplicationTypes.multiApp, title: "Flutter Markup Language V3.0.0", version: "3.0.0").launch();
}