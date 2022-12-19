// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
class PageConfiguration
{
  String? title;

  final String? url;
  final String? transition;

  Uri? uri;

  String get breadcrumb
  {
    String text = title ?? url ?? "";
    return text.toLowerCase().split('/').last.split('.xml').first;
  }

  PageConfiguration({required this.url, String? title, this.transition})
  {
    if (url != null) this.uri = Uri.tryParse(url!);
    this.title = title;
  }
}