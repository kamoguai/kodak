import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

///
///點擊圖片到此頁顯示
///Date: 2022-01-14
class DetailNetScreenPage extends StatefulWidget {
  final String tag;
  final String url;

  const DetailNetScreenPage({Key? key, required this.tag, required this.url})
      : super(key: key);

  @override
  _DetailNetScreenPageState createState() => _DetailNetScreenPageState();
}

class _DetailNetScreenPageState extends State<DetailNetScreenPage> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: widget.tag,
            child: CachedNetworkImage(
              imageUrl: widget.url,
              placeholder: (context, url) => Center(
                  child: Container(
                      width: 32,
                      height: 32,
                      child: const CircularProgressIndicator())),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
