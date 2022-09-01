import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:tuple/tuple.dart';

import '../classes/phases.dart';

double sizeCustomPainter = 500;

class Fresnelbody extends StatefulWidget {
  final Phases phases;
  const Fresnelbody(this.phases, {Key? key}) : super(key: key);

  @override
  State<Fresnelbody> createState() => _FresnelbodyState();
}

bool isAngleAIsChecked = true, isAngleBIsChecked = true, isAngleCIsChecked = true;
class _FresnelbodyState extends State<Fresnelbody> {
  String actualMode = '';
  String selectedVoltage= 'V';
  List<String> listVoltages = ['V', 'U'] ;
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
          if (widget.phases.phaseA.isNotEmpty) actualMode = widget.phases.phaseA[widget.phases.i-1].mode.toString();
        });
      }
    });

    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children : [
        Container(
          margin: const EdgeInsets.only(left: 20, top: 20),
          child:  Row(
            children: [
              const Text("Mode : ", style: TextStyle(fontWeight: FontWeight.bold)),
              widget.phases.phaseA.isEmpty ? const Text("") : Text(getModeName(widget.phases.phaseA[widget.phases.i-1].mode)),
            ],
          )
        ),
        if (widget.phases.phaseA.isNotEmpty && actualMode == 'D') Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20, top: 20),
              child:  const Text("According to : ", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, top: 20),
              child:  RadioGroup<String>.builder(
                groupValue: selectedVoltage, 
                onChanged: (value) => setState(() {
                  selectedVoltage = value!;
                }), 
                items: listVoltages, 
                itemBuilder: (item) => RadioButtonBuilder(item),
                direction: Axis.horizontal,
                horizontalAlignment: MainAxisAlignment.start,
              ),
            ),
          ],
        ), 
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20, top:20),
              child : CustomPaint(
                painter: FresnelDiagram(widget.phases, selectedVoltage, isAngleAIsChecked, isAngleBIsChecked, isAngleCIsChecked),
                size: Size(sizeCustomPainter, sizeCustomPainter),
              )   
            ),
            if (widget.phases.phaseA.isNotEmpty) Container(
              margin: const EdgeInsets.only(left: 40, top:20),
              child : Column (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Legend : ", style:  TextStyle(fontWeight: FontWeight.bold)),
                  selectedVoltage == 'U' ? Text('(I1,U12) : ${widget.phases.phaseA[widget.phases.i].angle}°') : Text('(I1,V1) : ${widget.phases.phaseA[widget.phases.i-1].angle}°'),
                  selectedVoltage == 'U' ? Text('(I2,U13) : ${widget.phases.phaseB[widget.phases.i].angle}°') : Text('(I2,V2) : ${widget.phases.phaseB[widget.phases.i-1].angle}°'),
                  selectedVoltage == 'U' ? Text('(I3,U32) : ${widget.phases.phaseC[widget.phases.i].angle}°') : Text('(I3,V3) : ${widget.phases.phaseC[widget.phases.i-1].angle}°'),
                  printLineForCheckBox(selectedVoltage,isAngleAIsChecked,'1'),
                  printLineForCheckBox(selectedVoltage,isAngleBIsChecked,'2'),
                  printLineForCheckBox(selectedVoltage,isAngleCIsChecked,'3')
                ]
              )
            ),
          ],
        )
    ]);
  }

  Row printLineForCheckBox(String selectedVoltage, bool isChecked, String phase){
    return Row(
      children: [
        selectedVoltage == 'U' ? Text('U$phase : ') : Text('V$phase : '),
        addCheckBox(isChecked,phase),
      ]
    );
  }

  Checkbox addCheckBox(bool isChecked, String angle) {
    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;

          if (angle == '1') {isAngleAIsChecked = !isAngleAIsChecked;}
          else if (angle == '2') {isAngleBIsChecked = !isAngleBIsChecked;}
          else {isAngleCIsChecked = !isAngleCIsChecked;}
        });
      },
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.black;
    }
    return Colors.orange;
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
}

class FresnelDiagram extends CustomPainter {
  Phases phases;
  String selectedVoltage;
  bool isAngleAIsChecked, isAngleBIsChecked, isAngleCIsChecked;
  FresnelDiagram(this.phases, this.selectedVoltage, this.isAngleAIsChecked,  this.isAngleBIsChecked,  this.isAngleCIsChecked);

  @override
  void paint(Canvas canvas, Size size) {
    double longueurV1 = 0, longueurV2 = 0, longueurV3 = 0, longueurI1 = 0, longueurI2 = 0, longueurI3 = 0;
    Tuple2<double, double> beginPoint = changeCoordonneesRepere(0,0);
    Paint paint1 = Paint(), paint2 = Paint(), paint3 = Paint(), paint4 = Paint();
    paint1.color = Colors.blue;
    paint2.color = Colors.red;
    paint3.color = Colors.green;
    paint4.color = Colors.black;

    canvas.drawLine(const Offset(0, 0), Offset(0, sizeCustomPainter), paint4);
    canvas.drawLine(const Offset(0, 0), Offset(sizeCustomPainter,0), paint4);
    canvas.drawLine( Offset(sizeCustomPainter,0), Offset(sizeCustomPainter, sizeCustomPainter), paint4);
    canvas.drawLine( Offset(0, sizeCustomPainter), Offset(sizeCustomPainter, sizeCustomPainter), paint4);
    

    if(isAngleAIsChecked && phases.phaseA.isNotEmpty ) {
      if(selectedVoltage == 'V') { longueurV1 = phases.phaseA[phases.phaseA.length-1].voltage*((sizeCustomPainter/2)-30)/300; } 
      else { longueurV1 = phases.phaseA[phases.phaseA.length-1].deltaVoltage*((sizeCustomPainter/2)-30)/300; }
      drawVector(canvas, beginPoint, 0, 0, longueurV1, paint1,'V1');
    }

    if(isAngleBIsChecked && phases.phaseA.isNotEmpty ) {
      if(selectedVoltage == 'V') { longueurV2 = phases.phaseB[phases.phaseB.length-1].voltage*((sizeCustomPainter/2)-30)/300; }
      else { longueurV2 = phases.phaseB[phases.phaseB.length-1].deltaVoltage*((sizeCustomPainter/2)-30)/300; }
      drawVector(canvas, beginPoint, 0, 120, longueurV2, paint2,'V2');
    }

    if(isAngleCIsChecked && phases.phaseA.isNotEmpty ) {
      if(selectedVoltage == 'V') { longueurV3 = phases.phaseC[phases.phaseC.length-1].voltage*((sizeCustomPainter/2)-30)/300; }
      else  { longueurV3 = phases.phaseC[phases.phaseC.length-1].deltaVoltage*((sizeCustomPainter/2)-30)/300; }
      drawVector(canvas, beginPoint, 120, 120, longueurV3, paint3,'V3');
    }

    if(isAngleAIsChecked && phases.phaseA.isNotEmpty ) {
      longueurI1 = 45; //phases.phaseA[phases.phaseA.length-1].current*((sizeCustomPainter/2)-30)/200;
      if(selectedVoltage == 'V') { drawVector(canvas, beginPoint, 0, -phases.phaseA[phases.phaseA.length-1].angle.toDouble(), longueurI1, paint1,'I1'); }
      else { drawVector(canvas, beginPoint, 0, -phases.phaseA[phases.phaseA.length-1].deltaAngle.toDouble(), longueurI1, paint1,'I1'); }
    }

    if(isAngleBIsChecked && phases.phaseA.isNotEmpty ) {
      longueurI2 = 90; //phases.phaseB[phases.phaseB.length-1].current*((sizeCustomPainter/2)-30)/200;
      if(selectedVoltage == 'V') { drawVector(canvas, beginPoint, 120, -phases.phaseB[phases.phaseB.length-1].angle.toDouble(), longueurI2, paint2, 'I2'); }
      else {  drawVector(canvas, beginPoint, 120, -phases.phaseB[phases.phaseB.length-1].deltaAngle.toDouble(), longueurI2, paint2, 'I2'); }
    }

    if(isAngleCIsChecked && phases.phaseA.isNotEmpty ) {
      longueurI3 = 90; //phases.phaseC[phases.phaseC.length-1].current*((sizeCustomPainter/2)-30)/200;
      if(selectedVoltage == 'V') { drawVector(canvas, beginPoint, 240, -phases.phaseC[phases.phaseC.length-1].angle.toDouble(), longueurI3, paint3,'I3'); }
      else { drawVector(canvas, beginPoint, 240, -phases.phaseC[phases.phaseC.length-1].deltaAngle.toDouble(), longueurI3, paint3,'I3'); }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate.semanticsBuilder != semanticsBuilder;
  }

  void drawVector(Canvas canvas, Tuple2<double, double> beginPoint, double alpha, double gamma, double longueur, Paint paint, String text) {
    double x=0, y=0;
    final textStyle = ui.TextStyle(color: Colors.black, fontSize: 20);
    final paragraphStyle = ui.ParagraphStyle(textDirection: TextDirection.ltr);
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 50));

    x = longueur*cos((alpha+gamma)*3.14/180);
    y = longueur*sin((alpha+gamma)*3.14/180);
   
    Tuple2<double, double> finalPoint= changeCoordonneesRepere(x,y); 
    canvas.drawLine(Offset(beginPoint. item1, beginPoint.item2), Offset(finalPoint.item1, finalPoint.item2), paint);
    if (longueur >10) canvas.drawParagraph(paragraph,  Offset(finalPoint.item1 + 10, finalPoint.item2 + 10));
  }
  
  Tuple2<double, double> changeCoordonneesRepere(double x, double y)
  { 
    return Tuple2<double, double>(((sizeCustomPainter)/2)+x, ((sizeCustomPainter)/2)-y) ;
  }
}

