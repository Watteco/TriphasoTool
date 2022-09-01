class TempoData {
  static final TempoData _tempoData = TempoData._internal();

  String tempoDataWithoutTimestamp = "";
  String tempoDataWithTimestamp = "";


  factory TempoData() {
    return _tempoData;
  }

  TempoData._internal();

}