import 'dart:convert';
import 'dart:ui';

import 'package:app/controller/data_controller.dart';
import 'package:app/generated/l10n.dart';
import 'package:app/model/topic_object.dart';
import 'package:app/model/upload_image_object.dart';
import 'package:app/model/user.dart';
import 'package:app/route_generator.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/image_picker_example.dart';
import 'package:app/utils/pref_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class CreatePostPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  CreatePostPage({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends StateMVC<CreatePostPage> {
  User user;
  String postText = "";
  PickedFile postPicture;
  DataController _con = DataController();

  TextEditingController _controller = TextEditingController();

  List<DropdownMenuItem<Topic>> topicsList = [];
  Topic selectedTopic;

  @override
  void initState() {
    super.initState();
    user = User.fromJson(json.decode(PreferenceUtils.getString('user', "")));
    print(user.toJson());
    _con.getTopics(apiResponse: (topics) {
      setState(() {
        topicsList = (topics.data as List)
            .map((i) => DropdownMenuItem(
                child: dropdownItemView(Topic.fromJson(i).name),
                value: Topic.fromJson(i)))
            .toList();
        topicsList.insert(
            0,
            DropdownMenuItem(
                child: dropdownItemView(S.of(context).select_topic),
                value: null));
      });
    });
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
            child: Column(children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: [
            _header(),
            _categoryDropdown(),
            _imageLayout()
          ]))),
          _commentEditFieldAndButton()
        ])));
  }

  Widget _header() {
    return Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: 170,
        child: Text(postText,
            textAlign: TextAlign.center, style: TextStyle(fontSize: 15)));
  }

  Widget _imageLayout() {
    return ImagePickerExamplePage(
        imageTitle: S.of(context).post_pic,
        layout: Container(
            width: MediaQuery.of(context).size.width,
            color: AppUtils.getColorFromHash(AppUtils.tabBgColor),
            padding: EdgeInsets.all(10),
            child: Icon(
                postPicture == null
                    ? Icons.broken_image
                    : FontAwesomeIcons.image,
                color: postPicture == null ? Colors.red : Colors.green,
                size: 40)),
        callback: (PickedFile file) {
          setState(() {
            postPicture = file;
          });
        });
  }

  Widget _commentEditFieldAndButton() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        color: AppUtils.getColorFromHash(AppUtils.darkGreyColor),
        child: Row(children: [
          Expanded(
              child: TextField(
                  controller: _controller,
                  maxLength: Constants.MAX_LENGTH,
                  maxLines: 1,
                  maxLengthEnforced: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    setState(() {
                      postText = value;
                    });
                  },
                  decoration: InputDecoration(
                      counter: Offstage(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      filled: true,
                      hintStyle:
                          TextStyle(color: Colors.grey[800], fontSize: 12),
                      hintText: S.of(context).post,
                      fillColor: Colors.white))),
          SizedBox(width: 5),
          InkWell(
              onTap: () {
                if (isValid()) {
                  createPost();
                }
              },
              child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(S.of(context).post,
                      style: TextStyle(color: Colors.white, fontSize: 20))))
        ]));
  }

  bool isValid() {
    if (postText.isEmpty) {
      AppUtils.showMessage(
          context, S.of(context).app_name, S.of(context).enter_post_desc);
      return false;
    } else if (postText.length > Constants.MAX_LENGTH) {
      AppUtils.showMessage(
          context, S.of(context).app_name, S.of(context).enter_post_desc_valid);
      return false;
    }
    if (selectedTopic == null) {
      AppUtils.showMessage(
          context, S.of(context).app_name, S.of(context).select_topic_proceed);
      return false;
    }
    return true;
  }

  void createPost() {
    AppUtils.onLoading(context);
    List<UploadImageObject> pickedFiles = List();
    if (postPicture != null)
      pickedFiles
          .add(UploadImageObject('image', postPicture.path, 'postImage.jpeg'));
    _con.createPost(postText, selectedTopic.id, pickedFiles,
        apiResponse: (response) {
      Navigator.pop(context);
      if (response.status == 200) {
        Navigator.of(context).pushReplacementNamed(RouteGenerator.HOME);
      } else {
        AppUtils.showMessage(context, S.of(context).app_name, response.message);
      }
    });
  }

  Widget _categoryDropdown() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, border: Border.all(color: Colors.black)),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(5),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
              hint: dropdownItemView(S.of(context).select_topic),
              iconEnabledColor: Colors.black,
              value: selectedTopic,
              items: topicsList,
              onChanged: (value) {
                setState(() {
                  selectedTopic = value;
                });
              }),
        ));
  }

  Widget dropdownItemView(String name) {
    return Container(
        width: MediaQuery.of(context).size.width - 50,
        child: Text(name, textAlign: TextAlign.center),
        alignment: Alignment.center);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _con.dispose();
  }
}
