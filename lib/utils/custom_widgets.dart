import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'app_utils.dart';
import 'constants.dart';

class CustomWidgets {
  static TextStyle postTextStyle = TextStyle(
      fontSize: 12, color: AppUtils.getColorFromHash(AppUtils.postTextColor));

  static Widget likesLayout(bool isLiked, int likes) {
    return Row(children: [
      Icon(isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
          size: 12),
      SizedBox(width: 5),
      Text('$likes', style: postTextStyle)
    ]);
  }

  static Widget commentsLayout(int commentsCount) {
    return Row(children: [
      Icon(FontAwesomeIcons.commentDots, size: 12),
      SizedBox(width: 5),
      Text('$commentsCount', style: postTextStyle)
    ]);
  }

  static Widget timeWidget(String createdAt) {
    return Text(Constants.getTimeAgo(createdAt),
        style: CustomWidgets.postTextStyle);
  }
}
