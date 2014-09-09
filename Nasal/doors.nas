# =====
# Doors
# =====

Doors = {};

Doors.new = func {
   obj = { parents : [Doors],
           frontl : aircraft.door.new("instrumentation/doors/frontl", 3.0),
           frontr : aircraft.door.new("instrumentation/doors/frontr", 3.0),
           passengerl : aircraft.door.new("instrumentation/doors/passengerl", 3.0),
           passengerr : aircraft.door.new("instrumentation/doors/passengerr", 3.0),
           luggagel : aircraft.door.new("instrumentation/doors/luggagel", 3.0),
           luggager : aircraft.door.new("instrumentation/doors/luggager", 3.0),
           door : aircraft.door.new("instrumentation/doors/door", 2.0),
           pilotw : aircraft.door.new("instrumentation/doors/pilotw", 1.0),
           slightfilter : aircraft.door.new("instrumentation/doors/slightfilter", 15.0),
           basketl : aircraft.door.new("instrumentation/doors/basketl", 2.0),
           basketr : aircraft.door.new("instrumentation/doors/basketr", 2.0),
           hook : aircraft.door.new("instrumentation/doors/hook", 2.0)
         };
   return obj;
};

Doors.frontlexport = func {
   me.frontl.toggle();
}

Doors.frontrexport = func {
   me.frontr.toggle();
}

Doors.passengerlexport = func {
   if ( !getprop("instrumentation/doors/luggagel/position-norm") ) {
     me.passengerl.toggle();
   } else {
     gui.popupTip("Luggage Door blocks Passenger Door !",3);
   }
}

Doors.passengerrexport = func {
   if ( !getprop("sim/model/ec130/basket_right") ) {
     me.passengerr.toggle();
   } else {
     gui.popupTip("Basket blocks Passenger Door !",3);
   }
}

Doors.luggagelexport = func {
   if ( !getprop("instrumentation/doors/passengerl/position-norm") ) {
     if ( !getprop("instrumentation/doors/basketl/position-norm") ) {
       me.luggagel.toggle();
     } else {
       gui.popupTip("Left basket must be closed !",3);
     }
   } else {
     gui.popupTip("Passenger Door blocks Luggage Door !",3);
   }
}

Doors.luggagerexport = func {
    if ( !getprop("instrumentation/doors/basketr/position-norm") ) {
      me.luggager.toggle();
    } else {
      gui.popupTip("Right basket must be closed !",3);
    }
}

Doors.doorexport = func {
   me.door.toggle();
}

Doors.pilotwexport = func {
   if ( !getprop("instrumentation/doors/frontl/position-norm") ) {
     me.pilotw.toggle();
   } else {
     gui.popupTip("Pilot window operable with closed door only !",3);
   }
}

Doors.slightfilterexport = func {
   if ( getprop("instrumentation/doors/slightfilter/enabled") ) {
     me.slightfilter.toggle();
   }
}

Doors.basketlexport = func {
   if ( getprop("sim/model/ec130/basket_left") ) {
     me.basketl.toggle();
   }
}

Doors.basketrexport = func {
   if ( getprop("sim/model/ec130/basket_right") ) {
     me.basketr.toggle();
   }
}

Doors.hookexport = func {
   if ( getprop("sim/model/ec130/hoist") ) {
     me.hook.toggle();
     if ( !getprop("instrumentation/doors/hook/position-norm") ) {
       gui.popupTip("Hook open !");
     } else {
       gui.popupTip("Hook closed !");
     }
   }
}

# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
doorsystem = Doors.new();
