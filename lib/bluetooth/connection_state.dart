import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectionStateService {
  //static bool isConnected = false;
  static ValueNotifier<bool> isConnected = ValueNotifier(false);
  static BluetoothDevice? device;

  static ValueNotifier<String> firmwareVersion =
    ValueNotifier("--");
    
  static ValueNotifier<String> deviceId =
    ValueNotifier("--");

  static ValueNotifier<int> batterySoc =
    ValueNotifier(-1);

  static ValueNotifier<int> imuAngle = ValueNotifier(0);

  
}