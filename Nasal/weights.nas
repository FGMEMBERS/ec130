##external sores and weights##

var external_weights = func {

  wirecutter = props.globals.getNode("/sim/model/ec130/external/wirecutter/weight-lb", 1);
  mirror = props.globals.getNode("/sim/model/ec130/external/mirror/weight-lb", 1);

  FLIR = props.globals.getNode("/sim/model/ec130/external/FLIR/weight-lb", 1);
  searchlight = props.globals.getNode("/sim/model/ec130/external/searchlight/weight-lb", 1);

  basket_left = props.globals.getNode("/sim/model/ec130/external/basket_left/weight-lb", 1);
  basket_right = props.globals.getNode("/sim/model/ec130/external/basket_right/weight-lb", 1);

  float_deflated_left = props.globals.getNode("/sim/model/ec130/external/float_deflated_left/weight-lb", 1);
  float_deflated_right = props.globals.getNode("/sim/model/ec130/external/float_deflated_right/weight-lb", 1);
  float_inflated_left = props.globals.getNode("/sim/model/ec130/external/float_inflated_left/weight-lb", 1);
  float_inflated_right = props.globals.getNode("/sim/model/ec130/external/float_inflated_right/weight-lb", 1);

  snowshoe_left = props.globals.getNode("/sim/model/ec130/external/snowshoe_left/weight-lb", 1);
  snowshoe_right = props.globals.getNode("/sim/model/ec130/external/snowshoe_right/weight-lb", 1);

  hoist = props.globals.getNode("/sim/model/ec130/external/hoist/weight-lb", 1);


  if ( getprop("/sim/model/ec130/wirecutter") ){
    wirecutter.setValue(10);
  }else{
    wirecutter.setValue(0);
  }

  if ( getprop("/sim/model/ec130/mirror") ){
    mirror.setValue(10);
  }else{
    mirror.setValue(0);
  }

  if ( getprop("/sim/model/ec130/FLIR") ){
    FLIR.setValue(40);
  }else{
    FLIR.setValue(0);
  }

  if ( getprop("/sim/model/ec130/searchlight") ){
    searchlight.setValue(50);
  }else{
    searchlight.setValue(0);
  }

  if ( getprop("/sim/model/ec130/basket_left") ){
    basket_left.setValue(65);
  }else{
    basket_left.setValue(0);
  }

  if ( getprop("/sim/model/ec130/basket_right") ){
    basket_right.setValue(65);
  }else{
    basket_right.setValue(0);
  }

  if ( getprop("/sim/model/ec130/emerg_floats") ){
    float_deflated_left.setValue(67.285);
    float_deflated_right.setValue(67.285);
  }else{
    float_deflated_left.setValue(0);
    float_deflated_right.setValue(0);
  }

  # now the inflated floats- they keep their weight of course as with inflation no additional weight is added, but they influence the aerodynamics.
  # So we set weight to zero, but YASim will increase drag #
  if( getprop("/controls/gear/floats-inflat") ){
    float_inflated_left.setValue(0);
    float_inflated_right.setValue(0);
  }else{
    float_inflated_left.setValue(0);
    float_inflated_right.setValue(0);
  }

  #mhab
  if ( getprop("/sim/model/ec130/snowshoes") ){
    snowshoe_left.setValue(10);
    snowshoe_right.setValue(10);
  }else{
    snowshoe_left.setValue(0);
    snowshoe_right.setValue(0);
  }

  #mhab
  if ( getprop("/sim/model/ec130/hoist") ){
    hoist.setValue(50);
  }else{
    hoist.setValue(0);
  }

  #mhab
  # get sum weight of equipment
  var weight_equipment=0;

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/wirecutter/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/mirror/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/FLIR/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/searchlight/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/basket_left/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/basket_right/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/float_deflated_left/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/float_deflated_right/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/float_inflated_left/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/float_inflated_right/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/snowshoe_left/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/snowshoe_right/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/hoist/weight-lb");

  setprop("sim/weight[13]/weight-lb",weight_equipment);


  # mhab deactivated
  #  settimer(weights,0.1);
}

external_weights();
