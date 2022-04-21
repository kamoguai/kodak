import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/dialog/CustomerDialog.dart';
import 'package:scanner/common/widget/dialog/UploadDialog.dart';
import 'package:share_plus/share_plus.dart';

import 'ImageGridViewPage.dart';

///
///點擊圖片到此頁顯示
///Date: 2022-01-14
class DetailFileScreenPage extends StatefulWidget {
  final String tag;
  final String url;
  final List<String> urlList;
  final String? token;
  final String? aesUrl;
  final List<CheckBoxModel> ckModelList;
  const DetailFileScreenPage({
    Key? key,
    required this.tag,
    required this.url,
    this.token,
    required this.urlList,
    this.aesUrl,
    required this.ckModelList,
  }) : super(key: key);

  @override
  _DetailFileScreenPageState createState() => _DetailFileScreenPageState();
}

class _DetailFileScreenPageState extends State<DetailFileScreenPage>
    with BaseWidget {
  CheckBoxModel ckModel = CheckBoxModel();

  ///圖片滑動controller
  PageController _pageViewCtrl = PageController();

  ///圖片編輯key
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  ///初始圖片位置
  int nowPage = 0;

  ///執行share
  Future<void> _onShare(BuildContext context) async {
    ///把loading取消
    final box = context.findRenderObject() as RenderBox?;
    final List<String> urlList = [];
    if (ckModel.imageUri.isNotEmpty) {
      urlList.add(ckModel.imageUri);
      if (Platform.isAndroid) {
        await Share.shareFiles(urlList,
            text: "share files",
            subject: "share files",
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
      } else {
        await Share.shareFiles(urlList,
            text: "share files",
            subject: "share files",
            sharePositionOrigin:
                box!.localToGlobal(Offset(0.0, deviceHeight10(context) * 7)) &
                    box.size);
      }
    }
  }

  ///刪除widget
  void _deleteWidger() {
    setState(() {
      deleteTemporaryFile(ckModel.imageUri);
    });
  }

  ///刪除暫存檔
  deleteTemporaryFile(String filePath) async {
    try {
      await File(filePath).delete();
    } catch (error) {
      debugPrint('Delete TemporaryFile error');
    }
  }

  ///upload按鈕 dialog
  Widget _Dialog(BuildContext contect, title, content) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: CustomerDialog(
          title: title,
          content: content,
        ),
      )),
    );
  }

  Widget _UploadDialog(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // type: MaterialType.transparency,
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight10(context) * 3,
            horizontal: deviceWidth10(context)),
        child: UploadDialog(
          token: widget.token,
          imagePathList: [ckModel.imageUri],
        ),
      )),
    );
  }

  initData() async {
    nowPage = int.parse(widget.tag);
    ckModel = widget.ckModelList[nowPage];
    _pageViewCtrl = PageController(initialPage: nowPage);
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    initData();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Material(
            child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('static/images/bg.png'),
                        fit: BoxFit.fill)),
                child: Column(
                  children: [_appBar(), _body(), _bottomBar()],
                ))));
  }

  /// appbar
  Widget _appBar() {
    Widget w;
    w = SizedBox(
        height: deviceHeight10(context),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.only(
                          top: MyScreen.backArrowPaddingTop(context), left: 10),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ))),
              Expanded(
                  flex: 6,
                  child: Center(
                      child: Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MyScreen.homePageFontSize(context),
                      ),
                    ),
                  ))),
              Expanded(
                  flex: 2,
                  child: GestureDetector(
                      onTap: () async {
                        NavigatorUtils.goEditImage(context, ckModel.imageUri,
                            '${ckModel.val}', widget.token, widget.aesUrl);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 20),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MyScreen.defaultTableCellFontSize(context),
                          ),
                        ),
                      )))
            ]));
    return w;
  }

  Widget _body() {
    Widget w;
    String valStr = "Scan000";
    if (nowPage < 9) {
      valStr = "Scan000${nowPage + 1}";
    } else if (nowPage >= 9 && nowPage < 99) {
      valStr = "Scan00${nowPage + 1}";
    } else if (nowPage >= 99 && nowPage < 999) {
      valStr = "Scan0${nowPage + 1}";
    } else {
      valStr = "Scan${nowPage + 1}";
    }
    w = Expanded(
        child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider:
                          FileImage(File(widget.ckModelList[index].imageUri)),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.contained * 4,
                      heroAttributes: PhotoViewHeroAttributes(
                          tag: widget.ckModelList[index].val),
                    );
                  },
                  itemCount: widget.ckModelList.length,
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.white),
                  pageController: _pageViewCtrl,
                  onPageChanged: (index) {
                    setState(() {
                      nowPage = index;
                      ckModel = widget.ckModelList[nowPage];
                    });
                  },
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    valStr,
                    style: TextStyle(
                        fontSize: MyScreen.defaultTableCellFontSize(context),
                        color: Colors.blue),
                  ),
                ),
              ],
            )));

    return w;
  }

  ///bottomBar
  Widget _bottomBar() {
    Widget w;
    w = SizedBox(
      height: deviceHeight10(context),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.token!.isEmpty) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => _Dialog(
                          context, '', 'Please login to be use file upload'));
                  return;
                } else {
                  if (Platform.isAndroid) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _UploadDialog(context));
                  } else {
                    NavigatorUtils.goUploadCloud(context,
                        token: widget.token, imagePathList: [ckModel.imageUri]);
                  }
                }
              },
              child: Image.asset('static/images/ccs.png'),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                _deleteWidger();
              },
              child: Image.asset('static/images/trash.png'),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (widget.token!.isEmpty) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _Dialog(context, '', 'Please login to be use share'));
                  return;
                } else {
                  _onShare(context);
                }
              },
              child: Image.asset('static/images/Ellipse.png'),
            ),
          ),
        ],
      ),
    );
    return w;
  }
}
