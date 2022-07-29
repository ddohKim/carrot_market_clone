import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello/constants/data_keys.dart';
import 'package:hello/data/user_model.dart';

class UserService{ //colleciton 내 documentation 이 존재하고 그 안에 데이터를 저장할 수 있다 subcollection도 가능
  //Future firestoreTest() async{
 //     FirebaseFirestore.instance.collection('TESTING_COLLECTION').add({'testing':'testing value', 'number':123123}); //Firestore에 colleciton 내 document(이것은 자동으로 키가 생성됨) 정보를 추가할 때는 json Map<string,dynamic> 을 사용
 // }

 // void firestoreReadTest() { //documnetsnapshot으로 document를 받아오는데 이것은 json (map) 구조로 되어있음. 이것을 doc의 주소에서 get해서 가져옴, then은 future 처럼 데이터를 받아올때까지 기다림
 //  FirebaseFirestore.instance.collection('TESTING_COLLECTION').doc('1bD5ngSXdV40jmXOv8PA').get().then((DocumentSnapshot<Map<String,dynamic>> value) => print(value.data()));
 // }




static final UserService _userService=UserService._internal(); //앱 빌드 시 어떤 곳에서 userService instance 생성하더라도 단 한번만 실행해줌
factory UserService()=>_userService; //singleleton ?
UserService._internal();

Future createdNewUser(Map<String,dynamic>json, String userKey) async{
 DocumentReference<Map<String,dynamic>> documentReference= FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
 //documentReference 에  userKey에 해당하는 instance를 가져오는데 이때 없다면 새로 생성
 final DocumentSnapshot documentSnapshot=await documentReference.get();//현재의 user 가 이미 존재하는 지 존재하지 않는지 확인하기 위해서 이를 사용
  if(!documentSnapshot.exists){ //만약 documentSnapshot이 존재하지 않다면
   await documentReference.set(json);//새로운 Reference에 데이터를 넣어준다
  }
}


Future<UserModel> getUserModel(String userKey) async{
 DocumentReference<Map<String,dynamic>> documentReference= FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
 //documentReference 에 새로운 userKey를 생성하는데
 final DocumentSnapshot<Map<String,dynamic>> documentSnapshot=await documentReference.get();//현재의 user 가 이미 존재하는 지 존재하지 않는지 확인하기 위해서 이를 사용

UserModel userModel=UserModel.fromSnapShot(documentSnapshot);
return userModel;

}

}