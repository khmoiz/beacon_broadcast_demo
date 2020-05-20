import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beacon BroadCast Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.purpleAccent,
      ),
      home: MyHomePage(title: 'Beacon BroadCast'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String uuid = '11111111-2222-3333-4444-555555555555',
      major = '6666',
      minor = '9999';
  String deviceUUID;
  BeaconBroadcast beaconBroadcast = BeaconBroadcast();
  bool _isAdvertising = false;
  String _error = "No errors";
  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  initState() {
    // TODO: implement initState

    super.initState();
    startupConfig();
  }

  Future<void> startupConfig() async {
    String _uuid;
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      _uuid = iosDeviceInfo.identifierForVendor;
      deviceUUID = _uuid;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      _uuid = androidDeviceInfo.androidId;
      deviceUUID = _uuid;
    }
    setState(() {
      uuid = _uuid;
    });
  }

  Future<void> startBroadcasting() async {
    bool supported = await checkTransmissionSupported();
    if (supported) {
      if (Platform.isIOS) {
        setState(() {
          beaconBroadcast
              .setUUID(uuid)
              .setMajorId(int.parse(major))
              .setMinorId(int.parse(minor))
              .setIdentifier('com.ibeacon.autoly')
              .start();
          updateAdvertising();
        });
      } else if (Platform.isAndroid) {
        setState(() {
          beaconBroadcast
              .setUUID(uuid)
              .setMajorId(int.parse(major))
              .setMinorId(int.parse(minor))
              .setManufacturerId(0x004C)
              .setLayout("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24")
              .start();
          updateAdvertising();
        });
      }

//      beaconBroadcast.getAdvertisingStateChange().listen((state) {
//        _isAdvertising = state;
//      });
    } else {
      log("BEACON BROADCAST  : CANNOT START - TRANSMISSION NOT SUPPORTED!");
    }
  }

  void stopBroadcasting() {
    setState(() {
      beaconBroadcast.stop();
      updateAdvertising();
    });
  }

  Future<void> updateAdvertising() async {
    var temp = await beaconBroadcast.isAdvertising();
    setState(() {
      _isAdvertising = !_isAdvertising;
    });
  }

  void updateBeaconDetails(String _uuid, String _major, String _minor) {
    setState(() {
      uuid = _uuid;
      major = _major;
      minor = _minor;
    });
  }

  Future<bool> checkTransmissionSupported() async {
    var transmissionSupportStatus =
        await beaconBroadcast.checkTransmissionSupported();
    var supported = false;
    var temp = "";
    switch (transmissionSupportStatus) {
      case BeaconStatus.SUPPORTED:
        log("BEACON STATUS : SUPPORTED");
        supported = true;
        break;
      case BeaconStatus.NOT_SUPPORTED_MIN_SDK:
        // Your Android system version is too low (min. is 21)
        log("BEACON STATUS : SDK NOT SUPPORTED (UNDER API 21)");
        temp = "SDK NOT SUPPORTED (UNDER API 21)";
        supported = false;
        break;
      case BeaconStatus.NOT_SUPPORTED_BLE:
        log("BEACON STATUS : NO BLUETOOTH FOUND");
        temp = "NO BLUETOOTH FOUND";
        supported = false;

        // Your device doesn't support BLE
        break;
      case BeaconStatus.NOT_SUPPORTED_CANNOT_GET_ADVERTISER:
        log("BEACON STATUS : DEVICE NOT COMPATIBLE");
        temp =
            "CHIPSET OR DRIVER NOT COMPATIBLE WITH APPLICATION \n CHECK IF BLUETOOTH IS TURNED ON";

        // Either your chipset or driver is incompatible

        supported = false;

        break;
    }

    setState(() {
      _error = temp;
    });
    return supported;
  }

  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please Turn BLUETOOTH ON!', style: TextStyle(fontSize: 20)),
            Card(
              elevation: 10,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Custom Beacon Details',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              decorationThickness: 1.5,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.solid),
                        ),
                        IconButton(
                          tooltip: "Reset Beacon UUID/MAJOR/MINOR",
                          icon: Icon(Icons.restore),
                          iconSize: 28,
                          splashColor: Theme.of(context).accentColor,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            if (_isAdvertising) {
                              stopBroadcasting();
                            }
                            updateBeaconDetails(deviceUUID, "6666", "9999");
                          },
                        ),
                        IconButton(
                          tooltip: "Edit Beacon UUID/MAJOR/MINOR",
                          icon: Icon(Icons.edit),
                          iconSize: 28,
                          splashColor: Theme.of(context).accentColor,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            if (_isAdvertising) {
                              stopBroadcasting();
                            }
                            _onEditBeacon();
                          },
                        ),
                      ],
                    ),
                    Text(
                      'UUID:',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '$uuid',
                      softWrap: true,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Major : ${major.toString()} | Minor : ${minor.toString()}  ',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Broadcasting : ${_isAdvertising.toString().toUpperCase()}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isAdvertising ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text(
                    !_isAdvertising
                        ? "Start BroadCasting Beacon"
                        : "Stop BroadCasting Beacon",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    if (_isAdvertising) {
                      stopBroadcasting();
                    } else {
                      startBroadcasting();
                    }
                  },
                ),
              ),
            ),
            Divider(
              height: 10,
              thickness: 3,
            ),
            Text('ERROR DISPLAY',
                style: TextStyle(
                    fontSize: 20, decoration: TextDecoration.underline)),
            Text(
              '$_error',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_isAdvertising) {
            stopBroadcasting();
          } else {
            startBroadcasting();
          }
        },
        tooltip: 'Start or stop broadcasting the beacon',
        backgroundColor: _isAdvertising ? Colors.red : Colors.green,
        icon: Icon(_isAdvertising ? Icons.stop : Icons.play_arrow),
        label: Text(_isAdvertising ? "Stop" : "Start"),
      ),
    );
  }

  void _onEditBeacon() {
    TextEditingController uuidController = TextEditingController();
    TextEditingController majorController = TextEditingController();
    TextEditingController minorController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update Beacon Details"),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    updateBeaconDetails(
                        uuidController.text.toString(),
                        majorController.text.toString(),
                        minorController.text.toString());
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Update Beacon Details'),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  autovalidate: true,
                  onChanged: () {
                    Form.of(primaryFocus.context).save();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: uuidController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter UUID';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            helperText: "UUID", border: OutlineInputBorder()),
                      ),
                      TextFormField(
                        controller: majorController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          } else if (int.tryParse(value) == null) {
                            return 'Please enter an integer';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            helperText: "Major", border: OutlineInputBorder()),
                      ),
                      TextFormField(
                        controller: minorController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          } else if (int.tryParse(value) == null) {
                            return 'Please enter an integer';
                          }
                          return null;
                        },
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            helperText: "Minor", border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
