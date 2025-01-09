// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:phone_state/phone_state.dart';

// // void main() => runApp(CallScreen());

// class CallScreen extends StatefulWidget {
//   @override
//   _CallScreenState createState() => _CallScreenState();
// }

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

// class _CallScreenState extends State<CallScreen>
//     with SingleTickerProviderStateMixin {
//   bool _isCalling = false;
//   late AnimationController _animationController;
//   late Animation<Color?> _textColorAnimation;
//   String name = '';
//   String phoneNumber = '';
//   String additionalDetails = ''; // รายละเอียดเพิ่มเติม
//   PhoneStateStatus status = PhoneStateStatus.NOTHING;
//   bool granted = false;
//   String telegramLinkraw = '';
//   bool savebutton = false;

//   String callstate = "";

//   Future requestPermission() async {
//     // var status = await Permission.phone.request();
//     // var storageStatus = await Permission.storage.request();
//     // var manageExternalStorageStatus =
//     //     await Permission.manageExternalStorage.request();
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.phone,
//       Permission.storage,
//       Permission.manageExternalStorage,
//     ].request();

//     if (statuses[Permission.phone]!.isGranted &&
//         statuses[Permission.storage]!.isGranted &&
//         statuses[Permission.manageExternalStorage]!.isGranted) {
//       return true;
//     } else {
//       return false;
//     }

//     // switch (status) {
//     //   case PermissionStatus.denied:
//     //   case PermissionStatus.restricted:
//     //   case PermissionStatus.limited:
//     //   case PermissionStatus.permanentlyDenied:
//     //     return false;
//     //   case PermissionStatus.granted:
//     //     return true;
//     // }
//   }

//   void setStream() {
//     PhoneState.phoneStateStream.listen((event) {
//       setState(() {
//         if (event != null) {
//           status = event;
//           if (status == PhoneStateStatus.CALL_ENDED) {
//             // _endCall();
//             searchFile();
//           }
//         }
//       });
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     if (Platform.isIOS) setStream();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 1),
//     );

//     _textColorAnimation = ColorTween(begin: Colors.white, end: Colors.red)
//         .animate(_animationController);
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _startCall() async {
//     try {
//       setState(() {
//         _isCalling = true;
//         savebutton = false;
//       });
//       _animationController.forward();
//       print('กำลังโทร...');
//       var status = await Permission.phone.status;
//       if (!status.isGranted) {
//         print('ไม่ได้รับอนุญาติให้ใช้งาน');
//         granted = await requestPermission();
//       } else {
//         fetchData();
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   void _endCall() {
//     setState(() {
//       _isCalling = false;
//       savebutton = false;
//     });
//     _animationController.reverse();
//     print('สิ้นสุดการโทร');
//   }

//   Map<String, String> headers = {
//     'Content-type': 'application/json',
//     'Accept': 'application/json',
//     'Access-Control-Allow-Origin': '*',
//   };

//   void fetchData() async {
//     try {
//       HttpOverrides.global = MyHttpOverrides();

//       var request = http.Request(
//           'POST',
//           Uri.parse(
//               'https://cf_kaaphone.karanagsdevcloudinfra.workers.dev/autocall/getlist'));
//       request.followRedirects = false;
//       request.body = json.encode({"func": "getPhonestate"});
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         String data = await response.stream.bytesToString();
//         print('Success');
//         print(data);

//         if (data == '[]') {
//           print('ไม่พบข้อมูล');
//           setState(() {
//             name = 'ไม่พบข้อมูล';
//             phoneNumber = '';
//           });

//           return _endCall();
//         }

//         var jsonData = json.decode(data);
//         setState(() {
//           name = jsonData[0]['name'];
//           phoneNumber = jsonData[0]['phone'];
//         });

//         var state = await UpdateSheet("", "กำลังโทร", "", "updatePhonestate1");
//         print('กำลังโทร...');
//         if (state == true) {
//           bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
//           setStream();
//           print(res);
//           if (res == true) {
//             print('เรียกโทรสำเร็จ');
//           } else {
//             print('เรียกโทรไม่สำเร็จ');
//           }
//         }
//       } else {
//         print('Error');
//         print(response.reasonPhrase);
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.blueGrey[900],
//           elevation: 0,
//           title: Text(
//             _isCalling ? 'กำลังค้นหา' : 'การโทร',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           actions: [
//             IconButton(
//               icon: _isCalling ? Icon(Icons.call_end) : Icon(Icons.call),
//               iconSize: 30,
//               onPressed: _isCalling ? _endCall : _startCall,
//             ),
//             // IconButton(
//             //   icon: Icon(Icons.dialpad),
//             //   onPressed: () {
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //           builder: (context) =>
//             //               DialPadPage()), // เรียกใช้ DialPadPage
//             //     );
//             //   },
//             // ),
//           ],
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: Container(
//                 color: Colors.blueGrey[900],
//                 padding: EdgeInsets.all(16),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       AnimatedBuilder(
//                         animation: _textColorAnimation,
//                         builder: (context, child) {
//                           return Text(
//                             'AUTO CALL4',
//                             style: TextStyle(
//                               fontSize: 24.0,
//                               fontWeight: FontWeight.bold,
//                               color: _textColorAnimation.value,
//                               shadows: [
//                                 Shadow(
//                                   color: Colors.black,
//                                   offset: Offset(2, 2),
//                                   blurRadius: 2,
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                       Visibility(
//                         visible:
//                             !_isCalling, // Hide the text when _isCalling is true
//                         child: Text(
//                           'By Karan',
//                           style: TextStyle(
//                             fontSize: 16.0,
//                             color: Colors.grey[400],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16.0),
//                       Visibility(
//                         visible: _isCalling,
//                         child: Column(
//                           children: [
//                             CircleAvatar(
//                               radius: 80.0,
//                               backgroundImage:
//                                   AssetImage('assets/images/avatar.png'),
//                             ),
//                             SizedBox(height: 8.0),
//                             Text(
//                               'ชื่อ: $name',
//                               style: TextStyle(
//                                 fontSize: 24.0,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(height: 8.0),
//                             Text(
//                               'เบอร์โทร: $phoneNumber',
//                               style: TextStyle(
//                                 fontSize: 16.0,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(height: 8.0),
//                             Visibility(
//                               visible: savebutton,
//                               child: TextField(
//                                 onChanged: (value) {
//                                   setState(() {
//                                     additionalDetails = value;
//                                   });
//                                 },
//                                 decoration: InputDecoration(
//                                   labelText: 'รายละเอียดเพิ่มเติม',
//                                   labelStyle: TextStyle(color: Colors.white),
//                                   enabledBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(color: Colors.white),
//                                   ),
//                                   focusedBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(color: Colors.white),
//                                   ),
//                                 ),

//                                 style: TextStyle(color: Colors.white),
//                                 maxLines:
//                                     3, // กำหนดให้สามารถพิมพ์ข้อความหลายบรรทัดได้ไม่เกิน 3 บรรทัด
//                                 minLines:
//                                     1, // กำหนดให้สามารถพิมพ์ข้อความในบรรทัดเดียวได้
//                               ),
//                             ),
//                             SizedBox(height: 16),
//                             Visibility(
//                               visible: savebutton,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   saveAdditionalDetails();
//                                 },
//                                 child: Text('บันทึก'),
//                                 style: ElevatedButton.styleFrom(
//                                   primary: Colors.green,
//                                   onPrimary: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(32.0),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             // Container(
//             //   width: double.infinity,
//             //   color: Colors.blueGrey[900],
//             //   padding: EdgeInsets.all(16),
//             //   child: ElevatedButton(
//             //     onPressed: _isCalling ? _endCall : _startCall,
//             //     child: Icon(
//             //       _isCalling ? Icons.call_end : Icons.call,
//             //       size: 30,
//             //     ),
//             //     style: ElevatedButton.styleFrom(
//             //       shape: CircleBorder(),
//             //       padding: EdgeInsets.all(16),
//             //       primary: Colors.green,
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> searchFile() async {
//     // search voice record file in /storage/emulated/0/MIUI/sound_recorder/call_rec
//     // search file name equal to phoneNumber
//     // if found, fetch file to server
//     // String? path2 = '/storage/emulated/0/MIUI/sound_recorder/call_rec';
//     try {
//       print('searchFile');
//       var path = Directory('/storage/emulated/0/MIUI/sound_recorder/call_rec/');
//       List files = path.listSync();
//       // print(files);
//       for (var file in files) {
//         print(file.path);
//         print(phoneNumber.replaceAll('-', ''));
//         if (file.path.contains(phoneNumber.replaceAll('-', ''))) {
//           print('found');
//           // ชั่วคราว
//           // setState(() {
//           //   telegramLinkraw = 'https://t.me/+HiCmN5baU2lhZDc1';
//           //   callstate = "รับสาย";
//           //   savebutton = true;
//           // });
//           // หน่วงเวลา 5 วินาที
//           await Future.delayed(Duration(seconds: 5));
//           String token = '5338310168:AAFS16o80unaHFof_B_n3vH52thy8GxJBZk';
//           String chatId = '-920770789';
//           var request2 = http.MultipartRequest('POST',
//               Uri.parse('https://api.telegram.org/bot$token/sendAudio'));
//           request2.fields.addAll({
//             'chat_id': chatId,
//             'caption': 'เบอร์โทร: $name',
//           });
//           request2.files
//               .add(await http.MultipartFile.fromPath('audio', file.path));
//           var res = await request2.send();
//           print(res.statusCode);
//           if (res.statusCode == 200) {
//             print('Success');
//             //delete file if found
//             file.delete();
//             String data = await res.stream.bytesToString();
//             print('Success');
//             print(data);

//             var jsonData = json.decode(data);
//             // var telegramLink = "https://t.me/c/1339968405/" +
//             //     jsonData['result']['message_id'].toString();
//             var fileId = jsonData['result']['audio']['file_id'].toString();
//             print('https://api.telegram.org/bot$token/getFile?file_id=$fileId');
//             var telegramLink = http.Request(
//                 'GET',
//                 Uri.parse(
//                     'https://api.telegram.org/bot$token/getFile?file_id=$fileId'));

//             telegramLink.followRedirects = false;
//             telegramLink.headers.addAll(headers);

//             var res2 = await http.Client().send(telegramLink);
//             print(res2.statusCode);
//             if (res2.statusCode == 200) {
//               print('Success');
//               String data2 = await res2.stream.bytesToString();
//               print(data2);
//               var jsonData2 = json.decode(data2);
//               var telegramLink2 = "https://api.telegram.org/file/bot$token/" +
//                   jsonData2['result']['file_path'].toString();
//               print(telegramLink2);
//               setState(() {
//                 telegramLinkraw = telegramLink2;
//                 callstate = "รับสาย";
//                 savebutton = true;
//               });
//             } else {
//               print('Error1');
//             }
//           } else {
//             print('Error2');
//           }
//         } else {
//           //delete file if not found
//           print('delete file if not found');
//           // UpdateSheet("telegramLink2","รับสาย");
//           // setState(() {
//           //   telegramLinkraw = "";
//           //   callstate = "ไม่รับสาย";
//           //   savebutton = true;
//           // });
//           if (files.length == 0) {
//             // UpdateSheet("", "ไม่รับสาย", null);
//             setState(() {
//               telegramLinkraw = "";
//               callstate = "ไม่รับสาย";
//               savebutton = true;
//             });
//           }
//           file.delete();
//         }
//       }
//       if (files.length == 0) {
//         // UpdateSheet("", "ไม่รับสาย", null);
//         setState(() {
//           telegramLinkraw = "";
//           callstate = "ไม่รับสาย";
//           savebutton = true;
//         });
//       }
//     } catch (e) {
//       print('Error3');
//       print(e);
//     }
//   }

//   Future UpdateSheet(telegramLink, callstate, additionalDetails, func) async {
//     try {
//       print('UpdateSheet');
//       HttpOverrides.global = MyHttpOverrides();
//       var request3 = http.Request(
//           'POST',
//           Uri.parse(
//               'https://cf_kaaphone.karanagsdevcloudinfra.workers.dev/autocall/updatePhonestate'));
//       request3.followRedirects = false;
// //     {
// //     "func": "updatePhonestate",
// //     "phone": "088-5256217",
// //     "timeStamp": "19.29",
// //     "Record": "https://voidrecord-ex1.mp3",
// //     "phonestate": "รับสาย"
// // }
//       print(phoneNumber);
//       // if (additionalDetails) {
//       //   request.body = json.encode({
//       //     "func": "updatePhonestate",
//       //     "phone": phoneNumber,
//       //     "timeStamp": DateTime.now().toString(),
//       //     "Record": telegramLink,
//       //     "phonestate": callstate,
//       //     "detail": additionalDetails
//       //   });
//       // } else {
//       //   request.body = json.encode({
//       //     "func": "updatePhonestate",
//       //     "phone": phoneNumber,
//       //     "timeStamp": DateTime.now().toString(),
//       //     "Record": telegramLink,
//       //     "phonestate": callstate,
//       //   });
//       // }
//       request3.body = json.encode({
//         "func": func,
//         "phone": phoneNumber,
//         "timeStamp": DateTime.now().toString(),
//         "Record": telegramLink,
//         "phonestate": callstate,
//         "detail": additionalDetails
//       });

//       print(request3.body);

//       request3.headers.addAll(headers);

//       http.StreamedResponse response = await request3.send();

//       if (response.statusCode == 200) {
//         String data = await response.stream.bytesToString();
//         print('Success');
//         print(data);

//         var jsonData = json.decode(data);
//         // _endCall();
//         return true;
//         // _startCall();
//         // setState(() {
//         //   name = jsonData[0]['name'];
//         //   phoneNumber = jsonData[0]['phone'];
//         // });
//       } else {
//         print('Error');
//         print(response.reasonPhrase);
//         return false;
//       }
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }

//   Future<void> saveAdditionalDetails() async {
//     setState(() {
//       _isCalling = false;
//     });
//     // if (_isCalling) {
//     var isUpdate = await UpdateSheet(
//         telegramLinkraw, callstate, additionalDetails, "updatePhonestate2");
//     print('isUpdate detail');
//     if (isUpdate) {
//       _endCall();
//       setState(() {
//         additionalDetails = "";
//         telegramLinkraw = "";
//         callstate = "";
//         name = "";
//         phoneNumber = "";
//         savebutton = false;
//       });
//       _startCall();
//     }
//     // }
//   }
// }
