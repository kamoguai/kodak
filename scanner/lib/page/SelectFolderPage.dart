import 'package:flutter/material.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';

///
///選擇scan後資料夾
///Date: 2022-01-15
///
class SelectFolderPage extends StatefulWidget {
  final List<String> pathList;

  const SelectFolderPage({Key? key, required this.pathList}) : super(key: key);

  @override
  _SelectFolderPageState createState() => _SelectFolderPageState();
}

class _SelectFolderPageState extends State<SelectFolderPage> with BaseWidget {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: deviceHeight7(context),
      padding: const EdgeInsets.all(0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.pathList.length,
        itemBuilder: (context, index) {
          return Card(
            child: GestureDetector(
              onTap: () {
                NavigatorUtils.goImageView(context, widget.pathList[index]);
              },
              child: Column(
                children: [
                  Image(
                    width: deviceWidth5(context),
                    height: deviceWidth5(context),
                    image: const AssetImage('static/images/file.png'),
                  ),
                  Text('scan$index')
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
