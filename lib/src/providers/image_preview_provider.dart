import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_insta_picker/src/models/file_model.dart';
import 'package:flutter_insta_picker/src/models/options.dart';
import 'package:flutter_insta_picker/src/models/result.dart';
import 'package:path/path.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:image/image.dart' as imageLib;

class ImagePreviewProvider extends ChangeNotifier{

  List<FileModel> files = [];

  Translations _translations;

  set translations(Translations translations) { this._translations = translations; }

  _updateFiles(FileModel file, File resultFile){

    int index = this.files.indexOf(file);
    file.filePath = resultFile.path;
    this.files[index] = file;

    notifyListeners();

  }

  addFilter(BuildContext context, FileModel file, Options options) async {

    File f = File(file.filePath);
    var image = imageLib.decodeImage(f.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);

    Map filterResult = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
          title: Text(this._translations.filters, style: TextStyle(color: options.customizationOptions.iconsColor),),
          image: image,
          filters: presetFiltersList,
          filename: basename(file.filePath),
          appBarColor: options.customizationOptions.appBarColor,
          appBarIconsColor: options.customizationOptions.iconsColor,
          loader: Center(child: CircularProgressIndicator(backgroundColor: options.customizationOptions.iconsColor,)),
          fit: BoxFit.contain,
        ),
      ),
    );

    if (filterResult != null && filterResult.containsKey('image_filtered')) {

      File resultFile = filterResult['image_filtered'];

      if (resultFile != null) {

        this._updateFiles(file, resultFile);

      }

    }

  }

  edit(FileModel file, Options options) async {

    File editResult = await ImageCropper.cropImage(
        sourcePath: file.filePath,
        cropStyle: CropStyle.rectangle,
        compressFormat: ImageCompressFormat.png,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: options.customizationOptions.appBarColor,
          statusBarColor: options.customizationOptions.appBarColor,
          backgroundColor: options.customizationOptions.appBarColor,
          toolbarWidgetColor: options.customizationOptions.iconsColor,
          activeControlsWidgetColor: options.customizationOptions.iconsColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          showCropGrid: true
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          title: '',
          doneButtonTitle: this._translations.save,
          cancelButtonTitle: this._translations.cancel
        )
    );

    if (editResult != null) {

      this._updateFiles(file, editResult);

    }

  }

  submit(BuildContext context){

    List<PickedFile> pickedFiles = [];

    if (files != null){
      files.map((file) {
        pickedFiles.add(
            PickedFile(
                path: file.filePath,
                name: basename(file.filePath)
            )
        );
      }).toList();

      Navigator.pop(context, InstaPickerResult(pickedFiles: pickedFiles, resultType: ResultType.IMAGE));
    }

  }

}