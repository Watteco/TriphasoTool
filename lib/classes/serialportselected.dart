import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialportSelected {
  static final SerialportSelected _serialport = SerialportSelected._internal();

  late SerialPort port;
  bool isOpen = false;
  int refreshTime = 1;

  factory SerialportSelected() {
    return _serialport;
  }

  SerialportSelected._internal();

}