import 'package:flutter/material.dart';
import 'package:flutter_insta_picker/src/models/options.dart';
import 'package:flutter_insta_picker/src/models/result.dart';
import 'package:flutter_insta_picker/src/providers/gallery_provider.dart';
import 'package:flutter_insta_picker/src/providers/photo_provider.dart';
import 'package:flutter_insta_picker/src/providers/picker_provider.dart';
import 'package:flutter_insta_picker/src/providers/video_provider.dart';
import 'package:flutter_insta_picker/src/widgets/gallery.dart';
import 'package:flutter_insta_picker/src/widgets/photo.dart';
import 'package:flutter_insta_picker/src/widgets/video.dart';
import 'package:provider/provider.dart';

class InstaPicker {

  static Future<InstaPickerResult> pick(
      BuildContext context,
      {Options options}
  ) async => await Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => Picker(options: options)));

}

class Picker extends StatelessWidget {

  final Options options;

  Picker({this.options});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<PhotoProvider>(create: (_) => PhotoProvider()),
          ChangeNotifierProvider<VideoProvider>(create: (_) => VideoProvider()),
          ChangeNotifierProvider<PickerProvider>(create: (_) => PickerProvider()),
          ChangeNotifierProvider<GalleryProvider>(create: (_) => GalleryProvider()),
        ],
        child: PickerView(options: options),
    );
  }

}

class PickerView extends StatefulWidget {

  final Options options;

  PickerView({Key key, this.options}) : super(key: key);

  @override
  _PickerViewState createState() => _PickerViewState();

}

class _PickerViewState extends State<PickerView> with SingleTickerProviderStateMixin {

  PickerProvider _pickerProvider;
  List<Widget> _pages = [];
  List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();

    if (widget.options.showGalleryTab){
      _pages.add(Gallery(galleryViewOptions: widget.options));
      _tabs.add(Tab(text: widget.options.translations.galleryTabTitle));
    }

    if (widget.options.showPhotoTab){
      _pages.add(Photo(photoViewOptions: widget.options));
      _tabs.add(Tab(text: widget.options.translations.photoTabTitle));
    }

    if (widget.options.showVideoTab){
      _pages.add(Video(videoViewOptions: widget.options));
      _tabs.add(Tab(text: widget.options.translations.videoTabTitle));
    }

    _pickerProvider =  Provider.of<PickerProvider>(context, listen: false);
    _pickerProvider.tabController = TabController(length: _pages.length, vsync: this);
    _pickerProvider.pageController = PageController();
  }

  @override
  void dispose() {
    _pickerProvider.pageController.dispose();
    _pickerProvider.tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return Consumer<PickerProvider>(
         builder : (context, provider, child){
           return Scaffold(
             body: PageView(
               controller: provider.pageController,
               children: _pages,
               onPageChanged: (index){
                  provider.onPageChange(context, index);
                  if(!provider.pageIsChanging) provider.pageIsChanging = true;
               },
             ),
             bottomNavigationBar: SizedBox(
               child: TabBar(
                 controller: provider.tabController,
                 tabs: _tabs,
                 isScrollable: false,
                 indicatorWeight: 1.5,
                 labelColor: widget.options.customizationOptions.tabBarTextColor,
                 indicatorColor: widget.options.customizationOptions.tabBarIndicatorColor,
                 unselectedLabelColor: widget.options.customizationOptions.tabBarTextColor,
                 onTap: (index){
                   provider.onPageChange(context, index);
                   if(!provider.pageIsChanging) provider.pageIsChanging = true;
                 },
               ),
             ),
           );
         }
     );
  }

}

