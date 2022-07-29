import 'package:flutter/material.dart';

CategoryProvider categoryProvider=CategoryProvider();//미리 instance생성 해줌, singleton으로 해주는게 best?!


class CategoryProvider extends ChangeNotifier {//영어로 표현해주는게 가장 좋음
   String _selectedCategoryInEng = 'none'; //private으로 설정해서 다른 곳에서 이 _selected를 직접적으로 접근 못하도록 해줌
  String get currentCategoryInEng=>_selectedCategoryInEng;  //대신 currentCategoryInEng으로 접근함
  String get currentCategoryInKor=>categoriesMapEngToKor[_selectedCategoryInEng]!; //currentKor은 Map index를 통해서 받아온다

void setNewCategoryWithEng(String newCategory){ //setNewCategoryWithEng함수로 newCategory를 받아와서 notifyLisner로 값이 변경되었음을 알린다
  if(categoriesMapEngToKor.keys.contains(newCategory)){ //newCategory라는 string을 받아올 때 categoryinEng 에 들어있는지 없는지 혹시 모를 경우를 대비해야 한다
    _selectedCategoryInEng=newCategory;
    notifyListeners();
  }
}
  void setNewCategoryWithKor(String newCategory){ //한국어가 들어올 수 도 있기 때문에 newCategory를 받아와서 notifyLisner로 값이 변경되었음을 알린다
    if(categoriesMapEngToKor.values.contains(newCategory)){ //newCategory라는 string을 받아올 때 해당 한국어가 들어있는지 없는지 혹시 모를 경우를 대비해야 한다
      _selectedCategoryInEng=categoriesMapKorToEng[newCategory]!; //한글이 들어왔기 때문에 이를 다시 영어로 변경해주어야 한다
      notifyListeners();
    }
  }

}

const Map<String, String> categoriesMapEngToKor = { //
  'none': '선택',
  'furniture': '가구',
  'electronics': '전자기기',
  'kids': '유아동',
  'sports': '스포츠',
  'etc': '기타'
};


Map<String, String> categoriesMapKorToEng=categoriesMapEngToKor.map((key, value) => MapEntry(value, key)); //현재 EngtoKor의 Key,value를 가져와서 이를 바꿔서 다시 MapEntry를 통해 저장
