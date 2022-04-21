import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scanner/common/config/Config.dart';
import 'package:scanner/common/local/LocalStorage.dart';
import 'package:scanner/common/redux/SysState.dart';
import 'package:scanner/common/style/MyStyle.dart';
import 'package:scanner/common/utils/NavigatorUtils.dart';
import 'package:scanner/common/widget/BaseWidget.dart';
import 'package:scanner/common/widget/MyTabBarWidget.dart';
import 'package:scanner/page/tabPage/FunctionPage.dart';
import 'package:scanner/page/tabPage/ViewPage.dart';

///
///Date: 2022-01-08
///首頁
///
class HomePage extends StatefulWidget {
  static const String sName = "home";
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with BaseWidget, SingleTickerProviderStateMixin {
  final TarWidgetControl tabBarContrl = TarWidgetControl();
  late TabController _tabContrl;

  String deviceHostName = '';

  ///渲染 Tab 的 Item
  List<Tab> renderTabItem() {
    var itemList = ["Scanners", "Document"];
    renderItem(String item, int i) {
      return Tab(
        child: Text(
          item,
          style: TextStyle(fontSize: MyScreen.homePageFontSize(context)),
          maxLines: 1,
        ),
      );
    }

    List<Tab> list = [];
    for (int i = 0; i < itemList.length; i++) {
      list.add(renderItem(itemList[i], i));
    }
    return list;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initData();
  }

  initData() async {
    _tabContrl = TabController(length: 2, vsync: this);
    deviceHostName = await LocalStorage.get(Config.devices) ?? '';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<SysState>(builder: (context, store) {
      return SafeArea(
          top: false,
          child: Scaffold(
            body: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image(
                          image: const AssetImage('static/images/icon.jpg'),
                          fit: BoxFit.fill,
                          width: deviceWidth3(context),
                          height: kToolbarHeight,
                        ),
                      ),
                      onTap: () {
                        // this._changeTaped();
                        NavigatorUtils.goLogin(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 1,
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                      child: DefaultTabController(
                          length: 2,
                          child: Scaffold(
                              appBar: AppBar(
                                elevation: 1.0,
                                backgroundColor: Colors.white,
                                title: TabBar(
                                    indicatorWeight: 2,
                                    indicatorColor: Colors.blue,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    labelColor: Colors.blue,
                                    tabs: renderTabItem()
                                    // controller: _tabContrl,
                                    ),
                              ),
                              body: TabBarView(
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    FunctionPage(
                                      deviceHostName: deviceHostName,
                                    ),
                                    const ViewPage()
                                  ]))))
                ],
              ),
            ),
          ));
    });
  }
}
