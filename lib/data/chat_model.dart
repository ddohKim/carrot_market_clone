import 'package:cloud_firestore/cloud_firestore.dart';

/// chatKey : ""
/// msg : ""
/// createdDate : ""
/// userKey : ""
/// reference : ""

class ChatModel {
  ChatModel({
    required  this.msg,
    required  this.createdDate,
    required  this.userKey,
      this.reference,});

  ChatModel.fromJson(Map<String, dynamic> json,this.chatKey, this.reference) {

    msg = json['msg']??"";
    createdDate = json['createdDate'] == null
        ? DateTime.now().toUtc()
        : (json['createdDate'] as Timestamp).toDate();
    userKey = json['userKey']??"";

  }
String? chatKey; //자동으로 생성되기 때문에 안줘도 된다
 late String msg;
 late DateTime createdDate;
 late String userKey;
  DocumentReference? reference;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['msg'] = msg;
    map['createdDate'] = createdDate;
    map['userKey'] = userKey;
    return map;
  }


  ChatModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) //UserModel.fromSnapshot에서 해당 받아온 snapshot을 fromJson으로 넘겨 json 데이터로 새로 설정해서 휴대폰 cache로 저장
      : this.fromJson(snapshot.data()!, snapshot.id, snapshot.reference);

  ChatModel.fromQuerySnapShot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) //docs 는 UserModel.fromSnapshot 아닌 querydocumentsnapshot으로 받아야 하기 때문에 이걸 사용해줘서 ITemModel List를 받아온다
      : this.fromJson(snapshot.data(), snapshot.id, snapshot.reference); //무조건 snapshot은 데이터가 존재한다
}