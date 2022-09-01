import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

import '../classes/serialportselected.dart';

class Connection extends StatefulWidget {
  const Connection({Key? key}) : super(key: key);

  @override
  State<Connection> createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  List<String> listPhases = SerialPort.availablePorts;
  String? selectedPort = '';
  var uart = SerialportSelected();
  late SerialPort serialPortActuel;
  final myController = TextEditingController();
  SerialPortConfig serialPortConfig = SerialPortConfig();
  bool isClicked = false;

  @override
  void initState() {
    serialPortConfig.baudRate = 19200;
    serialPortConfig.bits = 8;
    serialPortConfig.parity = 0;
    serialPortConfig.stopBits = 1;
    serialPortConfig.rts = SerialPortRts.on;  
    serialPortConfig.dtr = 0;
    serialPortConfig.xonXoff = 0;

    if (!uart.isOpen) {
      selectedPort = listPhases[0]; ///TRAITER CONDITION PAS DE CONNECTION
      uart.port = SerialPort(selectedPort!);
    } else {
      selectedPort = uart.port.name;
    }
    serialPortActuel = uart.port;
    super.initState();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 150),
            child : const Text('Select the Port Coms on wich the Triphas\'O is connected :', style: TextStyle(fontSize: 20)),
          ),
          DropdownButton<String>(
            value: selectedPort,
            items: listPhases
                .map((phase) => DropdownMenuItem<String>(
                  value: phase,
                  child: Text(phase)))
                .toList(),
            onChanged: (phase) => setState(() => {
              selectedPort = phase,
              serialPortActuel.close(),
              print("portcom ${serialPortActuel.name} deconnected"),
              uart.port = SerialPort(selectedPort!),
              serialPortActuel = uart.port,
              uart.isOpen = false,
              isClicked = false,
            }), 
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            ElevatedButton(
              onPressed: !isClicked ? () {
                  connectToPortCom();
                  setState(() {
                    isClicked = true;
                  });
                } : null,
              child: const Text('Connect'),
            ),
            ElevatedButton(
              onPressed: !isClicked ? () {
                  setState(() {
                    listPhases = SerialPort.availablePorts;
                  });
                } : null,
              child: const Text('Rescan'),
            ),
          ]),
          Container(
            margin: const EdgeInsets.only(top: 50),
            child : const Text('Enter the number of seconds for a refresh of the data :', style: TextStyle(fontSize: 20)),
          ),
          SizedBox(
            width: 50,
            height: 30,
            child: TextField(
              controller: myController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onEditingComplete: () => {
                setState(() {
                  uart.refreshTime = int.parse(myController.text);
                })
              },
              decoration: InputDecoration.collapsed(hintText: uart.refreshTime.toString()),
            )
          ),
        ],
      ),
    );
  }
  
  connectToPortCom() {
    if (!uart.isOpen) {
      ///Reading the three phases' last information sent by the triphas'O sensor
      uart.port.openRead();
      uart.port.config = serialPortConfig; //always after opening the port com
      uart.isOpen = true;
    }
  }
}
