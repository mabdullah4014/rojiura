import 'package:app/model/api_response.dart';
import 'package:app/model/comment_object.dart';
import 'package:app/model/post_object.dart';
import 'package:app/model/topic_object.dart';
import 'package:app/model/upload_image_object.dart';
import 'package:app/repo/data_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class DataController extends ControllerMVC {
  void getTopics({Function(ApiResponse<List<Topic>>) apiResponse}) async {
    await apiGetTopics().then((response) {
      apiResponse(response);
    });
  }

  void getPostsByTopic(
      {int topicId,
      int page,
      Function(ApiResponse<List<Post>>) apiResponse}) async {
    await apiGetPostsByTopic(topicId, page).then((response) {
      apiResponse(response);
    });
  }

  void getPostDetail(int postId,
      {Function(ApiResponse<Post>) apiResponse}) async {
    await apiGetPost(postId).then((response) {
      apiResponse(response);
    });
  }

  void likePost(int postId, {Function(ApiResponse<String>) apiResponse}) async {
    await apiLikePost(postId).then((response) {
      apiResponse(response);
    });
  }

  void createPost(
      String postDesc, int topicId, List<UploadImageObject> pickedFiles,
      {Function(ApiResponse<Post>) apiResponse}) async {
    await apiCreatePost(postDesc, topicId, pickedFiles).then((response) {
      apiResponse(response);
    });
  }

  void deletePost(int postId, {Function(ApiResponse<void>) apiResponse}) async {
    await apiDeletePost(postId).then((response) {
      apiResponse(response);
    });
  }

  void likeComment(int postId, int commentId,
      {Function(ApiResponse<dynamic>) apiResponse}) async {
    await apiLikeComment(postId, commentId).then((response) {
      apiResponse(response);
    });
  }

  void addComment(int postId, String comment,
      {int parentCommentId, Function(ApiResponse<Comment>) apiResponse}) async {
    await apiAddComment(postId, comment, parentCommentId: parentCommentId)
        .then((response) {
      apiResponse(response);
    });
  }

  void searchPost(String query,
      {Function(ApiResponse<List<Post>>) apiResponse}) async {
    await apiSearchPost(query).then((response) {
      apiResponse(response);
    });
  }

  void deleteComment(int postId, int commentId,
      {Function(ApiResponse<void>) apiResponse}) async {
    await apiDeleteComment(postId, commentId).then((response) {
      apiResponse(response);
    });
  }
}
