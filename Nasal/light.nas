# functions for searchlight handling
# mhab 20131023

#
# power up/down with timer delay
#
slight_toggle_power = func () {

  var s = getprop("sim/model/ec130/searchlight-state-default");
  var p = getprop("sim/model/ec130/searchlight-active");

  if ( !p ) {
    gui.popupTip("Searchlight is powered up ...",4);
    setprop("sim/model/ec130/searchlight-paused",1);
    setprop("sim/model/ec130/searchlight-active",1);
    settimer( func {
      setprop("sim/model/ec130/searchlight-paused",0);
      setprop("sim/model/ec130/searchlight-cycle-state",1);
      setprop("sim/model/ec130/searchlight-state",s);
    }, 4);
  } else {
    gui.popupTip("Searchlight is shut down ...",2);
    setprop("sim/model/ec130/searchlight-paused",1);
    settimer( func {
      setprop("sim/model/ec130/searchlight-active",0);
      setprop("sim/model/ec130/searchlight-paused",0);
      setprop("sim/model/ec130/searchlight-cycle-state",1);
    }, 2);
  }
}

#
# reset searchlight heading,elevation,lightcones
#
slight_reset = func () {

  var h = getprop("/sim/model/ec130/searchlight-heading-default");
  var p = getprop("/sim/model/ec130/searchlight-heading-deg") - h;
  if ( p < 0 ) { p=p*-1.0 };
  # slew rate 18deg/sec
  var t = p/18.0;
  interpolate("/sim/model/ec130/searchlight-heading-deg", h, t);

  var e = getprop("/sim/model/ec130/searchlight-elevation-default");
  var p = getprop("/sim/model/ec130/searchlight-elevation-deg") - e;
  if ( p < 0 ) { p=p*-1.0 };
  var t = p/18.0;
  interpolate("/sim/model/ec130/searchlight-elevation-deg", e, t);

  # set to 1 km (3) as default, 1: 200m, 2: 500m, 3: 1km, 4: 1.6km
  var s = getprop("sim/model/ec130/searchlight-state-default");
  setprop("/sim/model/ec130/searchlight-state",s);
  setprop("sim/model/ec130/searchlight-cycle-state",1);

}

#
# cycle searchlight distance (lightcone size)
# do it as described in SX-16 manual:
#   --> on the original control is only 1 knob to change distance
#       and continued pressing it changes distance from near to far and back
#       no possibility to go both directions directly
#
slight_cycle = func () {

  var p = getprop("/sim/model/ec130/searchlight-state");
  var s = getprop("/sim/model/ec130/searchlight-cycle-state");
  if ( s == 1 ) {
    if ( p < 4 ){
      setprop("/sim/model/ec130/searchlight-state",p+1);
    } else {
      setprop("/sim/model/ec130/searchlight-cycle-state",0);
      setprop("/sim/model/ec130/searchlight-state",p-1);
    }
  } else {
    if ( p > 1 ){
      setprop("/sim/model/ec130/searchlight-state",p-1);
    } else {
      setprop("/sim/model/ec130/searchlight-cycle-state",1);
      setprop("/sim/model/ec130/searchlight-state",p+1);
    }
  }
}

