import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController _textEditingController=TextEditingController();
  @override
  void dispose() {
_textEditingController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //appbar에 검색창을 넣는다
        titleSpacing: 0, //titleSpacing은 제목의 여유 공간을 의미하는데 이를 0으로 주어 꽉 차게 한다
        title: Padding(
          padding: const EdgeInsets.only(right: 8), //오른쪽에만 패딩 8정도 준다
          child: Container(

            child: Center( // 검색창 중앙으로 오도록 설정
              child: TextFormField(
                textInputAction: TextInputAction.go, //enter키를 누르면 검색을 한다는 의미
                controller: _textEditingController,
                onFieldSubmitted: (value){ //제출이 되는 순간(즉 검색이 끝나는 순간을 파악) 엔터나 done을 누르면 된다

                },
                decoration: InputDecoration( // TextformField 내부 꾸미기
                  isDense: true,//위 아래 빽빽하게 해준다
                    fillColor: Colors.grey[200],
                    filled: true, //filled를 해야 filledColor 적용
                    hintText: '아이템 검색',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8,vertical: 8), //contentpadding 은 글자와 textformfield 테두리의 padding을 의미한다
                    focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.transparent)),
                    enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.transparent)),
                  //  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.transparent)) //border는 focused. enabled... 등 하나도 사용을 안해야 border를 사용한다
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(title: Text(_textEditingController.text),);
          },
          separatorBuilder: (context, index) {
            return Container();
          },
          itemCount: 30),
    );
  }
}
