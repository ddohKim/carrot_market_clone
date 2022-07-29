class TimeCalculation{
  static String getTimeDiff(DateTime createdDate){ //static으로 정적으로 두어 굳이 인스턴스 생성없이 사용가능
    DateTime now=DateTime.now();
    Duration timeDiff=now.difference(createdDate); //현재시간 now에서 createdDate 만들어진 시간을 빼서 이를 duraiton으로 나타낸다
    if(timeDiff.inHours<=1){
      return '  방금 전';
    }
    else if(timeDiff.inHours<=24)
     { return '  ${timeDiff.inHours} 시간 전';}
    else
    {
      return '  ${timeDiff.inDays} 일 전';} //몇일 전
  }
}