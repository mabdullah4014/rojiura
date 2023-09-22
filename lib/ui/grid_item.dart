import 'package:app/model/post_object.dart';
import 'package:app/utils/custom_widgets.dart';
import 'package:app/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  GridItem({this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onTap();
        },
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Container(
                child: Stack(fit: StackFit.expand, children: <Widget>[
              CachedNetworkImage(imageUrl: post.image_url, fit: BoxFit.cover),
              Positioned(
                  child: Container(
                      color: post.image_url.isNullOrEmpty()
                          ? Colors.white
                          : Colors.white70)),
              Container(
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: CustomWidgets.timeWidget(post.created_at),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomWidgets.likesLayout(
                                  post.liked, post.reaction_like_count),
                              CustomWidgets.commentsLayout(post.comments_count)
                            ])),
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          post.desc,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(fontSize: 22),
                        ))
                  ],
                ),
              )
            ]))));
  }
}
