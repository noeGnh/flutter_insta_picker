class InstaPickerResult{

  List<PickedFile> pickedFiles;
  ResultType resultType;

  InstaPickerResult({this.pickedFiles, this.resultType});

}

class PickedFile{

  String path;
  String name;

  PickedFile({this.path, this.name});

}

enum ResultType{
  IMAGE,
  VIDEO
}