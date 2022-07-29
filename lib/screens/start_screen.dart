import 'package:flutter/material.dart';
import 'package:hello/screens/start/address_page.dart';
import 'package:hello/screens/start/auth_page.dart';
import 'package:hello/screens/start/intro_page.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatelessWidget {
  StartScreen({Key? key}) : super(key: key);


  PageController _pageController=PageController(); //pagecontroller로 페이지 넘길수 있도록 하기

  @override
  Widget build(BuildContext context) {
    return Provider<PageController>.value( //pageController를 다른 page에서도 자유롭게 사용하기 위해서 provider를 이용해서 전달해주고자 함
      value: _pageController, //value로 공유하고자하는 것을 전달
      child: Scaffold(
        body: PageView( //좌우로 스크린 스크롤 가능한 PageView
          controller: _pageController,
          //physics: NeverScrollableScrollPhysics(), //스크롤이 불가능하게 함
          children: [
            IntroPage(),
            AddressPage(),
            AuthPage(),
            Container(color: Colors.accents[6])
          ],
        ),
      ),
    );
  }
}
