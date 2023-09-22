import 'dart:async';
import 'dart:io';

import 'package:app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'app_utils.dart';

class ImagePickerExamplePage extends StatefulWidget {
  ImagePickerExamplePage({this.imageTitle, this.layout, this.callback});

  final String imageTitle;
  final Widget layout;
  final Function(PickedFile) callback;

  @override
  _ImagePickerExamplePageState createState() => _ImagePickerExamplePageState();
}

class _ImagePickerExamplePageState extends StateMVC<ImagePickerExamplePage> {
  PickedFile _imageFile;
  dynamic _pickImageError;
  String _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
        imageQuality: 80,
      );
      setState(() {
        _imageFile = pickedFile;
        widget.callback(_imageFile);
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
        widget.callback(null);
      });
    }
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return InkWell(
          onLongPress: () {
            AppUtils.yesNoDialog(context, S.of(context).delete,
                S.of(context).delete_image_message, () {
              Navigator.of(context).pop();
              setState(() {
                _imageFile = null;
                widget.callback(null);
              });
            });
          },
          child: Image.file(File(_imageFile.path),
              width: 70, height: 70, fit: BoxFit.cover));
    } else if (_pickImageError != null) {
      return Text(
        'Error: $_pickImageError',
        style: TextStyle(fontSize: 10),
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Image not picked',
        style: TextStyle(fontSize: 10),
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: () {
          if (_imageFile != null) {
            AppUtils.yesNoDialog(context, S.of(context).delete,
                S.of(context).delete_image_message, () {
              Navigator.of(context).pop();
              setState(() {
                _imageFile = null;
                widget.callback(null);
              });
            });
          }
        },
        onTap: () {
          if (_imageFile == null) {
            _onImageButtonPressed(ImageSource.gallery, context: context);
          } else {
            imageDialog(context, S.of(context).image, _imageFile.path);
          }
        },
        child: widget.layout);
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _addButton() {
    return IconButton(
        icon: Icon(Icons.add, size: 30, color: Theme.of(context).primaryColor),
        onPressed: () {
          _onImageButtonPressed(ImageSource.camera, context: context);
        });
  }

  void imageDialog(BuildContext context, String title, String imagePath) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: Colors.black87)),
          content: Image.file(File(imagePath), fit: BoxFit.cover),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
