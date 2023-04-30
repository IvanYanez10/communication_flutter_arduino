import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService{
  BluetoothService(){}

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  Future<bool> enableBluetooth() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    List<BluetoothDevice> _devicesList = [];
    try {
      _devicesList = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    return _devicesList;
  }
}