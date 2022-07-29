import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hello/constants/common_size.dart';
import 'package:provider/provider.dart';

class IntroPage extends StatelessWidget {
 // PageController controller; //pagecontroller를 authscreen에서 받아오기
  IntroPage( {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Size size = MediaQuery.of(context)
          .size; //size를 가져오기, 실제 어플을 만들때는 maybeOf 를 이용해서 null의 상황 역시 대비을 해야 한다.

      final imgSize = size.width - 32;
      final sizeOfPosImg = imgSize * 0.1;

      return SafeArea(
        //상태바 등에 가려지지 않도록 safearea
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: common_padding),
          //좌우에 padding 주
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            //폰마다 스크린 사이즈가 다르기때문에 주로 이런거 사용하는게 좋음
            children: [
              Text("토마토마켓",
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(color: Theme.of(context).colorScheme.primary)),
              //copywith에 들어있는 것을 제외한 모든 것을 headline1으로 통일시켜
              Container(
                width: imgSize, //사이즈를 스크린 화면에 맞게 하기
                height: imgSize,
                child: Stack(
                  //widget 쌓기
                  children: [
                    ExtendedImage.asset('assets/images/icons8-facebook-48.png'),
                    Positioned(
                        width: sizeOfPosImg,
                        left: imgSize * 0.45,
                        height: sizeOfPosImg,
                        top: imgSize * 0.45,
                        child: ExtendedImage.asset(
                            'assets/images/icons8-twitter-48.png')),
                  ],
                ),
              ),
              Text("우리 동네 중고 직거래 토마토마켓",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              //Theme.of를 이용해 primarySwatch 색 가져옴
              Text("토마토마켓은 동네 직거래 마켓이에요. \n   내 동네를 설정하고 시작해보세요!",
                  style: Theme.of(context).textTheme.headline5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //boundary를 늘려주기
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<PageController>().animateToPage(1, //provider를 사용해서 controller를 접근하는 것
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease);
                      //var response=await Dio.get('url'); Dio 는 http 즉 외부의 데이터를 가져와서 사용할 때 사용하는 library


                    },
                    child: Text("내 동네 설정하고 시작하기",
                        style: Theme.of(context).textTheme.button),
                    style: TextButton.styleFrom(
                      //ButtonStyle보다 TextButton.stylefrom이 더 이용하기 쉬움
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
