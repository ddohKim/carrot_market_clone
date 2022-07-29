import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:hello/constants/shared_pref_keys.dart';
import 'package:hello/data/user_model.dart';
import 'package:hello/repository/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final user = DateTime.now().microsecondsSinceEpoch.toString();
UserModel? _userModel;

class UserProvider extends ChangeNotifier {
  //provider는 상태 관리를 하는 것으로 changenotifier 클래스의 현재 상태가 변경된 부분을 하위 위젯들에게 알려주고 이를 변경시키는 역할


  final String _userKey = user;

  bool _userLoggedIn =
      false; //밖에서 변경되는 것을 막아야 notiyListener로 외부의 widget들에게 알려줌. 만약 접근 가능하다면 정확히 언제 알려줄지를 모름

  void setUserAuth(bool authState) {
    _userLoggedIn = authState;
    notifyListeners(); //현재 changenotifer에 속해있는 widget들에게 notifyLinser로 알려줌
  }

  bool get userState =>
      _userLoggedIn; //밖에서 _userLoggedIn을 접근할 수 있도록 userState로 접근하기

  String get userKey => _userKey;

  Future setNewUser() async {
    //새로운 user를 생성하기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString(SHARED_ADDRESS) ??
        ""; //key 값은 shared_pref.keys.dart 에 따로 저장해놨음
    double lat = prefs.getDouble(SHARED_LAT) ?? 0;
    double lon = prefs.getDouble(SHARED_LON) ?? 0;
    String phoneNumber = '123123123';
    String userKey = _userKey;

    UserModel userModel = UserModel(
        userKey: "",
        //userModel instance 생성을 해줘서 해당 값들을 넣어주기
        phoneNumber: phoneNumber,
        address: address,
        geoFirePoint: GeoFirePoint(lat, lon),
        createdDate: DateTime.now().toUtc());

    await UserService().createdNewUser(userModel.toJson(),
        userKey); //UserService를 호출해서 userModel을 json 으로 바꿔서 저장을 해줌

    _userModel = await UserService().getUserModel(
        userKey); //userKey를 통해 firestore에서 해당 user 정보를 받아와서 다시 phone cache에 저장해줌

  }

  UserModel? get userModel =>
      _userModel; // 휴대폰 속 캐쉬에 저장된 _userModel을 외부에서 사용할 수 있도록
}
