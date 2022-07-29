import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hello/constants/common_size.dart';
import 'package:hello/states/select_image_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
class MultiImageSelect extends StatefulWidget {
  MultiImageSelect({
    Key? key,
  }) : super(key: key);

  @override
  State<MultiImageSelect> createState() => _MultiImageSelectState();
}

class _MultiImageSelectState extends State<MultiImageSelect> {
bool _isPickingImage=false;


  //_image라는 여기서만 사용가능한 변수를 생성
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        //좌우로 스크롤 되는 listview를 하기 위해서는 scrolldirection 지정을 해준다, 이때 정확하게 listview 크기 생성을 위해 크기 지정을 해줘야 함
        SelectImageNotifier selectImageNotifier=context.watch<SelectImageNotifier>(); //watch가 여러번 쓰이기 때문에 한번만 사용하기 위해서 위에서 지정해줌, provider는 location.dart 에 넣어줬다(input screen에 넣기)
        Size _size = MediaQuery
            .of(context)
            .size; //size를 받아옴,
        double imageSize = (_size.width / 3) - common_padding * 2;
        return SizedBox(
          height: _size.width / 3, //가로길이를 1/3로 해줌
          width: _size.width,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: EdgeInsets.all(common_padding), //contianer에 패딩을 줘서
                child: InkWell(
                  onTap: () async {
                    _isPickingImage=true;
                    //imagePicker를 사용해서 앨범을 열게 됨
                    final ImagePicker _picker = ImagePicker();
                    final List<XFile>? images = await _picker.pickMultiImage(imageQuality: 10); //image quality를 줄여서 저장해야 메모리 효율
                    if (images != null && images.isNotEmpty) {
                      //images를 받아와서 이게 널이 아니고 비어있지도 않다면
                   await context.read<SelectImageNotifier>().setNewImages(images); //changeNotifier를 통해서 select_image_notifier의 _images에 값을 넣어준다

                      _isPickingImage=false;
                      setState(() {}); //setState로 상태 변경
                    }
                  },
                  child: Container(
                    width: imageSize, //size에 padding 크기를 빼준
                    decoration: BoxDecoration(
                      //Container 외부에 border를 만든다
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey, width: 1)),
                    child: _isPickingImage?Padding(
                      padding: const EdgeInsets.all(common_sm_padding),
                      child: CircularProgressIndicator(),
                    ):Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //해당 children들이 가운데로 올 수 있도록 설정
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.grey,
                        ),
                        Text(
                          "0 / 10",
                          style: Theme
                              .of(context)
                              .textTheme
                              .subtitle2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ...List.generate(
                //list 내 ㅣist를 넣고 싶을 때는 ...을 앞에 써주면 된다
                 selectImageNotifier.images.length, //ChangeNotifier를 통해서 image 개수 만큼 넣어준다
                      (index) =>
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: common_padding,
                                top: common_padding,
                                bottom: common_padding),
                            //위, 아래, 오른쪽에 padding을 줘서 size를 맞춤
                            child: ExtendedImage.memory(
                              //_images[index], //images index에 하나씩 꺼내온다
                              selectImageNotifier.images[index],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.grey, width: 1),
                              shape: BoxShape.rectangle,
                              fit: BoxFit.cover,
                              //image를 꽉차게 해줌
                              //rectangle로 지정해놓아야 테두리가 깍인다
                              width: imageSize,
                              height: imageSize,
                              loadStateChanged: (state) {
                                //loadStateChanged 를 통해서 현재 사진을 가져오고 있을 때의 loading 화면을 보여줘야 한다
                                switch (state.extendedImageLoadState) {
                                  case LoadState.loading:
                                    return Container(
                                        width: imageSize,
                                        //사진을 가져올 동안은 progressindicator를 보여준다
                                        height: imageSize,
                                        padding: EdgeInsets.all(
                                            imageSize / 3),
                                        child:
                                        CircularProgressIndicator());
                                  case LoadState.completed:
                                    return null; //아무것도 안나타냄
                                  case LoadState.failed:
                                    return Icon(
                                        Icons.cancel); //실패시 실패 아이콘 보여줌
                                }
                              },
                            ),
                          ),
                          Positioned(
                            //stack 안에서만 사용가능한 WIGdet
                              right: 0,
                              top: 0,
                              //오른쪽, 위쪽으로부터 0만큼 떨어져 있음
                              width: 40,
                              //크기를 명시를 해야 정확한 위치에 widget이 위치함 8(패딩크기)+8(패딩크기)+24(위젯 크기)
                              height: 40,
                              child: IconButton(
                                onPressed: () {
                                  selectImageNotifier.removeImage(index); //버튼 클릭시 해당 사진을 remove한다
                                },
                                padding: EdgeInsets.all(8),
                                //위 아래 오른쪽 윈쪽 모두 padding 8 을 줘서 클릭 범위를 넓혀준다
                                icon: Icon(Icons.remove_circle),
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                              ))
                        ],
                      ))
            ],
          ),
        );
      },
    );
  }
}
