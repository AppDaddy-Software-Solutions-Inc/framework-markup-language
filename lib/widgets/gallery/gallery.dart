// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryScreen extends StatefulWidget
{
  final List<String> files;
  final String startFile;
  GalleryScreen(this.files, this.startFile);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
{
  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(body: GalleryWidget(widget.files, widget.startFile));
  }
}

class GalleryWidget extends StatefulWidget
{
  final List<String> files;
  final String startFile;

  GalleryWidget(this.files, this.startFile);

  @override
  State createState() => GalleryWidgetState();
}

class GalleryWidgetState extends State<GalleryWidget>
{
  PageController? pager;
  int currentIndex = 0;

  @override
  initState()
  {
    super.initState();
    if ((widget.files.contains(widget.startFile))) currentIndex = widget.files.indexOf(widget.startFile);
    pager = PageController(initialPage: currentIndex);
  }

  void onPageChanged(int index)
  {
    // int i = 0;
    setState(() {currentIndex = index;});
  }

  @override
  Widget build(BuildContext context)
  {
    return PhotoViewGallery.builder(builder: builder as PhotoViewGalleryPageOptions Function(BuildContext, int)?, itemCount: widget.files.length, pageController: pager, onPageChanged: onPageChanged, backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.shadow.withOpacity(0.75)));
  }

  PhotoViewGalleryPageOptions? builder (BuildContext context, int index)
  {
    if (index < widget.files.length)
    {
      String file = widget.files[index];
      if (file.trim().startsWith("data:"))
      {
        UriData uri = UriData.parse(file);
        file = uri.contentText;
      }
      return PhotoViewGalleryPageOptions(imageProvider: MemoryImage(Base64Codec().decode(file)), initialScale: 1.5);
    }
    return null;
  }
}