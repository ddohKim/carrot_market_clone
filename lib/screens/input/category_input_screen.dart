import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beamer/beamer.dart';
import '../../states/category_provider.dart';

class CategoryInputScreen extends StatelessWidget {
  const CategoryInputScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "카테고리 선택",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: ListView.separated(
          //listview로 여러개의 카테고리 정보를 보여준다
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                context.read<CategoryProvider>().setNewCategoryWithKor(
                    categoriesMapEngToKor.values.elementAt(
                        index)); //setNewCategorywithEng 으로 한글로 설정된 카테고리를 여어로 바꿔준다
                context.beamBack();
              }, //버튼 클릭 후 다시 돌아가기
              title: Text(
                categoriesMapEngToKor.values.elementAt(index),
                style: TextStyle(
                    color:
                        context.read<CategoryProvider>().currentCategoryInKor == //해당 인덱스의 카테고리가 현재 provider의 카테고리가 같다면
                                categoriesMapEngToKor.values.elementAt(index)
                            ? Theme.of(context).primaryColor
                            : Colors.black54),
              ), //Map 데이터의 value들을 가져오는 방법 elementAt을 사용
            );
          },
          separatorBuilder: (context, index) {
            return Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300],
            );
          },
          itemCount: categoriesMapEngToKor.length),
    );
  }
}
