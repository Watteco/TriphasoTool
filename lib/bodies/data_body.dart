import 'dart:async';

import 'package:flutter/material.dart';
import 'package:triphasotool/classes/phases.dart';

import '../classes/dataphase.dart';
import '../classes/phase.dart';
import '../classes/serialportselected.dart';

class DataBody extends StatefulWidget {
  final Phases phases;
  const DataBody(this.phases, {Key? key}) : super(key: key);

  @override
  State<DataBody> createState() => _DataBodyState();
}

class _DataBodyState extends State<DataBody> {
  var uart = SerialportSelected();
  String actualMode = 'S';
  List<String> listPhases = [
    'All Phases',
    'Phase 1',
    'Phase 2',
    'Phase 3',
    'Sum Phases'
  ];
  String? selectedPhase = 'All Phases';
  List<String> phaseDefinition = ["V", "I", "(I1,V1)", "(I1, U12)", "U12"];
  List<String> phaseADefinition = ["V", "I", "(I1,V1)", "(I1, U12)", "U12"];
  List<String> phaseBDefinition = ["V", "I", "(I2,V2)", "(I2, U13)", "U13"];
  List<String> phaseCDefinition = ["V", "I", "(I3,V3)", "(I3, U32)", "U32"];

  List<String> epDefinition = [
    "",
    "Active Power",
    "ReActive Power",
    "Active Energy",
    "ReActive Energy"
  ];
  DataPhase actualPhase = DataPhase();
  DataPhase dataPhaseA = DataPhase(),
      dataPhaseB = DataPhase(),
      dataPhaseC = DataPhase(),
      dataPhaseD = DataPhase();

  int index = 0;
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
      if (!isDisposed) {
        //isDisposed is here to prevent error from inactive widget when the page is closed
        setState(() {
          if (widget.phases.phaseA.isNotEmpty) {
            actualPhase =
                changeTabsValues(widget.phases, selectedPhase, context);
            phaseDefinition = changeLegendNames(selectedPhase);
            actualMode = widget.phases.phaseA[widget.phases.i].mode;

            //for 'all phases' selection
            dataPhaseA = changeTabsValues(widget.phases, 'Phase 1', context);
            dataPhaseB = changeTabsValues(widget.phases, 'Phase 2', context);
            dataPhaseC = changeTabsValues(widget.phases, 'Phase 3', context);
            dataPhaseD = changeTabsValues(widget.phases, 'Sum Phases', context);
          }
        });
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.only(left: 20, top: 20),
            child: Row(
              children: [
                const Text("Mode : ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                widget.phases.phaseA.isEmpty
                    ? const Text("")
                    : Text(getModeName(actualMode)),
              ],
            )),
        Container(
          margin: const EdgeInsets.only(left: 20, top: 20),
          child: DropdownButton<String>(
              value: selectedPhase,
              items: listPhases
                  .map((phase) => DropdownMenuItem<String>(
                      value: phase, child: Text(phase)))
                  .toList(),
              onChanged: (phase) => setState(() => {
                    selectedPhase = phase,
                    if (widget.phases.phaseA.isNotEmpty)
                      {
                        actualPhase = changeTabsValues(
                            widget.phases, selectedPhase, context),
                        phaseDefinition = changeLegendNames(selectedPhase),
                      }
                  }),
              hint: const Text('Choose a Phase')),
        ),
        if (selectedPhase != 'All Phases')
          DataDisplay(
              selectedPhase: selectedPhase,
              phaseDefinition: phaseDefinition,
              actualMode: actualMode,
              actualPhase: actualPhase,
              epDefinition: epDefinition),
        if (selectedPhase == 'All Phases')
          Row(
            children: [
              Column(
                children: [
                  const TitleDataBlock(title: 'Phase 1', marginTop: 20),
                  DataDisplay(
                      selectedPhase: 'Phase 1',
                      phaseDefinition: phaseADefinition,
                      actualMode: actualMode,
                      actualPhase: dataPhaseA,
                      epDefinition: epDefinition),
                  const TitleDataBlock(title: 'Phase 2', marginTop: 150),
                  DataDisplay(
                      selectedPhase: 'Phase 2',
                      phaseDefinition: phaseBDefinition,
                      actualMode: actualMode,
                      actualPhase: dataPhaseB,
                      epDefinition: epDefinition),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 100),
                child: Column(
                  children: [
                    const TitleDataBlock(title: 'Phase 3', marginTop: 20),
                    DataDisplay(
                        selectedPhase: 'Phase 3',
                        phaseDefinition: phaseCDefinition,
                        actualMode: actualMode,
                        actualPhase: dataPhaseC,
                        epDefinition: epDefinition),
                    const TitleDataBlock(title: 'Sum Phases', marginTop: 150),
                    DataDisplay(
                        selectedPhase: 'Sum Phases',
                        phaseDefinition: phaseADefinition,
                        actualMode: actualMode,
                        actualPhase: dataPhaseD,
                        epDefinition: epDefinition),
                  ],
                ),
              )
            ],
          ),
      ],
    );
  }
}

///Allows the title of the data block to have some space above and a style
class TitleDataBlock extends StatelessWidget {
  const TitleDataBlock({
    Key? key,
    required this.title,
    required this.marginTop,
  }) : super(key: key);

  final String title;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              color: Color.fromARGB(238, 255, 136, 1))),
    );
  }
}

///Filling the valeurs in the data block
class DataDisplay extends StatelessWidget {
  const DataDisplay({
    Key? key,
    required this.selectedPhase,
    required this.phaseDefinition,
    required this.actualMode,
    required this.actualPhase,
    required this.epDefinition,
  }) : super(key: key);

  final String? selectedPhase;
  final List<String> phaseDefinition;
  final String actualMode;
  final DataPhase actualPhase;
  final List<String> epDefinition;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 20, top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedPhase != 'Sum Phases')
              ColumnData(
                  definition: phaseDefinition,
                  boldVariable: true,
                  isDeltaMode: actualMode == 'D' ? true : false,
                  columnType: 1),
            if (selectedPhase != 'Sum Phases') const SizedBox(width: 30),
            if (selectedPhase != 'Sum Phases')
              ColumnData(
                  definition: actualPhase.phaseValues,
                  boldVariable: false,
                  isDeltaMode: actualMode == 'D' ? true : false,
                  columnType: 1),
            if (selectedPhase != 'Sum Phases') const SizedBox(width: 80),
            ColumnData(
                definition: epDefinition,
                boldVariable: true,
                isDeltaMode: actualMode == 'D' ? true : false,
                columnType: 2),
            const SizedBox(width: 50),
            ColumnData(
                definition: actualPhase.instantaneousValues,
                boldVariable: false,
                isDeltaMode: actualMode == 'D' ? true : false,
                columnType: 2),
            const SizedBox(width: 50),
            ColumnData(
                definition: actualPhase.averageValues,
                boldVariable: false,
                isDeltaMode: actualMode == 'D' ? true : false,
                columnType: 2)
          ],
        ));
  }
}

///Display of the data columns
class ColumnData extends StatefulWidget {
  const ColumnData({
    Key? key,
    required this.definition,
    required this.boldVariable,
    required this.isDeltaMode,
    required this.columnType,
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
          for (var i = 0;
              widget.isDeltaMode
                  ? i < widget.definition.length
                  : i < widget.definition.length - 2;
              i++)
            Container(
              margin: const EdgeInsets.all(5),
              child: widget.boldVariable
                  ? Text(widget.definition[i],
                      style: const TextStyle(fontWeight: FontWeight.bold))
                  : Text(widget.definition[i]),
            )
        else if (widget.columnType == 2 && widget.boldVariable)
          for (var i = 0; i < widget.definition.length; i++)
            Container(
                margin: const EdgeInsets.all(5),
                child: Text(
                  widget.definition[i],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ))
        else if (widget.columnType == 2 && !widget.boldVariable)
          for (var i = 0; i < widget.definition.length; i++)
            Container(
                margin: const EdgeInsets.all(5),
                child: i == 0
                    ? Text(widget.definition[i],
                        style: const TextStyle(
                            decoration: TextDecoration.underline))
                    : Text(widget.definition[i]))
      ],
    );
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
  List<String> phaseADefinition = ["V", "I", "(I1,V1)", "(I1, U12)", "U12"];
  List<String> phaseBDefinition = ["V", "I", "(I2,V2)", "(I2, U13)", "U13"];
  List<String> phaseCDefinition = ["V", "I", "(I3,V3)", "(I3, U32)", "U32"];

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
DataPhase changeTabsValues(
    Phases phases, String? selectedPhase, BuildContext context) {
  DataPhase dataPhase = DataPhase();
  switch (selectedPhase) {
    case "Phase 1":
      dataPhase = updateDataPhase(phases.phaseA[phases.phaseA.length - 1], 1);
      break;
    case "Phase 2":
      dataPhase = updateDataPhase(phases.phaseB[phases.phaseB.length - 1], 2);
      break;
    case "Phase 3":
      dataPhase = updateDataPhase(phases.phaseC[phases.phaseC.length - 1], 3);
      break;
    case "Sum Phases":
      dataPhase =
          updateDataPhase(phases.phaseABC[phases.phaseABC.length - 1], 4);
      break;
    default:
      dataPhase = dataPhase;
      break;
  }

  return dataPhase;
}

///Retrieve data from the phase in order to save them into dataphase class variable
DataPhase updateDataPhase(Phase phase, int nbPhase) {
  DataPhase dataPhase = DataPhase();

  dataPhase.phaseValues = [
    '${phase.voltage} V',
    '${phase.current} A',
    '${phase.angle} °',
    '${phase.deltaAngle.toString()} °',
    '${phase.deltaVoltage} V'
  ];

  if (phase.mode == 'D' && nbPhase == 2) {
    dataPhase.instantaneousValues = [
      'Instantaneous',
      '- W',
      '- Var',
      '- W.h',
      '- Var.h'
    ];

    dataPhase.averageValues = ['Average on - s', '- W', '- Var'];
  } else {
    dataPhase.instantaneousValues = [
      'Instantaneous',
      '${phase.activePowerInst.toString()} W',
      '${phase.reactivePowerInst.toString()} Var',
      '${phase.activeEnergy.toString()} W.h',
      '${phase.reactiveEnergy.toString()} Var.h'
    ];

    dataPhase.averageValues = [
      'Average on ${phase.timingSec} s',
      '${phase.activePowerAv.toString()} W',
      '${phase.reactivePowerAv.toString()} Var'
    ];
  }

  if (phase.mode == 'M') {
    dataPhase.mode = "Monophase";
  } else if (phase.mode == 'S') {
    dataPhase.mode = "Star";
  } else {
    dataPhase.mode = "Delta";
  }

  return dataPhase;
}
