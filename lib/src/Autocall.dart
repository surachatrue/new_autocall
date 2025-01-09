import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialpad/flutter_dialpad.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// void main() => runApp(CallScreen());

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  bool _isCalling = false;
  late AnimationController _animationController;
  late Animation<Color?> _textColorAnimation;
  String name = '';
  String phoneNumber = '';
  String additionalDetails = ''; // รายละเอียดเพิ่มเติม
  bool granted = false;
  String telegramLinkraw = '';
  bool savebutton = false;

  String callstate = "";

  Future requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    if (statuses[Permission.phone]!.isGranted &&
        statuses[Permission.storage]!.isGranted &&
        statuses[Permission.manageExternalStorage]!.isGranted) {
      return true;
    } else {
      return false;
    }
  }



  @override
  void initState() {
    super.initState();
    // if (Platform.isIOS) setStream();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _textColorAnimation = ColorTween(begin: Colors.white, end: Colors.red)
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          elevation: 0,
          title: Text(
            _isCalling ? 'กำลังค้นหา' : 'การโทร',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            // IconButton(
              // Qr scanner
              // icon: Icon(Icons.qr_code),
              // onPressed: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => DialPadPage(),
              //     ),
              //   );
              // },
            // ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.blueGrey[900],
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: _textColorAnimation,
                        builder: (context, child) {
                          return DialPad(
                              enableDtmf: true,
                              //outputMask: "(000) 000-0000",
                              hideSubtitle: false,
                              backspaceButtonIconColor: Colors.red,
                              buttonTextColor: Colors.white,
                              dialOutputTextColor: Colors.white,
                              keyPressed: (value) {
                                print('$value was pressed');
                              },
                              makeCall: (number) {
                                print(number);
                              });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
