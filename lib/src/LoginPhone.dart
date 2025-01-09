import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:ags_authrest2/ags_authrest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
// import 'package:mobile_number/mobile_number.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simnumber/sim_number.dart';
import 'package:simnumber/siminfo.dart';

// void main() => runApp(LoginPhone());

class LoginPhone extends StatefulWidget {
  @override
  _LoginPhoneState createState() => _LoginPhoneState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class _LoginPhoneState extends State<LoginPhone>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String name = '';
  String phoneNumber1 = '';
  String phoneNumber2 = '';
  String simData1 = '';
  String simData2 = '';
  String additionalDetails = ''; // รายละเอียดเพิ่มเติม
  bool granted = false;
  String telegramLinkraw = '';
  bool savebutton = false;
  bool _isCheck = true;
  var auth = Ags_restauth();

  // String _mobileNumber = '';
  final StreamController<String> _mobileNumber = StreamController<String>();

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

  Future<void> initMobileNumberState() async {
    try {
      // requestPermission();
      if (!mounted) return;
      // _mobileNumber.add((await MobileNumber.mobileNumber)!);
      SimInfo _simCard = await SimNumber.getSimData();

      if (_simCard.cards.length == 0) {
        // _showAlertInput('ไม่พบเบอร์โทรศัพท์', DialogType.error);
        _showAlert2('ไม่พบเบอร์โทรศัพท์', DialogType.error);
        setState(() {
          _isCheck = false;
        });
        return;
      }

      var simData1 = _simCard.cards[0];
      log('simData1: $simData1');
      phoneNumber1 = simData1.phoneNumber.toString();
      if (phoneNumber1.startsWith('+66')) {
        phoneNumber1 = phoneNumber1.substring(3);
        phoneNumber1 = '0$phoneNumber1';
      }
      _showAlert2('เบอร์โทรศัพท์ของคุณคือ $phoneNumber1', DialogType.info);

      auth.SECERT_JWT = "GgiTrbw6wryB9g.Qvaz6";
      auth.R_USER = "CF_MYSQL";

      var headers = {
        'Authorization':
            auth.genTokenEncryp(), // genTokenEncryp() or genToken()
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      };

      var bodyData = {
        "database": "BCT_Twilio",
        "query": "SELECT * FROM `login_autocall` WHERE  `phone` = ? LIMIT 1",
        "values": [phoneNumber1]
      };

      var body = json.encode(bodyData);
      var sqlUrl = 'https://agilesoftgroup.com/mysql/query';
      var request = http.Request('POST', Uri.parse(sqlUrl));
      request.body = json.encode(auth.encrypbody(body));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var dataRaw = await response.stream.bytesToString();
        var data = json.decode(dataRaw);
        if (data.length > 0) {
          // check sound path
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

          var bodyCheckBrand = {
            "database": "BCT_Twilio",
            "query": "SELECT * FROM `deviceInfo` WHERE `brand` = ?  LIMIT 1",
            "values": [androidInfo.manufacturer.toLowerCase()]
          };
          var bodyCheckBrandEncode = json.encode(bodyCheckBrand);
          var requestCheckBrand =
              http.Request('POST', Uri.parse(sqlUrl)); // or http.post(sqlUrl);
          requestCheckBrand.body =
              json.encode(auth.encrypbody(bodyCheckBrandEncode));
          requestCheckBrand.headers.addAll(headers);
          http.StreamedResponse responseCheckBrand =
              await requestCheckBrand.send();
          if (responseCheckBrand.statusCode == 200) {
            // _showAlert2('กำลังตรวจสอบข้อมูลของซิมการ์ด', DialogType.info);
            var dataRawCheckBrand =
                await responseCheckBrand.stream.bytesToString();
            var dataCheckBrand = json.decode(dataRawCheckBrand);
            // print(dataCheckBrand);
            if (dataCheckBrand.length > 0 &&
                dataCheckBrand[0]['path'] != null) {
              // print('พบข้อมูล');
              print(dataCheckBrand[0]['path']);
              // เช็คว่ามี path นี้ในเครื่องหรือจริงไหม
              var dir = Directory(dataCheckBrand[0]['path']);
              if (!dir.existsSync()) {
                var bodyCheckBrandList = {
                  "database": "BCT_Twilio",
                  "query": "SELECT `path` FROM `deviceInfo`",
                  "values": [""]
                };
                var bodyCheckBrandListEncode = json.encode(bodyCheckBrandList);
                var requestCheckBrandList = http.Request(
                    'POST', Uri.parse(sqlUrl)); // or http.post(sqlUrl);
                requestCheckBrandList.body =
                    json.encode(auth.encrypbody(bodyCheckBrandListEncode));
                requestCheckBrandList.headers.addAll(headers);
                http.StreamedResponse responseCheckBrandList =
                    await requestCheckBrandList.send();
                if (responseCheckBrandList.statusCode == 200) {
                  var dataRawCheckBrandList =
                      await responseCheckBrandList.stream.bytesToString();
                  var dataCheckBrandList = json.decode(dataRawCheckBrandList);
                  // print(dataCheckBrandList);
                  if (dataCheckBrandList.length > 0) {
                    for (var i = 0; i < dataCheckBrandList.length; i++) {
                      var dir = Directory(dataCheckBrandList[i]['path']);
                      if (dir.existsSync()) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString('path', dataCheckBrandList[i]['path']);
                        prefs.setString('phone', phoneNumber1);
                        prefs.setString('emp_id', data[0]['sip']);
                        prefs.setString('bu', data[0]['bu']);
                        prefs.setString('branch', data[0]['branch']);
                        // navigate to Autocallpage
                        // ignore: use_build_context_synchronously
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/ListPhone',
                          (Route<dynamic> route) => false,
                        );
                        return;
                      }
                    }
                  }
                }
              } else {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                prefs.setString('path', dataCheckBrand[0]['path']);
                prefs.setString('phone', phoneNumber1);
                prefs.setString('emp_id', data[0]['sip']);
                prefs.setString('bu', data[0]['bu']);
                prefs.setString('branch', data[0]['branch']);
                // navigate to Autocallpage
                // ignore: use_build_context_synchronously
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/ListPhone',
                  (Route<dynamic> route) => false,
                );
              }
              // save path

              _showAlert2('ไม่พบข้อมูลของที่อยู่เสียง', DialogType.error);
            } else {
              // print('ไม่พบข้อมูล');
              _showAlert2('ไม่พบ Device ในฐานข้อมูล', DialogType.error);
            }
          } else {
            print('http error');
            _showAlert2(
                'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้', DialogType.error);
          }
          setState(() {
            _isCheck = false;
          });
        } else {
          _showAlert2(
              'ซิมการ์ดไม่ถูกต้องหรือยังไม่ได้ลงทะเบียน', DialogType.error);
          // print('ไม่พบข้อมูล');
        }
      } else {
        _showAlert2(response.statusCode, DialogType.error);
      }

      //
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    requestPermission();
    initMobileNumberState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mobileNumber.close();
    super.dispose();
  }

  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };

  // Widget fillCards() {
  //   print(_simCard);
  //   List<Widget> widgets = _simCard
  //       .map((SimCard sim) => Text(
  //           'Sim Card Number: (${sim.countryPhonePrefix}) - ${sim.number}\nCarrier Name: ${sim.carrierName}\nCountry Iso: ${sim.countryIso}\nDisplay Name: ${sim.displayName}\nSim Slot Index: ${sim.slotIndex}\n\n'))
  //       .toList();

  //   return Column(children: widgets);
  // }

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
          actions: [],
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
                      _title(),
                      // if (_isCheck)
                      //   ElevatedButton(
                      //     onPressed: () {
                      //       _showAlert1('เข้าสู่ระบบ', DialogType.info);
                      //     },
                      //     child: Text('เริ่มใช้งาน'),
                      //   ),
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

  _showAlert1(message, dialogType) {
    AwesomeDialog(
      context: context,
      // barrierColor: Color.fromARGB(255, 36, 68, 123),
      dialogBackgroundColor: Colors.blueGrey[900],
      animType: AnimType.scale,
      dialogType: dialogType,
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              message,
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
            ),
            const SizedBox(
              height: 10,
            ),
            // CircularProgressIndicator(),
          ],
        ),
      ),
      btnCancel: ElevatedButton(
        onPressed: () {
          // Navigator.pop(context);
          initMobileNumberState();
        },
        child: Text('login'),
      ),
    )..show();
  }

  _showAlert2(message, dialogType) {
    AwesomeDialog(
      context: context,
      // barrierColor: Color.fromARGB(255, 36, 68, 123),
      dialogBackgroundColor: Colors.blueGrey[900],
      animType: AnimType.scale,
      dialogType: dialogType,
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              message,
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
            // CircularProgressIndicator(),
          ],
        ),
      ),
      btnCancel: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('ปิด'),
      ),
    )..show();
  }

  _showAlertInput(message, dialogType) {
    AnimatedButton(
      text: 'Body with Input',
      color: Colors.blueGrey,
      pressEvent: () {
        late AwesomeDialog dialog;
        dialog = AwesomeDialog(
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.info,
          keyboardAware: true,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Form Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Material(
                  elevation: 0,
                  color: Colors.blueGrey.withAlpha(40),
                  child: TextFormField(
                    autofocus: true,
                    minLines: 1,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Material(
                  elevation: 0,
                  color: Colors.blueGrey.withAlpha(40),
                  child: TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    minLines: 2,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                AnimatedButton(
                  isFixedHeight: false,
                  text: 'Close',
                  pressEvent: () {
                    dialog.dismiss();
                  },
                )
              ],
            ),
          ),
        )..show();
      },
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'PKG',
          style: GoogleFonts.portLligatSans(
            // textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: ' AutoCall',
              style: TextStyle(
                  color: Color.fromARGB(255, 224, 139, 48), fontSize: 30),
            ),
            TextSpan(
              text: '3',
              style: TextStyle(color: Colors.redAccent, fontSize: 40),
            ),
          ]),
    );
  }
}
