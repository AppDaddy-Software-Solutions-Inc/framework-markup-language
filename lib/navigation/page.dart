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

  PageConfiguration({required this.url, this.title, this.transition})
  {
    if (url != null) uri = Uri.tryParse(url!);
  }
}