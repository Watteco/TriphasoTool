class DataPhase {
  late List<String> phaseValues;
  late List<String> instantaneousValues;
  late List<String> averageValues;
  late String mode;

  DataPhase() {
    phaseValues = ["0V","0A","0°","0°","0V"];
    instantaneousValues = ["Instantaneous","0","0","0","0"]; 
    averageValues = ["Average on Xs","0","0"];
    mode = "";
  }
}
