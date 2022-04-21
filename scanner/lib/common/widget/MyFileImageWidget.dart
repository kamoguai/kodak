import 'package:flutter/material.dart';

class MyFileImageWidget extends StatefulWidget {
  final ImageProvider provider;
  const MyFileImageWidget({Key? key, required this.provider}) : super(key: key);

  @override
  _MyFileImageWidgetState createState() => _MyFileImageWidgetState();
}

class _MyFileImageWidgetState extends State<MyFileImageWidget> {
  late ImageStream _imageStream;
  late ImageInfo _imageInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 依赖改变时，图片的配置信息可能会发生改变
    _getImage();
  }

  @override
  void didUpdateWidget(MyFileImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider != oldWidget.provider) _getImage();
  }

  void _getImage() {
    final ImageStream oldImageStream = _imageStream;
    // 调用imageProvider.resolve方法，获得ImageStream。
    _imageStream =
        widget.provider.resolve(createLocalImageConfiguration(context));
    //判断新旧ImageStream是否相同，如果不同，则需要调整流的监听器
    if (_imageStream.key != oldImageStream.key) {
      final ImageStreamListener listener = ImageStreamListener(_updateImage);
      oldImageStream.removeListener(listener);
      _imageStream.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      // Trigger a build whenever the image changes.
      _imageInfo = imageInfo;
    });
  }

  @override
  void dispose() {
    _imageStream.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: _imageInfo.image, // this is a dart:ui Image object
      scale: _imageInfo.scale,
    );
  }
}
