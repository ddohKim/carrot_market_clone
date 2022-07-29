import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

/// item_image : ""
/// item_title : ""
/// item_key : ""
/// item_address : ""
/// item_price : 0.0
/// seller_key : ""
/// buyer_key : ""
/// seller_image : ""
/// buyer_image : ""
/// geo_fire_point : ""
/// last_msg : ""
/// last_msg_time : "2012-04-21T18:25:43-05:00"
/// last_msg_user_key : ""
/// chatroom_key : ""

class ChatroomModel {
  ChatroomModel(
      {required this.itemImage,
      required this.itemTitle,
      required this.itemKey,
      required this.itemAddress,
      required this.itemPrice,
      required this.sellerKey,
      required this.buyerKey,
      required this.sellerImage,
      required this.buyerImage,
      required this.geoFirePoint,
      this.lastMsg='',
      required this.lastMsgTime,
     this.lastMsgUserKey='',
      required this.chatroomKey,
      this.reference});

  ChatroomModel.fromJson(Map<String, dynamic> json,this.chatroomKey, this.reference) {
    itemImage = json['itemImage'] ?? "";
    itemTitle = json['itemTitle'] ?? "";
    itemKey = json['itemKey'] ?? "";
    itemAddress = json['itemAddress'] ?? "";
    itemPrice = json['itemPrice'] ?? 0;
    sellerKey = json['sellerKey'] ?? "";
    buyerKey = json['buyerKey'] ?? "";
    sellerImage = json['sellerImage'] ?? "";
    buyerImage = json['buyerImage'] ?? "";
    geoFirePoint =json['geoFirePoint']==null?GeoFirePoint(0, 0): GeoFirePoint(
        (json['geoFirePoint']['geopoint']).latitude,
        (json['geoFirePoint']['geopoint'])
            .longitude);
    lastMsg = json['lastMsg'] ?? "";
    lastMsgTime = json['lastMsgTime'] == null
        ? DateTime.now().toUtc()
        : (json['lastMsgTime'] as Timestamp).toDate();
    lastMsgUserKey = json['lastMsgUserKey'] ?? "";
  }

  late String itemImage;
  late String itemTitle;
  late String itemKey;
  late String itemAddress;
  late num itemPrice;
  late String sellerKey;
  late String buyerKey;
  late String sellerImage;
  late String buyerImage;
  late GeoFirePoint geoFirePoint;
  late String lastMsg;
  late DateTime lastMsgTime;
  late String lastMsgUserKey;
  late String chatroomKey;
  DocumentReference? reference;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['itemImage'] = itemImage;
    map['itemTitle'] = itemTitle;
    map['itemKey'] = itemKey;
    map['itemAddress'] = itemAddress;
    map['itemPrice'] = itemPrice;
    map['sellerKey'] = sellerKey;
    map['buyerKey'] = buyerKey;
    map['sellerImage'] = sellerImage;
    map['buyerImage'] = buyerImage;
    map['geoFirePoint'] = geoFirePoint.data;
    map['lastMsg'] = lastMsg;
    map['lastMsgTime'] = lastMsgTime;
    map['lastMsgUserKey'] = lastMsgUserKey;
    return map;
  }

  ChatroomModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) //ChatroomModel.fromSnapshot에서 해당 받아온 snapshot을 fromJson으로 넘겨 json 데이터로 새로 설정해서 휴대폰 cache로 저장
      : this.fromJson(snapshot.data()!, snapshot.id, snapshot.reference);

  ChatroomModel.fromQuerySnapShot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) //docs 는 UserModel.fromSnapshot 아닌 querydocumentsnapshot으로 받아야 하기 때문에 이걸 사용해줘서 ITemModel List를 받아온다
      : this.fromJson(snapshot.data(), snapshot.id, snapshot.reference); //무조건 snapshot은 데이터가 존재한다

static String generateChatRoomKey(String buyer,String itemKey){
  return '${itemKey}_$buyer'; //itemKey_buyer로 chatroomKey를 생성한다
}


}
