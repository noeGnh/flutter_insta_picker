import 'package:flutter/material.dart';
import 'package:flutter_insta_picker/src/providers/photo_provider.dart';
import 'package:flutter_insta_picker/src/providers/video_provider.dart';
import 'package:provider/provider.dart';

class PickerProvider extends ChangeNotifier{

  static const GALLERY_PAGE_INDEX = 0;
  static const PHOTO_PAGE_INDEX = 1;
  static const VIDEO_PAGE_INDEX = 2;

  PageController pageController;
  TabController tabController;

  bool pageIsChanging = false;

  void onPageChange(BuildContext context, int index) async {

    if (tabController == null || pageController == null || pageIsChanging) return;

    await pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);

    tabController.animateTo(index);

    pageIsChanging = false;

    PhotoProvider photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    VideoProvider videoProvider = Provider.of<VideoProvider>(context, listen: false);

    switch(index){
      case GALLERY_PAGE_INDEX:
        break;

      case PHOTO_PAGE_INDEX:
        photoProvider.getAvailableCameras(true);
        break;

      case VIDEO_PAGE_INDEX:
        videoProvider.getAvailableCameras(true);
        break;
    }

  }

}