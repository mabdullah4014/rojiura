import 'dart:ui';

import 'package:app/controller/data_controller.dart';
import 'package:app/model/post_object.dart';
import 'package:app/model/topic_object.dart';
import 'package:app/route_generator.dart';
import 'package:app/ui/grid_item.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/custom_widgets.dart';
import 'package:app/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class GridPostPage extends StatefulWidget {
  GridPostPage({this.topic});

  final Topic topic;

  @override
  _GridPostPageState createState() => _GridPostPageState();
}

class _GridPostPageState extends StateMVC<GridPostPage> {
  static final double gridItemDimension = 170;
  DataController _con = DataController();
  Future<List<Post>> postsListFuture;
  ScrollController _scrollController = new ScrollController();

  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          currentPage++;
        });
        _fetchPosts();
      }
    });
  }

  void _fetchPosts() {
    setState(() {
      isLoading = true;
    });
    _con.getPostsByTopic(
        topicId: widget.topic.id,
        page: currentPage,
        apiResponse: (apiResponse) {
          setState(() {
            isLoading = false;
          });
          if (apiResponse.status == 200)
            setState(() {
              List<Post> newList = (apiResponse.data['data'] as List)
                  .map((i) => Post.fromJson(i))
                  .toList();
              if (newList.isNullOrEmpty()) {
                if (currentPage > 1) currentPage--;
              }
              if (postsListFuture != null) {
                postsListFuture.then((value) {
                  if (!value.isNullOrEmpty()) {
                    List<Post> postList = value;
                    postList.addAll(newList);
                    postsListFuture = Future.value(postList);
                  } else
                    postsListFuture = Future.value(newList);
                });
              } else
                postsListFuture = Future.value(newList);
            });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        color: AppUtils.getColorFromHash(AppUtils.lightGreyColor),
        child: FutureBuilder<List<Post>>(
            future: postsListFuture,
            builder:
                (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
              List<Post> postsList = snapshot.data;
              if (snapshot.hasData) {
                return RefreshIndicator(
                  // ignore: missing_return
                  onRefresh: () {
                    resetValues();
                    _fetchPosts();
                  },
                  child: Column(children: [
                    Expanded(
                      child: GridView.count(
                          controller: _scrollController,
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 10,
                          scrollDirection: Axis.vertical,
                          children: List.generate(postsList.length, (index) {
                            return GridItem(
                                post: postsList[index],
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(RouteGenerator.DETAIL,
                                          arguments: postsList[index].id)
                                      .then((value) {
                                    if (!(value as String).isNullOrEmpty()) {
                                      print(value);
                                      if ((value as String) == 'refresh') {
                                        resetValues();
                                        _fetchPosts();
                                      }
                                    }
                                  });
                                });
                          })),
                    ),
                    Visibility(
                      visible: isLoading,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor)),
                      ),
                    )
                  ]),
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: Text("${snapshot.error}",
                        style: TextStyle(color: Colors.white)));
              }
              return AppUtils.getCircularProgress(context);
            }));
  }

  void resetValues() {
    setState(() {
      currentPage = 1;
      postsListFuture = Future.value(null);
    });
  }
}
