import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class QRScannerController extends GetxController {
  var barcode = ''.obs;

  // ฟังก์ชันจัดการเมื่อสแกน QR Code สำเร็จ
  Future<void> onScan(String gId, String sId) async {
    if (gId.isEmpty || sId.isEmpty) {
      Get.snackbar("Invalid QR Code", "The G_Id or S_Id is empty.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      print("Scanned G_Id: $gId");
      print("Scanned S_Id: $sId");

      // ดึงข้อมูลจาก Google Docs พร้อมทั้ง S_Id
      await fetchSheetData(gId, sId);
    } catch (e) {
      Get.snackbar("Error", "Failed to process G_Id and S_Id: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ฟังก์ชันดึงข้อมูลจากสเปรดชีต
  Future<void> fetchSheetData(String gId, String sId) async {
    var client = await _getAuthenticatedClient();
    var sheetsApi = sheets.SheetsApi(client);

    try {
      var spreadsheet = await sheetsApi.spreadsheets.get(gId);
      if (spreadsheet.sheets == null || spreadsheet.sheets!.isEmpty) {
        print("No sheets found in this spreadsheet.");
        return;
      }

      // ค้นหา sheet โดยใช้ S_Id หรือ gid
      var sheet = spreadsheet.sheets!.firstWhere(
            (sheet) => sheet.properties!.sheetId == int.parse(sId),

      );

      if (sheet == null) {
        print("Sheet with the specified S_Id not found.");
        return;
      }

      String sheetName = sheet.properties!.title!;
      print("Found sheet with name: $sheetName");

      // ดึงข้อมูลจาก Google Sheet
      await fetchGoogleDocWithSId(gId, sheetName, sId);
    } catch (e) {
      print("Error fetching Google Sheet data: $e");
    }
  }

  // ฟังก์ชันดึงข้อมูลจาก Google Doc
  Future<void> fetchGoogleDocWithSId(String gId, String sheetName, String sId) async {
    var client = await _getAuthenticatedClient();
    var sheetsApi = sheets.SheetsApi(client);

    try {
      String range = '$sheetName!A1:Z99'; // Adjust range if needed (e.g., A to Z columns)
      var response = await sheetsApi.spreadsheets.values.get(gId, range);

      if (response.values == null || response.values!.isEmpty) {
        print("No data found at the specified range.");
        return;
      }

      // Assume the first row contains the headers
      var headerRow = response.values![0];

      // Find the index of "PHONE" and "STA" columns
      int phoneColumnIndex = headerRow.indexOf("PHONE");
      int staColumnIndex = headerRow.indexOf("STA");

      if (phoneColumnIndex == -1 || staColumnIndex == -1) {
        print("Unable to find the columns for PHONE or STA");
        return;
      }
      List<String> phoneNumbersToCall = [];
      // Loop through the rows starting from the second row (skip header row)
      for (var row in response.values!.sublist(1)) {
        if (row.length > phoneColumnIndex! && row.length > staColumnIndex!) {
          var columnPhone = row[phoneColumnIndex];
          var columnSta = row[staColumnIndex];
          bool isValidPhone = _isValidPhone(columnPhone);
          // Print out the PHONE and STA values
          if (isValidPhone && columnSta == "รอโทร") {
            print("PHONE: $columnPhone, STA: $columnSta");
            phoneNumbersToCall.add(columnPhone.toString());
          }else if(isValidPhone && columnSta != "รอโทร"){
            print("PHONE: $columnPhone, STA: $columnSta");
            if (columnPhone != null && columnSta != null) {
              // Show a Snackbar indicating no phone number is waiting for a call
             await Get.dialog(
                AlertDialog(
                  title: Text("No Call Pending"),
                  content: Text("Phone: $columnPhone is not in 'รอโทร' status."),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        // Close the dialog when the user presses the button
                        Get.back();
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
                barrierDismissible: false,  // Prevent closing by tapping outside the dialog
              );
            } else {
              print("Invalid phone or status value.");
            }

          }
        }
      }

      for (var phone in phoneNumbersToCall) {
        print("Calling: $phone");
        await FlutterPhoneDirectCaller.callNumber(phone);
      }
    } catch (e) {
      print("Error fetching data for S_Id $sId: $e");
    }
  }

  // ฟังก์ชันตรวจสอบความถูกต้องของ PHONE
  bool _isValidPhone(value) {
    return RegExp(r'^[\d+\-\(\)\s]*$').hasMatch(value);
  }

  // ฟังก์ชันดึงข้อมูลการยืนยันตัวตน
  Future<auth.AutoRefreshingAuthClient> _getAuthenticatedClient() async {
    var credentialsJson = await rootBundle.loadString('assets/credentials.json');
    var credentials = auth.ServiceAccountCredentials.fromJson(json.decode(credentialsJson));

    return await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/spreadsheets.readonly'], // Read-only access scope
    );
  }
}
