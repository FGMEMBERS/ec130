# init some properties for Nasal's sake
setprop("/systems/hydraulic_servos/servosp", 0);

WarningPanelUpdate = func {
  var fuel =  props.globals.getValue("/consumables/fuel/tank[0]/level-lbs") or 0;
  var fuelp = props.globals.getValue("/controls/fuel/tank/fuellines_filled") or 0;
  var fuelf = props.globals.getValue("/controls/fuel/tank/fuelfilter") or 0;
  var servo = props.globals.getValue("/systems/hydraulic_servos/servosp") or 0;
  var hydr = props.globals.getValue("/systems/hydraulic_servos/servosp") or 0;
  var genload = props.globals.getValue("/systems/electrical/gen-load") or 0;
  var batt = props.globals.getValue("/systems/electrical/batt-volts") or 0;
  var pitot = props.globals.getValue("/controls/anti-ice/pitot-heat") or 0;
  var horn = props.globals.getValue("/controls/electric/horn") or 0;
  var door = props.globals.getValue("/sim/model/ec130/doors/door-open") or 0;
  var engp = props.globals.getValue("/engines/engine/oil-pressure-bar") or 0;
  var oilp = props.globals.getValue("/engines/engine/oil-pressure-bar-filter") or 0;
  var mgbp = props.globals.getValue("/rotors/gear/mgb-oil-pressure-bar") or 0;
  var twtgrip = props.globals.getValue("/controls/engines/engine/power") or 0;
#  var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
#  var volts = props.globals.getValue("/systems/electrical/volts") or 0;
#  var starter = props.globals.getValue("/controls/engines/engine/starter") or 0;
  var LaL = props.globals.getValue("/systems/electrical/outputs/landing-light") or 0;
  var TxL = props.globals.getValue("/systems/electrical/outputs/taxi-light") or 0;
  var servotest = getprop("/controls/electric/servotest");
  var firetest = getprop("/controls/electric/firetest");
  var test = getprop("/controls/electric/warningtest");
  var gov = props.globals.getValue("/controls/engines/engine/governor") or 0;
  var gyro = props.globals.getValue("/controls/electric/gyrocompass") or 0;

###cautions###

  if ((fuel <106) or test)
  {
    setprop("/instrumentation/annunciators/warning/fuel",1);
  } else {
    setprop("/instrumentation/annunciators/warning/fuel",0.0);
  }

  if ((fuelp < 0.99) or test)
  {
    setprop("/instrumentation/annunciators/warning/fuelp",1);
  } else {
    setprop("/instrumentation/annunciators/warning/fuelp",0.0);
  }

  if ((fuelf > 0.2) or test)
  {
    setprop("/instrumentation/annunciators/warning/fuelf",1);
  } else {
    setprop("/instrumentation/annunciators/warning/fuelf",0.0);
  }

  # value unclear, guess only
  if ((servo < 10) or servotest or test)
  {
    setprop("/instrumentation/annunciators/warning/servo",1);
  } else {
    setprop("/instrumentation/annunciators/warning/servo",0.0);
  }

  # value unclear, guess only
  if ((hydr < 10) or test)
  {
    setprop("/instrumentation/annunciators/warning/hydr",1);
  } else {
    setprop("/instrumentation/annunciators/warning/hydr",0.0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/emergxmit",1);
  } else {
    setprop("/instrumentation/annunciators/warning/emergxmit",0.0);
  }

  if ((genload<0.3) or test)
  {
    setprop("/instrumentation/annunciators/warning/gen",1);
  } else {
    setprop("/instrumentation/annunciators/warning/gen",0.0);
  }

  if ((batt < 24 ) or test)
  {
    setprop("/instrumentation/annunciators/warning/batt",1);
  } else {
    setprop("/instrumentation/annunciators/warning/batt",0.0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/inv",1);
  } else {
    setprop("/instrumentation/annunciators/warning/inv",0.0);
  }

  if ((pitot < 1) or test)
  {
    setprop("/instrumentation/annunciators/warning/pitot",1);
  } else {
    setprop("/instrumentation/annunciators/warning/pitot",0.0);
  }

  if ((horn < 1) or test)
  {
    setprop("/instrumentation/annunciators/warning/horn",1);
  } else {
    setprop("/instrumentation/annunciators/warning/horn",0.0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/noideayet",1);
  } else {
    setprop("/instrumentation/annunciators/warning/noideayet",0.0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/mgbtemp",1);
  } else {
    setprop("/instrumentation/annunciators/warning/mgbtemp",0.0);
  }

  if (door or test)
  {
    setprop("/instrumentation/annunciators/warning/door",1);
  } else {
    setprop("/instrumentation/annunciators/warning/door",0.0);
  }

  if ( !gov or test)
  {
    setprop("/instrumentation/annunciators/warning/gov",1);
  } else {
    setprop("/instrumentation/annunciators/warning/gov",0.0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/engchip",1);
  } else {
    setprop("/instrumentation/annunciators/warning/engchip",0.0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/mgbchip",1);
  } else {
    setprop("/instrumentation/annunciators/warning/mgbchip",0.0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/tgbchip",1);
  } else {
    setprop("/instrumentation/annunciators/warning/tgbchip",0.0);
  }

  if (LaL or TxL or test)
  {
    setprop("/instrumentation/annunciators/warning/lite",1);
  } else {
    setprop("/instrumentation/annunciators/warning/lite",0.0);
  }

  # LIMIT is cotrolled via limits.nas
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/limit",1);
  }

  if ( !gyro or test)
  {
    setprop("/instrumentation/annunciators/warning/gyro",1);
  } else {
    setprop("/instrumentation/annunciators/warning/gyro",0.0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/trim",1);
  } else {
    setprop("/instrumentation/annunciators/warning/trim",0.0);
  }

###warnings###

  if ((oilp <1.1) or test)
  {
    setprop("/instrumentation/annunciators/cautions/engp",1);
    setprop("/sim/sound/gong", 1);
  } else {
    setprop("/instrumentation/annunciators/cautions/engp",0);
  }

  if ((engp < 1.1) or test)
  {
    setprop("/instrumentation/annunciators/cautions/engp",1);
    setprop("/sim/sound/gong", 1);
  } else {
    setprop("/instrumentation/annunciators/cautions/engp",0);
  }

  if ((mgbp < 1) or test)
  {
    setprop("/instrumentation/annunciators/cautions/mgbp",1);
    setprop("/sim/sound/gong", 1);
  } else {
    setprop("/instrumentation/annunciators/cautions/mgbp",0);
  }

  if ( !gov or test )
  {
    setprop("/instrumentation/annunciators/warning/redgov",1);
    setprop("/sim/sound/gong", 1);
  } else {
    setprop("/instrumentation/annunciators/warning/redgov",0.0);
  }

  if (firetest or test)
  {
    setprop("/instrumentation/annunciators/warning/engfire",1);
    setprop("/sim/sound/gong", 1);
  } else {
    setprop("/instrumentation/annunciators/warning/engfire",0.0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/battemp",1);
    setprop("/sim/sound/gong", 1);
  } else {
    setprop("/instrumentation/annunciators/warning/battemp",0.0);
  }

  if ((twtgrip < 0.99) or test)
  {
    setprop("/instrumentation/annunciators/cautions/twtgrip",1);
    setprop("/sim/sound/gong", 1);
  } else {
    setprop("/instrumentation/annunciators/cautions/twtgrip",0);
  }

  # not in real use yet
  if (test)
  {
    setprop("/instrumentation/annunciators/warning/pa",1);
    setprop("/sim/sound/gong", 1);
  } else {
    setprop("/instrumentation/annunciators/warning/pa",0.0);
  }

  # turn off gong
  if (     !getprop("/instrumentation/annunciators/warning/engp")
       and !getprop("/instrumentation/annunciators/cautions/mgbp")
       and !getprop("/instrumentation/annunciators/warning/redgov")
       and !getprop("/instrumentation/annunciators/warning/engfire")
       and !getprop("/instrumentation/annunciators/warning/battemp")
       and !getprop("/instrumentation/annunciators/cautions/twtgrip")
       and !getprop("/instrumentation/annunciators/warning/pa") ) {
    setprop("/sim/sound/gong", 0);
  }

###
if (test)
  {
    setprop("/instrumentation/annunciators/test",1);
  } else {
    setprop("/instrumentation/annunciators/test",0);
  }

  settimer(WarningPanelUpdate, 0.1);
}

WarningPanelUpdate();
