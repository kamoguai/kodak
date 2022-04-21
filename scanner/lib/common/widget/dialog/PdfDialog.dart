import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:scanner/common/model/UserInfo.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/AesUtils.dart';
import 'package:scanner/common/utils/CommonUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smblib/smblib.dart';

class PdfDialog extends StatefulWidget {
  final List<String>? filePath;
  final String? nasPath;
  final String? currentPath;
  final Function? callback;
  const PdfDialog(
      {Key? key, this.filePath, this.nasPath, this.callback, this.currentPath})
      : super(key: key);

  @override
  State<PdfDialog> createState() => _PdfDialogState();
}

class _PdfDialogState extends State<PdfDialog> with BaseWidget {
  TextEditingController fContrl = TextEditingController();
  FocusNode textFocus = FocusNode();
  String folderName = '';
  List<Uint8List> imagesUint8list = [];
  final pdf = pw.Document();
  DialogType dialogTypes = DialogType.init;
  List<String> dropList = ["-Select-", "Normal", "PDF"];
  String pickStr = "-Select-";

  /// 裝載userinfo
  late UserInfo userInfo;
  RowModel rModel = RowModel();
  List<RowModel> listModel = [];

  ///紀錄nas路徑
  String _fullPostPath = "smb://";
  String _currentPath = "";

  createPdf() async {
    for (var model in listModel) {
      await getImageByte(model.loPath);
    }
    //create a list of images
    final List<pw.Widget> pdfImages = imagesUint8list.map((image) {
      return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisSize: pw.MainAxisSize.max,
              children: [
                // pw.Text(
                //     'Image'
                //             ' ' +
                //         (imagesUint8list
                //                     .indexWhere((element) => element == image) +
                //                 1)
                //             .toString(),
                //     style: const pw.TextStyle(fontSize: 22)),
                pw.SizedBox(height: 10),
                pw.Image(
                    pw.MemoryImage(
                      image,
                    ),
                    height: 700,
                    fit: pw.BoxFit.fill)
              ]));
    }).toList();

    //create PDF
    pdf.addPage(pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return <pw.Widget>[
            // pw.Column(
            //     crossAxisAlignment: pw.CrossAxisAlignment.center,
            //     mainAxisSize: pw.MainAxisSize.min,
            //     children: [
            //       pw.Text('Create a Simple PDF',
            //           textAlign: pw.TextAlign.center,
            //           style: const pw.TextStyle(fontSize: 26)),
            //       pw.Divider(),
            //     ]),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.max,
                children: pdfImages),
          ];
        }));
  }

  savePdfFile(String fileName) async {
    String sPath = listModel[0].loPath;
    String fPath = sPath.substring(0, sPath.lastIndexOf("/") + 1);
    String fullPath = fPath + fileName + ".pdf";
    File file = File(fullPath);
    file.writeAsBytesSync(await pdf.save());

    sPath = listModel[0].postPath;
    fPath = sPath.substring(0, sPath.lastIndexOf("/") + 1);
    fullPath = fPath + fileName + ".pdf";
    var res = await Smblib.UploadFile(fullPath, file.path);
    if (res == "1") {
      CommonUtils.showToast(context, msg: 'File upload success');
    } else {
      CommonUtils.showToast(context, msg: 'File upload fail ');
    }
    widget.callback!(widget.currentPath!);
    Navigator.pop(context);
  }

  getImageByte(String imagePath) async {
    final Uint8List bytesList = File(imagePath).readAsBytesSync();
    setState(() {
      imagesUint8list.add(bytesList);
    });
  }

  Future<void> fileUpload(String fileName) async {
    showLoadingDialog(context);
    int count = 0;
    String res = "";
    for (String localPath in widget.filePath!) {
      String imgFileName = localPath.substring(localPath.lastIndexOf("/") + 1);
      String loPath = "";
      if (imgFileName.contains(".aes")) {
        String filesPath =
            localPath.substring(0, localPath.lastIndexOf("/") + 1);

        /// get dir
        Directory dir = Directory(filesPath);
        List<FileSystemEntity> files = dir.listSync(recursive: true);
        for (FileSystemEntity dic in files) {
          FileStat fi = dic.statSync();
          if (fi.type.toString().contains("file")) {
            print(fi);
            if (dic.uri.path.contains('.aes')) {
              if (count == 0) {
                for (FileSystemEntity dic in files) {
                  FileStat fi = dic.statSync();
                  if (fi.type.toString().contains("file")) {
                    if (!dic.uri.path.contains('.aes')) {
                      dic.delete(recursive: true);
                    }
                  }
                  count++;
                }
              }
            }
          }
        }
        loPath = await _getNormalFile(localPath);
        String postUrl = _currentPath + imgFileName.replaceAll(".aes", "");
        rModel.loPath = loPath;
        rModel.postPath = postUrl;
        listModel.add(rModel);
        rModel = RowModel();
        if (dialogTypes == DialogType.normal) {
          res = await Smblib.UploadFile(postUrl, loPath);
          if (res == "1") {
            CommonUtils.showToast(context, msg: 'File upload success');
          } else {
            CommonUtils.showToast(context, msg: 'File upload fail ');
            return;
          }
        }
      } else {
        loPath = localPath;
        String postUrl = _currentPath + imgFileName;
        rModel.loPath = loPath;
        rModel.postPath = postUrl;
        listModel.add(rModel);
        rModel = RowModel();
        if (dialogTypes == DialogType.normal) {
          res = await Smblib.UploadFile(postUrl, loPath);
          if (res == "1") {
            CommonUtils.showToast(context, msg: 'File upload success');
          } else {
            CommonUtils.showToast(context, msg: 'File upload fail ');
            return;
          }
        }
      }
    }
    if (dialogTypes == DialogType.pdf) {
      ///執行轉pdf
      await createPdf();
      await savePdfFile(fileName);
    } else if (dialogTypes == DialogType.normal) {
      widget.callback!(widget.currentPath!);
      // Navigator.pop(context);
    }

    Navigator.pop(context);
  }

  _getNormalFile(String path) async {
    Uint8List encData = await _readData(path);
    AesUtils.aesIv = userInfo.aesIv;
    AesUtils.aesKey = userInfo.aesKey;
    var plainData = await AesUtils.decryptAES(encData);
    String reStr = (path.replaceAll('.aes', ''));
    String p = await _writeData(plainData, reStr);
    return p;
  }

  Future<Uint8List> _readData(path) async {
    File f = File(path);
    var res = f.readAsBytesSync();
    return res;
  }

  Future<String> _writeData(dataToWrite, fileNameWithPath) async {
    File f = File(fileNameWithPath);
    await f.writeAsBytes(dataToWrite);
    return f.path;
  }

  _initData() async {
    setState(() {
      _currentPath =
          widget.nasPath!.substring(0, widget.nasPath!.lastIndexOf("/") + 1);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagesUint8list = [];
    _initData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('static/images/bg.png'),
                    fit: BoxFit.fill)),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: selectorPrintType(),
                ))));
  }

  ///搜尋bar
  Widget searchDropDown() {
    Widget dropWidget;
    dropWidget = FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: Colors.grey[350],
                  icon: const Visibility(
                    visible: false,
                    child: Icon(
                      Icons.arrow_circle_down_sharp,
                      color: Colors.white,
                    ),
                  ),
                  value: pickStr,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: MyScreen.minFontSize(context)),
                  isDense: true,
                  items: dropList.map((String val) {
                    return DropdownMenuItem(
                      child: Center(
                        child: Text(
                          val,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      value: val,
                    );
                  }).toList(),
                  onChanged: (String? newVal) async {
                    String str = newVal!;
                    if (str == "Normal") {
                      setState(() {
                        dialogTypes = DialogType.normal;
                        fileUpload("");
                      });
                      Navigator.pop(context);
                    } else if (str == "PDF") {
                      setState(() {
                        dialogTypes = DialogType.pdf;
                      });
                    }
                  }),
            ));
      },
    );
    return dropWidget;
  }

  ///搜尋bar
  Widget searchTextField() {
    Widget widget;
    widget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          folderName = value;
        },
        controller: fContrl,
        focusNode: textFocus,
        decoration: const InputDecoration(
          fillColor: Colors.white,
          filled: true,
          labelText: '',
          // labelStyle: TextStyle(color: Colors.),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
        ),
      ),
    );
    return widget;
  }

  ///init
  List<Widget> initDialog() {
    List<Widget> list = [];
    list = [
      Container(
          alignment: Alignment.center,
          child: Text(
            'Output file type',
            style: TextStyle(
                fontSize: MyScreen.smallFontSize(context), color: Colors.white),
          )),
      const SizedBox(
        height: 30,
      ),
      searchDropDown(),
      const SizedBox(
        height: 30,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: GestureDetector(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('static/images/yellowBtn.png'),
                Text(
                  'cancel',
                  style: TextStyle(fontSize: MyScreen.smallFontSize(context)),
                )
              ],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          )),
        ],
      ),
    ];
    return list;
  }

  /// pdf
  List<Widget> pdfDialog() {
    List<Widget> list = [];
    list = [
      const SizedBox(
        height: 20,
      ),
      Text(
        'Transfer to PDF',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: MyScreen.smallFontSize(context), color: Colors.white),
      ),
      const SizedBox(
        height: 10,
      ),
      Text(
        'Please enter file name :',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: MyScreen.smallFontSize(context), color: Colors.white),
      ),
      const SizedBox(
        height: 20,
      ),
      searchTextField(),
      const SizedBox(
        height: 20,
      ),
      GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('static/images/yellowBtn.png'),
            Text(
              'print',
              style: TextStyle(fontSize: MyScreen.smallFontSize(context)),
            )
          ],
        ),
        onTap: () async {
          if (fContrl.value.text.isNotEmpty) {
            await fileUpload(fContrl.value.text);
          } else {
            Fluttertoast.showToast(msg: "Please enter file name");
            return;
          }
        },
      )
    ];

    return list;
  }

  List<Widget> selectorPrintType() {
    List<Widget> list = [];
    switch (dialogTypes) {
      case DialogType.init:
        return initDialog();
      case DialogType.pdf:
        return pdfDialog();
      case DialogType.normal:
        return initDialog();
    }
  }
}

class RowModel {
  late String postPath;
  late String loPath;
  RowModel();
}

enum DialogType { init, pdf, normal }
