import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> startScan() async {
    await FlutterBluePlus.startScan();
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }
}