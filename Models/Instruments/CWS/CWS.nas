WarningPanelUpdate = func {
  var engp = props.globals.getNode("/engines/engine/oil-pressure-bar").getValue() or 0;
  var horn = props.globals.getNode("/controls/electric/horn").getValue() or 0;
  var mgbp = props.globals.getNode("/rotors/gear/mgb-oil-pressure-bar").getValue() or 0;
  var pitot = props.globals.getNode("/controls/anti-ice/pitot-heat").getValue() or 0;
  var fuelp = props.globals.getNode("/controls/fuel/tank/fuellines_filled").getValue() or 0;
  var batt = props.globals.getNode("/systems/electrical/batt-volts").getValue() or 0;
  var n1 = props.globals.getNode("/engines/engine/n1-pct").getValue() or 0;
  var twtgrip = props.globals.getNode("/controls/engines/engine/power").getValue() or 0;
  var oilp = props.globals.getNode("/engines/engine/oil-pressure-bar-filter").getValue() or 0;
  var volts = props.globals.getNode("/systems/electrical/volts").getValue() or 0;
  var genload = props.globals.getNode("/systems/electrical/gen-load").getValue() or 0;
  var fuel =  props.globals.getNode("/consumables/fuel/tank[0]/level-lbs").getValue() or 0;
  var starter = props.globals.getNode("/controls/engines/engine/starter").getValue() or 0;
  var test = getprop("/controls/electric/warningtest");


###warnings###

  if ((fuel <106) or test)
  {
    setprop("/instrumentation/annunciators/warning/fuel",1);
  } else {
    setprop("/instrumentation/annunciators/warning/fuel",0.0);
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
  if ((fuelp < 0.99) or test)
  {
    setprop("/instrumentation/annunciators/warning/fuelp",1);
  } else {
    setprop("/instrumentation/annunciators/warning/fuelp",0.0);
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

###cautions###
  if ((oilp <1.1) or test)
  {
    setprop("/instrumentation/annunciators/cautions/engp",1);
  } else {
    setprop("/instrumentation/annunciators/cautions/engp",0);
  }

  if ((twtgrip < 0.99) or test)
  {
    setprop("/instrumentation/annunciators/cautions/twtgrip",1);
  } else {
    setprop("/instrumentation/annunciators/cautions/twtgrip",0);
  }

  if ((mgbp < 1) or test)
  {
    setprop("/instrumentation/annunciators/cautions/mgbp",1);
  } else {
    setprop("/instrumentation/annunciators/cautions/mgbp",0);
  }

  if ((engp < 1.1) or test)
  {
    setprop("/instrumentation/annunciators/cautions/engp",1);
  } else {
    setprop("/instrumentation/annunciators/cautions/engp",0);
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
