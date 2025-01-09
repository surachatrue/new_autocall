import 'dart:convert';
import 'dart:io';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import 'googleService.dart';


class Autocallpage extends StatefulWidget {
  @override
  _AutocallpageState createState() => _AutocallpageState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class _AutocallpageState extends State<Autocallpage>
    with SingleTickerProviderStateMixin {
  final QRScannerController qrController = Get.put(QRScannerController());
  String barcode = '';

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
            // Qr scanner
            icon: Icon(
              Icons.phone,
              size: 35,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/DialPadPage',
                (Route<dynamic> route) => false,
              );
            },
          ),
          actions: [
            IconButton(
              // Qr scanner
              icon: Icon(
                Icons.qr_code,
                size: 35,
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AiBarcodeScanner(
                      validator: (value) {
                        print("Value : ${value}");
                        return value.startsWith('https://');
                      },
                      canPop: false,
                      onScan: (String value) {
                        // debugPrint(value);

                        try {
                          // แปลงข้อมูล QR Code เป็น JSON

                        } catch (e) {
                          print("Error decoding QR Code: $e");
                        }

                        setState(() {
                          barcode = value;
                        });

                      },
                      onDetect: (p0) {
                        print("p0 type: ${p0.runtimeType}");
                        print("Detect : ${p0.toString()}");
                        print("Detect (formatted): ${jsonEncode(p0)}");

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
