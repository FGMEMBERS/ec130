##external sores and weights##

var weights = func {

float_deflated_right = props.globals.getNode("/sim/model/ec130/external/float_deflated_right/weight-lb", 1);
float_deflated_left = props.globals.getNode("/sim/model/ec130/external/float_deflated_left/weight-lb", 1);
float_inflated_right = props.globals.getNode("/sim/model/ec130/external/float_inflated_right/weight-lb", 1);
float_inflated_left = props.globals.getNode("/sim/model/ec130/external/float_inflated_left/weight-lb", 1);
FLIR = props.globals.getNode("/sim/model/ec130/external/FLIR/weight-lb", 1);
searchlight = props.globals.getNode("/sim/model/ec130/external/searchlight/weight-lb", 1);
basket_right = props.globals.getNode("/sim/model/ec130/external/basket_right/weight-lb", 1);
basket_left = props.globals.getNode("/sim/model/ec130/external/basket_left/weight-lb", 1);


if (getprop("/sim/model/ec130/emerg_floats")=="true"){
float_deflated_right.setValue(100);
float_deflated_left.setValue(100);
}else{
float_deflated_right.setValue(0);
float_deflated_left.setValue(0);
}

#now the inflated floats- they keep their weight of course as with inflation now additional weight is added, but they influences now the aerodynamic. So we set weight to zero, but YASim will increase drag#
if(getprop("/controls/gear/floats-inflat")=="true"){
float_inflated_right.setValue(0);
float_inflated_left.setValue(0);
}else{
float_inflated_right.setValue(0);
float_inflated_left.setValue(0);
}

if(getprop("/controls/gear/floats-inflat")=="true"){
float_inflated_right.setValue(0);
float_inflated_left.setValue(0);
}else{
float_inflated_right.setValue(0);
float_inflated_left.setValue(0);
}

if (getprop("/sim/model/ec130/basket_right")=="true"){
basket_right.setValue(20);
}else{
basket_right.setValue(0);
}

if (getprop("/sim/model/ec130/basket_left")=="true"){
basket_left.setValue(20);
}else{
basket_left.setValue(0);
}

if (getprop("/sim/model/ec130/FLIR")=="true"){
FLIR.setValue(40);
}else{
FLIR.setValue(0);
}

if (getprop("/sim/model/ec130/searchlight")=="true"){
searchlight.setValue(50);
}else{
searchlight.setValue(0);
}



settimer(weights,0.1);
}
weights();