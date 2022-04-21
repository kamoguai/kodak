import 'package:flutter/material.dart';
import 'package:scanner/common/widget/BaseWidget.dart';

///
///tab bar共用模組
///Date: 2019-10-15
///
class MyTabBarWidget extends StatefulWidget {
  final int? type;

  final List<Widget> tabItems;

  final List<Widget> tabViews;

  final Widget? appBarActions;

  final Color? backgroundColor;

  final Color? indicatorColor;

  final Widget? title;

  final Widget? floatingActionButton;

  final TarWidgetControl? tarWidgetControl;

  final PageController? topPageControl;

  final ValueChanged<int>? onPageChanged;

  final Widget? bottomNavBarChild;

  final Widget? getBody;

  final Widget? drawer;

  const MyTabBarWidget(
      {Key? key,
      this.type,
      required this.tabItems,
      required this.tabViews,
      this.appBarActions,
      this.backgroundColor,
      this.indicatorColor,
      this.title,
      this.floatingActionButton,
      this.tarWidgetControl,
      this.topPageControl,
      this.onPageChanged,
      this.bottomNavBarChild,
      this.getBody,
      this.drawer})
      : super(key: key);

  @override
  _MyTabBarWidgetState createState() => _MyTabBarWidgetState();
}

class _MyTabBarWidgetState extends State<MyTabBarWidget>
    with BaseWidget, SingleTickerProviderStateMixin {
  late final int _type;

  late List<Widget> _tabViews;

  late Widget _appBarActions;

  late Color _indicatorColor;

  late Widget _title;

  late Widget _floatingActionButton;

  late TarWidgetControl _tarWidgetControl;

  late PageController _pageController;
  late TabController _tabController;

  late ValueChanged<int> _onPageChanged;

  late Widget _bottomNavBarChild;

  late Widget _getBody;

  late Widget _drawer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: widget.tabItems.length);
    _pageController = PageController(keepPage: false);
    _tabViews = [];
  }

  ///整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: _drawer,
      appBar: AppBar(
        backgroundColor: widget.backgroundColor,
        elevation: 0,
        title: widget.title,
        bottom: TabBar(
          controller: _tabController,
          tabs: widget.tabItems,
          // indicatorColor: _indicatorColor,
          indicator: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.white),
          labelColor: Colors.red,
          unselectedLabelColor: Colors.white,
          onTap: (index) {
            _onPageChanged.call(index);
            _pageController.jumpTo(MediaQuery.of(context).size.width * index);
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: _tabViews,
        onPageChanged: (index) {
          _tabController.animateTo(index);
          _onPageChanged.call(index);
        },
      ),
      bottomNavigationBar: widget.bottomNavBarChild,
    );
  }
}

class TarWidgetControl {
  List<Widget> footerButton = [];
}
