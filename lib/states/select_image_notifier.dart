import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectImageNotifier extends ChangeNotifier {
  List<Uint8List> _images = [
  ]; //_images list 데이터를 여기에 저장해서 provider를 통해 다른 곳에서 접근 수 있도록 설정해줌
  Future setNewImages(List<XFile>? newImages) async {

      if (newImages != null && newImages.isNotEmpty) {
        _images.clear();
        for (int i = 0; i < newImages.length; i++){


        _images.add(await newImages[i]
            .readAsBytes()); //각 image, element 원소들을 readAsbytes 로 읽어옴//image들을 _images 에 한개씩 넣어준다

      }}


      notifyListeners(); //변화했음을 알림

    }

    void removeImage(int index) {
      if (_images.length >=
          index) { //만약 index가 _images 길이보다 작다면 해당 index 사진을 지워야 한다
        _images.removeAt(index);
        notifyListeners();
      }
    }

    List<Uint8List> get images =>
    _images; //다른 곳에서 접근할 수 있도록
  }