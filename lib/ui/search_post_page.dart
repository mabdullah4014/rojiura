import 'dart:async';

import 'package:app/controller/data_controller.dart';
import 'package:app/generated/l10n.dart';
import 'package:app/model/post_object.dart';
import 'package:app/ui/grid_item.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/custom_widgets.dart';
import 'package:app/utils/debouncer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:app/utils/extensions.dart';

import '../route_generator.dart';

class SearchPostPage extends StatefulWidget {
  final Function(int index) onTabSelected;

  SearchPostPage(this.onTabSelected);

  @override
  _SearchPostPageState createState() => _SearchPostPageState();
}

class _SearchPostPageState extends StateMVC<SearchPostPage> {
  TextEditingController editingController = TextEditingController();
  DataController _con = DataController();
  Future<dynamic> postsListFuture;

  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    postsListFuture = Future.value(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: Text(Constants.APP_NAME,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .merge(TextStyle(color: Colors.white))),
        ),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 14,
            unselectedFontSize: 14,
            showSelectedLabels: true,
            backgroundColor: AppUtils.getColorFromHash(AppUtils.darkGreyColor),
            unselectedItemColor:
                AppUtils.getColorFromHash(AppUtils.lightGreyColor),
            selectedItemColor: Colors.white,
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
            ]),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Container(
          height: double.infinity,
          color: AppUtils.getColorFromHash(AppUtils.lightGreyColor),
          padding: EdgeInsets.all(10),
          child: Column(children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(0),
                child: TextField(
                    onChanged: _filter,
                    controller: editingController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: S.of(context).search,
                        fillColor: Colors.white))),
            SizedBox(height: 10),
            FutureBuilder<dynamic>(
                future: postsListFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == 0) {
                      return SizedBox(height: 10);
                    } else if (snapshot.data == 1) {
                      return Center(
                          child: Text(S.of(context).no_posts,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15)));
                    } else {
                      List<Post> postsList = snapshot.data;
                      return Expanded(
                          child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 10,
                              scrollDirection: Axis.vertical,
                              children:
                                  List.generate(postsList.length, (index) {
                                return GridItem(
                                    post: postsList[index],
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          RouteGenerator.DETAIL,
                                          arguments: postsList[index].id);
                                    });
                              })));
                    }
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text("${snapshot.error}",
                            style: TextStyle(color: Colors.white)));
                  }
                  return Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)));
                })
          ]),
        )));
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.onTabSelected(tabItem);
      Navigator.of(context).pop();
    });
  }

  _filter(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      _debouncer.run(() {
        setState(() {
          postsListFuture = Future.value(null);
        });
        _con.searchPost(searchQuery, apiResponse: (response) {
          if (response.status == 200) {
            setState(() {
              List<Post> list =
                  (response.data as List).map((i) => Post.fromJson(i)).toList();
              if (list.isNullOrEmpty())
                postsListFuture = Future.value(1);
              else {
                postsListFuture = Future.value(list);
              }
            });
          }
        });
      });
    } else {
      setState(() {
        postsListFuture = Future.value(null);
      });
    }
  }
}
