import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodChannelPage extends StatefulWidget {
  @override
  _MethodChannelPageState createState() => _MethodChannelPageState();
}

class _MethodChannelPageState extends State<MethodChannelPage> {
  static const methodChannel =
      const MethodChannel('dixit.govind.platformchanneldemo/methodChannel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Method Channel"),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            osVersionButton(),
            checkCameraButton(),
            callNumberButton()
          ],
        ),
      ),
    );
  }

  Builder osVersionButton() {
    return Builder(
      builder: (context) => RaisedButton(
        onPressed: () {
          _getOSVersion().then((value) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(value),
                duration: Duration(seconds: 3),
              ),
            );
          });
        },
        child: Text('OS Version'),
      ),
    );
  }

  Builder checkCameraButton() {
    return Builder(
      builder: (context) => RaisedButton(
        onPressed: () {
          _isCameraAvailable().then((value) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(value['status']),
                duration: Duration(seconds: 3),
              ),
            );
          });
        },
        child: Text('Check Camera Hardware'),
      ),
    );
  }

  RaisedButton callNumberButton() {
    return RaisedButton(
      onPressed: () {
        _callNumber('1234');
      },
      child: Text('Call number 1234'),
    );
  }

  Future<String> _getOSVersion() async {
    String version;
    try {
      version = await methodChannel.invokeMethod('getOSVersion');
    } on PlatformException catch (e) {
      version = e.message;
    }
    return version;
  }

  Future<Map<String, String>> _isCameraAvailable() async {
    Map<String, String> cameraStatus;
    try {
      cameraStatus = await methodChannel.invokeMapMethod('isCameraAvailable');
    } on PlatformException catch (e) {
      cameraStatus = {'status': e.message};
    }
    return cameraStatus;
  }

  _callNumber(String number) async {
    await methodChannel.invokeMapMethod('callNumber', {'number': number});
  }
}
