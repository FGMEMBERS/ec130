# =====
# Doors
# =====

doors = {};

doors.new = func {
  obj = { parents : [doors],
          frontl : aircraft.door.new("instrumentation/doors/frontl", 3.0),
          frontr : aircraft.door.new("instrumentation/doors/frontr", 3.0),
          passengerl : aircraft.door.new("instrumentation/doors/passengerl", 3.0),
          passengerr : aircraft.door.new("instrumentation/doors/passengerr", 3.0),
          luggagel : aircraft.door.new("instrumentation/doors/luggagel", 3.0),
          luggager : aircraft.door.new("instrumentation/doors/luggager", 3.0),
          doorb : aircraft.door.new("instrumentation/doors/doorb", 2.0),
          pilotw : aircraft.door.new("instrumentation/doors/pilotw", 1.0),
          basketl : aircraft.door.new("instrumentation/doors/basketl", 2.0),
          basketr : aircraft.door.new("instrumentation/doors/basketr", 2.0),
          hook : aircraft.door.new("instrumentation/doors/hook", 2.0)
        };
  return obj;
};

doors.frontlexport = func {
  me.frontl.toggle();
}

doors.frontrexport = func {
  if ( !getprop("instrumentation/doors/passengerr/position-norm") ) {
    me.frontr.toggle();
  } else {
    screen.log.write("Passenger Door must be closed !");
  }
}

doors.passengerlexport = func {
  if ( !getprop("instrumentation/doors/luggagel/position-norm") ) {
    me.passengerl.toggle();
  } else {
    screen.log.write("Luggage Door blocks Passenger Door !");
  }
}

doors.passengerrexport = func {
  if ( !getprop("sim/model/ec130/basket_right") and getprop("instrumentation/doors/frontr/position-norm") ) {
    me.passengerr.toggle();
  } else {
    if ( !getprop("instrumentation/doors/frontr/position-norm") ) {
      screen.log.write("Front Door must be open !");
    }
    if ( getprop("sim/model/ec130/basket_right") ) {
      screen.log.write("Basket blocks Passenger Door !");
    }
  }
}

doors.luggagelexport = func {
  if ( !getprop("instrumentation/doors/passengerl/position-norm") ) {
    if ( !getprop("instrumentation/doors/basketl/position-norm") ) {
      me.luggagel.toggle();
    } else {
      screen.log.write("Left basket must be closed !");
    }
  } else {
    screen.log.write("Passenger Door blocks Luggage Door !");
  }
}

doors.luggagerexport = func {
  if ( !getprop("instrumentation/doors/basketr/position-norm") ) {
    me.luggager.toggle();
  } else {
    screen.log.write("Right basket must be closed !");
  }
}

doors.doorbexport = func {
  me.doorb.toggle();
}

doors.pilotwexport = func {
  if ( !getprop("instrumentation/doors/frontl/position-norm") ) {
    me.pilotw.toggle();
  } else {
    screen.log.write("Pilot window operable with closed door only !");
  }
}

doors.basketlexport = func {
  if ( getprop("sim/model/ec130/basket_left") ) {
    me.basketl.toggle();
  }
}

doors.basketrexport = func {
  if ( getprop("sim/model/ec130/basket_right") ) {
    me.basketr.toggle();
  }
}

doors.hookexport = func {
  if ( getprop("sim/model/ec130/hoist") ) {
    me.hook.toggle();
    var p = getprop("instrumentation/doors/hook/position-norm");
    if ( getprop("instrumentation/doors/hook/position-norm") < 0.9 ) {
      gui.popupTip("Hook opening ...",2);
    } else {
      gui.popupTip("Hook closing ...",2);
    }
    settimer(func { gui.popupTip("Hook " ~ (p ? "closed !" : "open !"));},2.1);
  }
}

# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
doorsystem = doors.new();

setprop("/instrumentation/doors/door-open",0);

# mhab added
DoorFlagUpdate = func {

  if ( getprop("instrumentation/doors/frontl/position-norm")     != 0
    or getprop("instrumentation/doors/frontr/position-norm")     != 0
    or getprop("instrumentation/doors/passengerl/position-norm") != 0
    or getprop("instrumentation/doors/passengerr/position-norm") != 0
    or getprop("instrumentation/doors/luggagel/position-norm")   != 0
    or getprop("instrumentation/doors/luggager/position-norm")   != 0
    or getprop("instrumentation/doors/doorb/position-norm")      != 0 ) {

    setprop("/instrumentation/doors/door-open",1);

  } else {
    setprop("/instrumentation/doors/door-open",0);
  }

  settimer(DoorFlagUpdate, 0.3);
}

DoorFlagUpdate();
