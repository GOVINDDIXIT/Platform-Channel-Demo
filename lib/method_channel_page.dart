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
        backgroundColor: Color(0xFF801E48),
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
      builder: (context) => OutlineButton(
        child: Text('Get OS Version'),
        onPressed: () {
          _getOSVersion().then((value) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(value),
                duration: Duration(seconds: 2),
              ),
            );
          });
        }, //callback when button is clicked
        borderSide: BorderSide(
          color: Color(0xFF801E48), //Color of the border
          style: BorderStyle.solid, //Style of the border
          width: 2.0, //width of the border
        ),
      ),
    );
  }

  Builder checkCameraButton() {
    return Builder(
      builder: (context) => OutlineButton(
        child: Text('Check Camera Hardware'),
        onPressed: () {
          _isCameraAvailable().then((value) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(value['status']),
                duration: Duration(seconds: 2),
              ),
            );
          });
        }, //callback when button is clicked
        borderSide: BorderSide(
          color: Color(0xFF801E48), //Color of the border
          style: BorderStyle.solid, //Style of the border
          width: 2.0, //width of the border
        ),
      ),
    );
  }

  OutlineButton callNumberButton() {
    return OutlineButton(
      child: Text('Call number 1234'),
      onPressed: () {
        _callNumber('1234');
      },
      //callback when button is clicked
      borderSide: BorderSide(
        color: Color(0xFF801E48), //Color of the border
        style: BorderStyle.solid, //Style of the border
        width: 2.0, //width of the border
      ),
    );
  }

  Future<String> _getOSVersion() async {
    String version;
    try {
      version = await methodChannel.invokeMethod('getOSVersion');
    } on PlatformException catch (e) {
      version = e.message;
    }
    return "Android " + version;
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
