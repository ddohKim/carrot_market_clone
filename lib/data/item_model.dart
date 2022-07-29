import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import '../states/user_provider.dart';

class ItemModel {
  //late 로 나중에 값을 주겠다
  late String itemKey;
  late String userKey;
  late List<String> imageDownloadUrls;
  late String title;
  late String category;
  late num price;
  late bool negotiable;
  late String detail;
  late String address;
  late GeoFirePoint geoFirePoint;
  late DateTime createdDate;
  late DocumentReference? reference;

  ItemModel({
    required this.itemKey,
    required this.userKey,
    required this.imageDownloadUrls,
    required this.title,
    required this.category,
    required this.price,
    required this.negotiable,
    required this.detail,
    required this.address,
    required this.geoFirePoint,
    required this.createdDate,
    this.reference,
  });

  ItemModel.fromJson(Map<String, dynamic> json,this.itemKey, this.reference) {
    userKey = json['userKey']??"";
    imageDownloadUrls = json['imageDownloadUrls'] != null
        ? json['imageDownloadUrls'].cast<String>()
        : [];
    title = json['title']??"";
    category = json['category']??"none";
    price = json['price']??0;
    negotiable = json['negotiable']??false;
    detail = json['detail']??"";
    address = json['address']??"";
    geoFirePoint =json['geoFirePoint']==null?GeoFirePoint(0, 0): GeoFirePoint(
        (json['geoFirePoint']['geopoint']).latitude,
        (json['geoFirePoint']['geopoint'])
            .longitude);
    createdDate = json['createdDate'] == null
        ? DateTime.now().toUtc()
        : (json['createdDate'] as Timestamp).toDate();
  }

  ItemModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) //UserModel.fromSnapshot에서 해당 받아온 snapshot을 fromJson으로 넘겨 json 데이터로 새로 설정해서 휴대폰 cache로 저장
      : this.fromJson(snapshot.data()!, snapshot.id, snapshot.reference);

  ItemModel.fromQuerySnapShot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) //docs 는 UserModel.fromSnapshot 아닌 querydocumentsnapshot으로 받아야 하기 때문에 이걸 사용해줘서 ITemModel List를 받아온다
      : this.fromJson(snapshot.data(), snapshot.id, snapshot.reference); //무조건 snapshot은 데이터가 존재한다

  Map<String, dynamic> toJson() { //firestore에 저장할때
    final map = <String, dynamic>{};
    map['userKey'] = userKey;
    map['imageDownloadUrls'] = imageDownloadUrls;
    map['title'] = title;
    map['category'] = category;
    map['price'] = price;
    map['negotiable'] = negotiable;
    map['detail'] = detail;
    map['address'] = address;
    map['geoFirePoint'] = geoFirePoint.data;
    map['createdDate'] = createdDate;
    return map;
  }

  Map<String, dynamic> toMinJson() { //firestore에 user에 최소한의 item 정보들을 저장할때
    final map = <String, dynamic>{};
    map['imageDownloadUrls'] = imageDownloadUrls.isEmpty?'':imageDownloadUrls.sublist(0,1); //1개의 list 내 index 만 필요하다
    map['title'] = title;
    map['price'] = price;
    return map;
  }

  static String generateItemKey(String userKey){
    String _userKey=userKey;
    String timeInMilli = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString(); //현재 저장하는 시간
    return '${_userKey}_$timeInMilli';
  }


}
