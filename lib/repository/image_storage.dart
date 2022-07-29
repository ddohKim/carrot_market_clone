import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../constants/data_keys.dart';


class ImageStorage {
  static Future<List<String>> uploadImages(List<Uint8List> images, String itemKey) async {
   // DocumentReference<Map<String, dynamic>> _userKey = FirebaseFirestore
    //    .instance.collection(COL_USERS).doc(userKey); //firestore에서 userKey받아오기

    var metaData = SettableMetadata(
        contentType: 'image/jpeg'); //SettableMetadata 에서 contentType 설정을 통해서 octect-stream 타입을 jpeg 타입으로 변경을 해준다

List<String> downloadUrls=[]; //여기에 upload 한 image url 들을 넣어줄것임
    try {
      for (int i = 0; i < images.length; i++) { //for문을 돌면서 순서대로 list 내 images들을 저장해준다. firebase 특성상 10개 미만?
        Reference reference = FirebaseStorage.instance.ref('images/$itemKey/$i.jpg'); //reference에 저장할 폴더를 설정해줌(userkey_time 이렇게 설정해줄 것임)
        if (images.isNotEmpty)
          await reference.putData(
              images[i], metaData); //contentType 설정 바꾼 metaData를 넣어준다
      downloadUrls.add(await reference.getDownloadURL()); //getDownLoadUrl을 통해 하나씩 url을 받아온다

      }} catch (e) {print(e);} //혹시 모를 에러 감지

    return downloadUrls; //downloadurl 리턴해줌

  }

}