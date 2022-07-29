import 'package:beamer/beamer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hello/router/locations.dart';
import 'package:hello/screens/start_screen.dart';
import 'package:hello/screens/splash_screen.dart';
import 'package:hello/states/user_provider.dart';
import 'package:provider/provider.dart';

final _routerDelegate = BeamerDelegate(
    locationBuilder: BeamerLocationBuilder(beamLocations: [HomeLocation(),InputLocation(),ItemLocation()]), //Beamer를 사용하는 location들을 모두 적어야 한다
    guards: [
      BeamGuard(
          pathBlueprints: [...HomeLocation().pathBlueprints,...InputLocation().pathBlueprints,...ItemLocation().pathBlueprints], //각 pathBlueprint 즉 경로를 모두 넣어주어 없을 시 로그인화면으로 가도록
          check: (context, location) {
            return context.watch<UserProvider>().userState; //true or false, context.watch로 changeNotifier의 provider에 관한 변수를 접근할 수 있음, context.read는 listen false 임
          }, //notifylistener 가 실행될 때마다 watch를 통해서 계속 값이 바뀜
          //만약 Beamguard check에서 false가 return 되면 showPage를 보여주라는 의미. 항상 Beamer는 BeamPage를 통해서 pagewidget 을 받아온
          showPage: BeamPage(child: StartScreen()))
    ]); //HomeLocation에서 blueprint를 읽어 알아서 beamber가 화면 전환
//guards는 로그인이 안되어있을 때 홈 화면으로 가지 못하도록 막는 역할, '/'이 홈화면이기 때문에 guarad로 막아줌

void main() async{
  Provider.debugCheckInvalidValueType=null; //일반적인 provider 를 사용하기 위해서 ,원래는 상태 변화에 따라서 위젯들을 바꿔주는데 사용만 할거면 이것을 적어줘야 함
  WidgetsFlutterBinding.ensureInitialized(); //firebase 와 flutter의 widget들을 연결 시켜주는 역할로 firebase 사용할 떄 초기화 과정이라 생각하면 됨
  runApp(Myapp()); //flutter를 시작하는 함수 (가장 큰 widget이 runApp 안에 들어와야 함, widget=component)
}

class Myapp extends StatefulWidget {
  //widget의 종류는 2가지가 있음 stf, stl. firebase 사용처럼 변경되어야 하는 위젯이면 stf 를 사용
  const Myapp({Key? key}) : super(key: key);

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  @override //build에 대한 재정의를 해야한다
  Widget build(BuildContext context) {
    //buildcontext 현재의 상태를 의미한다
    return FutureBuilder(
        future: Firebase.initializeApp(), //future 값을 return 하기 때문에 여기에 써서 사용
        //future는 데이터를 가져올때까지 다른일 하면서 기다리기 ,future:에서 future값 받아와
        builder: (context, snapshot) {
          //snapshot을 이용해서 사용
          //return _splashLoadingWidget(snapshot);
          return AnimatedSwitcher(
              duration: Duration(seconds: 1),
              child: _splashLoadingWidget(
                  snapshot)); //animatedSwitcher는 해당 위젯의 상태가 변할때 자동으로 fade 해줌
        });
  }

  StatelessWidget _splashLoadingWidget(AsyncSnapshot<Object?> snapshot) {
    if (snapshot.hasError) {
      //snapshot은 3개의 상태 있음 , hasError, hasData, 아직 불어와지지 않은 상
      print("error occur");
      return Text("error",textDirection: TextDirection.ltr,);
    } else if (snapshot.connectionState==ConnectionState.done) { //연결이 되어 있는 상태라면
      return TomatoApp();
    } else {
      return SplashScreen();
    }
  }
}

class TomatoApp extends StatelessWidget {
  const TomatoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>( //changeNotifierProvider를 여기에 줘서다 user_provider의 값을 routerDelegate에서 이용할 수 있도록 한
      create: (BuildContext context) { //<UserProvider> 를 명시해야 아래 위젯에서 UserProvider에 관련한 데이터들을 접근해서 찾을 수 있음
        return UserProvider();
      },
      child: MaterialApp.router(
        theme: ThemeData(
            primarySwatch: Colors.red,
            hintColor: Colors.grey[350],
            //TextFormFeild의 hint 색깔 지정
            textTheme: TextTheme(
              subtitle2: TextStyle(color: Colors.grey,fontSize: 13),
                subtitle1: TextStyle(color: Colors.black87,fontSize: 15),
                headline1: TextStyle(fontFamily: 'Nanum'),
                bodyText2: TextStyle(color: Colors.black87,fontSize:12,fontWeight: FontWeight.w300 ),
                button: TextStyle(color: Colors.white)),
            fontFamily: 'Nanum',
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(backgroundColor: Colors.red,primary: Colors.white,minimumSize: Size(48,48))), //기본 textbutton 지정해준다
            appBarTheme: AppBarTheme(
             foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                titleTextStyle: TextStyle(
                    color: Colors.black87, fontFamily: 'Nanum', fontSize: 28),
                elevation: 2,actionsIconTheme: IconThemeData(color: Colors.black87)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(selectedItemColor: Colors.black87,unselectedItemColor: Colors.black54)),
        //primaryScatch 로 알아서 글씨 색깔을 지정해준다, fontFamily로 font 바꿔줌
        //materialapp.router 는 materialapp과는 약간 다름
        routeInformationParser: BeamerParser(),
        routerDelegate: _routerDelegate, //global 변수로 할당된 beamer를 전달해주기
      ),
    );
  }
}
