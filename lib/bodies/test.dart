import 'dart:async';
import 'dart:io';

import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../classes/serialportselected.dart';


class DebugBody extends StatefulWidget {
  final String data, dataWithTimestamp;
  const DebugBody(this.data,this.dataWithTimestamp, {Key? key}) : super(key: key);

  @override
  State<DebugBody> createState() => _DebugBodyState();
}

class _DebugBodyState extends State<DebugBody> {
  var uart = SerialportSelected();
  bool isDisposed = false;
  late Timer timer;
  String dataText = "";
  final List<String> _statusTimeStamp = ['Yes', 'No'];
  String timeStamp = 'Yes';

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
          dataText = widget.dataWithTimestamp;
          // if (timeStamp == 'Yes') {
          //   dataText = widget.dataWithTimestamp;
          // } else {
          //   dataText = widget.data;
          // }
        });
      }
    });

    return  Container(
      margin: const EdgeInsets.only(left: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children : [
          const Text("Debug Mode : ", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(children: [
            const Text("Add Timestamp to trame ? "),
            RadioGroup<String>.builder(
              groupValue: timeStamp, 
              direction: Axis.horizontal,
              onChanged: (value) => setState(() {
                timeStamp = value!;
              }), 
              items: _statusTimeStamp, 
              itemBuilder: (item) => RadioButtonBuilder(item),
            ),
          ],),
          if (widget.data.isNotEmpty) Expanded(
            child: SingleChildScrollView (
              scrollDirection: Axis.vertical,
              child: Text(dataText),
            )
          ),
          FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: () =>saveCSVFile(widget.data),
            tooltip: 'save CSV file',
            child: const Icon(Icons.save),
          ), 
        ]
      ),
    );
  }
  
  ///Save the string which contains all the data received by the triphaso in a file
  saveCSVFile(String dataToSave) async{
    String dir = "${(await getDownloadsDirectory())?.absolute.path}/documentsTriphaso";
    String dateString = DateFormat('yyyy-MM-dd kk.mm').format(DateTime.now());
    File f = File("$dir/triphasoData-$dateString.csv");
    f.createSync(recursive: true);
    f.writeAsString(dataToSave);
  }
}





