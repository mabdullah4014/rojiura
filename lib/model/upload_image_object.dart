class UploadImageObject {
  String fieldName;
  String path;
  String imageName;

  UploadImageObject(this.fieldName, this.path, this.imageName);

  @override
  String toString() {
    return 'UploadImageObject{fieldName: $fieldName, path: $path, imageName: $imageName}';
  }
}
