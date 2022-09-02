import 'dart:async';

import 'package:flutter/material.dart';
import 'package:triphasotool/classes/phases.dart';

import '../classes/phase.dart';
import '../classes/serialportselected.dart';


class DataBody extends StatefulWidget {
  final Phases phases;
  const DataBody(this.phases, {Key? key}) : super(key: key);

  @override
  State<DataBody> createState() => _DataBodyState();
}

class DataPhase {
  List<String> phaseValues;
  List<String> instantaneousValues;
  List<String> averageValues;
  String mode;

  DataPhase({required this.phaseValues, required this.instantaneousValues, required this.averageValues, required this.mode});
}

class _DataBodyState extends State<DataBody> {
  var uart = SerialportSelected();
  String actualMode = 'S';
  List<String> listPhases = ['Phase 1','Phase 2', 'Phase 3', 'Sum Phases'] ;
  String? selectedPhase = 'Phase 1';
  List<String> phaseDefinition = ["V", "I","(I1,V1)","(I1, U12)", "U12" ];
  List<String> epDefinition = ["","Active Power", "ReActive Power", "Active Energy", "ReActive Energy"];
  DataPhase actualPhase = DataPhase(phaseValues: ["0V","0A","0°","0°","0V"], 
                                    instantaneousValues: ["Instantaneous","0","0","0","0"], 
                                    averageValues: ["Average on Xs","0","0"],
                                    mode:"");
  int index=0;
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
            actualPhase =  changeTabsValues(widget.phases,selectedPhase, actualPhase, context);
            phaseDefinition = changeLegendNames(selectedPhase);
            actualMode = widget.phases.phaseA[widget.phases.i].mode;
          } 
        });
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children : [
        Container(
          margin: const EdgeInsets.only(left: 20, top: 20),
          child: Row(
            children: [
              const Text("Mode : ", style: TextStyle(fontWeight: FontWeight.bold)),
              widget.phases.phaseA.isEmpty ? const Text("") : Text(getModeName(actualMode)),
            ],
          )
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, top: 20),
          child : DropdownButton<String>(
          value: selectedPhase,
          items: listPhases
              .map((phase) => DropdownMenuItem<String>(
                value: phase,
                child: Text(phase)))
              .toList(),
          onChanged: (phase) => setState(() => {
            selectedPhase = phase,
            if (widget.phases.phaseA.isNotEmpty) {
              actualPhase =  changeTabsValues(widget.phases,selectedPhase, actualPhase, context),
              phaseDefinition = changeLegendNames(selectedPhase),
            } 
          }), 
          hint: const Text('Choose a Phase')),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, top: 20),
          child:Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedPhase != 'Sum Phases') ColumnData(definition: phaseDefinition, boldVariable: true, isDeltaMode: actualMode == 'D' ? true : false, columnType : 1),
              if (selectedPhase != 'Sum Phases') const SizedBox(width: 50),
              if (selectedPhase != 'Sum Phases') ColumnData(definition: actualPhase.phaseValues, boldVariable: false, isDeltaMode: actualMode == 'D' ? true : false, columnType : 1),
              if (selectedPhase != 'Sum Phases') const SizedBox(width: 150),
              ColumnData(definition: epDefinition, boldVariable: true, isDeltaMode: actualMode == 'D' ? true : false, columnType : 2),
              const SizedBox(width: 50),
              ColumnData(definition: actualPhase.instantaneousValues, boldVariable: false, isDeltaMode: actualMode == 'D' ? true : false, columnType : 2),
              const SizedBox(width: 50),
              ColumnData(definition: actualPhase.averageValues, boldVariable: false, isDeltaMode: actualMode == 'D' ? true : false, columnType : 2)
            ],
          )
        )
      ],);
  }
}

///Display of the data columns
class ColumnData extends StatefulWidget {
  const ColumnData({
    Key? key,
    required this.definition, required this.boldVariable, required this.isDeltaMode, required this.columnType,
  }) : super(key: key);

  final List<String> definition;
  final bool boldVariable;
  final bool isDeltaMode;
  final int columnType;

  @override
  State<ColumnData> createState() => _ColumnDataState();
}

class _ColumnDataState extends State<ColumnData> {
  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.columnType == 1)  
          for(var i=0; widget.isDeltaMode ? i<widget.definition.length : i<widget.definition.length - 2 ; i++) Container(
            margin: const EdgeInsets.all(5),
            child : widget.boldVariable? Text(widget.definition[i],style: const TextStyle(fontWeight: FontWeight.bold)): Text(widget.definition[i]),
          )
        else if (widget.columnType == 2 && widget.boldVariable)
          for(var i=0; i<widget.definition.length; i++) Container(
            margin: const EdgeInsets.all(5),
            child: Text(widget.definition[i], style: const TextStyle(fontWeight: FontWeight.bold),)
            )
        else if (widget.columnType == 2 && !widget.boldVariable)
          for(var i=0; i<widget.definition.length; i++) Container( 
            margin: const EdgeInsets.all(5),
            child: i==0 ? Text(widget.definition[i],style: const TextStyle( decoration: TextDecoration.underline)): Text(widget.definition[i])
          )
      ],);
    }
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

  ///Update the legend showed in the screen depending on the selected phase
  List<String> changeLegendNames(String? selectedPhase) {  
  List<String> phaseADefinition = ["V", "I","(I1,V1)","(I1, U12)", "U12" ];
  List<String> phaseBDefinition = ["V", "I","(I2,V2)","(I2, U13)", "U13" ];
  List<String> phaseCDefinition = ["V", "I","(I3,V3)","(I3, U32)", "U32" ];

    switch (selectedPhase) {
      case "Phase 1":
          return phaseADefinition;
      case "Phase 2":
          return phaseBDefinition;
      case "Phase 3":
          return phaseCDefinition;
      default:
        return phaseADefinition;
    }
  }

  ///Update the data showed in the screen depending on the selected phase
  DataPhase changeTabsValues(Phases phases, String? selectedPhase, DataPhase actualDataPhase, BuildContext context) {  
    switch (selectedPhase) {
      case "Phase 1":
          actualDataPhase = updateDataPhase(phases.phaseA[phases.phaseA.length-1], 1);
        break;
      case "Phase 2":
          actualDataPhase =  updateDataPhase(phases.phaseB[phases.phaseB.length-1], 2);
        break;
      case "Phase 3":
          actualDataPhase =  updateDataPhase(phases.phaseC[phases.phaseC.length-1], 3);
        break;
      case "Sum Phases":
          actualDataPhase =  updateDataPhase(phases.phaseABC[phases.phaseABC.length-1], 4);
        break;
      default:
        actualDataPhase = actualDataPhase;
        break;
    }

    return actualDataPhase;
  }
  
  ///Retrieve data from the phase in order to save them into dataphase class variable
  DataPhase updateDataPhase (Phase phase, int nbPhase) {
    DataPhase dataPhase = DataPhase(phaseValues: List.empty(), instantaneousValues: List.empty(), averageValues: List.empty(),mode: '');
    
    dataPhase.phaseValues = ['${phase.voltage} V', 
                              '${phase.current} A', 
                              '${phase.angle} °', 
                              '${phase.deltaAngle.toString()} °',
                              '${phase.deltaVoltage} V'];

    if (phase.mode == 'D' && nbPhase == 2)  {
      dataPhase.instantaneousValues = ['Instantaneous',
                                      '- W',
                                      '- Var',
                                      '- W.h',
                                      '- Var.h'];
          
      dataPhase.averageValues = ['Average on - s',
                              '- W',
                              '- Var'];
    } else { 
      dataPhase.instantaneousValues = ['Instantaneous',
                                        '${phase.activePowerInst.toString()} W',
                                        '${phase.reactivePowerInst.toString()} Var',
                                        '${phase.activeEnergy.toString()} W.h',
                                        '${phase.reactiveEnergy.toString()} Var.h'];

      dataPhase.averageValues = ['Average on ${phase.timingSec} s',
                                '${phase.activePowerAv.toString()} W',
                                '${phase.reactivePowerAv.toString()} Var'];
    }

    if (phase.mode == 'M') { dataPhase.mode = "Monophase"; } 
    else if (phase.mode == 'S') { dataPhase.mode = "Star"; } 
    else { dataPhase.mode = "Delta";  }

    return dataPhase;
  }


