import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quilt/src/DashbaordWidget.dart';
import 'package:quilt/src/favorite/FavoriteWidget.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  final _navigatorKey = GlobalKey<NavigatorState>();

  List<Widget> _pages = [
    DashboardWidget(key: PageStorageKey('DashboardWidget'),),
    FavoriteWidget(key: PageStorageKey('Favorites'),),
    Container()
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      currentTab=index;
    });
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Set the status bar color to black once the animation is completed
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black, // Background color of status bar
      statusBarIconBrightness: Brightness.light, // Icon brightness for Android
      statusBarBrightness: Brightness.dark, // Icon brightness for iOS
    ));
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(backgroundColor: Colors.black,
      body:Navigator(
        key: _navigatorKey,
        initialRoute: HomeWidgetRoutes.DashboardWidget,
        onGenerateRoute: onGenerateRoute,
      ),/*IndexedStack(index: _currentIndex,children: [
        DashboardWidget(),
        FavoriteWidget()
      ],)*/
      bottomNavigationBar: Container(
        height: 45,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(0))),
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(

                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(child: Container(
                    child: SvgPicture.asset(
                        _currentIndex==0?"assets/images/house.svg":"assets/images/home_unselect.svg",
                        semanticsLabel: 'Acme Logo'),margin: EdgeInsets.only(right: 50),
                  ),onTap: (){
                    _onTabTapped(0);
                  },),
                  InkWell(child: Container(
                      child: SvgPicture.asset(
                          _currentIndex==1? "assets/images/bookmark_selected.svg":"assets/images/BookmarkSimple.svg",
                          semanticsLabel: 'Acme Logo'),margin: EdgeInsets.only(right: 50)
                  ),onTap: (){
                    _onTabTapped(1);
                  },),
                  Container(
                    child: SvgPicture.asset(
                        "assets/images/User1.svg",
                        semanticsLabel: 'Acme Logo'),
                  ),
                ],
              ),
            )
          ],
        ),
        alignment: Alignment.bottomCenter,
      ),
    ));
  }
  Route onGenerateRoute(RouteSettings settings) {
    final String? route= settings.name;
    print("routeName");
    print(route);
    routeName=route;
    final Widget nextWidget = routes[routeName]!;
    return CupertinoPageRoute( builder: (context) => nextWidget,
      settings: settings,);
  }
}