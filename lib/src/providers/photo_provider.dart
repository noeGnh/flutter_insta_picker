import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta_picker/insta_picker.dart';
import 'package:flutter_insta_picker/src/models/file_model.dart';
import 'package:flutter_insta_picker/src/models/result.dart';
import 'package:flutter_insta_picker/src/widgets/preview/image_preview.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';

class PhotoProvider extends ChangeNotifier{

  final Logger logger = Logger();

  CameraController controller;
  int selectedCameraIdx;
  String imagePath;
  List cameras;

  FlashMode flashMode = FlashMode.off;

  Future<void> onFlashButtonPressed() async {
    switch (flashMode){
      case FlashMode.torch: flashMode = FlashMode.auto; break;

      case FlashMode.off: flashMode = FlashMode.torch; break;

      default: flashMode = FlashMode.off;
    }

    await controller.setFlashMode(flashMode);

    notifyListeners();
  }

  void getAvailableCameras(bool mounted){

    availableCameras().then((availableCameras) {

      cameras = availableCameras;
      if (cameras.length > 0) {

        selectedCameraIdx = 0;

        notifyListeners();

        _initCameraController(cameras[selectedCameraIdx], mounted).then((void v) {});

      }else{
        logger.w("No camera available");
      }

    }).catchError((e) {
      logger.e('Error: ${e.code}\nError Message: $e.message');
    });

  }

  Future _initCameraController(CameraDescription cameraDescription, bool mounted) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    controller.addListener(() {

      if (mounted) {
        notifyListeners();
      }

      if (controller.value.hasError) {
        logger.e('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      logger.e(e);
    }

    if (mounted) {
      notifyListeners();
    }
  }

  void refreshCamera(bool mounted) {
    Future.delayed(Duration(milliseconds: 1000), () async {
      _initCameraController(cameras[0], mounted);
    });
  }

  void onSwitchCamera(bool mounted) {
    selectedCameraIdx = selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    _initCameraController(selectedCamera, mounted);
  }

  void onCapturePressed(context, options) async {

    try {

      String path;

      await controller.takePicture().then((XFile file) {
        path = file.path;
      });

      InstaPickerResult result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => ImagePreview(
              files: [
                FileModel(
                    filePath: path,
                    title: basename(path)
                )
              ],
              imagePreviewOptions: options,
              showAddButton: false,
            )
          )
      );

      if (result != null) Navigator.pop(context, result);

    } catch (e) {
      logger.e(e);
    }

  }

}