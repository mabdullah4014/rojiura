import 'package:app/controller/data_controller.dart';
import 'package:app/generated/l10n.dart';
import 'package:app/model/topic_object.dart';
import 'package:app/ui/grid_post_page.dart';
import 'package:app/ui/search_post_page.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/colored_tab_bar.dart';
import 'package:app/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class TopicsPostPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final Function(int index) onTabSelected;

  TopicsPostPage({Key key, this.parentScaffoldKey, this.onTabSelected})
      : super(key: key);

  @override
  _TopicsPostPageState createState() => _TopicsPostPageState();
}

class _TopicsPostPageState extends StateMVC<TopicsPostPage> {
  List<Topic> topicsList;
  DataController _con = DataController();

  @override
  void initState() {
    super.initState();

    _con.getTopics(apiResponse: (topics) {
      setState(() {
        topicsList =
            (topics.data as List).map((i) => Topic.fromJson(i)).toList();
        topicsList.insert(0, Topic(id: -1, name: S.of(context).all));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (topicsList != null && topicsList.isNotEmpty)
        ? DefaultTabController(
            length: topicsList.length,
            child: Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(FontAwesomeIcons.search,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SearchPostPage((index) {
                                      widget.onTabSelected(index);
                                    })));
                          })
                    ],
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    title: Text(Constants.APP_NAME,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .merge(TextStyle(
                              color: Colors.white,
                            ))),
                    bottom: ColoredTabBar(
                        AppUtils.getColorFromHash(AppUtils.tabBgColor),
                        TabBar(
                          indicator: BoxDecoration(
                            color: AppUtils.getColorFromHash(
                                AppUtils.darkGreyColor),
                          ),
                          unselectedLabelColor:
                              AppUtils.getColorFromHash(AppUtils.darkGreyColor),
                          tabs: List<Widget>.generate(topicsList.length,
                              (int index) {
                            return Tab(text: topicsList[index].name);
                          }),
                          isScrollable: true,
                        ))),
                body: TabBarView(
                    children:
                        List<Widget>.generate(topicsList.length, (int index) {
                  return GridPostPage(topic: topicsList[index]);
                }))))
        : AppUtils.getCircularProgress(context);
  }
}
