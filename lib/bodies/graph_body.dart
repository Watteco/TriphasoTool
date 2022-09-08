import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:group_radio_button/group_radio_button.dart';
import 'package:graphic/graphic.dart';
import 'package:triphasotool/classes/phases.dart';
import '../classes/phase.dart';
import '../classes/phases.dart';

class Graphbody extends StatefulWidget {
  final Phases phases;
  const Graphbody(this.phases, {Key? key}) : super(key: key);

  @override
  State<Graphbody> createState() => _GraphbodyState();
}

class _GraphbodyState extends State<Graphbody> {
  int time = 0;

  String actualMode = 'S';
  String? selectedPhase = 'Phase 1';
  List<String> listPhases = ['Phase 1','Phase 2', 'Phase 3'] ;
  
  final voltageChannel = StreamController<GestureSignal>.broadcast();
  final currentChannel = StreamController<GestureSignal>.broadcast();
  final angleChannel = StreamController<GestureSignal>.broadcast();
  final powerChannel = StreamController<GestureSignal>.broadcast();

  List<Map> phaseAValues = [], phaseBValues = [], phaseCValues = [], dataToDisplay = [];
  
  String dataX = 'cpt', dataVoltage = 'voltage', dataAngle = 'angle', dataPower = 'activePowerInst';
  final List<String> _statusVoltage = ['V', 'U'];
  String voltage='V';
  final List<String> _statusAngle = ['(I,V)', '(I,U)'];
  String angle='(I,V)';
  final List<String> _statusPower = ['Actif', 'Reactif'];
  String power='Actif';
  late String angleGraphTitle, voltageGraphTitle ;
  List<int> minGraph = [0,0,0,0], maxGraph = [10,10,10,10];
  bool isDisposed = false;
  late Timer timer;

  @override
  void dispose() {
    isDisposed = true;
    timer.cancel();
    super.dispose();
  }
  @override
  void initState() {
    isDisposed = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isDisposed) {//isDisposed is here to prevent error from inactive widget when the page is closed
        setState(() {
          if (widget.phases.phaseA.isNotEmpty) {
            dataToDisplay = changeDataToDisplay(selectedPhase!);
            minGraph = getMinForGraph(selectedPhase!, voltage, angle, power);
            maxGraph = getMaxForGraph(selectedPhase!, voltage, angle, power);
            actualMode = widget.phases.phaseA[widget.phases.i].mode;
          }
        });
      }
    });
    

    if (time == 0 && widget.phases.phaseA.isNotEmpty) {
      phaseAValues = saveDataIntoListOfMap(widget.phases.phaseA);
      phaseBValues = saveDataIntoListOfMap(widget.phases.phaseB);
      phaseCValues = saveDataIntoListOfMap(widget.phases.phaseC);

      dataToDisplay = phaseAValues;
      angleGraphTitle = changeGraphTitle(selectedPhase, angle);
      voltageGraphTitle = changeGraphTitle(selectedPhase, voltage);
      minGraph = getMinForGraph(listPhases[0],  voltage, angle, power);
      maxGraph = getMaxForGraph(selectedPhase!, voltage, angle, power);
      time = 1;
    }

    if (widget.phases.phaseA.isNotEmpty) {
      if (actualMode != 'D') {
        angle = '(I,V)';
        voltage = 'V';
      }
    }
    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children : [
        Container(
          margin: const EdgeInsets.only(left: 20),
          child:  Row(
            children: [
              const Text("Mode : ", style: TextStyle(fontWeight: FontWeight.bold)),
              widget.phases.phaseA.isEmpty ? const Text("") : Text(getModeName(actualMode)),
            ],
          )
        ),
        Container(
          margin: const EdgeInsets.only(left: 20),
          child : DropdownButton<String>(
          value: selectedPhase,
          items: listPhases
              .map((phase) => DropdownMenuItem<String>(
                value: phase,
                child: Text(phase)))
              .toList(),
          onChanged: (phase) => setState(() => {
            selectedPhase = phase,
            dataToDisplay = changeDataToDisplay(phase!),
            minGraph = getMinForGraph(phase,  voltage, angle, power),
            maxGraph = getMaxForGraph(selectedPhase!, voltage, angle, power),
            if (actualMode != 'D') {
              angle = '(I,V)',
              voltage = 'V',
            },
            angleGraphTitle = changeGraphTitle(selectedPhase,angle),
            voltageGraphTitle = changeGraphTitle(selectedPhase, voltage),
          }), 
          hint: const Text('Choose a Phase')),
        ),
        if (widget.phases.phaseA.isNotEmpty) Row(
          children: [
            Column(
              children: [
                Text(voltageGraphTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                GraphWidget(graphName: 'Voltage',dataToDisplay: dataToDisplay, dataX: dataX, dataY: dataVoltage, dataChannel: voltageChannel,min: minGraph[0], max: maxGraph[0]), 
                if (widget.phases.phaseA.isNotEmpty && actualMode == 'D') RadioGroup<String>.builder(
                  groupValue: voltage, 
                  direction: Axis.horizontal,
                  onChanged: (value) => setState(() {
                    voltage = value!;
                    dataVoltage = changeVoltageMode(voltage);
                    minGraph = getMinForGraph(selectedPhase!,  voltage, angle, power);
                    maxGraph = getMaxForGraph(selectedPhase!, voltage, angle, power);
                    angleGraphTitle = changeGraphTitle(selectedPhase, angle);
                    voltageGraphTitle = changeGraphTitle(selectedPhase, voltage);
                    Map data = dataToDisplay[0];
                    dataToDisplay.clear();
                    dataToDisplay.add(data);
                  }), 
                  items: _statusVoltage, 
                  itemBuilder: (item) => RadioButtonBuilder(item),
                ),
              ],
            ),
            Column(
              children: [
                const Text("Current", style: TextStyle(fontWeight: FontWeight.bold)),
                GraphWidget(graphName: 'Current',dataToDisplay: dataToDisplay, dataX: dataX, dataY: 'current', dataChannel: currentChannel,min: minGraph[1], max: maxGraph[1]),
              ],
            ),
          ],
        ),
        if (widget.phases.phaseA.isNotEmpty) Row(
          children: [
            Column(
              children: [
                Text(angleGraphTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                GraphWidget(graphName: 'Angle ',dataToDisplay: dataToDisplay, dataX: dataX, dataY: dataAngle, dataChannel: angleChannel,min: minGraph[2], max: maxGraph[2]),
                 if (widget.phases.phaseA.isNotEmpty && actualMode == 'D') RadioGroup<String>.builder(
                  groupValue: angle, 
                  direction: Axis.horizontal,
                  onChanged: (value) => setState(() {
                    angle = value!;
                    dataAngle = changeAngleMode(angle);
                    minGraph = getMinForGraph(selectedPhase!,  voltage, angle, power);
                    maxGraph = getMaxForGraph(selectedPhase!, voltage, angle, power);
                    angleGraphTitle = changeGraphTitle(selectedPhase, angle);
                    voltageGraphTitle = changeGraphTitle(selectedPhase, voltage);
                  }), 
                  items: _statusAngle, 
                  itemBuilder: (item) => RadioButtonBuilder(item),
                ),
              ],
            ),
             if (actualMode != 'D' || selectedPhase != 'Phase 2') Column(
              children: [
                const Text("Power", style: TextStyle(fontWeight: FontWeight.bold)),
                GraphWidget(graphName: 'Power',dataToDisplay: dataToDisplay, dataX: dataX, dataY: dataPower, dataChannel: powerChannel,min: minGraph[3], max: maxGraph[3]),
                RadioGroup<String>.builder(
                  groupValue: power, 
                  direction: Axis.horizontal,
                  onChanged: (value) => setState(() {
                    power = value!;
                    dataPower = changePowerMode(power);
                  }), 
                  items: _statusPower, 
                  itemBuilder: (item) => RadioButtonBuilder(item),
                ),
              ],
            ),
          ],
        ),
       
        
    ]);
  }

  ///get full name of the actual mode 
  String getModeName(String mode) {
    switch (mode) {
      case 'D': 
        return 'Delta';
      case 'S': 
        return 'Star';
      case 'M':  
        return 'Monophase';
      default:
        return 'Monophase';
    }
  }

  ///Update the title of the angle's graph depending on the selected phase
  String changeGraphTitle(String? selectedPhase, String graph) {  
    List<String> title = [];
    String phaseAAngleTitle = 'Angle (I1,V1)', phaseBAngleTitle = 'Angle (I2,V2)', phaseCAngleTitle = 'Angle (I3,V3)';
    String phaseAAngleTitleDelta = 'Angle (I1,U12)', phaseBAngleTitleDelta = 'Angle (I2,U13)', phaseCAngleTitleDelta = 'Angle (I3,U32)';
    String phaseAVoltageTitle = 'Voltage V1', phaseBVoltageTitle = 'Voltage V2', phaseCVoltageTitle = 'Voltage V3';
    String phaseAVoltageTitleDelta = 'Voltage U12', phaseBVoltageTitleDelta = 'Voltage U13', phaseCVoltageTitleDelta = 'Voltage U32';

    if (graph == '(I,V)') {
      title.add(phaseAAngleTitle);
      title.add(phaseBAngleTitle);
      title.add(phaseCAngleTitle);
    } else if (graph == '(I,U)') {
      title.add(phaseAAngleTitleDelta);
      title.add(phaseBAngleTitleDelta);
      title.add(phaseCAngleTitleDelta);
    } if (graph == 'V') {
      title.add(phaseAVoltageTitle);
      title.add(phaseBVoltageTitle);
      title.add(phaseCVoltageTitle);
    } else {
      title.add(phaseAVoltageTitleDelta);
      title.add(phaseBVoltageTitleDelta);
      title.add(phaseCVoltageTitleDelta);
    }

    switch (selectedPhase) {
      case "Phase 1":
          return title[0];
      case "Phase 2":
          return title[1];
      case "Phase 3":
          return title[2];
      default:
        return title[0];
    }
  }
  

  ///change the value of the variable dataToDisplay depends on the choice of the phase to display.
  List<Map> changeDataToDisplay (String phaseString) {
    List<Map> list = [];

    if (phaseString == listPhases[0]) { list = saveDataIntoListOfMap(widget.phases.phaseA);}
    else if (phaseString == listPhases[1]) { list = saveDataIntoListOfMap(widget.phases.phaseB);}
    else { list = saveDataIntoListOfMap(widget.phases.phaseC);}
    
    return list;
  }


  ///Convert a list<Phase> into a List<Map> for the chart library
  List<Map> saveDataIntoListOfMap(List<Phase> phase) {
    List<Map> dataToSave = [];
    for (int i=0; i< phase.length; i++){
      Map map = phase[i].toJson();
      map['cpt'] = i.toString();
      dataToSave.add(map);
    }

    return dataToSave;
  }

  ///Retrieve the min value of each data of the 4 graphs
  List<int> getMinForGraph(String phaseString, String dataVoltage, String dataAngle, String dataPower) {
    List<Phase> phase = [];
    List<int> minGraph = [0,0,0,0];

    if (phaseString == listPhases[0]) { phase = widget.phases.phaseA; }
    else if (phaseString == listPhases[1]) { phase = widget.phases.phaseB; }
    else { phase = widget.phases.phaseC; }

    if (dataVoltage == 'V') { minGraph[0] = phase.map((phase) => phase.voltage.round()).reduce(min) -1; }
    else {minGraph[0] = phase.map((phase) => phase.deltaVoltage.round()).reduce(min) -1;}
    minGraph[1] = phase.map((phase) => phase.current.round()).reduce(min)-1;
    if (dataAngle == '(I,V)') { minGraph[2] = phase.map((phase) => phase.angle).reduce(min) -1;}
    else {minGraph[2] = phase.map((phase) => phase.deltaAngle).reduce(min) -1;}
    if(dataPower == 'Actif') { minGraph[3] = phase.map((phase) => phase.activePowerInst).reduce(min) -1; }
    else { minGraph[3] = phase.map((phase) => phase.reactivePowerInst).reduce(min) -1; }
    
    return minGraph;
  }

  ///Retrieve the max value of each data of the 4 graphs
  List<int> getMaxForGraph(String phaseString, String dataVoltage, String dataAngle, String dataPower) {
    List<Phase> phase = [];
    List<int> maxGraph = [0,0,0,0];

    if (phaseString == listPhases[0]) { phase = widget.phases.phaseA; }
    else if (phaseString == listPhases[1]) { phase = widget.phases.phaseB; }
    else { phase = widget.phases.phaseC; }

    if (dataVoltage == 'V') { maxGraph[0] = phase.map((phase) => phase.voltage.round()).reduce(max) +1; }
    else {maxGraph[0] = phase.map((phase) => phase.deltaVoltage.round()).reduce(max) +1;}
    maxGraph[1] = phase.map((phase) => phase.current.round()).reduce(max) +1;
    if (dataAngle == '(I,V)') { maxGraph[2] = phase.map((phase) => phase.angle).reduce(max) +1;}
    else {maxGraph[2] = phase.map((phase) => phase.deltaAngle).reduce(max) +1;}
    if(dataPower == 'Actif') { maxGraph[3] = phase.map((phase) => phase.activePowerInst).reduce(max) +1; }
    else { maxGraph[3] = phase.map((phase) => phase.reactivePowerInst).reduce(max) +1; }
    
    return maxGraph;
  }

  ///change the value of the variable dataVoltage depends on the choice of the radioButton. In delta mode only
  String changeVoltageMode(String choix) {
    if (choix == 'V') { return 'voltage';}
    else { return 'deltaVoltage';}
  }

  ///change the value of the variable dataAngle depends on the choice of the radioButton. In delta mode only
  String changeAngleMode(String choix) {
    if (choix == '(I,V)') { return 'angle';}
    else { return 'deltaAngle';}
  }

  ///change the value of the variable dataPower depends on the choice of the radioButton. 
  String changePowerMode(String choix) {
    if (choix == 'Actif') { return 'activePowerInst';}
    else { return 'reactivePowerInst';}
  }
}

class GraphWidget extends StatelessWidget {
  const GraphWidget({
    Key? key,
    required this.graphName,
    required this.dataToDisplay,
    required this.dataX,
    required this.dataY,
    required this.dataChannel, 
    required this.min,
    required this.max,
  }) : super(key: key);

  final List<Map> dataToDisplay;
  final String dataX;
  final String dataY;
  final String graphName;
  final int min;
  final int max;
  final StreamController<GestureSignal> dataChannel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30),
      width: 500,
      height: 150,
      child: ChartWidget(dataToDisplay: dataToDisplay, dataX: dataX, dataY: dataY, dataChannel: dataChannel, min: min, max: max)
      
    );
  }
}

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    Key? key,
    required this.dataToDisplay,
    required this.dataX,
    required this.dataY,
    required this.dataChannel, 
    required this.min,
    required this.max,
  }) : super(key: key);

  final List<Map> dataToDisplay;
  final String dataX;
  final String dataY;
  final int min;
  final int max;
  final StreamController<GestureSignal> dataChannel;

  @override
  Widget build(BuildContext context) {
    return Chart(
      padding: (_) => const EdgeInsets.fromLTRB(40, 5, 10, 0),
      data: dataToDisplay,
      variables: {
        dataX: Variable(
          accessor: (Map map) => map[dataX] as String,
          scale: OrdinalScale(tickCount: 5),
        ),
        dataY: Variable(
          accessor: (Map map) => map[dataY] as num,
          scale: LinearScale(min: min,max: max, tickCount: 5),
        ),
      },
      elements: [
        LineElement(
          size: SizeAttr(value: 1),
        )
      ],
      axes: [
        Defaults.horizontalAxis
          ..line = null,
        Defaults.verticalAxis
      ],
      selections: {
        'touchMove': PointSelection(
          on: {
            GestureType.scaleUpdate,
            GestureType.tapDown,
            GestureType.longPressMoveUpdate
          },
          dim: Dim.x,
        )
      },
      tooltip: TooltipGuide(align: Alignment.topRight, variables: [dataX, dataY]),
      crosshair: CrosshairGuide(
        followPointer: [true, false],
        styles: [
          StrokeStyle(color: const Color(0xffbfbfbf), dash: [4, 2]),
          StrokeStyle(color: const Color(0xffbfbfbf), dash: [4, 2]),
        ],
      ),
      gestureChannel: dataChannel,
    );
  }
}

