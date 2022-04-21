import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_editor/image_editor.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/AesUtils.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';

///
///圖片編輯
///Date: 2022-01-19
///實際操作方法請洽：https://codertw.com/程式語言/721521/
class EditImagePage extends StatefulWidget {
  final String tag;
  final String url;
  final String? token;
  final String? aesUrl;
  const EditImagePage(
      {Key? key, required this.tag, required this.url, this.token, this.aesUrl})
      : super(key: key);

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> with BaseWidget {
  CheckBoxModel ckModel = CheckBoxModel();
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  bool isRotate = false;
  double sat = 1;
  double bright = 1;
  double con = 1;

  String imgGridPath = "";

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

  void rotateImg() async {
    editorKey.currentState?.rotate(right: false);
    setState(() {
      isRotate = true;
    });
  }

  ///編輯圖片後保存
  Future<void> saveImg() async {
    showLoadingDialog(context);

    ///取得套件狀態
    final ExtendedImageEditorState state = editorKey.currentState!;

    ///取得矩型
    final Rect? rect = state.getCropRect();

    ///取得狀態action
    final EditActionDetails action = state.editAction!;

    ///取得轉向物件
    final double radian = action.rotateAngle;

    ///將編輯過的檔案轉成byteArray
    final Uint8List? img = state.rawImageData;
    final flipHorizontal = action.flipY;
    final flipVertical = action.flipX;

    ///設定套件輸出option
    final ImageEditorOption option = ImageEditorOption();

    option.addOption(ClipOption.fromRect(rect!));
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
    if (action.hasRotateAngle) {
      option.addOption(RotateOption(radian.toInt()));
    }

    option.addOption(ColorOption.saturation(sat));
    option.addOption(ColorOption.brightness(bright));
    option.addOption(ColorOption.contrast(con));

    option.outputFormat = const OutputFormat.png(88);

    print(const JsonEncoder.withIndent('  ').convert(option.toJson()));

    final DateTime start = DateTime.now();

    ///將結果輸出byteArray
    final Uint8List? result = await ImageEditor.editImage(
      image: img!,
      imageEditorOption: option,
    );

    print('result.length = ${result?.length}');

    final Duration diff = DateTime.now().difference(start);

    print('image_editor time : $diff');
    print(ckModel.imageUri);
    String subPath = ckModel.imageUri
        .substring(0, ckModel.imageUri.lastIndexOf(Platform.pathSeparator) + 1);
    print("subPath => $subPath");
    String subFileName = ckModel.imageUri
        .substring(ckModel.imageUri.lastIndexOf(Platform.pathSeparator) + 1);
    print("subFileName => $subFileName");
    String reName = "";
    if (subFileName.contains(".tiff")) {
      reName =
          subFileName.replaceAll(".png", "").replaceAll(".tiff", "") + "a.tiff";
    } else {
      reName =
          subFileName.replaceAll(".png", "").replaceAll(".tiff", "") + "a.tiff";
    }
    String rePath = subPath + reName;

    ///刪除原本路徑檔案
    File(ckModel.imageUri).deleteSync(recursive: true);

    ///如果是aes檔案
    if (ckModel.aesUri != null && ckModel.aesUri!.isNotEmpty) {
      File(ckModel.aesUri!).deleteSync(recursive: true);
      File(rePath).writeAsBytesSync(result!);
      List<int> imgByte = [];
      for (var d in result) {
        imgByte.add(d);
      }

      /// aes加密
      var encResult = AesUtils.encryptAES(imgByte);

      /// 講檔案寫入資料夾並改名為.aes
      String p = await _writeData(encResult, rePath + '.aes');
      debugPrint("aes writing success -> $p");
    } else {
      ///file用byte寫檔
      File(rePath).writeAsBytesSync(result!);
    }

    Fluttertoast.showToast(msg: 'save success!');
    Navigator.pop(context);
    setState(() {
      imgGridPath = subPath;
      ckModel.imageUri = rePath;
    });
  }

  Future<String> _writeData(dataToWrite, fileNameWithPath) async {
    File f = File(fileNameWithPath);
    await f.writeAsBytes(dataToWrite);
    return f.absolute.toString();
  }

  initData() async {
    ckModel.imageUri = widget.url;
    ckModel.val = widget.tag;
    ckModel.isDel = true;
    ckModel.aesUri = widget.aesUrl;
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
                        onPressed: () async {
                          ///如果有旋轉
                          if (isRotate) {
                            Future.delayed(
                                const Duration(seconds: 1),
                                NavigatorUtils.goImageGridView(
                                    context, imgGridPath, true, widget.token));
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ))),
              Expanded(
                  flex: 6,
                  child: Center(
                      child: Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MyScreen.homePageFontSize(context),
                      ),
                    ),
                  ))),
              Expanded(
                  flex: 2,
                  child: GestureDetector(
                      onTap: () async {},
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 20),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          '',
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
    w = Expanded(
        child: Container(
      color: Colors.white,
      child: ExtendedImage.file(
        File(ckModel.imageUri),
        width: double.infinity,
        height: double.infinity,
        cacheRawData: true,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.editor,
        extendedImageEditorKey: editorKey,
        initEditorConfigHandler: (state) {
          return EditorConfig(
              maxScale: 8.0,
              cropRectPadding: const EdgeInsets.all(20),
              hitTestSize: 20.0);
        },
      ),
    ));

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
                onTap: () async {
                  saveImg();
                },
                child: Text(
                  'save',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MyScreen.appBarFontSize(context)),
                  textAlign: TextAlign.center,
                )),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                rotateImg();
              },
              child: Image.asset('static/images/rotate90.png'),
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
        ],
      ),
    );
    return w;
  }
}

class CheckBoxModel {
  late String val;
  late String imageUri;
  late String? aesUri;
  late bool isDel;
  CheckBoxModel();
}
