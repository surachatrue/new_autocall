import 'package:flutter/material.dart';

void main() => runApp(CallScreen());

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with SingleTickerProviderStateMixin {
  bool _isCalling = false;
  late AnimationController _animationController;
  late Animation<Color?> _textColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _textColorAnimation = ColorTween(begin: Colors.white, end: Colors.red).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startCall() {
    setState(() {
      _isCalling = true;
    });
    _animationController.forward();
    print('กำลังโทร...');
  }

  void _endCall() {
    setState(() {
      _isCalling = false;
    });
    _animationController.reverse();
    print('สิ้นสุดการโทร');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          elevation: 0,
          title: Text(
            'การโทร',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: _isCalling ? Icon(Icons.call_end) : Icon(Icons.call),
              iconSize: 30,
              onPressed: _isCalling ? _endCall : _startCall,
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
                      AnimatedBuilder(
                        animation: _textColorAnimation,
                        builder: (context, child) {
                          return Text(
                            'KAAPHON',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: _textColorAnimation.value,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Text(
                        'By Karan',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Visibility(
                        visible: _isCalling,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 80.0,
                              backgroundImage: AssetImage('assets/images/avatar.png'),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'ชื่อ: John Doe',
                              style: TextStyle(
                                fontSize: 24.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'เบอร์โทร: 123-456-7890',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.blueGrey[900],
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isCalling ? _endCall : _startCall,
                child: Icon(
                  _isCalling ? Icons.call_end : Icons.call,
                  size: 30,
                ),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                  // primary: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
