import 'package:ags_authrest2/ags_authrest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialpad/flutter_dialpad.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class DialPadPage extends StatefulWidget {
  @override
  _DialPadPageState createState() => _DialPadPageState();
}

class _DialPadPageState extends State<DialPadPage> with WidgetsBindingObserver {
  String phoneNumber = '';
  var auth = Ags_restauth();

  @override
  void initState() {
    super.initState();
    // setStream();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: DialPad(
                enableDtmf: true,
                //outputMask: "(000) 000-0000",
                hideSubtitle: true,
                backspaceButtonIconColor: Colors.red,
                buttonTextColor: Colors.white,
                dialOutputTextColor: Colors.white,
                keyPressed: (value) {
                  // print('$value was pressed');
                },
                makeCall: (number) async {
                  phoneNumber = number;
                  await FlutterPhoneDirectCaller.callNumber(number);
                  Navigator.pop(context);
                })),
      ),
    );
  }
}
