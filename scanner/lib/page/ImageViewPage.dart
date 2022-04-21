import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/dialog/UploadDialog.dart';
import 'package:scanner/page/DetailFileSreenPage.dart';
import 'package:share_plus/share_plus.dart';

///
///圖片顯示頁面
///Date: 2022-01-11
class ImageViewPage extends StatefulWidget {
  final String filePath;

  const ImageViewPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> with BaseWidget {
  int _currentIndex = 0; //預設值
  List<CheckBoxModel> ckModelList = [];
  CheckBoxModel checkModel = CheckBoxModel();
  List<Widget> renderList = [];
  List<String> imageUriList = [];
  List<String> imgFileTime = [];

  initData() async {
    ///將前一頁的sessionId帶入headers
    _filePath();
  }

  _filePath() async {
    Directory dir = Directory(widget.filePath);
    List<FileSystemEntity> files = dir.listSync(recursive: true);

    for (FileSystemEntity dic in files) {
      print(dic.absolute);
      FileStat fi = dic.statSync();
      imgFileTime.add(fi.changed.toString().substring(0, 16));
      if (fi.type.toString().contains("file")) {
        imageUriList.add(dic.uri.path);
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
        checkModel.docDirUri = "";
        ckModelList.add(checkModel);
        checkModel = CheckBoxModel();
      });
    }
  }

  //BottomNavigationBar 按下處理事件，更新設定當下索引值
  void _onItemClick(int index) {
    setState(() {
      _currentIndex = index;
      switch (_currentIndex) {
        case 0:
          showDialog(
              context: context,
              builder: (BuildContext context) => _uploadDialog(context));
          break;
        case 1:
          _addFavor();
          return;
        case 2:
          _deleteWidger();
          break;
      }
    });
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

  //加入最愛
  void _addFavor() {
    setState(() {
      if (ckModelList.isNotEmpty) {
        for (var dic in ckModelList) {
          if (dic.checked && !dic.isFavor) {
            dic.isFavor = true;
            saveDocDir(dic);
          } else if (dic.checked && dic.isFavor) {
            dic.isFavor = false;
            deleteDocDir(dic);
          }
        }
      }
    });
  }

  ///upload按鈕 dialog
  Widget _uploadDialog(BuildContext contect) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        margin: EdgeInsets.symmetric(
            vertical: deviceHeight4(context),
            horizontal: deviceWidth10(context)),
        child: const UploadDialog(),
      ),
    );
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
        await Share.shareFiles(uri,
            text: "share image",
            subject: "share image",
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
      }
    }
  }

  ///寫到落地檔暫存
  Future<void> saveDocDir(CheckBoxModel model) async {
    // showLoadingDialog(context);

    ///取得暫存位址
    final appDir = await getApplicationDocumentsDirectory();

    ///暫存位址添加folder
    var folderPath = appDir.path + Platform.pathSeparator + "ScanDir";

    ///判斷是否有此folder，沒有就創建
    if (!Directory(folderPath).existsSync()) {
      Directory(folderPath).createSync();
    } else {
      ///先刪除
      // Directory(folderPath).deleteSync();

      ///後建立
      // Directory(folderPath).createSync();
    }

    ///取得內部資料
    var ls = await LocalStorage.get(Config.imgDocDir);
    if (ls != null) {
      ///有資料就移除
      await LocalStorage.remove(Config.imgDocDir);
    }

    ///保存內部資料
    await LocalStorage.save(Config.imgDocDir, folderPath);
    File l = File(model.imageUri);
    print(l.stat());
    String fileName = model.imageUri.split(Platform.pathSeparator).last;
    File newL = l.copySync(folderPath + Platform.pathSeparator + fileName);
    model.docDirUri = folderPath + Platform.pathSeparator + fileName;
    // Navigator.pop(context);
  }

  ///刪除最愛檔案
  Future<void> deleteDocDir(CheckBoxModel model) async {
    File l = File(model.docDirUri);
    l.deleteSync(recursive: true);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    initData();
  }

  @override
  void dispose() {
    ckModelList.clear();
    imageUriList.clear();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
                                'Scan ${dic.val}',
                                style: TextStyle(
                                    fontSize: MyScreen.defaultTableCellFontSize(
                                        context),
                                    color: Colors.blue),
                              ),
                            ),
                            // Container(
                            //   alignment: Alignment.centerLeft,
                            //   padding: const EdgeInsets.only(left: 10),
                            //   child: Text(
                            //     dic.date,
                            //     style: TextStyle(
                            //         fontSize: MyScreen.defaultTableCellFontSize(
                            //             context),
                            //         color: Colors.blue),
                            //   ),
                            // ),
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
        body = Expanded(
            child: Container(
          width: double.infinity,
          color: Colors.white,
          child: showLoadingAnime(context),
        ));
      } else {
        body = Container(
            color: Colors.grey,
            child: ReorderableGridView.count(
              childAspectRatio: (itemWidth / itemHeight),
              crossAxisCount: 2,
              onReorder: (int oldIndex, int newIndex) {
                print('old -> $oldIndex');
                print('new -> $newIndex');
                setState(() {
                  // Widget element = gridWidget2().removeAt(oldIndex);
                  // gridWidget2().insert(newIndex, element);
                  CheckBoxModel oldM = ckModelList[oldIndex];
                  CheckBoxModel newM = ckModelList[newIndex];
                  int oVal = oldM.val;
                  int nVal = newM.val;
                  oldM.val = nVal;
                  newM.val = oVal;
                  CheckBoxModel model = ckModelList.removeAt(oldIndex);
                  ckModelList.insert(newIndex, model);
                });
              },
              children: gridWidget2(),
            ));
      }

      return body;
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: const AssetImage('static/images/icon.jpg'),
                fit: BoxFit.fill,
                width: deviceWidth3(context),
                height: kToolbarHeight,
              ),
            ],
          ),
          actions: [
            Builder(builder: (BuildContext context) {
              return IconButton(
                onPressed: () async {
                  _onShare(context);
                },
                icon: const Icon(Icons.share),
                color: Colors.white,
              );
            }),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
              color: Colors.white,
            ),
          ],
        ),
        body: _body(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          elevation: 2,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.cloud_upload,
                  size: kToolbarHeight / 1.7,
                ),
                label: 'upload'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite,
                  size: kToolbarHeight / 1.7,
                ),
                label: 'favorite'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.delete_outline,
                  size: kToolbarHeight / 1.7,
                ),
                label: 'trash'),
          ],
          currentIndex: _currentIndex,
          onTap: _onItemClick,
        ),
      ),
    );
  }
}

class CheckBoxModel {
  late int val;
  late bool checked;
  late String imageUri;
  late String date;
  late bool isDel;
  late bool isFavor;
  late String docDirUri;
  CheckBoxModel();
}
