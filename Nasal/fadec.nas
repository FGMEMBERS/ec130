###FADEC###
#simple hack- needs some work to look more professionell#

###Cycle of enginefuelpumps###
#simple hack#
var engfuelpumps =  func {

fuelpump = props.globals.getNode("/controls/engines/engine/fuel-pump", 1);
flines_filled = props.globals.getNode("/controls/fuel/tank/fuellines_filled", 1);
var n1 = props.globals.getNode("/engines/engine/n1-pct").getValue() or 0;
var CUTOFF = props.globals.getNode("/controls/engines/engine/cutoff").getValue() or 0;
var fp = props.globals.getNode("/controls/engines/engine/fuel-pump").getValue() or 0;

if (n1 > 60){
fuelpump.setValue(1);
}
else{
fuelpump.setValue(0);
}

if ((fp <1) and (CUTOFF==1)){
interpolate ("controls/fuel/tank/fuellines_filled",0, 3);
}


settimer(engfuelpumps, 0.1);
}
engfuelpumps();

###State of fuellines- if filled up engine can run- if not engine cuts off###
#simpel hack- known issue: boost-pump runs even without power#


var boostpumps = func {

flines_filled = props.globals.getNode("/controls/fuel/tank/fuellines_filled", 1);
var boostpump = props.globals.getNode("/controls/fuel/tank/boost-pump").getValue() or 0;
var n1 = props.globals.getNode("/engines/engine/n1-pct").getValue() or 0;
var CUTOFF = props.globals.getNode("/controls/engines/engine/cutoff").getValue() or 0;
var VOLTS = props.globals.getNode("/systems/electrical/volts").getValue() or 0;
var bp_pwr = getprop("/systems/electrical/outputs/boost-pump");

if (n1 <60){
if  ((boostpump >0) and (bp_pwr >22)){
interpolate ("controls/fuel/tank/fuellines_filled",1, 10);
}else{
interpolate ("controls/fuel/tank/fuellines_filled",0, 3);
}
}
if (CUTOFF==1){
interpolate ("controls/fuel/tank/fuellines_filled",0, 3);
}

settimer(boostpumps, 0.1);
}
boostpumps();


#####################################################

###Engine Start###

#controls.StartSelector = func(v = 1) {
 #   var vlt = getprop("systems/electrical/volts") or 0;
 #   if(vlt < 22) v=0;
#	setprop("controls/engines/engine/startselector",v);
#}

##starter cycle##
# var StartSelector
var start = func {

var ignition = props.globals.getNode("/controls/engines/engine/ignition", 1);
var starter = props.globals.getNode("/controls/engines/engine/starter", 1);
var fuelpump = props.globals.getNode("/controls/fuel/tank/boost-pump", 1);
var power = props.globals.getNode("controls/engines/engine/power", 1);
var starting = props.globals.getNode("controls/engines/engine/starting", 1);
var injection = props.globals.getNode("controls/engines/engine/injection", 1);


var CUTOFF = props.globals.getNode("/controls/engines/engine/cutoff").getValue() or 0;
var n1 = props.globals.getNode("/engines/engine/n1-pct").getValue() or 0;
var VOLTS = props.globals.getNode("/systems/electrical/volts").getValue() or 0;
var SEL = props.globals.getNode("/controls/engines/engine/startselector").getValue() or 0;




if ((SEL == 1) and (n1 < 63)){
if (VOLTS > 22){

starter.setValue (1);
}
}
else{
starter.setValue (0);
}

###ignition cycle###

if ((SEL ==1) and (n1 >17) and (n1 < 63)) {
if (VOLTS > 22){

ignition.setValue (1);
}
}
else{
ignition.setValue(0);
}

if ((n1 > 17) and (n1 < 63)){
starting.setValue(1.0);

}

settimer(start, 0.2);
}

start();



###fuel injection ###

var injection = {
init: func {

var injection = props.globals.getNode("controls/engines/engine/injection", 1);
var power = props.globals.getNode("controls/engines/engine/power", 1);

var flines_filled = props.globals.getNode("controls/fuel/tank/fuellines_filled").getValue() or 0;

var n1 = props.globals.getNode("/engines/engine/n1-pct").getValue() or 0;


if (flines_filled >0.90) {

power.setValue (0.13);
}
else
{
power.setValue(0.0);
}
if ((n1 > 18) and (n1 < 63)){
injection.setValue(1.0);}

}
};

setlistener("controls/engines/engine/starting", func {
injection.init();
});

###idle ###

var idle= {
init: func {


var power = props.globals.getNode("controls/engines/engine/power", 1);

var flines_filled = props.globals.getNode("controls/fuel/tank/fuellines_filled").getValue() or 0;

var n1 = props.globals.getNode("/engines/engine/n1-pct").getValue() or 0;
var CUTOFF = props.globals.getNode("/controls/engines/engine/cutoff").getValue() or 0;

 
if (CUTOFF==0){
power.setValue (0.71);

}
}

};


setlistener("controls/engines/engine/injection", func {
idle.init();
});

###flight###

var flight = func {

var flines_filled = props.globals.getNode("controls/fuel/tank/fuellines_filled").getValue() or 0;

var n1 = props.globals.getNode("/engines/engine/n1-pct").getValue() or 0;
var power = props.globals.getNode("controls/engines/engine/power", 1);
var SEL = props.globals.getNode("/controls/engines/engine/startselector").getValue() or 0;

if ((n1 > 1) and (flines_filled <0.90)) {

power.setValue(0);
}

if ((n1 > 1) and (SEL ==0)) {
power.setValue(0);
}

settimer(flight, 0.2);
}

flight();





