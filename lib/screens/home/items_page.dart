import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hello/constants/common_size.dart';
import 'package:hello/data/item_model.dart';
import 'package:hello/data/user_model.dart';
import 'package:hello/repository/item_service.dart';
import 'package:hello/repository/user_service.dart';
import 'package:hello/states/user_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:beamer/beamer.dart';
import 'package:provider/provider.dart';
class ItemsPage extends StatefulWidget {

  final String userKey;
  const ItemsPage({Key? key, required this.userKey}) : super(key: key);
  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {

   final List<ItemModel> _items=[]; //itemModel list를 업데이트를 해서 refreshindicator를 사용하도록 한다
   List<ItemModel> _items2=[];
  bool init= false; //init 플래그가 없으면 재실행할 때마다 _onRefresh가 2번 실행됨
  @override
  void initState() { //state가 새로 시작할 때 _onRefresh를 호출해서 가장 처음에도 화면이 보이도록 설정
    if(init==false)
    {_onRefresh();
    init=true;}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size size = MediaQuery.of(context).size;
        final imgSize = size.width / 4; //imageSize를 줘서 화면비율에 맞게 설정
             return AnimatedSwitcher(
                 duration: Duration(milliseconds: 800),
                 //바뀔 수 있도록 animatedSwitcher
                 child: (_items.isNotEmpty) //만약 데이터가 존재한다면 listview를 보여준다
                     ? _listView(imgSize)
                     : _shimmerListView(imgSize));
        //return _listView(imgSize);
        // return _shimmerListView(imgSize);
        //return FutureBuilder<List<ItemModel>>(
        //    //firestore에서 itemmodel list를 받아오기
        //    //future builder를 이용해서
        //    future: ItemService().getItems(), //item list를 받아오기
        //    builder: (context, snapshot) {
        //      return AnimatedSwitcher(
        //          duration: Duration(milliseconds: 800),
        //          //바뀔 수 있도록 animatedSwitcher
        //          child: (snapshot.hasData &&
        //                  snapshot
        //                      .data!.isNotEmpty) //만약 데이터가 존재한다면 listview를 보여준다
        //              ? _listView(imgSize, snapshot.data!)
        //              : _shimmerListView(imgSize));
        //    });

        // return FutureBuilder( //future builder를 이용해서
        //     future: Future.delayed(Duration(seconds: 2)), //2초동안 duration이 있는 다음
        //     builder: (context, snapshot) {
        //       return AnimatedSwitcher(
        //         duration: Duration(milliseconds: 800), //바뀔 수 있도록 animatedSwitcher
        //         child: (snapshot.connectionState != ConnectionState.done) //연결이 안끝났다면
        //             ? _shimmerListView(imgSize)
        //             : _listView(imgSize),
        //       );
        //     });
      },
    );
  }

  Future _onRefresh() async{
_items.clear();
_items2.clear();
_items.addAll(await ItemService().getItems(widget.userKey) ); //ItemService.getItems 로 새로 받아온 아이템들을 _item에 넣어줌, 자신의 item은 제외시킨다
_items2=_items.reversed.toList(); //가장 최근 것이 가장 위로 오도록 설정
    setState(() {

    });
  }

  Widget _listView(double imgSize) {
    return RefreshIndicator( //refreshIndicator로 새로운 정보 업데이르 할수 있도록 해줌
      onRefresh: _onRefresh,
      child: ListView.separated(
//reverse: true,
        //listview.separated 사용해서 list 만듬, 각 tile이 떨어져 있으면 더 깔끔해보임
        padding: EdgeInsets.all(common_padding),
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: common_padding * 2 + 1,
            //divider  전체 높이
            thickness: 1,
            //divider 선 의 두께
            color: Colors.grey[300],
            indent: common_sm_padding,
            //앞에서 어느정도 떨어져있는지 indent
            endIndent: common_sm_padding,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          ItemModel item = _items2[index];
          return InkWell(
            //InkWell, gestureDector로 터치가 안되는 것을 터치되도록 만들어 준다
            onTap: () {
              //UserService().firestoreTest();
              //  UserService().firestoreReadTest();

              context.beamToNamed('/item/${item.itemKey}') ; //context.beamToNamed에서 /item/:item.itemKey(해당 키로 iteme들 구분)를 전달해준다
            },
            child: SizedBox(
              height: imgSize,
              child: Row(
                children: [
                  SizedBox(
                      width: imgSize,
                      child: ExtendedImage.network(
                       item.imageDownloadUrls.isEmpty?"https://picsum.photos/50":item.imageDownloadUrls[0], //첫번째 대표사진만 보여준다
                        shape: BoxShape.rectangle,
                        //꼭짓점만 깍아주기 위해서는 직사각형으로 명시를 해준 상태에서
                        borderRadius: BorderRadius.circular(common_padding),
                        fit: BoxFit.cover,
                      )),

                  //ExtendedImage.network("https://picsum.photos/100",
                  //    shape: BoxShape.rectangle,
                  //     //꼭짓점만 깍아주기 위해서는 직사각형으로 명시를 해준 상태에서
                  //     borderRadius: BorderRadius.circular(common_padding))),
                  //borderRadius 중 circular에 double 값을 줘서 모서리를 깍는다
                  //network 상의 random image 받아오기
                  SizedBox(
                    width: common_padding,
                  ),
                  Expanded(
                      child: Column(
                    //Column이 Row 나머지를 꽉 채울 수 있도록
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text('53', style: Theme.of(context).textTheme.subtitle2),
                      Text("${item.price.toString()}원"),
                      Expanded(child: Container()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            //사이즈 조절
                            height: 16,
                            child: FittedBox(
                              //해당 위젯을 알맞게 알아서 크기를 조절해줌
                              child: Row(children: [
                                Icon(
                                  Icons.messenger_outline,
                                ),
                                Text('23'),
                                Icon(
                                  Icons.android_outlined,
                                ),
                                Text('30')
                              ]),
                            ),
                          ),
                        ],
                      )
                    ],
                  ))
                ],
              ),
            ),
          );
        },
        itemCount: _items2.length,
      ),
    );
  }

  Widget _shimmerListView(double imgSize) {
    //로딩시 shimmer가 반짝반짝 거리도록, 무조건 깜빡이고자 하는 것들은 Container를 사용해야 함
    return Shimmer.fromColors(
      //shimmer doc 에서 참고해서 작성하기
      highlightColor: Colors.grey[300]!,
      baseColor: Colors.grey[100]!,
      enabled: true, //사용할 수 있음
      child: ListView.separated(
        //listview.separated 사용해서 list 만듬, 각 tile이 떨어져 있으면 더 깔끔해보임
        padding: EdgeInsets.all(common_padding),
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: common_padding * 2 + 1,
            //divider  전체 높이
            thickness: 1,
            //divider 선 의 두께
            color: Colors.grey[300],
            indent: common_sm_padding,
            //앞에서 어느정도 떨어져있는지 indent
            endIndent: common_sm_padding,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: imgSize,
            child: Row(
              children: [
                Container(
                  width: imgSize,
                  height: imgSize,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      //꼭짓점만 깍아주기 위해서는 직사각형으로 명시를 해준 상태에서
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          common_padding)), //borderRadius 중 circular에 double 값을 줘서 모서리를 깍는다
                ),
                SizedBox(
                  width: common_padding,
                ),
                Column(
                  //Column이 Row 나머지를 꽉 채울 수 있도록
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 16,
                        width: 150,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            //꼭짓점만 깍아주기 위해서는 직사각형으로 명시를 해준 상태에서
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3))),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                        height: 16,
                        width: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            //꼭짓점만 깍아주기 위해서는 직사각형으로 명시를 해준 상태에서
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3))),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                        height: 16,
                        width: 180,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            //꼭짓점만 깍아주기 위해서는 직사각형으로 명시를 해준 상태에서
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3))),
                    Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            //사이즈 조절
                            height: 14,
                            width: 80,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                //꼭짓점만 깍아주기 위해서는 직사각형으로 명시를 해준 상태에서
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3))),
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        },
        itemCount: 10,
      ),
    );
  }
}
