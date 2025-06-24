class Phase {
  late String mode;
  late double voltage;
  late double current;
  late double tHDV;
  late double tHDI;
  late int angle;
  late double deltaVoltage ;
  late int deltaAngle;
  late int activePowerInst;
  late int reactivePowerInst;
  late int activePowerAv;
  late int reactivePowerAv;
  late int activeEnergy;
  late int reactiveEnergy;
  late int fundActivePowerInst;
	late int fundReactivePowerInst;
	late int fundActivePowerAv;
	late int fundReactivePowerAv;
	late int fundActiveEnergy;
	late int fundReactiveEnergy;
  late int timingSec;

  Phase(){
    mode = "0";
    voltage = 0;
    current = 0;
    tHDV = 0;
    tHDI = 0;
    angle = 0;
    deltaVoltage = 0;
    deltaAngle = 0;
    activePowerInst = 0;
    reactivePowerInst = 0;
    activePowerAv = 0;
    reactivePowerAv = 0;
    activeEnergy = 0;
    reactiveEnergy = 0;
    fundActivePowerInst = 0;
	  fundReactivePowerInst = 0;
	  fundActivePowerAv = 0;
	  fundReactivePowerAv = 0;
	  fundActiveEnergy = 0;
	  fundReactiveEnergy = 0;
    timingSec = 0;
  }

  factory Phase.fromJson(Map<Object, dynamic> data) {
    var phase = Phase();
    phase.mode = data['mode'] as String;
    phase.voltage = data['voltage'] as double;
    phase.current = data['current'] as double;
    phase.tHDV = data['tHDV'] as double;
    phase.tHDI = data['tHDI'] as double;
    phase.angle = data['angle'] as int;
    phase.deltaVoltage = data['deltaVoltage'] as double;
    phase.deltaAngle = data['deltaAngle'] as int;
    phase.activePowerInst = data['activePowerInst'] as int;
    phase.reactivePowerInst = data['reactivePowerInst'] as int;
    phase.activePowerAv = data['activePowerAv'] as int;
    phase.reactivePowerAv = data['reactivePowerAv'] as int;
    phase.activeEnergy = data['activeEnergy'] as int;
    phase.reactiveEnergy = data['reactiveEnergy'] as int;
    phase.fundActivePowerInst = data['fundActivePowerInst'] as int;
	  phase.fundReactivePowerInst = data['fundReactivePowerInst'] as int;
	  phase.fundActivePowerAv = data['fundActivePowerAv'] as int;
	  phase.fundReactivePowerAv = data['fundReactivePowerAv'] as int;
	  phase.fundActiveEnergy = data['fundActiveEnergy'] as int;
	  phase.fundReactiveEnergy = data['fundReactiveEnergy'] as int;
    phase.timingSec = data['timingSec'] as int;
    return phase;
  }

  Map toJson() => {
    'mode': mode,
    'voltage': voltage,
    'current': current,
    'tHDV': tHDV,
    'tHDI': tHDI,
    'angle': angle,
    'deltaVoltage': deltaVoltage,
    'deltaAngle': deltaAngle,
    'activePowerInst': activePowerInst,
    'reactivePowerInst': reactivePowerInst,
    'activePowerAv': activePowerAv,
    'reactivePowerAv': reactivePowerAv,
    'activeEnergy': activeEnergy,
    'reactiveEnergy': reactiveEnergy,
    'fundActivePowerInst': fundActivePowerInst,
	  'fundReactivePowerInst': fundReactivePowerInst,
	  'fundActivePowerAv': fundActivePowerAv,
	  'fundReactivePowerAv': fundReactivePowerAv,
	  'fundActiveEnergy': fundActiveEnergy,
	  'fundReactiveEnergy': fundReactiveEnergy,
    'timingSec': timingSec
  };
}

