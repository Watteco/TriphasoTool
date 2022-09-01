import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../classes/tempodata.dart';

class DebugBody extends StatefulWidget {
  final List<int> lastData;
  const DebugBody(this.lastData, {Key? key}) : super(key: key);

  @override
  State<DebugBody> createState() => _DebugBodyState();
}

class _DebugBodyState extends State<DebugBody> {
  String lastDataReceived = "";
  List<String> dataWithTimestamp = [];
  List<String> dataWithoutTimestamp = [];
  ScrollController scrollController = ScrollController();
  bool isDisposed = false;
  late Timer timer;
  final List<String> _statusTimeStamp = ['Yes', 'No'];
  String timeStamp = 'Yes';
  TempoData tempoData = TempoData();

  @override
  void initState() {
    isDisposed = false;
    dataWithoutTimestamp.add(tempoData.tempoDataWithoutTimestamp);
    dataWithTimestamp.add(tempoData.tempoDataWithTimestamp);

    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    timer.cancel();
    scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isDisposed) {//isDisposed is here to prevent error from inactive widget when the page is closed
        setState(() {
          if (widget.lastData.isNotEmpty) {
            
            ///Problem drag and drop
            // scrollController.animateTo(
            //   scrollController.position.maxScrollExtent, 
            //   duration: const Duration(milliseconds: 200),
            //   curve: Curves.easeInOut
            // );
          } 
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
          if (widget.lastData.isNotEmpty) Expanded(
            child: SingleChildScrollView (
              controller: scrollController,
              scrollDirection: Axis.vertical,
              child: timeStamp == 'Yes' ? Text(tempoData.tempoDataWithTimestamp) : Text(tempoData.tempoDataWithoutTimestamp),
            )
          ),
          FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: () =>saveCSVFile(),
            tooltip: 'save CSV file',
            child: const Icon(Icons.save),
          ), 
        ]
      ),
    );
  }
  
  ///Save the string which contains all the data received by the triphaso in a file
  saveCSVFile() async{
    String dir = "${(await getDownloadsDirectory())?.absolute.path}/documentsTriphaso";
    String dateString = DateFormat('yyyy-MM-dd kk.mm').format(DateTime.now());
    File f = File("$dir/triphasoData-$dateString.csv");
    f.createSync(recursive: true);
    f.writeAsString(tempoData.tempoDataWithTimestamp);
  }
}