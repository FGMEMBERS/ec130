##seat weights and views##

var set_seats = func {

  if ( getprop("sim/weight[0]/weight-lb") < 30 ) { setprop("sim/weight[0]/weight-lb",30) }
  if ( getprop("sim/weight[1]/weight-lb") < 30 ) { setprop("sim/weight[1]/weight-lb",30) }
  if ( getprop("sim/weight[2]/weight-lb") < 30 ) { setprop("sim/weight[2]/weight-lb",30) }
  if ( getprop("sim/weight[3]/weight-lb") < 30 ) { setprop("sim/weight[3]/weight-lb",30) }
  if ( getprop("sim/weight[4]/weight-lb") < 30 ) { setprop("sim/weight[4]/weight-lb",30) }
  if ( getprop("sim/weight[5]/weight-lb") < 30 ) { setprop("sim/weight[5]/weight-lb",30) }
  if ( getprop("sim/weight[6]/weight-lb") < 30 ) { setprop("sim/weight[6]/weight-lb",30) }
  if ( getprop("sim/weight[7]/weight-lb") < 30 ) { setprop("sim/weight[7]/weight-lb",30) }

  var p = getprop("/sim/model/ec130/interior_passengers");

  # pilot or co-pilot must be present (min weight 30+90lbs)
  if ( getprop("sim/weight[0]/weight-lb") < 120 ) {
    if ( getprop("sim/weight[1]/weight-lb") < 120 ) {
      setprop("sim/weight[0]/weight-lb",180)
    }
  }

  # 5 seats
  if ( p == 5 ) {
    # disable weight
    # front left seat
    setprop("sim/weight[2]/weight-lb",0);
  }

  # 6 seats
  if ( p == 6 ) {
    # set min weight if seats were activated from smaller configuration
    if ( getprop("sim/weight[2]/weight-lb") == 0 ) {
      setprop("sim/weight[2]/weight-lb",30);
    }
    if ( getprop("sim/weight[7]/weight-lb") == 0 ) {
      setprop("sim/weight[7]/weight-lb",30);
    }
  }

  # rescue config
  if ( p == 4 ) {

    # set weights
    setprop("sim/weight[2]/weight-lb",0);
    setprop("sim/weight[3]/weight-lb",30);
    setprop("sim/weight[7]/weight-lb",0);

    if ( getprop("sim/weight[6]/weight-lb") == 0 ) {
      setprop("sim/weight[6]/weight-lb",50);
    }
  }

  # synchronize views with weight
  set_views();
}

var set_views = func {

  # weights
  var copilotw = getprop("/sim/weight[1]/weight-lb");
  var frontlw =  getprop("/sim/weight[2]/weight-lb");
  var frontrw =  getprop("/sim/weight[3]/weight-lb");
  var rearlw =   getprop("/sim/weight[4]/weight-lb");
  var rearmlw =  getprop("/sim/weight[5]/weight-lb");
  var rearmrw =  getprop("/sim/weight[6]/weight-lb");
  var rearrw =   getprop("/sim/weight[7]/weight-lb");

  # views
  var copilotv = "sim/view[101]/enabled";
  var frontlv =  "sim/view[102]/enabled";
  var frontrv =  "sim/view[103]/enabled";
  var rearlv =   "sim/view[104]/enabled";
  var rearmlv =  "sim/view[105]/enabled";
  var rearmrv =  "sim/view[106]/enabled";
  var rearrv =   "sim/view[107]/enabled";

  # set views
  # pilotview cannot be disabled (is a fixed predefined view)
  if ( copilotw < 40 ){ setprop(copilotv,0) } else { setprop(copilotv,1) };
  if ( frontlw  < 40 ){ setprop(frontlv,0)  } else { setprop(frontlv,1)  };
  if ( frontrw  < 40 ){ setprop(frontrv,0)  } else { setprop(frontrv,1)  };
  if ( rearlw   < 40 ){ setprop(rearlv,0)   } else { setprop(rearlv,1)   };
  if ( rearmlw  < 40 ){ setprop(rearmlv,0)  } else { setprop(rearmlv,1)  };
  if ( rearmrw  < 40 ){ setprop(rearmrv,0)  } else { setprop(rearmrv,1)  };
  if ( rearrw   < 40 ){ setprop(rearrv,0)   } else { setprop(rearrv,1)   };

}
