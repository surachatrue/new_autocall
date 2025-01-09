import 'package:flutter/material.dart';
import 'package:pkgautocall3/src/Autocallpage.dart';
import 'package:pkgautocall3/src/DialPad.dart';
import 'package:pkgautocall3/src/ListPhone.dart';
import 'package:pkgautocall3/src/LoginPhone.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  // await dotenv.load(
  //     fileName:
  //         "assets/.env"); // mergeWith optional, you can include Platform.environment for Mobile/Desktop app
// await DotEnv.load(fileName: ".env");
  runApp(Home());
}

class Home extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Auto Call4',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // textTheme: textTheme.copyWith(
        //   headline6: textTheme.headline6!.copyWith(
        //     color: Colors.black,
        //   ),
        // ),
      ),
      debugShowCheckedModeBanner: false,
      // home: DialPadPage()
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => LoginPhone(),
        // '/': (BuildContext context) => ListPhone(),
        '/Autocallpage': (BuildContext context) => Autocallpage(),
        '/DialPadPage': (BuildContext context) => DialPadPage(),
        '/ListPhone': (BuildContext context) => ListPhone(),
        // '/': (BuildContext context) => ListPhoneTest(),
      },
    );
  }
}
