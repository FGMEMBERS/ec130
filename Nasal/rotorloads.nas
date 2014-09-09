#rotorloads
#simulating the force of the rotor due to Rotor-RPM, blade-incidence, g-forces and airpressure
#To-Do: calculate forces for each control, add airpressure
#very, very, very simplified- engineers: please make me right! 


var incidence = 0;
var rpm_norm = 0;

var run = func {
var incidence = props.globals.getNode("/rotors/main/incidence", 1);
var rpm_norm = props.globals.getNode("/rotors/main/rpm_norm", 1);
rotor_load = props.globals.getNode("/rotors/main/rotor_load", 1);

var rrpm = props.globals.getNode("/rotors/main/rpm").getValue() or 0;
var incidence = props.globals.getNode("/rotors/main/incidence").getValue() or 0;
var rpm_norm = props.globals.getNode("/rotors/main/rpm_norm").getValue() or 0;

var g = getprop("/accelerations/pilot-g");

var incidence1 =getprop("/rotors/main/blade/incidence-deg");
var incidence2 = getprop("/rotors/main/blade[1]/incidence-deg");
var incidence3 = getprop("/rotors/main/blade[2]/incidence-deg");



if (rrpm >0){
setprop("/rotors/main/rpm_norm", rrpm/386);
setprop("/rotors/main/incidence", (incidence1 + incidence2 + incidence2)/3);
}

if (rrpm >0){
force = rpm_norm * (incidence*2) * g/2;
rotor_load.setDoubleValue(force);
}else{
rotor_load.setDoubleValue(0);
}

settimer(run, 0.1);
}
run();







