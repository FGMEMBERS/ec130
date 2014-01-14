# functions for main rotor handling
# mhab 20131023

#
# cycle wake strength limit
# if
# 0: off
# 1: low
# 2: medium
# 3: high
#
cycle_wakes = func () {

  var p = getprop("rotors/main/wakevisible");
  if ( p < 3 ) {
    p = p + 1;
  } else {
    p = 0;
  }
  setprop("rotors/main/wakevisible", p);
  setprop("rotors/main/wake_flag_0",0);
  setprop("rotors/main/wake_flag_1",0);
  setprop("rotors/main/wake_flag_2",0);
  setprop("rotors/main/wake_flag_3",0);

  if ( p == 0 ) {
    setprop("rotors/main/wake_flag_0",1);
    gui.popupTip("Wake invisible");
  }
  if ( p == 1 ) {
    setprop("rotors/main/wake_flag_1",1);
    gui.popupTip("Wake low");
  }
  if ( p == 2 ) {
    setprop("rotors/main/wake_flag_2",1);
    gui.popupTip("Wake medium");
  }
  if ( p == 3 ) {
    setprop("rotors/main/wake_flag_3",1);
    gui.popupTip("Wake heavy");
  }
}
