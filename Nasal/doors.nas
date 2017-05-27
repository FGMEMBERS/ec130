# =====
# Doors
# =====

doors = {};

doors.new = func {
  obj = { parents : [doors],
          frontl : aircraft.door.new("/sim/model/ec130/doors/frontl", 3.0),
          frontr : aircraft.door.new("/sim/model/ec130/doors/frontr", 3.0),
          passengerl : aircraft.door.new("/sim/model/ec130/doors/passengerl", 3.0),
          passengerr : aircraft.door.new("/sim/model/ec130/doors/passengerr", 3.0),
          luggagel : aircraft.door.new("/sim/model/ec130/doors/luggagel", 3.0),
          luggager : aircraft.door.new("/sim/model/ec130/doors/luggager", 3.0),
          doorb : aircraft.door.new("/sim/model/ec130/doors/doorb", 2.0),
          pilotw : aircraft.door.new("/sim/model/ec130/doors/pilotw", 1.0),
          basketl : aircraft.door.new("/sim/model/ec130/doors/basketl", 2.0),
          basketr : aircraft.door.new("/sim/model/ec130/doors/basketr", 2.0),
          hook : aircraft.door.new("/sim/model/ec130/doors/hook", 2.0),
          mgpu : aircraft.door.new("/sim/model/ec130/mgpu", 7.0)
        };
  return obj;
};

doors.frontlexport = func {
  me.frontl.toggle();
}

doors.frontrexport = func {
  if ( getprop("/sim/model/variant") == "1" ) {
    # EC130 B4 has door dependencies on right side
    if ( !getprop("/sim/model/ec130/doors/passengerr/position-norm") ) {
      me.frontr.toggle();
    } else {
      screen.log.write("Passenger Door must be closed !!!");
    }
  } else {
    # H130 has no door dependencies on right side
    me.frontr.toggle();
  }
}

doors.passengerlexport = func {
  if ( !getprop("/sim/model/ec130/doors/luggagel/position-norm") ) {
    me.passengerl.toggle();
  } else {
    screen.log.write("Luggage Door blocks Passenger Door !!!");
  }
}

doors.passengerrexport = func {
  if ( getprop("/sim/model/variant") == "1" ) {
    # EC130 B4 has door dependencies on right side
    if ( !getprop("/sim/model/ec130/basket_right") and getprop("/sim/model/ec130/doors/frontr/position-norm") ) {
      me.passengerr.toggle();
    } else {
      if ( !getprop("/sim/model/ec130/doors/frontr/position-norm") ) {
        screen.log.write("Front Door must be open !!!");
      }
      if ( getprop("/sim/model/ec130/basket_right") ) {
        screen.log.write("Basket blocks Passenger Door !!!");
      }
    }
  } else {
    # H130 has same slide door dependencies as left side
    if ( !getprop("/sim/model/ec130/doors/luggager/position-norm") ) {
      me.passengerr.toggle();
    } else {
      screen.log.write("Luggage Door blocks Passenger Door !!!");
    }
  }
}

doors.luggagelexport = func {

  if ( !getprop("gear/gear[0]/wow") and !getprop("gear/gear[1]/wow") and !getprop("gear/gear[2]/wow") and !getprop("gear/gear[3]/wow") ) {
    screen.log.write("Only possible on ground !!!");
    return;
  }

  if ( !getprop("/sim/model/ec130/doors/passengerl/position-norm") ) {
    if ( !getprop("/sim/model/ec130/doors/basketl/position-norm") ) {
      me.luggagel.toggle();
    } else {
      screen.log.write("Left basket must be closed !");
    }
  } else {
    screen.log.write("Passenger Door blocks Luggage Door !!!");
  }
}

doors.luggagerexport = func {

  if ( !getprop("gear/gear[0]/wow") and !getprop("gear/gear[1]/wow") and !getprop("gear/gear[2]/wow") and !getprop("gear/gear[3]/wow") ) {
    screen.log.write("Only possible on ground !!!");
    return;
  }

  if ( getprop("/sim/model/variant") == "1" ) {
    if ( !getprop("/sim/model/ec130/doors/basketr/position-norm") ) {
      me.luggager.toggle();
    } else {
      screen.log.write("Right basket must be closed !!!");
    }
  } else {
    # H130 same luggage door dependencies as left side
    if ( !getprop("/sim/model/ec130/doors/passengerr/position-norm") ) {
      if ( !getprop("/sim/model/ec130/doors/basketr/position-norm") ) {
        me.luggager.toggle();
      } else {
        screen.log.write("Right basket must be closed !");
      }
    } else {
      screen.log.write("Passenger Door blocks Luggage Door !!!");
    }
  }
}

doors.doorbexport = func {

  if ( !getprop("gear/gear[0]/wow") and !getprop("gear/gear[1]/wow") and !getprop("gear/gear[2]/wow") and !getprop("gear/gear[3]/wow") ) {
    screen.log.write("Only possible on ground !!!");
    return;
  }

  me.doorb.toggle();
}

doors.pilotwexport = func {
  if ( !getprop("/sim/model/ec130/doors/frontl/position-norm") ) {
    me.pilotw.toggle();
  } else {
    screen.log.write("Pilot window operable with closed door only !!!");
  }
}

doors.basketlexport = func {

  if ( !getprop("gear/gear[0]/wow") and !getprop("gear/gear[1]/wow") and !getprop("gear/gear[2]/wow") and !getprop("gear/gear[3]/wow") ) {
    screen.log.write("Only possible on ground !!!");
    return;
  }

  if ( getprop("/sim/model/ec130/basket_left") ) {
    me.basketl.toggle();
  }
}

doors.basketrexport = func {

  if ( !getprop("gear/gear[0]/wow") and !getprop("gear/gear[1]/wow") and !getprop("gear/gear[2]/wow") and !getprop("gear/gear[3]/wow") ) {
    screen.log.write("Only possible on ground !!!");
    return;
  }

  if ( getprop("/sim/model/ec130/basket_right") ) {
    me.basketr.toggle();
  }
}

doors.hookexport = func {
  if ( getprop("/sim/model/ec130/hoist") ) {
    me.hook.toggle();
    var p = getprop("/sim/model/ec130/doors/hook/position-norm");
    if ( getprop("/sim/model/ec130/doors/hook/position-norm") < 0.9 ) {
      gui.popupTip("Hook opening ...",2);
    } else {
      gui.popupTip("Hook closing ...",2);
    }
    settimer(func { gui.popupTip("Hook " ~ (p ? "closed !" : "open !"));},2.1);
  }
}

doors.mgpuexport = func {
  if ( getprop("/controls/electric/external-power") ) {
    me.mgpu.toggle();
  }
}

# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
doorsystem = doors.new();

setprop("/sim/model/ec130/doors/door-open",0);

# mhab added
DoorFlagUpdate = func {

  if ( getprop("/sim/model/ec130/doors/luggagel/position-norm")   != 0
    or getprop("/sim/model/ec130/doors/luggager/position-norm")   != 0
    or getprop("/sim/model/ec130/doors/doorb/position-norm")      != 0 ) {

    setprop("/sim/model/ec130/doors/door-open",1);

  } else {
    setprop("/sim/model/ec130/doors/door-open",0);
  }

  settimer(DoorFlagUpdate, 0.3);
}

DoorFlagUpdate();
