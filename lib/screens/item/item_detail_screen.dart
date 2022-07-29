import 'package:beamer/beamer.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hello/constants/common_size.dart';
import 'package:hello/data/item_model.dart';
import 'package:hello/repository/chat_service.dart';
import 'package:hello/repository/item_service.dart';
import 'package:hello/screens/item/similar_item.dart';
import 'package:hello/states/category_provider.dart';
import 'package:hello/widgets/time_calculation.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../data/chatroom_model.dart';
import '../../data/user_model.dart';
import '../../states/user_provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemKey; //어떤 아이템인지 확인하는 키를 받아온다
  const ItemDetailScreen(this.itemKey, {Key? key})
      : super(key: key); //this.itemKey 로 키를 받아옴

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  PageController _pageController =
      PageController(); //smooth Page indicator를 사용하기 위해서는 pagecontroller 필요하다

  ScrollController _scrollController =
      ScrollController(); //스크롤 할 때 어느정도 스크롤했는지 알기 위해서
  Size? _size;
  bool isAppbarCollapsed = false; //스크롤을 하여 현재 사진이 안 보이는 스크롤을 했을 정도인지 확인
  num? _statusBarHeight;

  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(() {
      if (_size == null || _statusBarHeight == null)
        return; //size가 null이면 바로 return
      if (isAppbarCollapsed) {
        //만약 이미 true라면
        if (_scrollController.offset <= //만약 스크롤이 0보다 크다면 아직 색깔을 false로 바꿈
            _size!.width - kToolbarHeight - _statusBarHeight!) {
          isAppbarCollapsed = false;
          setState(() {});
        }
      } else {
        if (_scrollController.offset >
            _size!.width - kToolbarHeight - _statusBarHeight!) {
          isAppbarCollapsed = true;
          setState(() {});
        }
      }
    }); //addlistener를 하면 이 controller가 실행될때마다 안의 함수가 실행이 된다
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose(); //메모리 절약을 위해 필수적으로 controller는 dispose해줌
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      ScaffoldMessenger.of(context)
          .clearMaterialBanners();
    });


    return FutureBuilder<ItemModel>(
        future: ItemService().getItemModel(widget.itemKey), //itemModel 정보를 가져온다
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ItemModel itemModel =
                snapshot.data!; //itemModel instance에 해당 data를 넘겨준다
            UserModel userModel = context
                .read<UserProvider>()
                .userModel!; //userModel 을 provider를 통해서 가지고 온다
            return LayoutBuilder(
              builder: (context, constraints) {
                _size = MediaQuery.of(context).size;
                _statusBarHeight =
                    MediaQuery.of(context).padding.top; //상태바 길이를 의미한다
                return Stack(
                  //앱바의 색깔이 어두워서 잘 안보이는것을 방지하기 위해서 stack을 사용해서 위에 반투명한 것을 추가로 넣는다
                  fit: StackFit.expand, //해당 stack 화면이 꽉 차도록 설정
                  children: [
                    Scaffold(
                        bottomNavigationBar: SafeArea(
                          top: false,
                          bottom: true,
                          //iphone의 swipe할때 이를 방지하기 위해서 바닥을 true로 해준다
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(color: Colors.grey[300]!))),
                            //bottomNavigationbar를 구분해주기 위해서 top에 border를 줘 이를 통해 구역을 나눈다
                            child: Padding(
                              padding: const EdgeInsets.all(common_sm_padding),
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.favorite_border)),
                                  VerticalDivider(
                                    thickness: 1,
                                    width: common_sm_padding * 2 + 1,
                                    //두께가 1이고 indent 양 끝이 common_sm_padding이기 때문에 가로를 이렇게 준다
                                    indent: common_sm_padding,
                                    endIndent: common_sm_padding,
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "4000원",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Text(
                                        '가격제안불가',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      )
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  TextButton(
                                      onPressed: () async{
                                        String chatroomKey = //chatroomKey를 새로 생성해준다
                                            ChatroomModel.generateChatRoomKey(
                                                userModel.userKey,
                                                widget.itemKey);
                                        ChatroomModel _chatroomModel =
                                            ChatroomModel(
                                                //새로운 chatroom 만들어주기
                                                itemImage: itemModel.imageDownloadUrls.isEmpty?"":itemModel
                                                    .imageDownloadUrls[0],
                                                itemTitle: itemModel.title,
                                                itemKey: widget.itemKey,
                                                itemAddress: itemModel.address,
                                                itemPrice: itemModel.price,
                                                sellerKey: itemModel.userKey,
                                                buyerKey: userModel.userKey,
                                                sellerImage:
                                                    'https://picsum.photos/50',
                                                buyerImage:
                                                    'https://picsum.photos/50',
                                                geoFirePoint:
                                                    itemModel.geoFirePoint,
                                                chatroomKey: chatroomKey,
                                                lastMsgTime: DateTime.now());
                                        await ChatService()
                                            .createNewChatroom(_chatroomModel);

                                        context.beamToNamed('/item/${widget.itemKey}/$chatroomKey'); //해당 chatroom으로 이동한다

                                      },
                                      child: Text("채팅으로 거래하기"))
                                ],
                              ),
                            ),
                          ),
                        ), //BottomNavigationBar 사용도 되고 custom한 widget도 됨
                        body: CustomScrollView(controller: _scrollController,
                            //scoll이 어느정도 되었는지 확인하는 controller
                            //customScrollview는 sliver로 받아야하는데 sliver는 그냥 위젯 list가 아닌 sliver 위젯이 와야 한다. (slivertoboxadaptor로 묶으면 됨), sliver를 list 내 하나의 slice 단위라고 생각하면 됨
                            slivers: [
                              _imagesAppBar(itemModel, context),
                              //expanedHeight는 앱바의 최대 높이
                              SliverPadding(
                                //sliver를 패딩주는 방법
                                padding: EdgeInsets.all(common_sm_padding),
                                sliver: SliverList(
                                    //여기서는 widet이 아닌 sliver를 사용한다
                                    delegate: SliverChildListDelegate([
                                  //sliverlist를 이용해서 list widget들을 넣어줄것 이때 SliverchildlistDelegate로 하나씩 넣어준다
                                  _userSection(userModel),
                                  _divider(),
                                  Text(
                                    itemModel.title,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  SizedBox(
                                    height: common_padding,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        categoriesMapEngToKor[
                                            itemModel.category]!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .copyWith(
                                                decoration:
                                                    TextDecoration.underline),
                                      ),
                                      Text(
                                        '${TimeCalculation.getTimeDiff(itemModel.createdDate)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: common_padding,
                                  ),
                                  Text(
                                    itemModel.detail,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  SizedBox(
                                    height: common_padding,
                                  ),
                                  Text(
                                    "조회 33",
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                  _divider(),
                                  MaterialButton(
                                      //textbutton이 아니라 materialbutton을 사용 이미 textbutton은 font등 특정 모양이 정해져 있기 때문
                                      padding: EdgeInsets.zero,
                                      //padding을 0으로 주고 alignment를 맞춰줌
                                      onPressed: () {},
                                      child: Align(
                                          //왼쪽으로 align 해주기
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "이 게시글 신고하기",
                                          ))),
                                  _divider(),
                                  Row(
                                    children: [
                                      Text(
                                        "무무님의 판매 상품",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Expanded(child: Container()),
                                      SizedBox(
                                          width: _size!.width / 4,
                                          //임의로 가로 사이즈를 지정해주기 그래야 정확히 자리가 잡힘
                                          child: MaterialButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {},
                                              child: Align(
                                                  //alignment 지정해줘서 오른쪽 끝으로 가도록
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text("더보기"))))
                                    ],
                                  ),
                                ])),
                              ),
                              SliverToBoxAdapter(
                                //slivertoboxadapter 내에는 일반 widget이 오기 때문에 future를 풀어 user_item을 가져오려면 이를 사용하면 된다
                                child: FutureBuilder<List<ItemModel>>(
                                  future: ItemService().getUserItems(
                                      userModel.userKey, itemModel.itemKey),
                                  //userKey를 던져줘서 future를 풀어준다
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: common_sm_padding),
                                        child: GridView.count(
                                          padding: EdgeInsets.zero,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          //physics로 따로 gridview로만 scroll이 불가능하도록 해줌
                                          //GridView.count로 좌우로 개수를 지정해줘서 grid한 list 생성해준다
                                          shrinkWrap: true,
                                          // false면 두개가 있을 때 화면을 꽉 채우게 되는데 true로 두면 꽉 차지 않고 원하는 크기 만큼 채워지게 됨
                                          crossAxisCount: 2,
                                          childAspectRatio: 7 / 8,
                                          //가로가 7, 세로가 8
                                          mainAxisSpacing: common_sm_padding,
                                          //padding을 main, cross 모두 줘서 공간을 만들어준다
                                          crossAxisSpacing: common_sm_padding,
                                          children: List.generate(
                                              snapshot.data!.length,
                                              (index) => SimilarItem(
                                                  snapshot.data![index])),
                                        ),
                                      );
                                    }
                                    return Container(); //없으면 빈 깡통만 던져줌
                                  },
                                ),
                              ),
                            ])),
                    Positioned(
                        left: 0,
                        right: 0,
                        height: kToolbarHeight + _statusBarHeight!,
                        //앱바 길이+상태바 길이
                        top: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter, //시작을 가장 위쪽 가운데에서
                                  end: Alignment.bottomCenter, //끝을 가장 아래 가운데
                                  colors: [
                                Colors.black12,
                                Colors.black12,
                                Colors.black12,
                                Colors.black12,
                                Colors.transparent
                              ])), //linear graident가 되도록 색깔을 연하게 주기
                        )),
                    Positioned(
                        //사이즈를 앱바+상태바의 길이만큼만 보이도록 설정
                        left: 0,
                        right: 0,
                        height: kToolbarHeight + _statusBarHeight!,
                        //앱바 길이+상태바 길이
                        top: 0,
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          appBar: AppBar(
                            backgroundColor: (isAppbarCollapsed)
                                ? Colors.white
                                : //만약 isAppbarCollapsed가 true면  흰색 화면으로 가리기
                                Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: isAppbarCollapsed
                                ? Colors.black87
                                : Colors.white,
                          ),
                        )),
                  ],
                );
              },
            );
          } else {
            return Scaffold(
                body: Center(child: const CircularProgressIndicator()));
          }
        });
  }

  Widget _divider() {
    return Divider(
      height: common_sm_padding * 2 + 1,
      thickness: 2,
      color: Colors.grey[300]!,
    );
  }

  SliverAppBar _imagesAppBar(ItemModel itemModel, BuildContext context) {
    return SliverAppBar(
      expandedHeight: _size!.width,
      pinned: true,
      //pinned를 통해 scroll을 해도 appbar가 약간은 남아있도록 해준다
      flexibleSpace: FlexibleSpaceBar(
        title: SmoothPageIndicator(
          controller: _pageController,
          count: itemModel.imageDownloadUrls.isEmpty
              ? 1
              : itemModel.imageDownloadUrls.length,
          effect: WormEffect(
              activeDotColor: Theme.of(context).primaryColor,
              dotColor: Theme.of(context).colorScheme.background,
              radius: 2,
              dotHeight: 4,
              dotWidth: 4),
          onDotClicked: (index) {
//pageindicator를 넣어줄 수 있다
          },
        ),
        centerTitle: true, //title이 가운데로 올 수 있도록
        background: PageView.builder(
          //pageview.builder로 좌우로 스크롤 가능한 앱바를 만들어준다
          controller: _pageController,
          allowImplicitScrolling: true,
          //옆 페이지를 미리 loading를 해서 더 자연스럽게 표현해준다
          itemBuilder: (BuildContext context, int index) {
            return ExtendedImage.network(
              //item 사진들을 가져온다
              itemModel.imageDownloadUrls.isEmpty
                  ? 'https://picsum.photos/50'
                  : itemModel.imageDownloadUrls[index],
              fit: BoxFit.cover,
              scale: 0.1, //10%로 줄여서 보여준다
            );
          },
          itemCount: itemModel.imageDownloadUrls.length,
        ),
      ),
    );
  }

  Widget _userSection(UserModel userModel) {
    return Padding(
      padding: const EdgeInsets.all(common_sm_padding),
      child: Row(
        children: [
          ExtendedImage.network(
            'https://picsum.photos/50',
            fit: BoxFit.cover,
            width: _size!.width / 10,
            height: _size!.width / 10,
            shape: BoxShape.circle,
          ),
          SizedBox(
            width: common_sm_padding,
          ),
          SizedBox(
            height: _size!.width / 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  //'무무',
                  userModel.userKey.substring(0, 4),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  //'배곡동',
                  userModel.address,
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          ),
          SizedBox(
            width: common_sm_padding,
          ),
          Expanded(child: Container()), //중간에 꽉찬 expanded container 추가
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, //꽉 차도록 설정
                      children: [
                        Text(
                          "37.3도",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        SizedBox(
                            width: 42, //사이즈를 줘야 실행이 됨
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              //minHeight가 3이기 때문에 2를 줘서 양 모서리가 깎이도록 한다
                              child: LinearProgressIndicator(
                                //선을 그리기 위해서 linearprogressindicator를 사용함
                                minHeight: 3, //최소 높이는 3
                                value: 0.373, //온도 크기를 의미한다(value 값 지정시 멈춰있음)
                                color: Colors.blueAccent,
                                backgroundColor: Colors.grey[200],
                              ),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Icon(
                    Icons.android,
                    color: Colors.blue,
                  )
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                "매너온도",
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    decoration: TextDecoration
                        .underline), //copyWith는 이 부분만 따로 변경을 해준다는 의미.textdecoration에서 밑줄 찾기
              )
            ],
          )
        ],
      ),
    );
  }
}
