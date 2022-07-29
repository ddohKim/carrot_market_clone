import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hello/constants/common_size.dart';
import 'package:hello/data/item_model.dart';
import 'package:hello/screens/item/item_detail_screen.dart';

class SimilarItem extends StatelessWidget {
  final ItemModel _itemModel;
  const SimilarItem(this._itemModel,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell( //클릭이 가능하도록 설정
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){ //navigator 1을 사용해서 클릭시 해당 페이지로 넘어가는 역할을 함(stack으로 쌓임)
          return ItemDetailScreen(_itemModel.itemKey);
        }));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AspectRatio(
            aspectRatio: 5/4, //사진의 비율이 가로가 5, 세로가 4으로 비율을 정해준다
            child: ExtendedImage.network(
              _itemModel.imageDownloadUrls[0], //첫번째 사진만 보여줌
              fit: BoxFit.cover, //사진이 꽉 차지도록
           borderRadius: BorderRadius.circular(8),shape: BoxShape.rectangle, ),
          ),
          Text(
            _itemModel.title,
            overflow: TextOverflow.ellipsis, //글자가 초과되었을 시 ellipsis(생략)를 준다(...)
            maxLines: 1, //최대 라인은 1줄
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: common_padding),
            child: Text('${_itemModel.price.toString()}원',style: Theme.of(context).textTheme.subtitle2),
          )
        ],
      ),
    );
  }
}
