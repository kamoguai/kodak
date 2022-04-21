import 'dart:io';

import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/page/DetailFileSreenPage.dart';
import 'package:share_plus/share_plus.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({Key? key}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> with BaseWidget {
  ///裝head資料
  final Map<String, String> headersData = {};
  int _currentIndex = 0; //預設值
  List<CheckBoxModel> ckModelList = [];
  CheckBoxModel checkModel = CheckBoxModel();
  List<Widget> renderList = [];
  List<String> imageUriList = [];
  List<String> imgFileTime = [];

  initData() async {
    _filePath();
  }

  Widget shareBtn() {
    return FloatingActionButton(
      onPressed: () async {
        _onShare(context);
      },
      elevation: 2.0,
      heroTag: "share",
      tooltip: 'share',
      child: const Icon(Icons.share),
    );
  }

  Widget trashBtn() {
    return FloatingActionButton(
      onPressed: () async {
        _deleteWidger();
      },
      elevation: 2.0,
      heroTag: "trash",
      tooltip: 'trash',
      child: const Icon(Icons.delete_forever),
    );
  }

  ///刪除widget
  void _deleteWidger() {
    setState(() {
      if (ckModelList.isNotEmpty) {
        for (var dic in ckModelList) {
          if (dic.checked && !dic.isFavor) {
            dic.isDel = true;
            deleteTemporaryFile(dic.imageUri);
          }
        }
      }
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

  ///執行share
  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    if (ckModelList.isNotEmpty) {
      List<String> uri = [];
      for (var dic in ckModelList) {
        if (dic.checked) {
          uri.add(dic.imageUri);
        }
      }
      if (uri.isNotEmpty) {
        if (Platform.isAndroid) {
          await Share.shareFiles(uri,
              text: "share image",
              subject: "share image",
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
        } else {
          await Share.shareFiles(uri,
              text: "share image",
              subject: "share image",
              sharePositionOrigin:
                  box!.localToGlobal(const Offset(0.0, kToolbarHeight * 3)) &
                      box.size);
        }
      }
    }
  }

  _filePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    var folderPath = appDir.path + Platform.pathSeparator + "ScanDir";

    Directory dir = Directory(folderPath);
    bool isExsit = dir.existsSync();
    if (isExsit) {
      List<FileSystemEntity> files = dir.listSync(recursive: true);

      for (FileSystemEntity dic in files) {
        print(dic.absolute);
        FileStat fi = dic.statSync();
        imgFileTime.add(fi.changed.toString().substring(0, 16));
        if (fi.type.toString().contains("file")) {
          imageUriList.add(dic.uri.path);
        }

        print(imageUriList);
      }
    }
    getImgMetaData(imageUriList, imgFileTime);
  }

  ///呼叫api取得metaData
  void getImgMetaData(uriList, timeList) async {
    for (var i = 0; i < uriList.length; i++) {
      setState(() {
        checkModel.val = i;
        checkModel.checked = false;
        checkModel.imageUri = uriList[i];
        checkModel.date = timeList[i];
        checkModel.isDel = false;
        checkModel.isFavor = false;
        ckModelList.add(checkModel);
        checkModel = CheckBoxModel();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///gen grid圖片
    List<Widget> gridWidget2() {
      List<Widget> list = [];
      for (var dic in ckModelList) {
        if (!dic.isDel) {
          list.add(Card(
            key: ValueKey(dic.val),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return DetailFileScreenPage(
                      tag: '${dic.val}',
                      url: dic.imageUri,
                      urlList: imageUriList,
                      ckModelList: [],
                    );
                  }));
                },
                child: Hero(
                    tag: dic.val,
                    child: Container(

                        // color: Colors.grey,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: FileImage(
                              File(dic.imageUri),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                dic.date,
                                style: TextStyle(
                                    fontSize: MyScreen.defaultTableCellFontSize(
                                        context),
                                    color: Colors.blue),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                dic.isFavor
                                    ? Expanded(
                                        child: Container(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Transform.scale(
                                              child: const Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                              ),
                                              scale: 1.5,
                                            )))
                                    : const Expanded(child: SizedBox()),
                                Expanded(
                                    child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Transform.scale(
                                            scale: 2.0,
                                            child: Checkbox(
                                                value: dic.checked,
                                                onChanged: (val) {
                                                  setState(() {
                                                    dic.checked = val!;
                                                  });
                                                })))),
                              ],
                            ),
                          ],
                        )))),
          ));
        }
      }

      return list;
    }

    ///Scaffold's body widget
    Widget _body() {
      var size = MediaQuery.of(context).size;
      final double itemHeight = (size.height - kToolbarHeight * 3) / 2;
      final double itemWidth = size.width / 2;
      Widget body;
      if (ckModelList.isEmpty || isLoading) {
        body = Container(
          color: Colors.grey,
        );
      } else {
        body = Scaffold(
            body: Container(
                color: Colors.grey,
                child: ReorderableGridView.count(
                  childAspectRatio: (itemWidth / itemHeight),
                  crossAxisCount: 2,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      Widget element = gridWidget2().removeAt(oldIndex);
                      gridWidget2().insert(newIndex, element);
                      CheckBoxModel model = ckModelList.removeAt(oldIndex);
                      ckModelList.insert(newIndex, model);
                    });
                  },
                  children: gridWidget2(),
                )),
            floatingActionButton: AnimatedFloatingActionButton(
              colorEndAnimation: Colors.red,
              colorStartAnimation: Colors.blue,
              animatedIconData: AnimatedIcons.menu_arrow,
              fabButtons: [shareBtn(), trashBtn()],
            ));
      }

      return body;
    }

    return _body();
  }
}

class CheckBoxModel {
  late int val;
  late bool checked;
  late String imageUri;
  late String date;
  late bool isDel;
  late bool isFavor;
  CheckBoxModel();
}
