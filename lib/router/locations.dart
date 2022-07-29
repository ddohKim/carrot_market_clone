import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:hello/screens/chat/chatroom_screen.dart';
import 'package:hello/screens/home_screen.dart';
import 'package:hello/screens/input/category_input_screen.dart';
import 'package:hello/screens/input/input_screen.dart';
import 'package:hello/states/category_provider.dart';
import 'package:hello/states/select_image_notifier.dart';
import 'package:provider/provider.dart';
import '../screens/item/item_detail_screen.dart';
import '../screens/search/search_screen.dart';

class HomeLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(child: HomeScreen(), key: ValueKey('home')),//pathBlueprints에서 '/' 가 전달되면 HomeScreen 으로 이동한다는 의미다 ,key는 크게 중요하지느 않음
      if (state.pathBlueprintSegments
          .contains('search')) //만약 pathBlueprints에 search 단어가 포함되어 있다면
        BeamPage(child: SearchScreen(), key: ValueKey('search')),
    ];
  }

  @override
  List get pathBlueprints => ['/','/search']; //homepage 주소, initial path는 '/'

}

//main screen(back 버튼을 누르면 바로 꺼짐) 위에 추가적으로 screen들을 쌓을 수 잇도록
class InputLocation extends BeamLocation {
  @override
  Widget builder(BuildContext context, Widget navigator) {
    //해당 페이지를 만드는 builder 인데 여기서 changeNotifierProvider로 감싸면 해당, InputScreen, CateGoryINputScreen에서 visible하게 됨
    // TODO: implement builder

    return MultiProvider( //여러개의 provider 사용 시
        providers: [
          ChangeNotifierProvider.value(value: categoryProvider),
          ChangeNotifierProvider(create: (context) => SelectImageNotifier())
        ],

        //.value 사용방법. value 값은 필수로 들어아갸함 ,create 사용시 context를 받아와서 위와 같이 적어주면 된다
        child: super.builder(context, navigator));
  }

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      ...HomeLocation().buildPages(context, state),
      //HomeLocation의 buildPages를 가져와서 리스트 안에 리스트를 포함시킨다(...) 자동으로 가장 아래 HomeLocation이 깔리고 위에 BeamLocation이 생김
      if (state.pathBlueprintSegments
          .contains('input')) //만약 pathBlueprints에 input이라는 단어가 포함되어 있다면
        BeamPage(child: InputScreen(), key: ValueKey('input')),
      if (state.pathBlueprintSegments.contains(
          'category_input')) //만약 pathBlueprints에 category_input 단어가 포함되어 있다면
        BeamPage(child: CategoryInputScreen(), key: ValueKey('category_input'))
    ];
  }

  @override
  List get pathBlueprints => [
        '/input',
        '/input/category_input'
      ]; // '/' 만 있으면 homescreen을 보여주고 /input까지 있으면 해당 inputscreen을 보여줌

}

class ItemLocation extends BeamLocation{
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      ...HomeLocation().buildPages(context, state),
      //HomeLocation의 buildPages를 가져와서 리스트 안에 리스트를 포함시킨다(...) 자동으로 가장 아래 HomeLocation이 깔리고 위에 BeamLocation이 생김
      if (state.pathParameters.containsKey('item_id')//만약 pathParameter 의 키가 item_id라면
      )BeamPage(child: ItemDetailScreen(state.pathParameters['item_id']??""), key: ValueKey('item_id')),//ItemDetailScreen에 해당 키를 전달해준다
      if (state.pathParameters.containsKey('chatroom_id')//만약 pathParameter 의 키가 chatroom_id 가 포함되어 있다면
      )BeamPage(child: ChatroomScreen(state.pathParameters['chatroom_id']??"",), key: ValueKey('chatroom_id')),//chatroomscreen에 해당 키를 전달해준다
    ];
  }

  @override
  List get pathBlueprints => [
    '/item/:item_id/:chatroom_id', //현재 item 위에 item_id 위에 chatroom_id 를 stack 형식으로 쌓는 느낌이다
   '/:chatroom_id' //chatroomlist에서 갈수 있는 또 다른 방법을 만들어준다
  ];

}
