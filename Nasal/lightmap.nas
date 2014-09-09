#### this small script handle the intensity of the lightmap effect#

call_lightmap = func {


NAV = getprop("/systems/electrical/outputs/nav-lights") or 0;
BL = getprop("/systems/electrical/outputs/beacon") or 0;
LaL = getprop("/systems/electrical/outputs/landing-light") or 0;

SUN_ANGLE = getprop("sim/time/sun-angle-rad");


setprop("/systems/electrical/outputs/nav-lights-itensity",(SUN_ANGLE * (NAV * 0.0357)));
setprop("/systems/electrical/outputs/beacon-itensity",(SUN_ANGLE * (BL * 0.010625)));
setprop("/systems/electrical/outputs/landing-light-intensity",(SUN_ANGLE * (LaL * 0.0357)));

   settimer(call_lightmap, 0.0);   
}
 
init = func {
   settimer(call_lightmap, 0.0);
}

init();
