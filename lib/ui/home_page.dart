import 'package:app/generated/l10n.dart';
import 'package:app/ui/create_post_page.dart';
import 'package:app/ui/notification_listing.dart';
import 'package:app/ui/topics_post_page.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  int currentTab;
  Widget currentPage = TopicsPostPage();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  HomePage({Key key, this.currentTab}) {
    currentTab = currentTab != null ? currentTab : 0;
  }

  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Constants.listenToNotification(context);
    _selectTab(widget.currentTab);
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = TopicsPostPage(
              parentScaffoldKey: widget.scaffoldKey,
              onTabSelected: (tabIndex) {
                _selectTab(tabIndex);
              });
          break;
        case 1:
          widget.currentPage =
              NotificationListingPage(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 2:
          widget.currentPage =
              CreatePostPage(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
            key: widget.scaffoldKey,
            body: SafeArea(child: widget.currentPage),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 14,
                unselectedFontSize: 14,
                showSelectedLabels: true,
                backgroundColor:
                    AppUtils.getColorFromHash(AppUtils.darkGreyColor),
                unselectedItemColor:
                    AppUtils.getColorFromHash(AppUtils.lightGreyColor),
                selectedItemColor: Colors.white,
                currentIndex: widget.currentTab,
                onTap: (int i) {
                  this._selectTab(i);
                },
                // this will be set when a new tab is tapped
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.stream),
                      label: S.of(context).post),
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.bell),
                      label: S.of(context).notification),
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.plusCircle),
                      label: S.of(context).add)
                ])));
  }
}
