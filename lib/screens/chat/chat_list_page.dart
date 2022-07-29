import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hello/data/chatroom_model.dart';
import 'package:hello/repository/chat_service.dart';
import 'package:hello/states/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:beamer/beamer.dart';
class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userKey = context
        .read<UserProvider>()
        .userKey;
    return FutureBuilder<List<ChatroomModel>>(
      //ChatroomModel list를 받아올 수 있는 futuerbuilder 생성
        future: ChatService().getMyChatList(userKey),
        //userKey를 전달해줘서 getmychatList를 불러옴, 이걸 아래 snapshot이란 이름으로 사용한다
        builder: (context, snapshot) {
          Size _size = MediaQuery
              .of(context)
              .size;
          return Scaffold(
            body: ListView.separated(
                itemBuilder: (context, index) {
                  ChatroomModel chatroomModel =
                  snapshot.data![index]; //snapshot에서 charoomModel 하나씩 가져온다
                  bool iamBuyer = chatroomModel.buyerKey ==
                      userKey; //내가 buyer인지 seller인지 구분지음
                  return ListTile(
                    onTap: (){context.beamToNamed('/${chatroomModel.chatroomKey}');}, //클릭 시 해당 chatscreen으로 갈 수 있도록
                    leading: ExtendedImage.network(
                      'https://picsum.photos/100',
                      shape: BoxShape.circle,
                      fit: BoxFit.cover,
                      height: _size.width / 8,
                      width: _size.width / 8,
                    ),
                    trailing: ExtendedImage.network(
                      chatroomModel.itemImage,
                      shape: BoxShape.rectangle,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(4),
                      height: _size.width / 8,
                      width: _size.width / 8,
                    ),
                     title: RichText(
                       maxLines: 2, //최대 줄은 2줄로 설정
                         overflow: TextOverflow.ellipsis, //overflow가 나면 ...으로 보여준다
                         text: TextSpan(
                             style: Theme.of(context)
                                 .textTheme //글씨체를 다르게 하려면 richtext를 써서 해주면 된다
                                 .subtitle1,
                             text: iamBuyer
                                 ? chatroomModel.sellerKey //내가 buyer라면 sellerkey를 보여줘야 한다(상대방 이름이 보이도록 나중에 설정해주면 된다)
                                 : chatroomModel.buyerKey,
                             children: [
                           TextSpan(text: " "),
                           TextSpan(
                               style: Theme.of(context).textTheme.subtitle2,
                               text: chatroomModel.itemAddress)
                         ])),
                 //  title: Row(
                 //    children: [
                 //      Expanded( //주소가 다 보이도록 하고 싶음
                 //        child: Text(
                 //            iamBuyer
                 //                ? chatroomModel
                 //                .sellerKey //내가 buyer라면 sellerkey를 보여줘야 한다(상대방 이름이 보이도록 나중에 설정해주면 된다)
                 //                : chatroomModel.buyerKey, style: Theme
                 //            .of(context)
                 //            .textTheme //글씨체를 다르게 하려면 richtext를 써서 해주면 된다
                 //            .subtitle1,      maxLines: 1, //최대 줄은 1 설정
                 //             overflow: TextOverflow.ellipsis, //overflow가 나면 ...으로 보여준다
                 //        ),
                 //      ),Text(
                 //          chatroomModel.itemAddress, style: Theme
                 //          .of(context)
                 //          .textTheme
                 //          .subtitle2,    maxLines: 1, //최대 줄은 1줄로 설정
                 //        //     overflow: TextOverflow.ellipsis, //overflow가 나면 ...으로 보여준다
                 //      )
                 //    ],
                 //  ),
                    subtitle: Text(

                      chatroomModel.lastMsg,
                      maxLines: 1, //최대 줄은 2줄로 설정
                      overflow: TextOverflow.ellipsis, //overflow가 나면 ...으로 보여준다
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText1,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 1,
                    height: 1,
                    color: Colors.grey[300],
                  );
                },
                itemCount: snapshot.hasData
                    ? snapshot.data!.length
                    : 0), //snapshot 데이터가 존재한다면 그 길이를 itemCount로 준다
          );
        });
  }
}
