import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:hello/constants/common_size.dart';
import 'package:hello/constants/shared_pref_keys.dart';
import 'package:hello/states/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

VerificationStatus _verificationStatus =
    VerificationStatus.none; //처음 로그인 상태는 아무것도 없는 상태

class _AuthPageState extends State<AuthPage> {
  static const duration = Duration(milliseconds: 300);

  final inputBorder = OutlineInputBorder(
      //외부 테두리 설정해주는 OutlineInputBorder
      borderSide: BorderSide(color: Colors.grey));

  TextEditingController _phoneNumberController =
      TextEditingController(text: "010"); //command+d 키로 바로 복사 하기
  TextEditingController _codeController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>(); //formkey 사용하는 방법

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        Size size = MediaQuery.of(context).size;
        return IgnorePointer(
          // ignorepointer 아래 있는 모든 것들을 무시할 수 있는 위젯
          ignoring: _verificationStatus == VerificationStatus.verifying,
          //verifying 일때만 true로 해주어 추가적인 버튼 터치를 하지 못하도록 한다
          child: Form(
            //Form을 통해 값을 입력하여 이것을 사용할 수 있음(전화번호 입력값 확인 등)
            key: _formKey,
            child: Scaffold(
              appBar: AppBar(
                title: Text('전화번호 로그인',
                    style: Theme.of(context).appBarTheme.titleTextStyle),
              ), //elevation으로 그림자 설정해주기
              body: Padding(
                padding: const EdgeInsets.all(common_padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        ExtendedImage.asset(
                          'assets/images/icons8-apple-logo-48.png',
                          width: size.width * 0.15,
                          height: size.width * 0.15,
                        ),
                        SizedBox(
                          height: common_sm_padding,
                        ),
                        Text(
                            "토마토마켓은 휴대폰 번호로 가입해요.\n번호는 안전하게 보호되며\n어디에도 공개되지 않아요")
                      ],
                    ),
                    SizedBox(
                      height: common_padding,
                    ),
                    TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        //숫자만 기입할 수 있도록 숫자 키보드로 설정
                        inputFormatters: [
                          MaskedInputFormatter('000 0000 0000')
                        ],
                        //MaskedInputFormatter로 기본 타이핑 설정을 할 수 있다
                        decoration: InputDecoration(
                            focusedBorder: inputBorder, border: inputBorder),
                        validator: (phoneNumber) {
                          //validator를 이용하여 현재 phoneNumber가 제대로 들어왔는지 확인할 수 있음
                          if (phoneNumber != null && phoneNumber.length == 13) {
                            return null; //null을 return 하면 validator는 에러가 없다고 판단, true
                          } else {
                            return '전화번호 입력 다시 하세요'; //false로 판단
                          }
                        }),
                    SizedBox(
                      height: common_padding,
                    ),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState != null) //null이 아닐 때
                        {
                          bool passed = _formKey.currentState!.validate();
                          if (passed)
                            setState(() {
                              //한 화면에서 상태변화를 보려면 setState를 사용해서 변경을 해줘야 한다
                              _verificationStatus = VerificationStatus.codeSent;
                            });
                        }
                      },
                      child: Text("인증문자 받기"),
                    ),
                    SizedBox(
                      height: common_padding,
                    ),
                    AnimatedOpacity(
                      duration: duration,
                      opacity: (_verificationStatus == VerificationStatus.none)
                          ? 0
                          : 1, //투명도가 처음에는 0에서 1로 바뀜
                      child: AnimatedContainer(
                        //애니메이션을 주어서 현재 상태에 따라 container를 안보이게 했다가 보이게 할 수 있
                        duration: duration,
                        curve: Curves.easeInOut,
                        height: getVerificationHeight(_verificationStatus),
                        child: TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          //숫자만 기입할 수 있도록 숫자 키보드로 설정
                          inputFormatters: [MaskedInputFormatter("000000")],
                          //MaskedInputFormatter로 기본 타이핑 설정을 할 수 있다
                          decoration: InputDecoration(
                              focusedBorder: inputBorder, border: inputBorder),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: common_padding,
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeInOut,
                      height: getVerificationHeight(_verificationStatus),
                      child: TextButton(
                        onPressed: () {
                          attemptVerify();
                          UserProvider().setNewUser();
                        },
                        child: (_verificationStatus ==
                                VerificationStatus.verifying)
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "인증번호 확인",
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _getAddress() async {
    //sharedpreference를 이용하여 주소 받아오기, 데이터베이스로 넘길 임시 저장 데이터들에 주로 사용
    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    String address = prefs.getString(SHARED_ADDRESS) ?? ""; //key 값은 shared_pref.keys.dart 에 따로 저장해놨음
    double lat = prefs.getDouble(SHARED_LAT) ?? 0;
    double lon = prefs.getDouble(SHARED_LON) ?? 0;
  }

  void attemptVerify() async {
    //async await는 항상 같이 사용

    setState(() {
      _verificationStatus = VerificationStatus.verifying;
    });
    await Future.delayed(Duration(seconds: 1)); //1초동안 기다리기 위해서 await사용
    setState(() {
      _verificationStatus = VerificationStatus.verificationDone;
    });

    context.read<UserProvider>().setUserAuth(
        true); //read로 해야 listener 가 false 이므로 값이 1번만 변경되고 여기로 다시 암옴 watch는 값이 변경되면 watch 된 모든 곳을 다시 찾기 때문에 무한루프돔
  }
}

double getVerificationHeight(VerificationStatus status) {
  switch (status) {
    case VerificationStatus.none:
      return 0;
    case VerificationStatus.codeSent:

    case VerificationStatus.verifying:

    case VerificationStatus.verificationDone:
      return 35 +
          common_padding; //codeSent, verifying, verificaitonDone 모두 같은 크기이기 때문에 한번에 써줌
  }
}

enum VerificationStatus {
  //인증여부 상태를 enum으로 표현
  none,
  codeSent,
  verifying,
  verificationDone
}
