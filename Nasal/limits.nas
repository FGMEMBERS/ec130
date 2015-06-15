# $Id$
#
# Nasal script to print errors to the screen when aircraft exceed design limits:
#  - extending flaps above maximum flap extension speed(s)
#  - extending gear above maximum gear extension speed
#  - exceeding Vna
#  - exceeding structural G limits
#
# To use, include this .nas file and define one or more of
# limits/max-flap-extension-speed/speed
# limits/max-flap-extension-speed/flaps
# limits/vne
# limits/max-gear-extension-speed
# limits/max-positive-g
# limits/max-negative-g (must be defined in max-positive-g defined)
#
# You can define multiple max-flap-extension-speed entries for max extension
# speeds for different flap settings.

# =============================== Pilot G stuff (taken from hurricane.nas) =================================
# fix mhab: this is yasim here !!
#var pilot_g = props.globals.getNode("/fdm/jsbsim/accelerations/a-pilot-z-ft_sec2", 1);
#pilot_g.setDoubleValue(0);

var g_damp = 0;

var updatePilotG = func {
  # fix mhab
  #var g = pilot_g.getValue() ;
  #if (g == nil) { g = 0; }
  var g = 0;
  g_damp = ( g * 0.2) + (g_damp * 0.8);

  settimer(updatePilotG, 0.2);
}

updatePilotG();

var checkG_VNE_MTOW_RPM = func {
  if (getprop("/sim/freeze/replay-state"))
    return;

  var max_positive = getprop("/limits/max-positive-g");
  var max_negative = getprop("/limits/max-negative-g");
  var msg = "";

  # Convert the ft/sec^2 into Gs - allowing for gravity.
  var g = (- g_damp) / 32;

  if ((max_positive != nil) and (g > max_positive)) {
    msg = "Airframe structural positive-g load limit exceeded!";
  }

  if ((max_negative != nil) and (g < max_negative)) {
    msg = "Airframe structural negative-g load limit exceeded!";
  }

  # Now check VNE
  var airspeed = getprop("/velocities/airspeed-kt");
  var vne      = getprop("/limits/vne");
  var flt      = getprop("/controls/gear/floats-inflat");
  var vne_flt  = getprop("/limits/vne-floats");

  if ((airspeed != nil) and (vne != nil) and flt and (airspeed > vne_flt)) {
    msg = "Airspeed exceeds Vne with floats inflated!";
    setprop("/sim/sound/gong", 1);
  }

  if ((airspeed != nil) and (vne != nil) and (airspeed > vne)) {
    msg = "Airspeed exceeds Vne!";
    if (airspeed > (vne+20)) {
      msg = "EXTREME OVERSPEED !!!";
      setprop("/sim/sound/warn2600",1);
    } else {
      setprop("/sim/sound/warn2600",0);
    }
    if (airspeed > (vne+45)) setprop("/sim/crashed",1);
  } else {
    setprop("/sim/sound/warn2600",0);
  }
  
  #Now Check MTOW
  var TOW =getprop("/yasim/gross-weight-lbs");
  var MTOW = getprop("/limits/MTOW");
  if (TOW > MTOW) {
    msg = "Gross weight exceeds MTOW of 5350 lbs!";
  }

  #Check Rotor rpm - warning sounds activated when Button "Horn" on SCU is engaged
  Cont310 = props.globals.getNode("/sim/sound/Cont310", 1);
  Int310 = props.globals.getNode("/sim/sound/Intermittent310", 1);
  var min_rpm = props.globals.getValue("/limits/rpm-min") or 0;
  var max_rpm = props.globals.getValue("/limits/rpm-max") or 0;
  var rpm = props.globals.getValue("/rotors/main/rpm") or 0;
  var horn = props.globals.getValue("/systems/electrical/outputs/horn") or 0;
  
  if ((rpm > max_rpm) and (horn > 24)) {
    msg = "Rotor rpm exceeds max of 410!";
    Int310.setValue(1);
  }else{
    Int310.setValue(0);
  }

  if ((rpm < min_rpm) and (horn > 24)) {
    msg = "Rotor rpm less than 360!";
    Cont310.setValue(1);
  }else{
    Cont310.setValue(0);
  }
  
  #Check take-off limits
  var trq =getprop("/sim/model/ec130/torque-pct");
  var tot =getprop("/engines/engine/tot-degc");
  var ng =getprop("/engines/engine/n1-pct");
    
  var max_trq = getprop("/limits/trq-max");
  var max_tot = getprop("/limits/tot-max");
  var max_ng = getprop("/limits/ng-max");
  
  if ((trq > max_trq) and (horn > 24)) {
    msg = "Engine Torque exceeds max of 100%!";
    setprop("/sim/sound/Cont285",1);
  }elsif ((tot > max_tot) and (horn > 24)) {
    msg = "Engine T4 exceeds 915 deg!";
    setprop("/sim/sound/Cont285",1);
  }elsif ((ng > max_ng) and (horn > 24)) {
    msg = "Engine NG exceeds 101.1%!";
    setprop("/sim/sound/Cont285",1);
  }else{
    setprop("/sim/sound/Cont285",0);
  }
  
  if (msg != "") {
    # If we have a message, display it, but don't bother checking for
    # any other errors for 5 seconds. Otherwise we're likely to get
    # repeated messages.
    screen.log.write(msg);
    settimer(checkG_VNE_MTOW_RPM, 5);
    # mhab light up LIMIT warning on panel
    setprop("/instrumentation/annunciators/warning/limit",1);
  } else {
    # mhab switch off LIMIT warning on panel
    setprop("/instrumentation/annunciators/warning/limit",0);
    settimer(checkG_VNE_MTOW_RPM, 1);
  }
}

checkG_VNE_MTOW_RPM();
