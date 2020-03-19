import 'package:flutter/material.dart';
import 'package:platformchanneldemo/platform_channel.dart';

import 'event_channel_page.dart';
import 'method_channel_page.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF801E48),
        title: Text('Platform Channels'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Material(
              //Wrap with Material
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0)),
              elevation: 10.0,
              color: Color(0xFF801E48),
              clipBehavior: Clip.antiAlias,
              // Add This
              child: MaterialButton(
                minWidth: 200.0,
                height: 35,
                color: Color(0xFF801E48),
                child: new Text('Method Channel',
                    style: new TextStyle(fontSize: 16.0, color: Colors.white)),
                onPressed: () {
                  final page = MethodChannelPage();
                  navigate(context, page);
                },
              ),
            ),
            SizedBox(height: 16),
            Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0)),
              elevation: 10.0,
              color: Color(0xFF801E48),
              clipBehavior: Clip.antiAlias,
              child: MaterialButton(
                minWidth: 200.0,
                height: 35,
                color: Color(0xFF801E48),
                child: new Text('Event Channel',
                    style: new TextStyle(fontSize: 16.0, color: Colors.white)),
                onPressed: () {
                  final page = EventChannelPage();
                  navigate(context, page);
                },
              ),
            ),
            SizedBox(height: 16),
            Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0)),
              elevation: 10.0,
              color: Color(0xFF801E48),
              clipBehavior: Clip.antiAlias,
              child: MaterialButton(
                minWidth: 200.0,
                height: 35,
                color: Color(0xFF801E48),
                child: new Text('Combine Channels',
                    style: new TextStyle(fontSize: 16.0, color: Colors.white)),
                onPressed: () {
                  final page = PlatformChannel();
                  navigate(context, page);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => page,
        transitionsBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(end: Offset(0, 0), begin: Offset(1, 0))
                .animate(anim1),
            child: page,
          );
        },
      ),
    );
  }
}
