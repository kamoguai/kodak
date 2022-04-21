import 'package:flutter/material.dart';
import 'package:scanner/common/style/MyStyle.dart';

///
///自定義dialog信息
///Date: 2022-01-21
///
class CustomerDialog extends StatelessWidget {
  final String? title;
  final String? content;
  const CustomerDialog({Key? key, this.title, this.content}) : super(key: key);

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
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        child: Text(
                          title ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize:
                                  MyScreen.defaultTableCellFontSize(context),
                              color: Colors.white),
                        )),
                    Text(
                      content ?? '',
                      style: TextStyle(
                          fontSize: MyScreen.appBarFontSize(context),
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: GestureDetector(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset('static/images/yellowBtn.png'),
                                  Text(
                                    'ok',
                                    style: TextStyle(
                                        fontSize:
                                            MyScreen.defaultTableCellFontSize(
                                                context)),
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
