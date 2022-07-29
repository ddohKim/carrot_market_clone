import 'package:flutter/cupertino.dart';
import 'package:hello/data/chat_model.dart';
import 'package:hello/data/chatroom_model.dart';
import 'package:hello/repository/chat_service.dart';

class ChatProvider extends ChangeNotifier {
   ChatroomModel?
      _chatroomModel; //chatroomModel 및 List<ChatModel>을 firestore 에서 가져온다 (휴대폰 캐쉬로 저장해둠)
  List<ChatModel> _chatList = [];
  final String _chatroomKey; //필수적으로 chatprovider에 받아와야 함

  ChatProvider(this._chatroomKey) {
    //todo connect charroom
    ChatService().connectChatroom(_chatroomKey).listen(
        //connectChatroom으로 firestore 와 연결시켜놓고 ㅣisten을 통해 구독? 하는데 chatroomModel이 전달된다
        (chatroomModel) {
      _chatroomModel = chatroomModel;
    });
    //if chat list is empty, todo fetch 10 latest chats
    if (this._chatList.isEmpty) {
      ChatService().getChatList(_chatroomKey).then((chatList) {_chatList
          .addAll(chatList); //_chatroomKey를 받아온다, then으로 future  풀어서 사용
      notifyListeners(); //변경되었음을 알림
    });}
    else{//todo when new chatroom arrive, fetch lastest chats
      if(_chatList[0].reference==null){ //임의로 넣어줄 시 Reference가 비어있음
        _chatList.removeAt(0);
      } //만약 _chatList[0]의 reference가 비어있다면 _chatList의 index 0번을 지워준다
      ChatService().getLatestChatList(_chatroomKey, _chatList[0].reference!).then((lastestChats){ //_chatList[0] 이 가장 마지막 채팅을 의미한다 거기의 reference(참조값)

        _chatList.insertAll(0, lastestChats); //_chatList 가장 앞에 lastestChats을 넣어준다(새로 받아온것들을 넣어줌)
      notifyListeners();
      });
    }
  }


  void addNewChat(ChatModel chatModel){ //채팅 입력이 바로바로 보이도록 하기 위해서 먼저 _chatList에 입력하고 따로 firestore에 새로운 chat을 만듬
    _chatList.insert(0, chatModel); //미리 방금 입력한 채팅을 직접 입력해줌
    notifyListeners();
    ChatService().createNewChat(chatModel, _chatroomKey); //여기서 ChatService의 createNewChat으로 새로운 채팅을 만들어준다
  }

  List<ChatModel> get chatList => _chatList;

  ChatroomModel? get chatroomModel => _chatroomModel;

  String get chatroomKey => _chatroomKey;
}
