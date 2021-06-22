import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_insta_picker/insta_picker.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Example",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text("Example"),
          ),
          body: Content()
        ),
    );
  }
}

class Content extends StatefulWidget {
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {

  String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            child: imagePath != null ? Image.file(File(imagePath)) : Container(),
          ),
          ElevatedButton(
            onPressed: () async {
              InstaPickerResult result = await InstaPicker.pick(context, options: Options());
              if (result != null){

                imagePath = result.pickedFiles[0].path;
                print(result.pickedFiles);

              }
              setState(() {});
            },
            child: Text('Pick It'),
          )
        ],
      ),
    );
  }
}

