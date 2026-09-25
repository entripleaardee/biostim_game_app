import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'connection_state.dart';



class BLEnder {
  static BluetoothDevice? _device;
  static BluetoothService? _deviceInfoService;
  static BluetoothService? _sensorService;
  static BluetoothService? _controlService;
  static BluetoothService? _imuService;
  static BluetoothCharacteristic? _imuCharacteristic;
  static const int fireCommandId = 0x00;
  static List<BluetoothService> _services = [];

  static const String _deviceInfoServiceUuid ="56781234-5678-1234-1234-123456789000";
  static const String _deviceIdUuid ="56781234-5678-1234-1234-123456789002";
  static const String _firmwareUuid ="56781234-5678-1234-1234-123456789001";
  static const String _sensorServiceUuid = "56781234-5678-1234-1234-123456789100";
  static const String _batterySocUuid = "56781234-5678-1234-1234-123456789101";
  static const String _controlServiceUuid = "56781234-5678-1234-1234-123456789200";
  static const String _writeCharacteristicUuid = "56781234-5678-1234-1234-123456789201";
  static const String _imuServiceUuid ="56781234-5678-1234-1234-123456789300";
  static const String _imuCharacteristicUuid ="56781234-5678-1234-1234-123456789301";

      

  static void setDevice(BluetoothDevice device) {
    _device = device;
  }

  static Future<void> initialize() async {
    if (_device == null) return;

    _services = await _device!.discoverServices();
    for (var service in _services) {
      if (service.uuid.toString().toLowerCase() ==
          _deviceInfoServiceUuid.toLowerCase()) {

        _deviceInfoService = service;

        print("Device Information Service Found");

        
      }
      if (service.uuid.toString().toLowerCase() ==
          _sensorServiceUuid.toLowerCase()) {

        _sensorService = service;

        print("Sensor Service Found");
      }
      if (service.uuid.toString().toLowerCase() ==
          _controlServiceUuid.toLowerCase()) {

        _controlService = service;

        print("Control Service Found");
      }
      if (service.uuid.toString().toLowerCase() ==
          _imuServiceUuid.toLowerCase()) {

        _imuService = service;

        print("IMU Service Found");
      }
    }
    if (_deviceInfoService == null) {
      print("Device Information Service NOT found");
    } else {
      print("Device Information Service Ready");
    }
    if (_imuService == null) {
      print("IMU Service NOT found");
    } else {
      print("IMU Service Ready");
    }
    if (_sensorService == null) {
      print("Sensor Service NOT found");
    } else {
      print("Sensor Service Ready");
    }

    print("BLEnder initialized");
    print("Discovered services: ${_services.length}");

    for (var service in _services) {
          print("SERVICE: ${service.uuid}");

        for (var char in service.characteristics) {
          print("CHAR: ${char.uuid}");
        }
    }
          if (_imuService != null) {
          for (var characteristic in _imuService!.characteristics) {

            if (characteristic.uuid.toString().toLowerCase() ==
                _imuCharacteristicUuid.toLowerCase()) {

              _imuCharacteristic = characteristic;

              print("IMU Characteristic Found");
            }
          }
      }
  }

  static Future<List<int>?> _readCharacteristic(String uuid) async {
    if (_device == null || _deviceInfoService == null) return null;
    print("Looking for UUID: $uuid");

    if (_deviceInfoService == null) return null;
      for (var characteristic in _deviceInfoService!.characteristics) {
        final charUuid = characteristic.uuid.toString().toLowerCase();
        print("Checking: $charUuid");
       
        if (charUuid == uuid) {
          print("MATCH FOUND");
          try {
            return await characteristic.read();
          } catch (e) {
            print("Read error for $uuid: $e");
            return null;
          }
        }
      }

    return null;
  }

  // Device ID
  static Future<String> getDeviceId() async {
    final value = await _readCharacteristic(_deviceIdUuid);

    if (value == null || value.isEmpty) {
      return "Unknown Device";
    }

    return String.fromCharCodes(value);
  }

  //  Firmware Version
  static Future<String> getFirmwareVersion() async {
    final value = await _readCharacteristic(_firmwareUuid);

    if (value == null || value.isEmpty) {
      return "Unknown";
    }

    return String.fromCharCodes(value);
  }

  static Future<void> subscribeBattery() async {
    print("subscribeBattery() called");
    if (_sensorService == null) return;
    for (var characteristic in _sensorService!.characteristics) {
      final charUuid = characteristic.uuid.toString().toLowerCase();

      if (charUuid == _batterySocUuid.toLowerCase()) {

          print("Battery Characteristic Found");

          await characteristic.setNotifyValue(true);

          // we'll add the listener next
          characteristic.lastValueStream.listen((value) {

              print("Battery Notification: $value");

              if (value.isNotEmpty) {
                  ConnectionStateService.batterySoc.value = value.first;
              }

          });

          break;
      }
    }
  }


static Future<void> sendFireCommand({
    required int strength,
    required int duration,
    required int pulseWidth,
    required int rampUp,
    required int rampDown,s
  }) async {

    if (_controlService == null) return;

    for (var characteristic in _controlService!.characteristics) {

      final charUuid = characteristic.uuid.toString().toLowerCase();

      if (charUuid == _writeCharacteristicUuid.toLowerCase()) {

        final packet = [
          fireCommandId,                // Fire Command
          strength,                     // Strength
          duration,                     // Duration
          pulseWidth,                   // Pulse Width 
          rampUp,                       // Ramp Up
          rampDown,                     // Ramp Down
        ];

        try {
          await characteristic.write(packet);
          print("Packet Sent Successfully");
        } catch (e) {
          print("Fire Command Write Failed: $e");
        }

        // print("Packet Sent Successfully");
        break;
      }
    }
  }

  static Future<void> subscribeImu() async {

      if (_imuCharacteristic == null) return;

      print("Subscribing to IMU...");

      await _imuCharacteristic!.setNotifyValue(true);

      print("IMU Notifications Enabled");

      _imuCharacteristic!.lastValueStream.listen((value) {

        if (value.length >= 2) {

          int angle = value[0] | (value[1] << 8);

          // Convert uint16 -> int16
          if (angle >= 0x8000) {
            angle -= 0x10000;
          }

          //print("Decoded Angle: $angle");
          ConnectionStateService.imuAngle.value = angle;
        }

      });
    }

    static Future<void> stopImu() async {
      if (_imuCharacteristic == null) return;
        print("Stopping IMU...");
      await _imuCharacteristic!.setNotifyValue(false);
        print("IMU Notifications Disabled");
    }


}