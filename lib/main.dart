import 'package:flutter/material.dart';
import 'package:platformchanneldemo/platform_channel.dart';

import 'event_channel.dart';
import 'method_channel.dart';

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
        title: Text('Platform Channels'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                final page = MethodChannelPage();
                navigate(context, page);
              },
              child: Text('Method Channel'),
            ),
            RaisedButton(
              onPressed: () {
                final page = EventChannelPage();
                navigate(context, page);
              },
              child: Text('Event Channel'),
            ),
            RaisedButton(
              onPressed: () {
                final page = PlatformChannel();
                navigate(context, page);
              },
              child: Text('Combination of Both Channel'),
            )
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
