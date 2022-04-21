import 'package:flutter/material.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';

///
///上傳檔案dialog
///Date: 2022-01-11
class UploadDialog extends StatefulWidget {
  final String? token;
  final List<String>? imagePathList;
  final List<String>? imagePathAESList;
  const UploadDialog(
      {Key? key, this.token, this.imagePathList, this.imagePathAESList})
      : super(key: key);

  @override
  _UploadDialogState createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> with BaseWidget {
  List<String> dropList = ["-Select-", "Network Shared Folder", "Cloud"];
  String pickStr = "-Select-";

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
                  onChanged: (String? newVal) {
                    String str = newVal!;
                    if (str == "Cloud") {
                      Navigator.pop(context);
                      NavigatorUtils.goUploadCloud(context,
                          token: widget.token,
                          imagePathList: widget.imagePathList,
                          imagePathAESList: widget.imagePathAESList);
                    } else if (str == "Network Shared Folder") {
                      Navigator.pop(context);
                      NavigatorUtils.goUploadNas(context,
                          token: widget.token,
                          imagePathList: widget.imagePathList,
                          isCanUpload: true);
                    }
                  }),
            ));
      },
    );
    return dropWidget;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dropList = ["-Select-", "Network Shared Folder", "Cloud"];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dropList.clear();
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
                  children: [
                    Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Output Destinations',
                          style: TextStyle(
                              fontSize: MyScreen.smallFontSize(context),
                              color: Colors.white),
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
                                style: TextStyle(
                                    fontSize: MyScreen.smallFontSize(context)),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )),
                      ],
                    ),
                  ],
                ))));
  }
}
