import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quilt/src/DashbaordWidget.dart';
import 'package:quilt/src/PrefUtils.dart';

import '../../main.dart';


Color appColorBlack = Colors.black;
Color appColorGrey = Colors.grey[600]!;
Color selectedTabColor = Color(0xff192c96);

 bool? isShowBottom = true;
 String currentRouteName = HomeWidgetRoutes.DashboardWidget;

class _HomeWidgetStateProvider extends InheritedWidget {
  final HomeWidgetState? state;

  _HomeWidgetStateProvider({this.state, child}) : super(child: child);

  @override
  bool updateShouldNotify(_HomeWidgetStateProvider old) => false;
}

class MainContainerWidget extends StatefulWidget {
  @override
  HomeWidgetState createState() => HomeWidgetState();
}

class HomeWidgetState extends State<MainContainerWidget>
    with TickerProviderStateMixin {
  static HomeWidgetState? of(BuildContext context) {
    return (context
                .dependOnInheritedWidgetOfExactType<_HomeWidgetStateProvider>()
            as _HomeWidgetStateProvider)
        .state;
  }
  int _currentIndex=0;
  static int viewPos = 0;
  static bool isBack = false;
  static final navKey = GlobalKey<NavigatorState>();

  final String initialRouteName = "screen1";

  get isInitialRoute => currentRouteName == initialRouteName;


  Future<bool> onBackPress() async {

    isBack = false;
    if (!navKey.currentState!.canPop()) {
      return true;
    }
    navKey.currentState!.pop();
    updateRouteName();
    return false;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  void updateRouteName() {
    /// Check current route with popUntil callback function
    navKey.currentState!.popUntil((route) {
      final String? routeName = route.settings.name;
      log("routeName1");
      log(routeName.toString());
      log(viewPos.toString());
      if(routeName==HomeWidgetRoutes.FavoriteWidget||routeName==HomeWidgetRoutes.DashboardWidget||routeName=="/"||routeName==null){
        isShowBottom=true;
      }else{
        isShowBottom=false;
      }
      if(routeName=="/"||routeName==null||routeName==HomeWidgetRoutes.DashboardWidget){
        _currentIndex=0;
        print("_currentIndex");
        print(_currentIndex);
        PreferenceUtils.setInt("currentTap", _currentIndex);
        setState(() {});
      }
      navKey.currentState!.setState(() {
        currentRouteName = routeName==null?"/":routeName;
      });

      /// Return true to not pop
      return true;
    });
  }

  @override
  void didUpdateWidget(covariant MainContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(oldWidget);
    print("oldWidget111");
  }

  @override
  Widget build(BuildContext context) {
   HomeObserver routeObserver = HomeObserver(updateRoutes);

  return _HomeWidgetStateProvider(
      state: this,
      child: WillPopScope(child: Scaffold(backgroundColor: Colors.black,
          body: MaterialApp(
            navigatorKey: navKey,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: Colors.white,
            ),
            home: DashboardWidget(),
            onGenerateRoute: onGenerateRoute,navigatorObservers: [routeObserver],
          ),
          bottomNavigationBar: isShowBottom!
              ? Container(
            height: Platform.isIOS?95:80,padding: EdgeInsets.only(bottom: Platform.isIOS?10:0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(0))),
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(child: Container(child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
                        Container(decoration:  _currentIndex==0?BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 8,
                            ),
                          ],
                        ):null,
                          child: SvgPicture.asset(
                              _currentIndex==0?"assets/images/house.svg":"assets/images/home_unselect.svg",
                              semanticsLabel: 'Acme Logo'),
                        ),
                        Container(margin: EdgeInsets.only(top: 5),child: Text("Home",style: TextStyle(color:  _currentIndex==0?Color(0xffDA328D):Color(0xff888888),fontFamily: "Causten-Medium"),),)
                      ],),margin: EdgeInsets.only(right: 50),),onTap: (){
                        _onTabTapped(0);
                      },),
                      InkWell(child: Container(child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
                        Container(decoration:  _currentIndex==1?BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 8,
                            ),
                          ],
                        ):null,
                          child: SvgPicture.asset(
                              _currentIndex==1? "assets/images/bookmark_selected.svg":"assets/images/BookmarkSimple.svg",
                              semanticsLabel: 'Acme Logo',color: _currentIndex==1?Color(0xffDA328D):null),
                        ),
                        Container(margin: EdgeInsets.only(top: 5),child: Text("Favorites",style: TextStyle(color: _currentIndex==1?Color(0xffDA328D):Color(0xff888888),fontFamily: "Causten-Medium"),),)
                      ],),margin: EdgeInsets.only(right: 0),),onTap: (){
                        _onTabTapped(1);
                      },),
                      /*InkWell(child: Container(child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
                        Container(decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [

                          ],
                        ),
                          child: SvgPicture.asset(
                              "assets/images/User1.svg",
                              semanticsLabel: 'Acme Logo'),
                        ),
                        Container(margin: EdgeInsets.only(top: 5),child: Text("Profile",style: TextStyle(color: _currentIndex==2?Color(0xffDA328D):Color(0xff888888),fontFamily: "Causten-Medium"),),)
                      ],),margin: EdgeInsets.only(right: 0),),onTap: (){
                      },),*/

                    ],
                  ),
                )
              ],
            ),
            alignment: Alignment.bottomCenter,
          )
              : null), onWillPop: onBackPress),
    );
  }
  void _onTabTapped(int index) {
    PreferenceUtils.setInt("currentTap", index);
    if(_currentIndex!=index){
      setState(() {
        _currentIndex = index;
        currentTab=index;
      });
      if(_currentIndex==1){
        navKey.currentState!.pushNamed(HomeWidgetRoutes.FavoriteWidget);
      }else{
        for(int i=0;i<5;i++){
          if(!navKey.currentState!.canPop()){
            break;
          }
          navKey.currentState!.pop();
          updateRouteName();
        }
      }
    }

  }
  updateRoutes(bool? isShow,String routeName){
    isShowBottom=isShow;
    currentRouteName=routeName;
    if((routeName=="/")||(routeName==HomeWidgetRoutes.DashboardWidget)||(routeName==null)){
      _currentIndex=0;
    }
    PreferenceUtils.setInt("currentTap", _currentIndex);
    setState(() {

    });
  }
  Route onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    print(routeName);
    print("routeName");
    print(routeName);
    final Widget nextWidget = routes[routeName]!;
    if(routeName==HomeWidgetRoutes.FavoriteWidget||routeName==HomeWidgetRoutes.DashboardWidget||routeName==null){
      isShowBottom=true;
    }else{
      isShowBottom=false;
    }
    setState(() {
      currentRouteName = routeName!;
    });
    return CupertinoPageRoute( builder: (context) => nextWidget,
      settings: settings,)/*MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => nextWidget,
    )*/;
  }

}

class HomeObserver extends RouteObserver<PageRoute<dynamic>> {
   final Function(bool? isShowBottom,String currentRouteName) updateRoutes;
   HomeObserver( this.updateRoutes);
  @override
  void didPop(Route route, Route? previousRoute) {
    print("didPop1");
    routeName=previousRoute?.settings.name;
    print("routeName");
    print(routeName);

    if((routeName==HomeWidgetRoutes.FavoriteWidget)||(routeName=="/")||(routeName==HomeWidgetRoutes.DashboardWidget)||(routeName==null)){
      isShowBottom=true;
    }else{
      isShowBottom=false;
    }

    currentRouteName = routeName==null?"/":routeName!;
    updateRoutes(isShowBottom,currentRouteName);
    super.didPop(route, previousRoute);
  }
}
