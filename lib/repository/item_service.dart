import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello/data/item_model.dart';

import '../constants/data_keys.dart';

class ItemService {
  static final ItemService _itemService = ItemService
      ._internal(); //앱 빌드 시 어떤 곳에서 userService instance 생성하더라도 단 한번만 실행해줌
  factory ItemService() => _itemService; //singleleton ?
  ItemService._internal();

  Future createdNewItem(ItemModel itemModel, String itemKey,String userKey) async {
    DocumentReference<Map<String, dynamic>> itemDocReference =
        FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemKey);
    //documentReference 에  userKey에 해당하는 instance를 가져오는데 이때 없다면 새로 생성

    DocumentReference<Map<String, dynamic>> userItemDocReference = //user에도 items collection을 새로 만들어 여기에 그 정보들을 추가적으로 넣어준다
    FirebaseFirestore.instance.collection(COL_USERS).doc(userKey).collection(COL_USER_ITEMS).doc(itemKey);

    final DocumentSnapshot documentSnapshot = await itemDocReference
        .get(); //현재의 user 가 이미 존재하는 지 존재하지 않는지 확인하기 위해서 이를 사용
    if (!documentSnapshot.exists) {
      //만약 documentSnapshot이 존재하지 않다면
      // await documentReference.set(json);//새로운 Reference에 데이터를 넣어준다
      //transaciton으로 동시에 2군대에 데이터를 update해주는데 둘중하나라도 실패하면 두 곳다 안들어가기 때문에 큰 문제가 없다
     await FirebaseFirestore.instance.runTransaction((transaction) async{ //transaction에서는 기다리는 async가 필요하다
        transaction.set(itemDocReference, itemModel.toJson()); //transaciton은 데이터를이렇게 넣어준다
        transaction.set(userItemDocReference, itemModel.toMinJson()); //줄어든 데이터 minJson을 userItem에 이렇게 넣어준다
      });
    }
  }

  Future<ItemModel> getItemModel(String itemKey) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemKey);
    //documentReference 에 새로운 userKey를 생성하는데
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference
            .get(); //현재의 user 가 이미 존재하는 지 존재하지 않는지 확인하기 위해서 이를 사용

    ItemModel itemModel = ItemModel.fromSnapShot(documentSnapshot);
    return itemModel;
  }

  Future<List<ItemModel>> getItems(String userKey) async {
    //colleciton을 가져와서 그 안에 있는 모든 documents 들을 list로 받아오기
    CollectionReference<Map<String, dynamic>> collectionReference =
        FirebaseFirestore.instance.collection(COL_ITEMS);
    QuerySnapshot<Map<String, dynamic>> snapshots = await collectionReference
        .where('userKey',isNotEqualTo: userKey).get(); //get 을 통해 collection 내 document들을 받아오는데 이때 get은 future, userKey랑 같은 것들은 제외시킴(자기 정보를 제외함)
    List<ItemModel> items = []; //ItemModel을 받아오는 list
    for (int i = 0; i < snapshots.size; i++) {
      ItemModel itemModel = ItemModel.fromQuerySnapShot(snapshots.docs[i]);
      items.add(itemModel);
    }
    return items;
  }


  Future<List<ItemModel>> getUserItems(String userKey,String? itemKey) async { //한 유저가 저장한 item들을 가져오기 ,itemKey로 현재의 item이 보이지 않도록 해줌
    //colleciton을 가져와서 그 안에 있는 모든 documents 들을 list로 받아오기
    CollectionReference<Map<String, dynamic>> collectionReference =
    FirebaseFirestore.instance.collection(COL_USERS).doc(userKey).collection(COL_USER_ITEMS);
    QuerySnapshot<Map<String, dynamic>> snapshots = await collectionReference
        .get(); //get 을 통해 collection 내 document들을 받아오는데 이때 get은 future
    List<ItemModel> items = []; //ItemModel을 받아오는 list
    for (int i = 0; i < snapshots.size; i++) {
      ItemModel itemModel = ItemModel.fromQuerySnapShot(snapshots.docs[i]);
      if(itemKey==null||itemKey!=itemModel.itemKey) //itemKey가 null 이거나 itemKey가 itemModel의 itemKey와 다를때만 넣어준다
      items.add(itemModel);
    }
    return items;
  }

}
