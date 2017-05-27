
SlipIndicatorUpdate = func {

  if (    getprop("gear/gear[0]/wow")
       or getprop("gear/gear[1]/wow")
       or getprop("gear/gear[2]/wow")
       or getprop("gear/gear[3]/wow") ) {

    interpolate("/instrumentation/attitude-indicator/side-slip-indicated",0,1);

  } else {
    setprop("/instrumentation/attitude-indicator/side-slip-indicated",getprop("/orientation/side-slip-deg"));
  }

  settimer(SlipIndicatorUpdate, 0.1);
}

SlipIndicatorUpdate();
