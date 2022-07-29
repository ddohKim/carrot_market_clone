import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class UserModel {
  late String
      userKey; //user의 identity ,late는 나중에 데이터를 넣어준다는 의미(반드시 사용전에 null 이 되지 않도록 설정해줘야 함)
  late String phoneNumber; //user의 휴대폰 번호
  late String address; //user의 주소
  late GeoFirePoint
      geoFirePoint; //latitude, longitude를 가져와서 이를 geofirepoint로 변경해주고 다시 firestore에 저장 후 위치 정보 가져올 때 사용
  late DateTime createdDate; //해당 user 생성시간을 의미
  DocumentReference?
      reference; //firestore document 데이터를 받아와서 다시 여기에 넣어주는 모델이라면 reference가 필요함(필수적으로 필요하지는 않기 때문에 ? 붙여서)

  UserModel({
    //json to dart 에서 해당 json 형태로 만들어서 이를 생성하는데 private 설정 해제 해준 후에 temp.dart 를 복사해서 여기에 붙여넣기 하면 됨
    required this.userKey,
    required this.phoneNumber,
    required this.address,
    required this.geoFirePoint,
    required this.createdDate,
    this.reference,
  });

  UserModel.fromJson(Map<String, dynamic> json, this.userKey, this.reference) {
    //firestore 에 저장하는 방법대로 String 인지 다른 방식으로 저장하는지.. userKey, reference는 따로 저장을 해줄것
    phoneNumber = json['phoneNumber'];
    address = json['address'];
    geoFirePoint = GeoFirePoint(
        (json['geoFirePoint']['geopoint']).latitude,
        (json['geoFirePoint']['geopoint'])
            .longitude); //GeoFirePoint 를 생성해서 이를 넣어준다(geofirepoint plug in 확인해보면 어떤 형태인지 알 수 있음)
    createdDate = json['createdDate'] == null
        ? DateTime.now().toUtc()
        : (json['createdDate'] as Timestamp).toDate();
    //null이 아니면 json['createdDate']에서 받은 값이 TimeStamp 이고 이것을 toDate 즉 DateTime으로 변경을 한
  }

  UserModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) //UserModel.fromSnapshot에서 해당 받아온 snapshot을 fromJson으로 넘겨 json 데이터로 새로 설정해서 휴대폰 cache로 저장
      : this.fromJson(snapshot.data()!, snapshot.id, snapshot.reference);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['phoneNumber'] = phoneNumber;
    map['address'] = address;
    map['geoFirePoint'] = geoFirePoint.data; //data를 저장해줘야한다 document 찾아보면 나와있음
    map['createdDate'] = createdDate;

    return map;
  }
}
