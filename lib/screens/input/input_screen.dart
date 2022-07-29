import 'dart:typed_data';

import 'package:beamer/beamer.dart';
import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:hello/constants/common_size.dart';
import 'package:hello/data/item_model.dart';
import 'package:hello/repository/image_storage.dart';
import 'package:hello/repository/item_service.dart';
import 'package:hello/states/category_provider.dart';
import 'package:hello/states/select_image_notifier.dart';

import 'package:provider/provider.dart';
import '../../states/user_provider.dart';
import 'multi_image_select.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  bool _suggestPriceSelected = false;

  TextEditingController _priceController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _detailController = TextEditingController();
  @override
  void dispose() {
  _priceController.dispose();
  _titleController.dispose();
  _detailController.dispose();
    super.dispose();
  }
  final _divider = Divider(
    height: 1,
    color: Colors.grey[400],
    thickness: 1,
    indent: common_padding,
    endIndent: common_padding,
  );

  bool _isCreatingItem = false; //완료 버튼 누르고 정보들 업로드 할 때 로딩 화면 보이도록

  final _border =
  UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent));

  @override
  Widget build(BuildContext context) {
    //design을 알맞게 맞춰야 한다
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery
            .of(context)
            .size;
        return IgnorePointer(
          ignoring: _isCreatingItem, //_iscreatingitem 이 true 이면 클릭이 되지 않도록 설정
          child: Scaffold(
              appBar: AppBar(
                bottom: PreferredSize(preferredSize: Size(_size.width, 2),
                  //필수적으로 사이즈를 지정해야 줘야 해서 휴대폰 가로 길이와 높이는 2로 준다
                  child: _isCreatingItem ? LinearProgressIndicator(
                    minHeight: 2,) : Container(),),
                //loading 화면이 appbar 아래 한줄로 나오도록 설정
                actions: [
                  TextButton(
                    //추가적으로 appbar에 버튼들을 넣고 싶을 때
                      style: TextButton.styleFrom(
                          primary: Colors.black87, //클릭 시 클릭이 보이도록 색깔 설정
                          backgroundColor:
                          Theme
                              .of(context)
                              .appBarTheme
                              .backgroundColor),
                      onPressed: () async {
                        _isCreatingItem = true;
                        setState(() {

                        });

                        UserProvider userProvider=context.read<UserProvider>(); //Userprovider를 가져와서 휴대폰 cache 속 _userModel 에 접근할 수 있도록
                        final String itemKey = ItemModel.generateItemKey(userProvider
                            .userKey);
//itemModel instance를 생성해서 이걸 firestore에 업로드 해야 됨. 우선 firestorage에 사진 url을 우선적으로 저장하고 이걸 다시 가져오는 방식으로
                        //if(userProvider.userModel==null) {print(userProvider.userModel!.address.toString());return;} //safe 코드 작성


                        final num? price = num.tryParse(
                            _priceController.text.replaceAll(new RegExp(r"\D"), '')); // RegExp으로 숫자를 제외한 모든것을 없애준다 String을 num으로 바꿔서 저장
                        List<Uint8List> images = context
                            .read<SelectImageNotifier>()
                            .images; //images를 가져오기

                        List<String> downLoadUrls = await ImageStorage
                            .uploadImages(images, itemKey);
                       ItemModel itemModel = ItemModel(itemKey: itemKey,
                           userKey: userProvider.userKey,
                           imageDownloadUrls: downLoadUrls,
                           title: _titleController.text,
                           category: context
                               .read<CategoryProvider>()
                               .currentCategoryInEng,
                           price: price ?? 0,
                           //null 이면 0으로 저장
                           negotiable: _suggestPriceSelected,
                           detail: _detailController.text,
                             address: userProvider.userModel!.address, //이미 safe 코드 작성했음
                           geoFirePoint: GeoFirePoint(2,3),
                           createdDate: DateTime.now().toUtc()); //현재 시간을 넣어준다
//
//
                       await ItemService().createdNewItem(itemModel, itemKey,userProvider.userKey); //firestore에 itemModel을 json으로 저장해주기

                     
                        context.beamBack(); //beamer를 이용한 back버튼 생성
                      },
                      child: Text('완료', style: Theme
                          .of(context)
                          .textTheme
                          .bodyText2))
                ],
                leading: TextButton(
                  //가장 앞에 있는 leading에 버튼 넣기
                    style: TextButton.styleFrom(
                      backgroundColor:
                      Theme
                          .of(context)
                          .appBarTheme
                          .backgroundColor, primary: Colors.black87,),
                    //클릭 시 클릭이 보이도록 색깔 설정
                    onPressed: () {
                      context.beamBack(); //beamer를 이용한 back버튼 생성
                    },
                    child: Text(
                      '뒤로',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText2,
                    )),
                title: Text(
                  "중고거래 글 쓰기",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ), //appbar의 중심 제목
              ),
              body: ListView(
                //위 아래로 스크롤 되는 listview
                children: [
                  MultiImageSelect(),
                  _divider,
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                        hintText: '글 제목',
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: common_padding),
                        //글시에 대한 padding을 주기 위해서는 contentpadding 사
                        border: _border,
                        enabledBorder: _border,
                        focusedBorder: _border),
                  ),
                  _divider,
                  ListTile(
                    onTap: () {
                      context.beamToNamed(
                          '/input/category_input'); //beamToNamed로 다른 screen으로 넘어가도록 해줌
                    },
                    //listtile 이 압축된것인지 아닌지, listtile은 행이 1개 일 때 여러 row 느낌으로 사용하는 것, appbar와 비슷한 느낌?
                    dense: true,
                    title: Text(context
                        .watch<CategoryProvider>()
                        .currentCategoryInKor),
                    //한국어로 가져와서 보여줌
                    trailing: Icon(Icons.navigate_next),
                  ),
                  _divider,
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: common_padding),
                            child: TextFormField(
                              controller: _priceController,
                              inputFormatters: [
                                MoneyInputFormatter(
                                    mantissaLength: 0, trailingSymbol: '원')
                              ],
                              //mantissalLength로 소숫점 뒤에 붙어있는것 안보이도록, trailing으로 '원' 글자를 붙여서
                              //pubspec.yaml 에서 가져온 moneyformatter
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                //onchanged에서는 textformfield에 입력한 값이 value로 받아져와 어떠한 변경을 해줌
                                if (value == '0원')
                                  _priceController
                                      .clear(); //MoneyInputformatter default 값이 0 이기 때문에 이것을 안보이게 하고 싶어서 clear를 시킨다
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                  hintText: '얼마에 사시겠어요?',
                                  prefixIcon: ImageIcon(
                                    ExtendedAssetImageProvider(
                                        'assets/images/icons8-apple-logo-48.png'),
                                    color: (_priceController.text.isEmpty)
                                        ? Colors.grey[350]
                                        : Colors.black,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                      maxWidth: 20),
                                  //prefixIcon을 사용할 때 가로 사이즈는 boxconstraint를 사용한다
                                  contentPadding:
                                  EdgeInsets.symmetric(
                                      vertical: common_sm_padding),
                                  //conentpadding을 줘서 글씨가 중앙에 오도록 한다
                                  //icon, prefix, postfix 등 무엇을 사용할지는 사용자에 따라서 달라짐. 약간의 padding 차이
                                  //icon에 ImageIcon을 가져오려면 ExtendedImageProvider를 사용해서 가져오면 된다
                                  border: _border,
                                  enabledBorder: _border,
                                  focusedBorder: _border),
                            ),
                          )),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _suggestPriceSelected =
                            !_suggestPriceSelected; //누를때마다 false,true가 번갈아가며
                          });
                        },
                        icon: Icon(
                          _suggestPriceSelected
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: _suggestPriceSelected
                              ? Theme
                              .of(context)
                              .primaryColor
                              : Colors.black54,
                        ),
                        label: Text(
                          "가격제안 받기",
                          style: TextStyle(
                              color: _suggestPriceSelected
                                  ? Theme
                                  .of(context)
                                  .primaryColor
                                  : Colors.black54),
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            primary: Colors
                                .black), //primary로 버튼을 누를 때 색깔이 바뀌도록 설정, backgound는 투명색
                      )
                    ],
                  ),
                  _divider,
                  TextFormField(
                    controller: _detailController,
                    maxLines: null,
                    //여러개의 줄이 생기게 하기 위해서는 그냥 null로 주면 됨
                    keyboardType: TextInputType.multiline,
                    //typing을 할 때 엔터키가 완료가 아니라 진짜 엔터키가 나오도록 함
                    decoration: InputDecoration(
                        hintText: '올릴 게시글을 입력해 주세요',
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: common_padding),
                        //글시에 대한 padding을 주기 위해서는 contentpadding 사
                        border: _border,
                        enabledBorder: _border,
                        focusedBorder: _border),
                  ),
                ],
              )),
        );
      },
    );
  }
}
