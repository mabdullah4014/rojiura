import 'dart:convert';
import 'dart:ui';

import 'package:app/controller/notification_controller.dart';
import 'package:app/model/notification.dart';
import 'package:app/model/user.dart';
import 'package:app/route_generator.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/pref_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:app/utils/extensions.dart';

class NotificationListingPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  NotificationListingPage({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _NotificationListingPageState createState() =>
      _NotificationListingPageState();
}

class _NotificationListingPageState extends StateMVC<NotificationListingPage> {
  Future<List<Notif>> notificationListFuture;
  User user;

  NotificationController _con = NotificationController();

  ScrollController _scrollController = new ScrollController();

  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = User.fromJson(json.decode(PreferenceUtils.getString('user', "")));
    print(user.toJson());
    _fetchNotifications();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          currentPage++;
        });
        _fetchNotifications();
      }
    });
  }

  void _fetchNotifications() {
    setState(() {
      isLoading = true;
    });
    _con.getNotifications(
        page: currentPage,
        apiResponse: (apiResponse) {
          setState(() {
            isLoading = false;
          });
          if (apiResponse.status == 200)
            setState(() {
              List<Notif> newList = (apiResponse.data['data'] as List)
                  .map((i) => Notif.fromJson(i))
                  .toList();
              if (newList.isNullOrEmpty()) {
                if (currentPage > 1) currentPage--;
              }
              if (notificationListFuture != null) {
                notificationListFuture.then((value) {
                  if (!value.isNullOrEmpty()) {
                    List<Notif> postList = value;
                    postList.addAll(newList);
                    notificationListFuture = Future.value(postList);
                  } else
                    notificationListFuture = Future.value(newList);
                });
              } else
                notificationListFuture = Future.value(newList);
            });
        });
  }

  Future<List<Notif>> fetchStr(dynamic jsonResponse) async {
    await new Future.delayed(const Duration(seconds: 1));
    return (jsonResponse as List).map((i) => Notif.fromJson(i)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: Text(Constants.APP_NAME,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .merge(TextStyle(color: Colors.white))),
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: FutureBuilder<List<Notif>>(
                    future: notificationListFuture,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Notif>> snapshot) {
                      List<Notif> notifList = snapshot.data;
                      if (snapshot.hasData) {
                        return RefreshIndicator(
                            // ignore: missing_return
                            onRefresh: () {
                              resetValues();
                              _fetchNotifications();
                            },
                            child: Column(children: [
                              Expanded(
                                  child: ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                            color: Colors.black,
                                            thickness: 2,
                                          ),
                                      scrollDirection: Axis.vertical,
                                      itemCount: notifList.length,
                                      itemBuilder: (context, index) {
                                        return _listItem(notifList[index]);
                                      })),
                              Visibility(
                                  visible: isLoading,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                            Theme.of(context).primaryColor)),
                                  ))
                            ]));
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      // By default, show a loading spinner
                      return Center(child: CircularProgressIndicator());
                    }))));
  }

  Widget _listItem(Notif notificationObject) {
    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(RouteGenerator.DETAIL,
              arguments: notificationObject.post.id);
        },
        child: ListTile(
            trailing: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: CachedNetworkImage(
                    imageUrl: notificationObject.post.image_url,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100)),
            title: Text(notificationObject.post.desc),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 20),
              child: _timeWidget(notificationObject.created_at),
            )));
  }

  Widget _timeWidget(String createdAt) {
    return Text(Constants.getTimeAgo(createdAt), style: postTextStyle);
  }

  TextStyle postTextStyle = TextStyle(
      fontSize: 12, color: AppUtils.getColorFromHash(AppUtils.postTextColor));

  void resetValues() {
    setState(() {
      currentPage = 1;
      notificationListFuture = Future.value(null);
    });
  }
}
