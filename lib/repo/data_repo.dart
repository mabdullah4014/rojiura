import 'dart:convert';

import 'package:app/model/api_response.dart';
import 'package:app/model/comment_object.dart';
import 'package:app/model/post_object.dart';
import 'package:app/model/topic_object.dart';
import 'package:app/model/upload_image_object.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/constants.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

// ignore: implementation_imports
import 'package:http_parser/src/media_type.dart';

Future<ApiResponse<List<Topic>>> apiGetTopics() async {
  final String url = '${GlobalConfiguration().get('base_url')}topic';
  final client = new http.Client();
  final response = await client.get(url, headers: Constants.getHeader());
  return AppUtils.getResponseObject(response);
}

Future<ApiResponse<List<Post>>> apiGetPostsByTopic(
    int topicId, int page) async {
  String topicParam = topicId != -1 ? '&topic_id=$topicId' : '';
  final String url =
      '${GlobalConfiguration().get('base_url')}post?page=$page$topicParam';
  final client = new http.Client();
  final response = await client.get(url, headers: Constants.getHeader());
  return AppUtils.getResponseObject(response);
}

Future<ApiResponse<Post>> apiGetPost(int postId) async {
  final String url = '${GlobalConfiguration().get('base_url')}post/$postId';
  final client = new http.Client();
  final response = await client.get(url, headers: Constants.getHeader());
  return AppUtils.getResponseObject(response);
}

Future<ApiResponse<String>> apiLikePost(int postId) async {
  final String url =
      '${GlobalConfiguration().get('base_url')}post/$postId/like';
  final client = new http.Client();
  final response = await client.post(url, headers: Constants.getHeader());
  return AppUtils.getResponseObject(response);
}

Future<ApiResponse<Post>> apiCreatePost(
    String postDesc, int topicId, List<UploadImageObject> pickedFiles) async {
  final String url = '${GlobalConfiguration().get('base_url')}post';
  var request = new http.MultipartRequest('POST', Uri.parse(url));
  request.headers.addAll(Constants.getHeader());

  request.fields['desc'] = postDesc;
  request.fields['topic_id'] = topicId.toString();

  for (UploadImageObject file in pickedFiles) {
    http.MultipartFile.fromPath(file.fieldName, file.path,
            filename: file.imageName,
            contentType: MediaType.parse('image/jpeg'))
        .then((value) {
      request.files.add(value);
    });
  }
  final response = await request.send();
  var respStr = await http.Response.fromStream(response);
  return AppUtils.getResponseObject(respStr);
}

Future<ApiResponse<void>> apiDeletePost(int postId) async {
  final String url = '${GlobalConfiguration().get('base_url')}post/$postId';
  final client = new http.Client();
  final response = await client.delete(url, headers: Constants.getHeader());
  return AppUtils.getResponseObject(response);
}

Future<ApiResponse<dynamic>> apiLikeComment(int postId, int commentId) async {
  final String url =
      '${GlobalConfiguration().get('base_url')}post/$postId/comment/$commentId/like';
  final client = new http.Client();
  final response = await client.post(url, headers: Constants.getHeader());
  return AppUtils.getResponseObject(response);
}

Future<ApiResponse<Comment>> apiAddComment(int postId, String commentBody,
    {int parentCommentId = -1}) async {
  final String url =
      '${GlobalConfiguration().get('base_url')}post/$postId/comment';
  final client = new http.Client();
  Map<String, dynamic> body = Map();
  body['body'] = commentBody;
  if (parentCommentId != -1) body['parent_comment_id'] = parentCommentId;
  final response = await client.post(url,
      headers: Constants.getHeader(), body: json.encode(body));
  return AppUtils.getResponseObject(response);
}

Future<ApiResponse<List<Post>>> apiSearchPost(String query) async {
  final String url =
      '${GlobalConfiguration().get('base_url')}post/search?query=$query';
  final client = new http.Client();
  final response = await client.get(url, headers: Constants.getHeader());
  return AppUtils.getResponseObject(response);
}

Future<ApiResponse<void>> apiDeleteComment(int postId, int commentId) async {
  final String url =
      '${GlobalConfiguration().get('base_url')}post/$postId/comment/$commentId';
  final client = new http.Client();
  final response = await client.delete(url, headers: Constants.getHeader());
  return AppUtils.getResponseObject(response);
}
