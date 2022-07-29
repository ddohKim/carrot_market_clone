import 'package:dio/dio.dart';
import 'package:hello/constants/key.dart';
import 'package:hello/data/address_model.dart';
import 'package:hello/data/address_model2.dart';

class AddressService {
  //http 즉 api를 받아올때 사용하는 class
  //void dioTest() async{
  // var response=await Dio().get(path).catchError(e); //catchError로 에러를 받아올 수 있음
  // }
Future<AddressModel> searchAddressByStr(String text) async{ //검색해서 주소 찾

  final formData={ //자동으로 Data를 form에 맞게 설정해줌
    'key':VWORLD_KEY,
    'request':'search',
    'size':30,
    'query':text,
    'type':'ADDRESS',
  'category':"ROAD"
  };

  
  final response=await Dio().get('http://api.vworld.kr/req/search',queryParameters: formData).catchError((e){ //queryParameter를 통해서 자동으로 formData 정보를 form에 맞게 설정
    print(e); //vworld 에서 정보를 받아올 때는 json 형태다 (Map) 로 받아오기 때문에 string to json을 할 필요가 없
  });
  
  AddressModel addressModel=AddressModel.fromJson(response.data["response"]); //addressModel object에 Dio를 통해 받아온 response.data를 전달

return addressModel; //addressModel 을 return 해줌
}

Future<List<AddressModel2>> findAddressByGps({required double x, required double y}) async{ //gps로 주소 찾기

  final List<Map<String,dynamic>> formdatas=<Map<String,dynamic>>[]; //list 생성 5개의 주소를 받아온다

  formdatas.add({ //자동으로 Data를 form에 맞게 설정해줌
    'key':VWORLD_KEY,
    'service':'address',
    'type':'PARCEL',
    'request':'GetAddress',
    'point':'$x,$y'
  });
  formdatas.add({ //자동으로 Data를 form에 맞게 설정해줌
    'key':VWORLD_KEY,
    'service':'address',
    'type':'PARCEL',
    'request':'GetAddress',
    'point':'${x-0.01},$y'
  });
  formdatas.add({ //자동으로 Data를 form에 맞게 설정해줌
    'key':VWORLD_KEY,
    'service':'address',
    'type':'PARCEL',
    'request':'GetAddress',
    'point':'${x+0.01},$y'
  });
  formdatas.add({ //자동으로 Data를 form에 맞게 설정해줌
    'key':VWORLD_KEY,
    'service':'address',
    'type':'PARCEL',
    'request':'GetAddress',
    'point':'$x,${y-0.01}'
  });
  formdatas.add({ //자동으로 Data를 form에 맞게 설정해줌
    'key':VWORLD_KEY,
    'service':'address',
    'type':'PARCEL',
    'request':'GetAddress',
    'point':'$x,${y+0.01}'
  });

  List<AddressModel2> addresses=[]; //여러개의 주소를 저장하기 위해 list 사용

for(Map<String,dynamic> formData in formdatas){ //formdatas 내부의 원소들을 하나씩 가져와서 formData에 넣고 다음을 실행
  final response=await Dio().get('http://api.vworld.kr/req/address',queryParameters: formData).catchError((e){ //queryParameter를 통해서 자동으로 formData 정보를 form에 맞게 설정
    print(e); //vworld 에서 정보를 받아올 때는 json 형태다 (Map) 로 받아오기 때문에 string to json을 할 필요가 없
  });

  AddressModel2 addressModel=AddressModel2.fromJson(response.data["response"]); //addressModel object에 Dio를 통해 받아온 response.data를 전달
  if(response.data['response']['status']=='OK')//만약 주소를 받아올 수 있다면
    addresses.add(addressModel); //저장한다

}
return addresses; //list를 return 해준다




}



}