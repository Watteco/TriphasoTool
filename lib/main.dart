
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:intl/intl.dart';
import 'package:triphasotool/bodies/connection.dart';
import 'package:triphasotool/bodies/debug_body.dart';
import 'package:triphasotool/bodies/fresnel_body.dart';
import 'package:triphasotool/bodies/graph_body.dart';
import 'package:triphasotool/bodies/data_body.dart';
import 'package:triphasotool/classes/tempodata.dart';

import 'classes/phase.dart';
import 'classes/phases.dart';
import 'classes/serialportselected.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Triphas\'O Tool';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.black),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: appTitle),

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget myInitialWidget = const Connection();
  ValueNotifier<String> currentWidget = ValueNotifier("Connection");
  Phases phases = Phases();
  var uart = SerialportSelected();
  Uint8List data = Uint8List(0);  
  List<int> lastData = [] ;
  late Map<String,String> debugTextList = {};
  String debugText='', debugTextWithTimestamp='';
  int nbBytes = 0; 
  SerialPortConfig serialPortConfig = SerialPortConfig();
  late Timer timer;
  int actualRefreshTime = 5;

  @override
  void initState() {

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Do you really want to quit?'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      serialPortConfig.dispose();
                      uart.port.close();
                      timer.cancel();
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.orange),
                    child: const Text('Yes')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.orange),
                    child: const Text('No'),),
              ]);
        });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    serialPortConfig.baudRate = 19200;
    serialPortConfig.bits = 8;
    serialPortConfig.parity = 0;
    serialPortConfig.stopBits = 1;
    serialPortConfig.rts = SerialPortRts.on;  
    serialPortConfig.dtr = 0;
    serialPortConfig.xonXoff = 0;

    timer = Timer.periodic(Duration(seconds: uart.refreshTime), (timer) {
      //print("timer");
      setState(() {
        actualRefreshTime = uart.refreshTime;
        timer.cancel();
      });
      readingDataFromComPort(context);
    });
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: const Color.fromARGB(238, 255, 136, 1),),
      body: ValueListenableBuilder(
        builder: (context, value, child) => myInitialWidget,
        valueListenable: currentWidget,
        child: myInitialWidget,), 
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll through the options in the drawer 
        //if there isn't enough vertical space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(238, 255, 136, 1),
                  image: DecorationImage(image: AssetImage('images/logoWatteco.png'))
                ),
              ),
            ),
            ListTile(
              title: const Text('Data'),
              onTap: () {
                // Update the state of the app
                myInitialWidget = DataBody(phases);
                currentWidget.value = "DataBody";
                currentWidget.notifyListeners();
                // Then close the drawer
                Navigator.pop(context); 
              },
            ),
            ListTile(
              title: const Text('Graphs'),
              onTap: () {
                // Update the state of the app
                myInitialWidget = Graphbody(phases);
                currentWidget.value = "graph_body";
                currentWidget.notifyListeners();
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Fresnel Diagram'),
              onTap: () {
                myInitialWidget = Fresnelbody(phases);
                currentWidget.value = "fresnel_body";
                currentWidget.notifyListeners();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Debug'),
              onTap: () {
                myInitialWidget = DebugBody(lastData);
                currentWidget.value = "debug_body";
                currentWidget.notifyListeners();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Connection'),
              onTap: () {
                myInitialWidget = const Connection();
                currentWidget.value = "graph_body";
                currentWidget.notifyListeners();
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }

  void readingDataFromComPort(BuildContext context) {
    
    if (uart.isOpen) {
      nbBytes = uart.port.bytesAvailable;
      if (nbBytes > 0) {
        data = uart.port.read(nbBytes);
        int startLastTrame = checkForLastTrameStart(data);
        lastData.clear();
        if (startLastTrame != -1) {
          for(int i= startLastTrame; i<nbBytes; i++) {
            lastData.add(data[i]);
          }
          saveDataIntoTempoClass(lastData);
          saveThreePhasesData(lastData, context);
        }
      }
    }
  }

  ///Chez one the last trame save begin
  int checkForLastTrameStart(Uint8List data) {
    int cpt =0;
    for (int i=data.length-1; i>=0; i--) {
      if (data[i] == 65 && cpt == 7) { return i; }
      else if (data[i] == 66 || data[i] == 67 || data[i] == 67 || data[i] == 84 || data[i] == 10) {cpt ++;} 
    }
    return -1;
  }

  /// Browsing the data list containing the values of the 3 phases sent by uart in order to save them into global class
  void saveThreePhasesData(List<int>  data, BuildContext context) {
    bool saveValue = false, savePhase = false;
    int dataIndex = -1, nbPhasesRead = 0;
    List<int> dataRead = [];
    Phase readingPhase = Phase();

    if (data[0] == 65) {
      //we browse the data list containing the values of the 3 phases sent by uart
      for (int i=0; i< data.length; i++){
        if (data[i] == 44) { //if coma = next value
          saveValue = true;
          dataIndex ++;
        } else if (data[i] == 10){ //if carriage return = new phase
          saveValue = true;
          dataIndex ++;
          nbPhasesRead ++;
          savePhase = true;
        } else { //if data lambda = digit of the value  
          if (dataIndex!=0 && (data[i]<48 || data[i]>57)) { //the digit is not a number => number = 0
            if (data[i] == 45) { dataRead.add(45); }
            else { dataRead.add(48); }
          } else {
            dataRead.add(data[i]);
          }
        }
        
        //If saveValue = all the digits of the number have been read, we can save it
        if (saveValue) {   
          switch(dataIndex) {
            case 0:
              saveValue = false;
              break;
            case 1: 
              readingPhase.mode = ascii.decode(dataRead); 
              saveValue = false;
              break;
            case 2: 
              if (readingPhase.mode == 'D') { 
                readingPhase.deltaVoltage = double.parse((double.parse(ascii.decode(dataRead))/10).toStringAsFixed(1));
                readingPhase.voltage = double.parse((readingPhase.deltaVoltage/sqrt(3)).toStringAsFixed(1));
              } else {
                readingPhase.voltage = double.parse((double.parse(ascii.decode(dataRead))/10).toStringAsFixed(1));
                readingPhase.deltaVoltage = 0; 
              }
              saveValue = false;
              break;
            case 3: 
              readingPhase.current = double.parse(ascii.decode(dataRead))/10;  
              saveValue = false;
              break;
            case 4: 
              if (readingPhase.mode == 'D') { 
                readingPhase.deltaAngle = (int.parse(ascii.decode(dataRead)) + 360)%360; 
                if (nbPhasesRead == 0) {readingPhase.angle =  (readingPhase.deltaAngle - 30 + 360)%360; }
                else if (nbPhasesRead == 1) {readingPhase.angle =  (readingPhase.deltaAngle - 90 + 360)%360; }
                else {readingPhase.angle =  (readingPhase.deltaAngle + 30 + 360)%360;}
              } else {
                readingPhase.angle = (int.parse(ascii.decode(dataRead)) + 360)%360;  
                readingPhase.deltaAngle = 0; 
              } 
              saveValue = false;
              break;
            case 5: 
              if (readingPhase.mode == 'D' && nbPhasesRead == 1) {readingPhase.activePowerInst = 0;}
              else {readingPhase.activePowerInst = int.parse(ascii.decode(dataRead));}
              saveValue = false;
              break;
            case 6: 
              if (readingPhase.mode == 'D' && nbPhasesRead == 1) {readingPhase.reactivePowerInst = 0;}
              else {readingPhase.reactivePowerInst = int.parse(ascii.decode(dataRead)); }
              saveValue = false;
              break;
            case 7: 
              if (readingPhase.mode == 'D' && nbPhasesRead == 1) {readingPhase.activePowerAv = 0;}
              else {readingPhase.activePowerAv = int.parse(ascii.decode(dataRead)); }
              saveValue = false;
              break;
            case 8: 
              if (readingPhase.mode == 'D' && nbPhasesRead == 1) {readingPhase.reactivePowerAv = 0;}
              else {readingPhase.reactivePowerAv = int.parse(ascii.decode(dataRead)); }
              saveValue = false;
              break;
            case 9: 
              if (readingPhase.mode == 'D' && nbPhasesRead == 1) {readingPhase.activeEnergy = 0;}
              else {readingPhase.activeEnergy = int.parse(ascii.decode(dataRead)); }
              saveValue = false;
              break;
            case 10: 
              if (readingPhase.mode == 'D' && nbPhasesRead == 1) {readingPhase.reactiveEnergy = 0;}
              else {readingPhase.reactiveEnergy = int.parse(ascii.decode(dataRead)); }
              saveValue = false;
              break;
            case 11: 
              readingPhase.timingSec = int.parse(ascii.decode(dataRead));  
              dataIndex = -1;
              saveValue = false;
              break;
          }
          
          //Empty the buffer list in order to read a new value
          dataRead.clear();
        }
      
        //If savePhase = all the information of the phase have been read, we can save it into the global class
        if (savePhase) savePhase = saveDataIntoClass(readingPhase, nbPhasesRead, context,);
      }
    }  
  }
  
  ///Saving phase information into global class
  bool saveDataIntoClass(Phase readingPhase, int nbPhasesRead, BuildContext context ) {
    var tempoString = json.encode(readingPhase);
    var tempoValueDynamique = json.decode(tempoString) ;
    var tempoValue = Phase.fromJson(tempoValueDynamique);
        
    if (nbPhasesRead == 1) {
      if (phases.i == 20) {
        phases.phaseA.removeAt(0);
        phases.phaseB.removeAt(0);
        phases.phaseC.removeAt(0);
        phases.phaseABC.removeAt(0);
      } else {
        phases.i++;
      }
      phases.phaseA.add(tempoValue);
    } else if (nbPhasesRead == 2) {
      phases.phaseB.add(tempoValue);
    } else if (nbPhasesRead == 3) {
      phases.phaseC.add(tempoValue);
    } else {
      phases.phaseABC.add(tempoValue);
    }
  
    return false;
  }
  

  ///Save the date into a tempoClass in order to see all of them on the debugBody
  void saveDataIntoTempoClass(List<int> lastData) {
    TempoData tempoData = TempoData();
    String decodedData = ascii.decode(lastData);
    String dateString = DateFormat('yyyy-MM-dd kk.mm.ss').format(DateTime.now());
    
    for(int i=0; i<decodedData.length; i++) {
      if (decodedData[i] == 'A' || decodedData[i] == 'B' || decodedData[i] == 'C' || decodedData[i] == 'T') {
        tempoData.tempoDataWithTimestamp += "$dateString, ";
      }

      //If phase D change the name to have the most understable one (ABC for A+B+C)
      if (decodedData[i] == 'T') { 
        tempoData.tempoDataWithTimestamp += 'ABC';
        tempoData.tempoDataWithoutTimestamp += 'ABC';
        }
      else { 
        tempoData.tempoDataWithTimestamp += decodedData[i]; 
        tempoData.tempoDataWithoutTimestamp += decodedData[i];
      }
    }
  }
}