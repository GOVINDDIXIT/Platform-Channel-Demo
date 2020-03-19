import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


class PlatformChannel extends StatefulWidget {
  @override
  _PlatformChannelState createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<PlatformChannel> {
  IconData iconSwitch = Icons.battery_unknown;

  static const MethodChannel methodChannel =
  MethodChannel('dixit.govind.platformchanneldemo/methodChannel');

  static const EventChannel eventChannel =
  EventChannel('dixit.govind.platformchanneldemo/chargingEventChannel');

  String _batteryLevel = 'Battery Level: unknown.';
  String _chargingStatus = 'Battery Status: unknown.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await methodChannel.invokeMethod('getBatteryLevel');
      batteryLevel = '''Battery Level: $result%''';
    } on PlatformException {
      batteryLevel = 'Failed to get battery level.';
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    super.initState();
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void _onEvent(Object event) {
    setState(() {
      _chargingStatus =
      "Battery status: ${event == 'charging' ? '' : 'dis'}charging.";

      iconSwitch = (event == 'charging')
          ? Icons.battery_charging_full
          : Icons.battery_full;
    });
  }

  void _onError(Object error) {
    setState(() {
      _chargingStatus = 'Battery Status: unknown.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          body1: TextStyle(
            color: Colors.green,
            fontSize: 26.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          textTheme: TextTheme(
            title: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          color: Colors.purple,
          elevation: 2.0,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Platform Channel App Demo',
            style: GoogleFonts.roboto(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_batteryLevel,
                  style: GoogleFonts.lato(),
                  key: const Key('Battery level label')),
              FlatButton(
                onPressed: _getBatteryLevel,
                child: Icon(
                  iconSwitch,
                  size: 290.0,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                _chargingStatus,
                style: GoogleFonts.lato(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
