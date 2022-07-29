import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hello/constants/common_size.dart';
import 'package:beamer/beamer.dart';
import 'package:hello/data/chat_model.dart';
import 'package:hello/data/chatroom_model.dart';
import 'package:hello/data/user_model.dart';
import 'package:hello/repository/chat_service.dart';
import 'package:hello/states/chat_provider.dart';
import 'package:hello/states/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'chat.dart';

class ChatroomScreen extends StatefulWidget {
  final String chatroomKey;

  const ChatroomScreen(this.chatroomKey, {Key? key}) : super(key: key);

  @override
  _ChatroomScreenState createState() => _ChatroomScreenState();
}

OutlineInputBorder _border = OutlineInputBorder(
    //outlineinputborder에 border를 설정할 수있음
    borderRadius: BorderRadius.circular(20), //radious는 둥글게 20
    borderSide: BorderSide(color: Colors.grey));

class _ChatroomScreenState extends State<ChatroomScreen> {
  bool _isBanner = false;

  TextEditingController _textEditingController = TextEditingController();
  late ChatProvider _chatProvider; //chatProvider instance 하나 만들어줘서
  @override
  void initState() {
    _chatProvider = ChatProvider(widget
        .chatroomKey); //initState로 처음 widget이 생성될때 미리 _chatProvider를 생성하고 들어감
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>.value(
      //changeNotifier로 chatprovider를 구독한다
      value: _chatProvider,
      child: Consumer<ChatProvider>(
        //Consumer로 ChatProvider 구독
        builder: (context, chatProvider, child) {
          //가운데 value는 _chatProvider로 생각하면 된다
          Size _size = MediaQuery.of(context)
              .size; //이미 builder를 생성하기 때문에 layoutBuilder 필요없다
          UserModel userModel =
              context.read<UserProvider>().userModel!; //userModel 을 가져온다
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                  context.beamBack();
                },
              ),
            ),
            backgroundColor: Colors.grey[100],
            body: Center(
              child: SafeArea(
                child: Column(children: [
                  //action에는 원래 text위젯을 넣어줘서 이게 클릭되었을 때 어떤 행동을 취하도록 해줌
                  SizedBox(
                    height: 20,
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      height: 20,
                      child: _isBanner
                          ? IconButton(
                              icon: Icon(
                                Icons.keyboard_arrow_up,
                                size: 15,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentMaterialBanner(); //현재 banner를 닫기
                                _isBanner = false;

                                setState(() {});
                              })
                          : IconButton(
                              color: Colors.white,
                              onPressed: () {
                                _showBanner(context);
                                _isBanner = true;

                                setState(() {});
                              },
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                size: 15,
                                color: Colors.black87,
                              )),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    //채팅창 만들어주기
                    color: Colors.white,
                    child: ListView.separated(
                        reverse: true,
                        //반대로 순서 바꾸기
                        padding: EdgeInsets.all(common_padding),
                        //각 채팅 도형들에 모두 padding을 준다
                        itemBuilder: (context, index) {
                          bool _isMine = chatProvider.chatList[index].userKey ==
                              userModel
                                  .userKey; //만약 userModel의 userKey와 같다면 내 채팅을 의미
                          return Chat(
                            size: _size,
                            isMine: _isMine,
                            chatModel: chatProvider.chatList[index],
                          ); //채팅을 chatList[index] 각각을 하나씩 만들어 줌
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 12);
                        },
                        itemCount: chatProvider.chatList.length),
                  )),
                  _buildInputBar(userModel),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBanner(BuildContext context) {
    ChatroomModel? chatroomModel =
        context.read<ChatProvider>().chatroomModel; //chatroomModel을 받아온다
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        //배너 보여주는 방법
        padding: EdgeInsets.zero,
        leadingPadding: EdgeInsets.zero,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, top: 4, left: 16),
                  child: SizedBox(
                    height: 40,
                    child: chatroomModel == null //chatroomModel이 받아올때까지 contianer를 보여준다
                        ? Shimmer.fromColors( //shimmer로 감싸주어 좀 더 디자인적으로 예쁘께
                      highlightColor: Colors.grey[300]!, // shimmer로 loading 화면 깔끔해보이도록
                          baseColor: Colors.grey,
                          child: Container(
                      width: 32,height: 32,color: Colors.white,
                    ),
                        )
                        : ExtendedImage.network(
                            chatroomModel.itemImage,
                            fit: BoxFit.cover,
                      width: 32,height: 32,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: common_padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "거래완료   ",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Text(
                            chatroomModel==null?"":chatroomModel.itemTitle,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            chatroomModel==null?"":'${chatroomModel.itemPrice.toString()}원',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Text(" (가격제안 불가)",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: Colors.grey,
                                  )),
                        ],
                      )
                    ],
                  ),
                )
              ],

              //   contentPadding: EdgeInsets.only(left: 4, right: 8),
              //   title: RichText(
              //       //richtext로 여러개의 text에 대한 font를 다르게 할 수 있다. 이때 textspan으로 받기
              //       text: TextSpan(
              //           text: '거래완료',
              //           style: Theme.of(context).textTheme.bodyText1,
              //           children: [
              //         TextSpan(
              //             text: ' 이케아 소르테라 분리수거함 4개',
              //             style: Theme.of(context).textTheme.bodyText2)
              //       ])),
              //   subtitle: RichText(
              //       //richtext로 여러개의 text에 대한 font를 다르게 할 수 있다. 이때 textspan으로 받기
              //       text: TextSpan(
              //           text: '30000원',
              //           style: Theme.of(context).textTheme.bodyText1,
              //           children: [
              //         TextSpan(
              //             text: ' (가격제안불가)',
              //             style: Theme.of(context)
              //                 .textTheme
              //                 .bodyText2!
              //                 .copyWith(color: Colors.grey))
              //       ])),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: SizedBox(
                height: 32, //버튼 크기 지정해주기
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.black,
                  ),
                  label: Text(
                    "후기 남기기",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                              color: Colors.grey, width: 1))), //글자 style변경
                ),
              ),
            ),
          ],
        ),
        actions: [Container()]));
  }

  Widget _buildInputBar(UserModel userModel) {
    return SizedBox(
      height: 48, //사이즈를 지정해줘야 에러가 안난다
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.add,
              color: Colors.grey,
            ),
          ),
          Expanded(
              child: TextFormField(
            controller: _textEditingController,
            decoration: InputDecoration(
                hintText: '메세지를 입려하세요',
                isDense: true,
                //isDense로 약간 수직적으로 빽빽하게 만들어줌
                fillColor: Colors.white,
                //fillColor를 통해서 내부 색깔을 주고
                filled: true,
                //filled가 true여야 색깔이 변경됨
                suffixIcon: GestureDetector(
                    //IconButton 으로도 할 수 있는데 이는 클릭 가능한 구간이 커져서 gestureDector가 더 유용하다
                    onTap: () {},
                    child: Icon(Icons.emoji_emotions_outlined,
                        color: Colors.grey)),
                suffixIconConstraints: BoxConstraints.tight(Size(40, 40)),
                //가로 세로 40으로 설정해 놓아 이모지 이모티콘 크기를 설정한다.(원의 반지름이 20으로 설정되어있음)
                focusedBorder: _border,
                enabledBorder: _border,
                contentPadding: EdgeInsets.all(10),
                //contentpadding은 내부의 content와 outline간의 Padding을 의미하는데 이를 줄여줘 더 작게 만들어준다(dense 느낌)
                border: _border), //테두리 색깔
          )),
          IconButton(
              onPressed: () {
                ChatModel chatModel = ChatModel(
                    msg: _textEditingController.text,
                    createdDate: DateTime.now(),
                    userKey: userModel.userKey);

                _chatProvider.addNewChat(chatModel);
                //await ChatService().createNewChat(chatModel, widget.chatroomKey); //firestore에 chat 저장
                _textEditingController.clear(); //메세지를 보낸것을 다시 지워준다
              },
              icon: Icon(
                Icons.send,
                color: Colors.grey,
              ))
        ],
      ),
    );
  }
}
