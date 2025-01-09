import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ags_authrest2/ags_authrest.dart';
import 'package:phone_state_background/phone_state_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simnumber/sim_number.dart';

import 'ListPhone.dart';

class ListPhoneTest extends StatefulWidget {
  @override
  _ListPhoneTestState createState() => _ListPhoneTestState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class _ListPhoneTestState extends State<ListPhoneTest>
    with WidgetsBindingObserver {
  bool hasPermission = false;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _hasPermission();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _hasPermission();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _hasPermission() async {
    final permission = await PhoneStateBackground.checkPermission();
    if (mounted) {
      setState(() => hasPermission = permission);
    }
  }

  Future<void> _requestPermission() async {
    await PhoneStateBackground.requestPermissions();
  }

  Future<void> _stop() async {
    await PhoneStateBackground.stopPhoneStateBackground();
  }

  Future<void> _init() async {
    if (hasPermission != true) return;
    await PhoneStateBackground.initialize(phoneStateBackgroundCallbackHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text(widget.title),
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Has Permission: $hasPermission',
              style: TextStyle(
                fontSize: 16,
                color: hasPermission ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () => _requestPermission(),
                child: const Text('Check Permission'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () => _init(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background color
                  ),
                  child: const Text('Start Listener'),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () => _stop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Background color
                ),
                child: const Text('Stop Listener'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
