import 'package:flutter/material.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';

class BroadcastProvider with ChangeNotifier {
//  var beaconBroadcast = new BeaconBroadcast();

  bool _isTransmitting = false;

//  beaconBroadcast.setUUID(uuid);

  bool get isTransmitting => _isTransmitting;

  BroadcastProvider();
}
