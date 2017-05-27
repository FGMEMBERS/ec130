#
# Nasal script to print errors to the screen when aircraft exceed design limits:
#  - exceeding MTOW
#  - exceeding VNE
#  - exceeding RPM rotor limits
#  - exceeding TRQ limits
#  - exceeding structural G limits
#  - exceeding temperature limits
#  ...
#
# To use, define one or more of
# limits/vne
# limits/vne-floats
# limits/vne-door-open
# limits/MTOW
# limits/rpm-min
# limits/rpm-max
# limits/trq-max
# limits/tot-max
# limits/ng-max
# limits/max-positive-g
# limits/max-negative-g
# limits/min-temp-degc
# limits/max-temp-degc
#
# LIMIT caution on CWS:
# Not all detected warning situations will light up the LIMIT caution on CWS.
# The LIMIT caution only lights up for the cases described in POH.
# For other checks implemented here, only a message is written to the screen.

# =============================== Pilot G stuff (taken from hurricane.nas) =================================
# fix mhab: this is yasim here !!
#var pilot_g = props.globals.getNode("/fdm/jsbsim/accelerations/a-pilot-z-ft_sec2", 1);
#pilot_g.setDoubleValue(0);

setprop("/accelerations/max-pilot-g",0.999);
setprop("/accelerations/min-pilot-g",0.999);


var updatePilotG = func {
  # fix mhab
  var g = getprop("/accelerations/pilot-g");
  if (g == nil) { g = 0; }
  #var g_damp = getprop("/accelerations/pilot-gdamped");
  #if (g_damp == nil) { g_damp = 0; }

  if ( g > getprop("/accelerations/max-pilot-g") ) { setprop("/accelerations/max-pilot-g",g); }
  if ( g < getprop("/accelerations/min-pilot-g") ) { setprop("/accelerations/min-pilot-g",g); }

  settimer(updatePilotG, 0.2);
}

var check_G_VNE_MTOW_RPM_TEMP = func {
  if (getprop("/sim/freeze/replay-state"))
    return;

  var limit = 0;
  var msg  = "";
  var msg1 = "";
  var msg2 = "";

  var max_positive = getprop("/limits/max-positive-g");
  var max_negative = getprop("/limits/max-negative-g");

  var gmax = getprop("/accelerations/max-pilot-g");
  var gmin = getprop("/accelerations/min-pilot-g");

  if ( max_positive != nil and gmax > max_positive ) {
    msg = sprintf("Airframe structural positive-g load limit (%2.1f) exceeded (%2.1f)!",max_positive,gmax);
  }

  # fill message stack
  if ( msg1 == "" ) { msg1 = msg;
  } else { msg2 = msg; }

  if ( max_negative != nil and gmin < max_negative ) {
    msg = sprintf("Airframe structural negative-g load limit (%2.1f) exceeded (%2.1f)!",max_negative,gmin);
  }

  # fill message stack
  if ( msg1 == "" ) { msg1 = msg;
  } else { msg2 = msg; }

  # Now check VNE
  var airspeed = getprop("/velocities/airspeed-kt");
  var vne      = getprop("/limits/vne");
  if ( vne == nil ) { vne = 155; }
  var flt      = getprop("/controls/gear/floats-inflat");
  var vne_flt  = getprop("/limits/vne-floats");
  var alt      = getprop("/position/altitude-ft");
  var pwr      = getprop("/controls/engines/engine/power");

  var door_open = 0;
  var insert    = "";
  var insert2   = "";

  # 1) vne reduction for altitude is 3kts for 1000ft
  vne_red_alt = 3.0*alt/1000.0;
  vne_corr      = vne - vne_red_alt;
  if ( flt and vne_flt != nil ) {
    vne_corr  = vne_flt - vne_red_alt;
  }

  # 2) vne reduction if doors are open
  #
  # from pilot handbook:
  # LH sliding door manoevering:                                70kts (ignored here)
  # LH sliding door open+locked:                                80kts
  # LH sliding door removed:                                   110kts (ignored here)
  # LH sliding door open+locked/removed + RH door removed:      90kts (ignored here)
  # LH sliding door open+locked/removed + all right d. removed: 90kts (ignored here)
  # LH sliding door open+locked/removed + front doors removed:  90kts (ignored here)
  #
  # Rem.: configurations with removed doors are ignored for now

  if (    getprop("/sim/model/ec130/doors/frontl/position-norm")
       or getprop("/sim/model/ec130/doors/frontr/position-norm")
       or getprop("/sim/model/ec130/doors/passengerl/position-norm")
       or getprop("/sim/model/ec130/doors/passengerr/position-norm") ) {

    door_open = 1;
    vne_door = getprop("/limits/vne-door-open");
    if ( vne_door != nil ) {
      vne_corr = vne_door - vne_red_alt;
    }
  }

  # 3) in power off state vne limit is reduced by 30kts
  vne_red_pwr = 0;
  if ( !pwr ) {
    vne_red_pwr = 30;
    insert2=" PWR is OFF !"
  }
  vne_corr = vne_corr - vne_red_pwr;

  if ( airspeed != nil and vne != nil and airspeed > vne_corr ) {
    if ( flt ) {
      insert = "with floats inflated";
      setprop("/sim/sound/gong", 1);
    }
    if ( door_open ) {
      insert = "with doors open";
      setprop("/sim/sound/gong", 1);
    }

    msg = sprintf("Airspeed (%3.0f) exceeds VNE %s (%3.0f)! %s",airspeed,insert,vne_corr,insert2);

    if (airspeed > (vne_corr+20)) {
      msg = "EXTREME OVERSPEED !!!";
      setprop("/sim/sound/warn2600",1);
    } else {
      setprop("/sim/sound/warn2600",0);
    }
    if (airspeed > (vne_corr+45)) {
      # cutoff engine
      setprop("/controls/engines/engine/cutoffguard",0);
      setprop("/controls/engines/engine/cutoff",1);
      setprop("/controls/engines/engine/cutoff-norm",1);
      setprop("/controls/rotor/brake",1);
      # crash after 30 seconds
      settimer(func {setprop("/sim/crashed",1);}, 30);
    }
  } else {
    setprop("/sim/sound/warn2600",0);
  }
  
  # fill message stack
  if ( msg1 == "" ) { msg1 = msg;
  } else { msg2 = msg; }

  #Now Check MTOW
  var TOW =getprop("/yasim/gross-weight-lbs");
  var MTOW = getprop("/limits/mass-and-balance/maximum-takeoff-mass-lbs");
  if ( MTOW == nil ) { MTOW = 5350; }
  if (TOW > MTOW) {
    msg = sprintf("Gross weight (%4.0f lbs) exceeds MTOW of %4.0f lbs!",TOW,MTOW);
  }

  # fill message stack
  if ( msg1 == "" ) { msg1 = msg;
  } else { msg2 = msg; }

  #Check Rotor rpm - warning sounds activated when Button "Horn" on SCU is engaged
  Cont310 = props.globals.getNode("/sim/sound/Cont310", 1);
  Int310 = props.globals.getNode("/sim/sound/Intermittent310", 1);
  var min_rpm = getprop("/limits/rpm-min");
  var max_rpm = getprop("/limits/rpm-max");
  var rpm     = getprop("/rotors/main/rpm");
  if ( rpm == nil ) { rpm = 0; }
  var horn    = getprop("/systems/electrical/outputs/horn");
  if ( horn == nil ) { horn = 0; }

  if ( max_rpm != nil and rpm > max_rpm and horn > 24 ) {
    msg = sprintf("Rotor rpm (%3.0f) exceeds max of %3.0f!",rpm,max_rpm);
    Int310.setValue(1);
    limit = 1;
  }else{
    Int310.setValue(0);
  }

  if ( min_rpm != nil and rpm < min_rpm and horn > 24 ) {
    msg = sprintf("Rotor rpm (%3.0f) less than %3.0f!",rpm,min_rpm);
    Cont310.setValue(1);
    limit = 1;
  }else{
    Cont310.setValue(0);
  }

  # fill message stack
  if ( msg1 == "" ) { msg1 = msg;
  } else { msg2 = msg; }

  #Check take-off limits
  var trq =getprop("/sim/model/ec130/torque-pct");
  var tot =getprop("/engines/engine/tot-degc");
  var ng =getprop("/engines/engine/n1-pct");
    
  var max_trq = getprop("/limits/trq-max");
  var max_tot = getprop("/limits/tot-max");
  var max_ng = getprop("/limits/ng-max");

  if ( max_trq != nil and trq > max_trq and horn > 24) {
    msg = sprintf("Engine Torque (%3.0f%%) exceeds max of %3.0f%%!",trq,max_trq);
    setprop("/sim/sound/Cont285",1);
    limit = 1;
  }elsif ( max_tot != nil and tot > max_tot and horn > 24 ) {
    msg = sprintf("Engine T4 (%3.0f) exceeds %3.0f deg!",tot,max_tot);
    setprop("/sim/sound/Cont285",1);
    limit = 1;
  }elsif ( max_ng != nil and ng > max_ng and horn > 24 ) {
    msg = sprintf("Engine NG (%5.1f) exceeds %5.1f%%!",ng,max_ng);
    setprop("/sim/sound/Cont285",1);
    limit = 1;
  }else{
    setprop("/sim/sound/Cont285",0);
  }

  # fill message stack
  if ( msg1 == "" ) { msg1 = msg;
  } else { msg2 = msg; }

  #Check temperature limits
  var temp     = getprop("/environment/temperature-degc");
  var temp_min = getprop("/limits/min-temp-degc");
  var temp_max = getprop("/limits/max-temp-degc");

  if ( (temp_min != nil and temp < temp_min) or (temp_max != nil and temp > temp_max) ) {
    msg = sprintf("Operation Temperature Limit (%3.0f/%3.0f) exceeded (%3.0f°C) !",temp_min,temp_max,temp);
  }
  
  # fill message stack
  if ( msg1 == "" ) { msg1 = msg;
  } else { msg2 = msg; }

  if (msg1 != "") {
    # If we have a message on stack, display stack, but don't bother checking for
    # any other errors for 5 seconds. Otherwise we're likely to get
    # repeated messages.
    screen.log.write(msg1);
    if (msg2 != "") {
      screen.log.write(msg2);
    }
    # mhab light up LIMIT warning on panel
    if ( limit ) { setprop("/instrumentation/annunciators/warning/limit",1); }
    settimer(check_G_VNE_MTOW_RPM_TEMP, 5);
  } else {
    # mhab switch off LIMIT warning on panel
    setprop("/instrumentation/annunciators/warning/limit",0);
    settimer(check_G_VNE_MTOW_RPM_TEMP, 1);
  }
}

setlistener("/sim/signals/fdm-initialized", func {
  settimer(func {
    check_G_VNE_MTOW_RPM_TEMP();
    updatePilotG();
  }, 1);
});
