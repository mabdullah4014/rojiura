import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:app/controller/data_controller.dart';
import 'package:app/controller/user_controller.dart';
import 'package:app/generated/l10n.dart';
import 'package:app/model/comment_object.dart';
import 'package:app/model/post_object.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/custom_widgets.dart';
import 'package:app/utils/pref_util.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:app/utils/extensions.dart';

class PostDetailPage extends StatefulWidget {
  PostDetailPage({this.postId});

  final int postId;

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends StateMVC<PostDetailPage> {
  Future postFuture;
  Post post;
  Map<dynamic, dynamic> commentsList;
  User user;
  ScrollController _scrollController = ScrollController();
  DataController _con = DataController();
  TextEditingController _textEditingController = TextEditingController();

  final int LEFT_BUBBLE = 0;
  final int RIGHT_BUBBLE = 1;

  bool isAnythingUpdated = false;

  FocusNode editFieldFocusNode;

  int parentCommentId = -1;

//  Color highlightedColor = Color.fromRGBO(102, 170, 238, 0.4);
//  int latestIndex = -1;

  @override
  void initState() {
    super.initState();
    editFieldFocusNode = FocusNode();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        setState(() {
          parentCommentId = -1;
        });
        editFieldFocusNode.unfocus();
      }
    });

    commentsList = Map();
    user = User.fromJson(json.decode(PreferenceUtils.getString('user', "")));
    print("User : ${user.toJson().toString()}");
    print("Post Id : ${widget.postId}");
    _con.getPostDetail(widget.postId, apiResponse: (apiResponse) {
      setState(() {
        postFuture = fetchStr(apiResponse.data);
      });
    });
  }

  Future fetchStr(dynamic jsonResponse) async {
    await new Future.delayed(const Duration(seconds: 1));
    post = Post.fromJson(jsonResponse);
    initFirebase();
    return post;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                title: Text(Constants.APP_NAME,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .merge(TextStyle(color: Colors.white)))),
            resizeToAvoidBottomInset: true,
            body: SafeArea(
                child: FutureBuilder(
                    future: postFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        post = snapshot.data;
                        return Column(
                            //alignment:new Alignment(x, y)
                            children: <Widget>[
                              Expanded(
                                  child: SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Column(children: [
                                        _header(),
                                        _detail(),
                                        _commentsSection()
                                      ]))),
                              Align(
                                  alignment: FractionalOffset.bottomCenter,
                                  child: _commentEditFieldAndButton())
                            ]);
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      // By default, show a loading spinner
                      return Center(child: CircularProgressIndicator());
                    }))));
  }

  Widget _header() {
    return Stack(children: <Widget>[
      Visibility(
          visible: !post.image_url.isNullOrEmpty(),
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: CachedNetworkImage(
                  height: 200, imageUrl: post.image_url, fit: BoxFit.contain))),
      Container(
          padding: EdgeInsets.all(5),
          child: Stack(children: [
            Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    icon: Icon(FontAwesomeIcons.chevronCircleLeft,
                        color: Colors.black, size: 32),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })),
            Align(
                alignment: Alignment.topRight,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _deleteIcon(),
                  CustomWidgets.timeWidget(post.created_at)
                ]))
          ]))
    ]);
  }

  Widget _detail() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Text(
            post.desc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            InkWell(
                onTap: () {
                  likePost(post.id);
                },
                child: CustomWidgets.likesLayout(
                    post.liked, post.reaction_like_count)),
            CustomWidgets.commentsLayout(commentsList.length)
          ])
        ]));
  }

  Widget _deleteIcon() {
    return Visibility(
      visible: isSameUser(post.owner.uuid),
      child: IconButton(
          icon: Icon(FontAwesomeIcons.trashAlt, color: Colors.black),
          onPressed: () {
            AppUtils.yesNoDialog(
                context, S.of(context).app_name, S.of(context).delete_post, () {
              Navigator.pop(context);
              _deletePost();
            });
          }),
    );
  }

  Widget _commentDeleteIcon(Comment comment) {
    return Visibility(
        maintainSize: false,
        visible: isSameUser(comment.user.uuid),
        child: InkWell(
            onTap: () {
              AppUtils.yesNoDialog(
                  context, S.of(context).app_name, S.of(context).delete_comment,
                  () {
                Navigator.pop(context);
                _deleteComment(comment.id);
              });
            },
            child: Row(children: [
              Icon(FontAwesomeIcons.trashAlt, color: Colors.black, size: 12),
              SizedBox(width: 5),
              Text(S.of(context).delete, style: CustomWidgets.postTextStyle)
            ])));
  }

  Widget _commentsSection() {
    return Container(
      color: AppUtils.getColorFromHash(AppUtils.lightGreyColor),
      child: ListView.separated(
          separatorBuilder: (context, index) =>
              Divider(color: Colors.transparent, thickness: 3),
          padding: EdgeInsets.all(10),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: commentsList.length,
          itemBuilder: (context, index) {
            int key = commentsList.keys.elementAt(index);
            return _commentItem(commentsList[key], index);
          }),
    );
  }

  Widget _commentItem(Comment comment, int index) {
    if (comment.user.uuid == user.uuid) {
      //on right
      return Container(
        decoration: BoxDecoration(
//            color: index == latestIndex ? highlightedColor : Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          _commentBubble(RIGHT_BUBBLE, comment, index),
          SizedBox(width: 10),
          _commentIcon(RIGHT_BUBBLE, comment, index)
        ]),
      );
    } else {
      //on left
      return Container(
        decoration: BoxDecoration(
//            color: index == latestIndex ? highlightedColor : Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          _commentIcon(LEFT_BUBBLE, comment, index),
          SizedBox(width: 10),
          _commentBubble(LEFT_BUBBLE, comment, index)
        ]),
      );
    }
  }

  Widget _commentBubble(int whichBubble, Comment comment, int index) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: EdgeInsets.all(5),
        child: Bubble(
          color: Colors.white,
          nip: (whichBubble == LEFT_BUBBLE)
              ? BubbleNip.leftBottom
              : BubbleNip.rightBottom,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(comment.body),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                          onTap: () {
                            likeComment(comment);
                          },
                          child: CustomWidgets.likesLayout(
                              comment.isLiked(), comment.getLikeCount())),
                      SizedBox(width: 10),
                      InkWell(
                          onTap: () {
                            setState(() {
                              parentCommentId = comment.id;
                            });
                            editFieldFocusNode.requestFocus();
                          },
                          child: Row(children: [
                            Icon(FontAwesomeIcons.commentDots,
                                color: Colors.black, size: 12),
                            SizedBox(width: 5),
                            Text(S.of(context).reply,
                                style: CustomWidgets.postTextStyle)
                          ])),
                      Visibility(
                          maintainSize: false,
                          visible: isSameUser(comment.user.uuid),
                          child: SizedBox(width: 10)),
                      _commentDeleteIcon(comment),
                      SizedBox(width: 10),
                      CustomWidgets.timeWidget(comment.created_at),
                    ])
              ]),
        ));
  }

  Widget _commentIcon(int whichBubble, Comment comment, int index) {
    return Column(children: [
      Container(
          width: 40,
          height: 40,
          padding: (whichBubble == RIGHT_BUBBLE && isSameUser(post.owner.uuid))
              ? EdgeInsets.only(right: 5, bottom: 3)
              : EdgeInsets.all(0),
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: AppUtils.getColorFromHash(comment.user.colour),
              shape: BoxShape.circle),
          child: getCommentIconChild(whichBubble, comment)),
      SizedBox(height: 3),
      Text(
        '${comment.index}',
        style: TextStyle(color: Colors.white, fontSize: 14),
      )
    ]);
  }

  Widget _commentEditFieldAndButton() {
    return Container(
      color: AppUtils.getColorFromHash(AppUtils.darkGreyColor),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      child: Row(children: [
        Expanded(
            child: TextField(
                focusNode: editFieldFocusNode,
                controller: _textEditingController,
                onSubmitted: (value) {
                  if (isValid()) _addComment();
                },
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey[800], fontSize: 12),
                    hintText: S.of(context).comment,
                    fillColor: Colors.white))),
        SizedBox(width: 5),
        InkWell(
          onTap: () {
            if (isValid()) _addComment();
          },
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              S.of(context).post,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        )
      ]),
    );
  }

  void likePost(int postId) {
    AppUtils.onLoading(context);
    _con.likePost(postId, apiResponse: (response) {
      Navigator.pop(context);
      if (response.status == 200) {
        setState(() {
          post.reaction_like_count =
              response.data["data"]["reaction_like_count"];
          post.liked = response.data["data"]["liked"];

          isAnythingUpdated = true;
        });
      } else {
        AppUtils.showMessage(context, S.of(context).app_name, response.message);
      }
    });
  }

  void likeComment(Comment comment) {
    AppUtils.onLoading(context);
    _con.likeComment(post.id, comment.id, apiResponse: (response) {
      Navigator.of(context).pop();
      if (response.status == 200) {
        setState(() {
          if (response.data != null) {
            Comment comment = Comment.fromJson(response.data['data']);
            if (comment != null) {
              commentsList[comment.index] = comment;
            }
          }
        });
      } else {
        AppUtils.showMessage(context, S.of(context).app_name, response.message);
      }
    });
  }

  void _deletePost() {
    AppUtils.onLoading(context);
    _con.deletePost(post.id, apiResponse: (response) {
      Navigator.pop(context);
      if (response.status == 200) {
        AppUtils.showMessage(
            context, S.of(context).app_name, S.of(context).post_deleted,
            callback: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop('refresh');
        });
      } else {
        AppUtils.showMessage(context, S.of(context).app_name, response.message);
      }
    });
  }

  void _deleteComment(int commentId) {
    AppUtils.onLoading(context);
    _con.deleteComment(post.id, commentId, apiResponse: (response) {
      Navigator.pop(context);
      if (response.status != 200) {
        AppUtils.showMessage(context, S.of(context).app_name, response.message);
      }
    });
  }

  void _addComment() {
    print("Parent comment Id : $parentCommentId");
    _con.addComment(post.id, _textEditingController.text,
        parentCommentId: parentCommentId, apiResponse: (response) {
      editFieldFocusNode.unfocus();
      setState(() {
        parentCommentId = -1;
      });
      if (response.status == 200) {
        setState(() {
          if (response.data != null) {
            Comment comment = Comment.fromJson(response.data);
            if (comment != null) commentsList[comment.index] = comment;
          }
          _textEditingController.clear();
        });
      } else {
        Fluttertoast.showToast(msg: S.of(context).unable_to_comment);
      }
    });
  }

  void initFirebase() {
    FirebaseDatabase.instance
        .reference()
        .child(post.id.toString())
        .onChildChanged
        .listen((event) {
      if (event != null && event.snapshot != null) {
        dynamic resultList = event.snapshot.value;
        int index = int.parse(event.snapshot.key);
        setState(() {
          commentsList[index] = Comment.fromJson(resultList);
          isAnythingUpdated = true;
        });
      }
    });

    FirebaseDatabase.instance
        .reference()
        .child(post.id.toString())
        .onChildAdded
        .listen((event) {
      if (event != null && event.snapshot != null) {
        dynamic resultList = event.snapshot.value;
        int index = int.parse(event.snapshot.key);
        setState(() {
          commentsList[index] = Comment.fromJson(resultList);
          isAnythingUpdated = true;
        });
//        setState(() {
//          latestIndex = commentsList.length - 1;
//        });
//        _scrollController.animateTo(
//          _scrollController.position.maxScrollExtent,
//          duration: Duration(seconds: 1),
//          curve: Curves.fastOutSlowIn,
//        );
//        Timer(Duration(seconds: 2), () {
//          setState(() {
//            latestIndex = -1;
//          });
//        });
      }
    });

    FirebaseDatabase.instance
        .reference()
        .child(post.id.toString())
        .onChildRemoved
        .listen((event) {
      if (event != null && event.snapshot != null) {
        int index = int.parse(event.snapshot.key);
        setState(() {
          commentsList.remove(index);
          isAnythingUpdated = true;
        });
      }
    });
  }

  Widget getCommentIconChild(int whichBubble, Comment comment) {
    if (whichBubble == RIGHT_BUBBLE && isSameUser(post.owner.uuid)) {
      return Icon(FontAwesomeIcons.crown, color: Colors.white, size: 15);
    } else {
      return Text('${comment.user_index}',
          style: TextStyle(color: Colors.white));
    }
  }

  bool isValid() {
    if (_textEditingController.text.isEmpty) {
      AppUtils.showMessage(
          context, S.of(context).app_name, S.of(context).enter_comment);
      return false;
    }
    return true;
  }

  bool isSameUser(String uuid) {
    return uuid == currentUser.value.uuid;
  }

  // ignore: missing_return
  Future<bool> _onBackPressed() {
    if (isAnythingUpdated) {
      Navigator.of(context).pop("refresh");
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    editFieldFocusNode.dispose();
    _con.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}
