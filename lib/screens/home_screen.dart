import 'package:flutter/material.dart';
import 'package:hello/constants/common_size.dart';
import 'package:hello/screens/chat/chat_list_page.dart';
import 'package:hello/screens/home/items_page.dart';
import 'package:hello/states/user_provider.dart';
import 'package:hello/widgets/expandable_fab.dart';
import 'package:provider/provider.dart';
import 'package:beamer/beamer.dart';

import '../data/user_model.dart';
class HomeScreen extends StatefulWidget {
  //인덱스가 계속 바뀌기 때문에 stf
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
   // UserModel? userModel=context.read<UserProvider>().userModel;
    return Scaffold(
      floatingActionButton: ExpandableFab(distance: 90, children: [ //floatingActionButton을 사용해도 되지만 임의로 만든 expandablefab을 사용해도 문제 없음
    MaterialButton(onPressed: (){
      context.beamToNamed('/input');
      
      
    }, shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(common_padding)),
      height: 24,minWidth:24,color: Theme.of(context).colorScheme.primary,
      child: Icon(Icons.add),
        ),

        MaterialButton(onPressed: (){}, shape: CircleBorder(),
          height: 24,color: Theme.of(context).colorScheme.primary,
          child: Icon(Icons.android),
          //꼭짓점만 깍아주기 위해서는 직사각형으로 명시를 해준 상태에서
        ),
        MaterialButton(onPressed: (){}, shape: CircleBorder(),
          height: 24,color: Theme.of(context).colorScheme.primary,
          child: Icon(Icons.outbond),
          //꼭짓점만 깍아주기 위해서는 직사각형으로 명시를 해준 상태에서
        ),
      ],),
      body: IndexedStack( //index 로 stack을 쌓는다는 의미, navigationbar가 어떤걸 클릭하느냐에 따라 해당 stack이 가장 위로 보임, 미리 로딩이되어 있어 전환 속도 빠름
        index: _bottomSelectedIndex,
        children: [
          ItemsPage(userKey:UserProvider().userKey), //0번째 index일때
          ChatListPage(),
          Container(color: Colors.accents[_bottomSelectedIndex],),
          Container(color: Colors.accents[_bottomSelectedIndex],)
        ],
      ),
        appBar: AppBar(
          //actions로  IconButton을 추가할 수 있음
          centerTitle: false, //타이틀을 왼쪽으로 가도록 해줌
          title: Text(
            "공덕동",
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ), //style을 appbartheme으로 맞추기
          actions: [
            IconButton(
                onPressed: () {
                  context.read<UserProvider>().setUserAuth(false);
                  context.beamToNamed('/'); //홈페이지로 이동 후 로그아웃 해야 정상적으로 로그아웃
                },
                icon: Icon(Icons.logout)),
            IconButton(onPressed: () {

              context.beamToNamed('/search'); //search screen 으로 이동

            }, icon: Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: Icon(Icons.menu))
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomSelectedIndex, //해당 페이지 인덱스가 어디 있는지 확인할 때 쓰임
          onTap: (index) {
            //아이콘을 누를때하다 해당 Index를 받아옴
            setState(() {
              _bottomSelectedIndex = index; //이것을 계속 저장을 해줘서 아이콘 및 화면이 바뀔수 있도록
            });

          },
          type: BottomNavigationBarType.fixed, //버튼 클릭 시 애니메이션을 없앰
          items: [
            //최소 2개 이상
            BottomNavigationBarItem(
                icon: Icon(_bottomSelectedIndex == 0
                    ? Icons.home
                    : Icons.home_outlined),
                label: ""), //BottomNavigationBarItem에서 icon을 사용
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage(_bottomSelectedIndex == 1
                    ? 'assets/images/icons8-apple-logo-48.png'
                    : 'assets/images/icons8-twitter-48.png',)),
                label: ""),
            BottomNavigationBarItem(
                icon: Icon(_bottomSelectedIndex == 2
                    ? Icons.work
                    : Icons.work_outline),
                label: ""),
            BottomNavigationBarItem(
                icon: Icon(_bottomSelectedIndex == 3
                    ? Icons.outbond
                    : Icons.outbond_outlined),
                label: ""),
          ],
        ));
  }
}
