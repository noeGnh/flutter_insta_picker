import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta_picker/src/models/options.dart';
import 'package:flutter_insta_picker/src/providers/video_provider.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';

Options options;

class Video extends StatelessWidget {

  Video({@required Options videoViewOptions}){ options = videoViewOptions; }

  @override
  Widget build(BuildContext context) => VideoView();

}

class VideoView extends StatefulWidget {
  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> with AutomaticKeepAliveClientMixin{
  VideoProvider provider;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    provider =  Provider.of<VideoProvider>(context, listen: false);
    // provider.getAvailableCameras(mounted);

    provider.translations = options.translations;
    provider.durationLimit = options.customizationOptions.videoCustomization.maximumRecordingDuration.inSeconds;
  }

  @override
  void dispose() {
    provider.controller.dispose();
    provider.cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: options.customizationOptions.bgColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: CameraPreviewWidget(),
            ),
            Consumer<VideoProvider>(
              builder: (ctx, provider, child){

                return LinearProgressIndicator(
                  value: provider.getIndicatorProgress(),
                  valueColor: AlwaysStoppedAnimation<Color>(options.customizationOptions.accentColor),
                  backgroundColor: Colors.white,
                );

              }
            ),
            SizedBox(height: 5.0),
            Consumer<VideoProvider>(
                builder: (ctx, provider, child){

                  return Text(
                    "00 : ${provider.showDuration()}",
                    textAlign: TextAlign.center,
                  );

                }
            ),
            SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CameraTogglesRowWidget(mounted),
                CaptureControlRowWidget(),
                FlashToggleRowWidget(),
              ],
            ),
            SizedBox(height: 20.0)
          ],
        ),
      ),
    );
  }
}

class CameraPreviewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    VideoProvider videoProvider =  Provider.of<VideoProvider>(context, listen: true);

    if (videoProvider.controller == null || !videoProvider.controller.value.isInitialized) {
      return Stack(
        children: [
          Positioned(
              child: Container(
                  width: size.width,
                  child: LinearProgressIndicator(
                      backgroundColor: options.customizationOptions.bgColor,
                      valueColor: AlwaysStoppedAnimation<Color>(options.customizationOptions.accentColor)
                  )
              )
          )
        ],
      );
    }

    return AspectRatio(
      aspectRatio: videoProvider.controller.value.aspectRatio,
      child: CameraPreview(videoProvider.controller),
    );

  }
}

class CaptureControlRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    VideoProvider videoProvider =  Provider.of<VideoProvider>(context, listen: true);

    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            VideoCaptureButton(videoProvider)
          ],
        ),
      ),
    );

  }
}

class CameraTogglesRowWidget extends StatelessWidget {

  final bool mounted;

  CameraTogglesRowWidget(this.mounted);

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {

    VideoProvider videoProvider =  Provider.of<VideoProvider>(context, listen: true);

    if (videoProvider.cameras == null || videoProvider.cameras.isEmpty) return Spacer();

    CameraDescription selectedCamera = videoProvider.cameras[videoProvider.selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(left: 21),
              child: Icon(_getCameraLensIcon(lensDirection), color: options.customizationOptions.iconsColor, size: 32,),
            ),
            onTap: (){
              videoProvider.onSwitchCamera(mounted);
            },
          )
      ),
    );

  }
}

class FlashToggleRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    VideoProvider videoProvider =  Provider.of<VideoProvider>(context, listen: true);

    IconData iconData;

    switch(videoProvider.flashMode){
      case FlashMode.auto:  iconData = Icons.flash_auto; break;

      case FlashMode.torch: iconData = Icons.flash_on; break;

      default:  iconData = Icons.flash_off;
    }

    return Expanded(
      child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(right: 21),
              child: Icon(iconData, color: options.customizationOptions.iconsColor, size: 32,),
            ),
            onTap: (){
              if (videoProvider.controller != null && videoProvider.controller.value.isInitialized){
                videoProvider.onFlashButtonPressed();
              }
            },
          )
      ),
    );

  }
}

class VideoCaptureButton extends StatefulWidget {
  final VideoProvider videoProvider;

  VideoCaptureButton(this.videoProvider, {Key key}) : super(key: key);

  @override
  _VideoCaptureButtonState createState() => _VideoCaptureButtonState();
}

class _VideoCaptureButtonState extends State<VideoCaptureButton> {

  SuperTooltip superTooltip = SuperTooltip(
    popupDirection: TooltipDirection.up,
    borderRadius: 3.0,
    borderWidth: 0.0,
    hasShadow: false,
    content: Material(
      child: Text(
        options.translations.pressAndHoldToRecord,
        softWrap: true,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (d) => widget.videoProvider.startVideoRecording(context, mounted),
      onLongPressEnd: (d) => widget.videoProvider.stopVideoRecording(context, mounted),
      child: FloatingActionButton(
        heroTag: null,
        child: Icon(Icons.camera, color: options.customizationOptions.bgColor,),
        backgroundColor: options.customizationOptions.iconsColor,
        onPressed: () => widget.videoProvider.manageTooltip(context, superTooltip),
      ),
    );
  }
}

