import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_insta_picker/src/models/file_model.dart';
import 'package:flutter_insta_picker/src/models/result.dart';
import 'package:path/path.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoPreviewProvider extends ChangeNotifier{

  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  get trimmer => this._trimmer;

  get endValue => this._endValue;

  get isPlaying => this._isPlaying;

  get startValue => this._startValue;

  get progressVisibility => this._progressVisibility;

  set isPlaying(bool v){ this._isPlaying = v; notifyListeners(); }

  set endValue(double v){ this._endValue = v; }

  set startValue(double v){ this._startValue = v; }

  set progressVisibility(bool v){ this._progressVisibility = v; notifyListeners(); }

  List<FileModel> files;

  loadVideoTrimmer() async => await _trimmer.loadVideo(videoFile: File(files[0].filePath));

  submit(BuildContext context) async {

    this.progressVisibility = true;

    await this._trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
    ).then((result) {

      this.progressVisibility = false;

      List<PickedFile> pickedFiles = [];

      if (files != null){
        files.map((file) {
          pickedFiles.add(
              PickedFile(
                  path: result,
                  name: basename(result)
              )
          );
        }).toList();

        Navigator.pop(context, InstaPickerResult(pickedFiles: pickedFiles, resultType: ResultType.VIDEO));
      }

    });

  }

}