################
#saving states so it makes it all a bit more realistic#
################


var save_list = [ "/sim/model/fuel/tank[0]/level-gal_us",
		 "/engines/engine/oil-temperature-degc-filter",
		 "/sim/model/ec130/flightnumber",
		  ];

aircraft.data.add(save_list);

# Load saved fuel level on sim initialization

var tank_0 = props.globals.getNode("/consumables/fuel/tank[0]/level-gal_us", 1);
#var tank_1 = props.globals.getNode("/consumables/fuel/tank[1]/level-gal_us", 1);
var copy_0 = props.globals.getNode("/sim/model/fuel/tank[0]/level-gal_us", 1);
#var copy_1 = props.globals.getNode("/sim/model/fuel/tank[1]/level-gal_us", 1);

var update_fuel = func {

    if (copy_0.getValue() != nil) {
        tank_0.setValue(copy_0.getValue());
    }
   # if (copy_1.getValue() != nil) {
   #     tank_1.setValue(copy_1.getValue());
   # }

    setlistener("/consumables/fuel/tank[0]/level-gal_us", func {
        copy_0.setValue(tank_0.getValue());
    });

   # setlistener("/consumables/fuel/tank[1]/level-gal_us", func {
   #     copy_1.setValue(tank_1.getValue());
   # });
 
}

var loadup = func{

#var CUTOFF = props.globals.getNode("/controls/engines/engine/cutoff").getValue() or 0;
var copy_0 = props.globals.getNode("/sim/model/fuel/tank[0]/level-gal_us").getValue() or 0;
var tank_0 = props.globals.getNode("/consumables/fuel/tank[0]/level-gal_us", 1);

tank_0.setValue(copy_0);
}



var load = setlistener("/sim/signals/fdm-initialized", func {
    #set_tanks(fuel_valve.getValue());
    update_fuel();
    loadup();
    #add_hours();
    #update_lights_intensity();
    #smoke_rain_update();
    #update_canopy_visibility();
    #MP_update();
    removelistener(load);
});

#Load saved fuel level on sim initialization
# Load saved fuel level on sim initialization

