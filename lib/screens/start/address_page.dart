import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:hello/constants/common_size.dart';
import 'package:hello/constants/shared_pref_keys.dart';
import 'package:hello/data/address_model.dart';
import 'package:hello/data/address_model2.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'address_service.dart';

class AddressPage extends StatefulWidget {
  AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  TextEditingController _textEditingController = TextEditingController();

  AddressModel? _addressModel;
  List<AddressModel2> _addressModel2List = [];

  bool _isGettingGps = false; //Gps 정보를 받아오고 있는지

  @override
  void dispose() {
    //메모리 낭비를 줄이기 위해 현재 state가 사라질 때 controller 역시 같이 없애주어야 한다
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(left: common_padding, right: common_padding),
      //safearea의 최소 padding을 좌우 모두 줄때 사용
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            //글씨 입력가능하도록 하는 것
            controller: _textEditingController,
            //controller를 통해 입력받은 글씨를 받아올 수 있음
            onFieldSubmitted: (text) async {
              //엔터를 치면 해당 text를 준다
              _addressModel2List.clear();
              _addressModel = await AddressService().searchAddressByStr(
                  text); //받아온 text를 이용하여 AddressService의 searchAddressBystr을 전달 해줘서 주소를 검색할 수 있도록 한다
              setState(() {
                //상태변화 업데이트
              });
            },
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                hintText: "도로명으로 검색",
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                //textcolor를 main에서 지정한 hintColor로 해
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                prefixIconConstraints: BoxConstraints(
                    //아이콘의 최소 크기를 맞춰줘서 글자와 아이콘간의 간격 줄이기
                    minWidth: 24,
                    minHeight: 24)), //decoration으로 TextFormField 안에 아이콘 넣기
          ),
          TextButton.icon(
            //텍스트버튼 안에 icon을 넣어주고 싶을때 사용
            icon: _isGettingGps
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                : Icon(
                    //만약 gsp정보를 받아오고 있는 중이라면 circularProgress 보여주도록 함
                    CupertinoIcons.compass,
                    color: Colors.white,
                    size: 20,
                  ),
            onPressed: () async {
              _addressModel = null; //_addressModel를 null로 만들어 준다
              _addressModel2List.clear(); //새로운 정보를 계속 받아올 수 있게 지워준다
              setState(() {
                _isGettingGps = true; //gps 정보를 받아오는 중이
              });

              Location location = new Location(); //location 0bject 생성

              bool _serviceEnabled;
              PermissionStatus _permissionGranted;
              LocationData _locationData;

              _serviceEnabled = await location
                  .serviceEnabled(); //location 서비스를 사용할 수 있는지 없는 지 판단
              if (!_serviceEnabled) {
                //이것이 false라면
                _serviceEnabled = await location
                    .requestService(); //requestService로 서비스 요청 여부 확인
                if (!_serviceEnabled) {
                  //이것도 안된다면
                  return; // 그냥 나감
                }
              }

              _permissionGranted =
                  await location.hasPermission(); //gps permission 허락 여부 판단
              if (_permissionGranted == PermissionStatus.denied) {
                //만약 거절된다면
                _permissionGranted =
                    await location.requestPermission(); //permission 요청 여부 확인
                if (_permissionGranted != PermissionStatus.granted) {
                  //만약 permisson을 거절한다면
                  return; //그냥 나감
                }
              }
              _locationData = await location
                  .getLocation(); //permission, location 서비스를 이용 할 수 있으면 _locationData 에 location 정보를 받아온다
              List<AddressModel2> addresses = await AddressService()
                  .findAddressByGps(
                      x: _locationData.longitude!,
                      y: _locationData
                          .latitude!); //해당 주소를 findAddressByGps에 넘겨줌
              _addressModel2List
                  .addAll(addresses); //gps 로부터 받은 주소를 _addressModel2에 넣어준다

              setState(() {
                _isGettingGps = false;
              });
            },
            label: Text(
              //textbutton.icon 에는 child가 아닌 label을 사용해야 한다.
              _isGettingGps ? "위치를 찾는중" : "현재위치로 찾기",
              style: Theme.of(context).textTheme.button,
            ),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: Size(
                    10, 47)), //minimumSize를 지정하여 listview scroll 시 어색하지 않도록 설정
          ),
          if (_addressModel != null)
            Expanded(
              //스크린의 나머지 전체부분을 차지한다고 생각하면 됨
              child: ListView.builder(
                  itemCount: (_addressModel == null ||
                          _addressModel!.result == null ||
                          _addressModel!.result!.items ==
                              null) //_addressModel이 null 이라면
                      ? 0 //item 개수는 0
                      : _addressModel!.result!.items!.length, // item 개수 만큼
                  padding: EdgeInsets.symmetric(vertical: common_padding),
                  itemBuilder: (context, index) {
                    //padding을 줘서 가장 처음과 가장 마직막 tile에 여유공간 주기
                    //listView로 scroll 가능하게 만듬
                    //listviewbuilder로 index를 가져올 수 있음

                    if (_addressModel!.result == null ||
                        _addressModel!.result!.items == null ||
                        _addressModel!.result!.items![index].address == null)
                      return Container(); //만약 null이면 빈공간으로 둠
                    return ListTile(
                      onTap: () {
                        //num.parse 로 String을 num 으로 바꿔준다. 이때 항상 null check를 해줘야함
                        _savedAddressAndGoToNextPage(
                            _addressModel!
                                    .result!.items![index].address!.road ??
                                "",
                            num.parse(
                                _addressModel!.result!.items![index].point!.y ??
                                    '0'),
                            num.parse(
                                _addressModel!.result!.items![index].point!.x ??
                                    '0')); //만약 raod 가 비어있다면 빈 string을 저장해준다.
                      },
                      //listTile은 tile들을 한 블록으로 묶어서 사용하도록
                      leading: Icon(Icons.image),
                      trailing: ExtendedImage.asset(
                          'assets/images/icons8-apple-logo-48.png'),
                      title: Text(
                          _addressModel!.result!.items![index].address!.road ??
                              ""),
                      //road가 null이면 ""
                      subtitle: Text(_addressModel!
                              .result!.items![index].address!.parcel ??
                          ""), //parcel이 null이면 ""
                    );
                  }),
            ),
          if (_addressModel2List.isNotEmpty)
            Expanded(
              //스크린의 나머지 전체부분을 차지한다고 생각하면 됨
              child: ListView.builder(
                  itemCount: _addressModel2List.length, // item 개수 만큼
                  padding: EdgeInsets.symmetric(vertical: common_padding),
                  itemBuilder: (context, index) {
                    //padding을 줘서 가장 처음과 가장 마직막 tile에 여유공간 주기
                    //listView로 scroll 가능하게 만듬
                    //listviewbuilder로 index를 가져올 수 있음

                    if (_addressModel2List[index].result == null ||
                        _addressModel2List[index].result!.isEmpty)
                      return Container(); //만약 null이면 빈공간으로 둠
                    return ListTile(
                      onTap: () {
                        _savedAddressAndGoToNextPage(
                            _addressModel2List[index].result![0].text ?? "",
                            num.parse(
                                _addressModel2List[index].input!.point!.y ??
                                    '0'),
                            num.parse(
                                _addressModel2List[index].input!.point!.x ??
                                    '0')); //만약 text가 비어있다면 빈 string을 저장
                      },

                      //listTile은 tile들을 한 블록으로 묶어서 사용하도록
                      leading: Icon(Icons.image),
                      trailing: ExtendedImage.asset(
                          'assets/images/icons8-apple-logo-48.png'),
                      title:
                          Text(_addressModel2List[index].result![0].text ?? ""),
                      // result[0].text 속에 주소가 들어있음
                      subtitle: Text(
                          _addressModel2List[index].result![0].zipcode ??
                              ""), //
                    );
                  }),
            )
        ],
      ),
    );
  }

  _savedAddressAndGoToNextPage(String address, num lat, num lon) async {
    //해당 지역 버튼을 누르면 자동으로 다음 화면으로 넘어갈 수 있도록 설정
    await _saveAddressOnSharedPreference(address, lat, lon);
    context.read<PageController>().animateToPage(2,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  _saveAddressOnSharedPreference(String address, num lat, num lon) async {
    //받아온 address 를 다른 곳에서도 사용하기 위해서 임시로 저장하는 느낌
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); //prefs 라는 sharedpreference 인스턴스 생성
    await prefs.setString(SHARED_ADDRESS, address); //key, value 가 옴 key로 접근 가능
    await prefs.setDouble(SHARED_LAT, lat.toDouble());
    await prefs.setDouble(SHARED_LON, lon.toDouble());
  }
}
