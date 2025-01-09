import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ags_authrest2/ags_authrest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phone_state_background/phone_state_background.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'googleService.dart';

var auth = Ags_restauth();

@pragma('vm:entry-point')
Future<void> phoneStateBackgroundCallbackHandler(
  PhoneStateBackgroundEvent event,
  String number,
  int duration,
) async {
  switch (event) {
    case PhoneStateBackgroundEvent.incomingstart:
      log('Incoming call start, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingmissed:
      log('Incoming call missed, number: $number, duration: $duration s');
      searchFile(number);
      break;
    case PhoneStateBackgroundEvent.incomingreceived:
      log('Incoming call received, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingend:
      {
        log('Incoming call ended, number: $number, duration $duration s');
        searchFile(number);
        break;
      }
    case PhoneStateBackgroundEvent.outgoingstart:
      {
        log('Outgoing call start, number: $number, duration: $duration s');
      }
    case PhoneStateBackgroundEvent.outgoingend:
      {
        log('Outgoing call ended, number: $number, duration: $duration s');
        searchFile(number);
        break;
      }
  }
}

class ListPhone extends StatefulWidget {
  @override
  _ListPhoneState createState() => _ListPhoneState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class _ListPhoneState extends State<ListPhone> with WidgetsBindingObserver {
  String barcode = '';

  List<Map<String, dynamic>> _callHistory = [];
  bool hasPermission = false;
  late MobileScannerController _controller;
  final QRScannerController qrController = Get.put(QRScannerController());
  @override
  void initState() {
    // setStream();
    // WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addObserver(this);
    _requestPermission();
    _fetchCallHistory();
    _hasPermission();
    _initForegroundTask();
    
    super.initState();
  }

  Future<void> _hasPermission() async {
    final permission = await PhoneStateBackground.checkPermission();
    setState(() => hasPermission = permission);
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await PhoneStateBackground.requestPermissions();
    // await _init();
  }

  Future<void> _stop() async {
    await FlutterForegroundTask.stopService();
  }

  Future<void> _init() async {
    if (hasPermission != true) return;
    await PhoneStateBackground.initialize(phoneStateBackgroundCallbackHandler);
  }

  Future<void> _initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.resumed) {
      await _hasPermission();
    }
  }

  Future<void> _fetchCallHistory() async {
    String mnumber2 = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mnumber2 = prefs.getString('phone')!;

    auth.SECERT_JWT = "GgiTrbw6wryB9g.Qvaz6";
    auth.R_USER = "CF_MYSQL";

    var headers = {
      'Authorization': auth.genTokenEncryp(),
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    };
    var bodyData = {
      "database": "BCT_Twilio",
      "query":
          "SELECT * FROM `pkgatc_logs` WHERE `from` = ? ORDER BY `running` DESC LIMIT 5",
      "values": [mnumber2]
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
        setState(() {
          _callHistory = List<Map<String, dynamic>>.from(data);
        });
      } else {
        _showAlert2('ไม่พบข้อมูล', DialogType.error);
      }
    }
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
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          elevation: 0,
          title: IconButton(
            icon: Icon(
              Icons.phone,
              size: 35,
            ),
            onPressed: () {
              _init();
              Navigator.pushNamed(
                context,
                '/DialPadPage',
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.qr_code,
                size: 35,
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AiBarcodeScanner(
                      validator: (value)  {
                        print("This value");
                        print(value.toString());
                        List<dynamic> data = jsonDecode(value.toString()); // Decode the JSON string
                        print("Decoded data: $data");
                        if (data.isNotEmpty && data[0].containsKey('G_Id')) {
                          String gId = data[0]['G_Id'];
                          String sId = data[0]['S_Id'];

                          // Call the controller method with the extracted gId

                           qrController.onScan(gId,sId);
                        } else {
                          print("Invalid Barcode: Missing 'G_Id'");
                        }

                        return value.startsWith('https://docs.google.com/spreadsheets/d/');
                      },
                      canPop: false,
                      onScan: (value){},
                        onDetect: (p0) async {
                          print("p0 type: ${p0.runtimeType}");
                          print("Detect (raw): ${p0.toString()}");


                          // await qrController.onScan(gId);
                        },
                      onDispose: () {
                        debugPrint("Barcode scanner disposed!");
                      },
                      controller: MobileScannerController(
                        detectionSpeed: DetectionSpeed.noDuplicates,
                      ),
                    ),
                  ),
                );
              },
            ),
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
                      _title(),
                      if (_callHistory.isNotEmpty) _buildCallHistory(),
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

  Widget _buildCallHistory() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _callHistory.length,
      itemBuilder: (context, index) {
        var call = _callHistory[index];
        return Card(
          color: Colors.blueGrey[800],
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            leading: Icon(Icons.phone, color: Colors.orangeAccent),
            title: Text(
              'โทรไปยัง: ${call['to']}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            subtitle: Text(
              'เวลา: ${call['date']}',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14.0,
              ),
            ),
            onTap: () async {
              await FlutterPhoneDirectCaller.callNumber(call['to']);
            },
          ),
        );
      },
    );
  }

  _showAlert2(message, dialogType) {
    AwesomeDialog(
      context: context,
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

Future<void> searchFile(String number) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs);
    var pathSound = prefs.getString('path');
    var path = Directory(pathSound!);
    log('searchFile: $number');
    await Future.delayed(Duration(seconds: 5));
    log(number.replaceAll('-', ''));
    List files = path.listSync();

    for (var file in files) {
      // Check if the file is actually a directory or a file
      if (file is File) {
        if (file.path.contains(number.replaceAll('-', ''))) {
          log(file.path);
          log(number);
          await uploadTos3(file.path, number);
          // InsertMySQL("ติดต่อได้", "");
          await Future.delayed(Duration(seconds: 5));
          file.delete();
          break;  // Exit the loop once the file is found and processed
        } else {
          await uploadTos3(file.path, "");
          await Future.delayed(Duration(seconds: 5));
          file.delete();
        }
      } else if (file is Directory) {
        // If it's a directory, you can choose to skip it or handle it differently
        log('Skipping directory: ${file.path}');
      }
    }
  } catch (e) {
    print('Error3');
    print(e);
  }
}

Future<String?> findPhoneNumber(String filename2) async {
  try {
    // อ่านไฟล์
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pathSound = prefs.getString('path');
    // var path = Directory(pathSound!);
    File file = File(filename2);
    String fileName = file.path;

    // ใช้ regex เพื่อค้นหาตัวเลขติดกัน 10 ตัว
    RegExp regExp = RegExp(r'\b\d{10}\b');
    Iterable<Match> matches = regExp.allMatches(fileName);

    if (matches.isNotEmpty) {
      for (Match match in matches) {
        // print('Phone number: ${match.group(0)}');
        return match.group(0);
      }
    } else {
      print('No phone numbers found.');
      // return fileName.substring(fileName.length - 14, fileName.length - 4);
      return fileName
          .replaceAll(pathSound!, '')
          .replaceAll("/", "")
          .substring(0, 20);
    }
  } catch (e) {
    print('Error reading file: $e');
    return null;
  }
  return null;
}

uploadTos3(fileMp3, String number) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var phoneCall = prefs.getString('phone');
  // _showAlert2('กำลังอัพโหลดไฟล์เสียง', DialogType.info);
  var request = http.MultipartRequest('POST',
      Uri.parse('https://s3midupload.agilesoftgroup.com/S3-Mid-Upload'));
  request.fields.addAll({'folder': "PKGAUTOCALL2/$phoneCall"});
  request.files.add(await http.MultipartFile.fromPath('file', fileMp3));
  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var s3Link = await response.stream.bytesToString();
    // {"s3link":"https://linebotkeep-file.s3.ap-southeast-1.amazonaws.com/PKGAUTOCALL2/0895436648/04072024-155008-722K%E0%B8%9E%E0%B8%B5%E0%B9%88%E0%B8%81%E0%B9%87%E0%B8%AD%E0%B8%952%202024-07-04%2015-50-03.m4a"}

    var s3LinkRaw = json.decode(s3Link);
    // log(s3LinkRaw['s3link']);
    InsertMySQL("ติดต่อได้", s3LinkRaw['s3link'], fileMp3, number);
    // Navigator.pop(context);
    return true;
  } else {
    print('Failed!');
    // _showAlert2('อัพโหลดไฟล์เสียงไม่สำเร็จ', DialogType.error);
    return false;
  }
}

InsertMySQL(status, link, filepath, String number) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var phoneCall = prefs.getString('phone');
  var emp_id = prefs.getString('emp_id');
  var bu = prefs.getString('bu');
  var branch = prefs.getString('branch');
  auth.SECERT_JWT = "GgiTrbw6wryB9g.Qvaz6";
  auth.R_USER = "CF_MYSQL";
  String? numberTo = number;
  log('numberTo: $numberTo');
  if (number == "") {
    numberTo = await findPhoneNumber(filepath);
  }
  var headers = {
    'Authorization': auth.genTokenEncryp(), // genTokenEncryp() or genToken()
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  };
  // print(headers);
  // ex. body
  var bodyData = {
    "database": "BCT_Twilio",
    "query":
        "INSERT INTO `pkgatc_logs` (`from`, `to`, `emp_id`, `bu`, `branch`, `status`, `gid`, `S3_Link`, `date`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())",
    "values": [phoneCall, numberTo, emp_id, bu, branch, status, 'NoBCT', link]
  };

  var body = json.encode(bodyData);
  var sqlUrl = 'https://agilesoftgroup.com/mysql/query';
  var request = http.Request('POST', Uri.parse(sqlUrl));
  request.body = json.encode(auth.encrypbody(body));
  request.headers.addAll(headers);
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    // var dataRaw = await response.stream.bytesToString();
    return true;
  } else {
    print('Failed!');
    return false;
  }
}
