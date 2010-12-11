var test = func{

#var lat = props.globals.getNode("/position/latitude-deg", 1);
#var long = props.globals.getNode("/position/longitude-deg", 1);

if (getprop("/controls/engines/engine/magnetos") >1){
interpolate("position/latitude-deg", 34.2699200,5);
interpolate("position/longitude-deg", -116.8494700,5);
#fgcommand( "presets-commit" );

#lat.setDoubleValue(34.2659200);
#long.setDoubleValue(-116.8484700);
}
settimer(test, 0.1);
}
test();
  
