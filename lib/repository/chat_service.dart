import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello/data/chatroom_model.dart';

import '../constants/data_keys.dart';
import '../data/chat_model.dart';

class ChatService {
  static final ChatService _chatService = ChatService
      ._internal(); //앱 빌드 시 어떤 곳에서 userService instance 생성하더라도 단 한번만 실행해줌
  factory ChatService() => _chatService; //singleleton ?
  ChatService._internal();

  //create new chat room
  Future createNewChatroom(ChatroomModel chatroomModel) async {
    DocumentReference<Map<String, dynamic>> documentReference =
    FirebaseFirestore.instance.collection(COL_CHATROOMS).doc(
        ChatroomModel.generateChatRoomKey(
            chatroomModel.buyerKey, chatroomModel.itemKey));
    //documentReference 에  doc에 generateChatroomKey를 통해서 새로운 키를 가지는 document를 만들어준다. (buyerKey+itemKey를 더한것)
    final DocumentSnapshot documentSnapshot =
    await documentReference.get(); //이미 존재하는 지 존재하지 않는지 확인하기 위해서 이를 사용
    if (!documentSnapshot.exists) {
      //만약 documentSnapshot이 존재하지 않다면
      await documentReference
          .set(chatroomModel.toJson()); //새로운 Reference에 데이터를 넣어준다
    }
  }

//create new chat
  Future createNewChat(ChatModel chatModel, String chatroomKey) async {
    DocumentReference<
        Map<String,
            dynamic>> documentReference = FirebaseFirestore.instance
        .collection(COL_CHATROOMS)
        .doc(chatroomKey)
        .collection(COL_CHATS)
        .doc(); //여기서 doc이름은 firestore에서 알아서 저장되도록 하고 나중에 createdDate로 가져올때 순서를 맞춰준다
    //documentReference 에  doc에 generateChatroomKey를 통해서 새로운 키를 가지는 document를 만들어준다. (buyerKey+itemKey를 더한것)

    DocumentReference<Map<String, dynamic>>
    chatroomDocRef = //chatroom에 마지막 메세지 등을 업데이트하기 위해서 이를 새로 불러온다
    FirebaseFirestore.instance.collection(COL_CHATROOMS).doc(chatroomKey);

    await documentReference
        .set(chatModel.toJson()); //무조건 새로운 Reference에 데이터를 넣어준다(새로운 챗을 넣어주기 때문)

    //transaciton으로 동시에 2군대에 데이터를 update해주는데 둘중하나라도 실패하면 두 곳다 안들어가기 때문에 큰 문제가 없다
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      //transaction에서는 기다리는 async가 필요하다
      transaction.set(documentReference,
          chatModel.toJson()); //transaciton은 데이터를 이렇게 넣어준다 (1.chat 데이터를 생성해준다)
      transaction.update(chatroomDocRef, {
        //update를 해야 firestore의 기존 정보가 날아가지 않는다 중요!! (set은 새로 생성)
        'lastMsg': chatModel.msg,
        ' lastMsgTime': chatModel.createdDate,
        'lastMsgUserKey': chatModel.userKey,
      }); // (2.chatroom 에 마지막 메세지 및 마지막 메세지 시간등을 저장)
    });
  }

  Stream<ChatroomModel> connectChatroom(String chatroomKey) {
    //stream으로 chatroom에 대한 정보가 변할때마다 바꿔줘야 하기때문에 계속 연결을 시켜놓아야 한다
    return FirebaseFirestore.instance
        .collection(COL_CHATROOMS)
        .doc(chatroomKey)
        .snapshots()
        .transform(
        snapshotToChatroom); //여기서 chatroomKey doc에 있는 데이터는 chatroomModel에 대한 것이다
  }

  var snapshotToChatroom =
  StreamTransformer< //streamtransformer로 documentsnapshot을 chatroomModel로 바꿔준다
      DocumentSnapshot<Map<String, dynamic>>,
      ChatroomModel>.fromHandlers(handleData: (snapshot, sink) {
    ChatroomModel _chatroomModel = ChatroomModel.fromSnapShot(
        snapshot); //_chatroomModel instance 생성을 해서 여기에 json 데이터를 object로 바꾼것을 넣어줌
    sink.add(
        _chatroomModel); //_chatroomModel이 변경될때마다 sink를 통해 connectChatroom에서 계속 변경이 됨
  });

//get chatroom detail

//get chat list
  Future<List<ChatModel>> getChatList(String chatroomKey) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection(COL_CHATROOMS)
        .doc(chatroomKey)
        .collection(COL_CHATS)
        .orderBy("createdDate",
        descending: true) //내림차순을 true로 해서 가장 최근 순서대로 불러온다
        .limit(10)
        .get(); //chat 을 10개씩만 제한해서 받아오는데 get을 통해 future<querysnpashot> 으로 받아온다

    List<ChatModel> chatlist = [];
    for (var docSnapshot in snapshot.docs) {
      //snapshot.docs에 들어있는 각 docSnapshot들을
      ChatModel chatModel =
      ChatModel.fromQuerySnapShot(docSnapshot); // 낱개의 chatModel 에 각각 넣어줘서
      chatlist.add(chatModel); //chatlist에 하나씩 집어넣는다
    }
    return chatlist;
  }

  //latest chat
  Future<List<ChatModel>> getLatestChatList(//최신 채팅들을 불러오기
      String chatroomKey,
      DocumentReference currentLatestChatRef) async {
    //currentLatestChatRef 는 해당 docreference 를 기준으로 위의 10개를 가져오거나 아래 10개를 가져오는 등의 역할(해당 doc 위치) 을 한다
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection(COL_CHATROOMS)
        .doc(chatroomKey)
        .collection(COL_CHATS)
        .orderBy("createdDate",
        descending: true) //내림차순을 true로 해서 가장 최근 순서대로 불러온다
        .endBeforeDocument(
        await currentLatestChatRef.get()) //현재 doc 기준 더 최근 것들만 불러온다

        .get(); //chat 을 10개씩만 제한해서 받아오는데 get을 통해 future<querysnpashot> 으로 받아온다

    List<ChatModel> chatlist = [];
    for (var docSnapshot in snapshot.docs) {
      //snapshot.docs에 들어있는 각 docSnapshot들을
      ChatModel chatModel =
      ChatModel.fromQuerySnapShot(docSnapshot); // 낱개의 chatModel 에 각각 넣어줘서
      chatlist.add(chatModel); //chatlist에 하나씩 집어넣는다
    }
    return chatlist;
  }

//older chat

  Future<List<ChatModel>> getOlderChatList(//이전 채팅들을 불러오기
      String chatroomKey,
      DocumentReference oldestChatRef) async {
    //currentLatestChatRef 는 해당 docreference 를 기준으로 위의 10개를 가져오거나 아래 10개를 가져오는 등의 역할(해당 doc 위치) 을 한다
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection(COL_CHATROOMS)
        .doc(chatroomKey)
        .collection(COL_CHATS)
        .orderBy("createdDate",
        descending: true) //내림차순을 true로 해서 가장 최근 순서대로 불러온다
        .startAfterDocument(await oldestChatRef.get()) //현재 doc 기준 옛날 채팅들을 불러온다

        .limit(10) //10개만 받아오기
        .get(); //chat 을 10개씩만 제한해서 받아오는데 get을 통해 future<querysnpashot> 으로 받아온다

    List<ChatModel> chatlist = [];
    for (var docSnapshot in snapshot.docs) {
      //snapshot.docs에 들어있는 각 docSnapshot들을
      ChatModel chatModel =
      ChatModel.fromQuerySnapShot(docSnapshot); // 낱개의 chatModel 에 각각 넣어줘서
      chatlist.add(chatModel); //chatlist에 하나씩 집어넣는다
    }
    return chatlist;
  }

  Future<List<ChatroomModel>> getMyChatList(String myUserKey) async {
    List<ChatroomModel> chatroomList = []; //chatroomList에 buyer, seller 모두 넣어준다

    //내가 buyer 경우
    QuerySnapshot<Map<String, dynamic>> buying = await FirebaseFirestore
        .instance
        .collection(COL_CHATROOMS)
        .where('buyerKey', isEqualTo: myUserKey)
        .get(); //buyerKey가 myUserKey와 같은 querysnapshot들만 가져온다

    //내가 seller 인 경우

    QuerySnapshot<Map<String, dynamic>> selling = await FirebaseFirestore
        .instance
        .collection(COL_CHATROOMS)
        .where('sellerKey', isEqualTo: myUserKey)
        .get(); //sellerKey가 myUserKey와 같은 querysnapshot들만 가져온다
    for (var documentSnapshot in buying.docs) { //chatroomList에 받아온 documentSnapshot을 하나씩 넣어준다
      chatroomList.add(ChatroomModel.fromQuerySnapShot(documentSnapshot));
    }
    for (var documentSnapshot in selling.docs) { //chatroomList에 받아온 documentSnapshot을 하나씩 넣어준다
      chatroomList.add(ChatroomModel.fromQuerySnapShot(documentSnapshot));
    }
    chatroomList.sort((a, b) => (a.lastMsgTime).compareTo(b.lastMsgTime)); //lastMsgTime 시간 순서대로 정렬을 해준다
    return chatroomList;

  }
}
