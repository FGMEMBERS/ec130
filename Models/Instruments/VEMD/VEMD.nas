#######VEMD######

####FLI = FirstLimitIndicator####
###Calculation into "FLI"###

var fliconvert= func {

  var NG = props.globals.getValue("/engines/engine/n1-pct") or 0;
  var T4 = props.globals.getValue("/engines/engine/tot-degc") or 0;
  var TRQ = props.globals.getValue("/sim/model/ec130/torque-pct") or 0;

  var fliNG = NG/10;
  var fliT4 = T4/100;
  var fliTRQ = TRQ/10;

  setprop ("/instrumentation/VEMD/FLI/fliTRQ", fliTRQ);
  setprop ("/instrumentation/VEMD/FLI/fliT4", fliT4);
  setprop ("/instrumentation/VEMD/FLI/fliNG", fliNG);

  settimer(fliconvert, 0.1);
}

setlistener("/sim/signals/fdm-initialized", fliconvert);

###Interpolation###

var compare_roc = func {

  var fliNG = props.globals.getValue("/instrumentation/VEMD/FLI/fliNG") or 0;
  var fliT4 = props.globals.getValue("/instrumentation/VEMD/FLI/fliT4") or 0;
  var fliTRQ = props.globals.getValue("/instrumentation/VEMD/FLI/fliTRQ") or 0;
     
  var delta_NG = props.globals.getValue("/instrumentation/VEMD/delta-n1-filter") or 0;
  var delta_TRQ = props.globals.getValue("/instrumentation/VEMD/delta-trq-filter") or 0;
  var delta_T4 = props.globals.getValue("/instrumentation/VEMD/delta-t4-filter") or 0;
 
  if (delta_NG > delta_TRQ){
    if (delta_NG > delta_T4){
      interpolate ("/instrumentation/VEMD/FLI/FLI", fliNG, 2);
    } else {
      interpolate ("/instrumentation/VEMD/FLI/FLI", fliT4, 2);
    }
  }else{
    if (delta_TRQ > delta_T4) {
      interpolate ("/instrumentation/VEMD/FLI/FLI", fliTRQ, 2);
    }else{
      interpolate ("/instrumentation/VEMD/FLI/FLI", fliT4, 2)
    }
  }

  settimer(compare_roc, 0.1);
}

setlistener("/sim/signals/fdm-initialized", compare_roc);

##########################
#### different phases ####
#initial phase - initial test phase
var initialphase = func{

  tested = props.globals.getNode("/instrumentation/VEMD/Phase/tested", 1);
  var volts = props.globals.getValue("/systems/electrical/volts") or 0;

  tested.setValue(0);

  if (volts >22){
    tested.setValue(1);
    settimer(initialphase, 0.1);
  }else{
    tested.setValue(0);
    settimer(initialphase, 4);
  }
}

initialphase();

var flightphase = func{

  tested = props.globals.getValue("/instrumentation/VEMD/Phase/tested") or 0;
  var pwr = props.globals.getValue("/systems/electrical/volts") or 0;
  var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
  var rpm = props.globals.getValue("/rotors/main/rpm") or 0;
  flphase = props.globals.getNode("/instrumentation/VEMD/Phase/flight", 1);
  sdphase = props.globals.getNode("/instrumentation/VEMD/Phase/shutdown", 1);
  var SEL = props.globals.getValue("/controls/engines/engine/startselector") or 0;
  var delta_Nminus = props.globals.getValue("/instrumentation/VEMD/delta-n1") or 0;
  var rotbr = props.globals.getValue("/controls/rotor/brake") or 0;

  if ((n1 > 60) and (tested > 0)){
    flphase.setValue(1);
  }else{
    flphase.setValue(0);
  }

  # fix mhab: delta_Nminus sometimes gets 0 during shutdown
  # if that happens sdphase is not recognized and causes flickering flightreport <-> vehiclepage
  # problem: if delta_Nminus is allowed to be 0 another condition is necessary to
  # distinguish startup vs. shutdown phase. for the moment the state of rotor brake is used
  # FIXME: maybe some more decisive prop can be identified to distinguish startup/shutdown ?!
  if ((SEL < 1) and (delta_Nminus <= 0) and (rpm < 70) and (tested > 0 ) and ( rotbr > 0)){
    sdphase.setValue(1);
  }else{
    sdphase.setValue(0);
  }

  settimer(flightphase, 0.1);
}

flightphase();


############################
# mhab merged from timer.nas
############################
var p = "/sim/model/ec130/flight-duration/";
var display = props.globals.getNode(p ~ "display", 1);
var time = props.globals.getNode("/sim/time/elapsed-sec");
var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
var bg = props.globals.getNode("/sim/model/ec130/flight-duration", 1);
var trig = props.globals.getValue("controls/engines/engine/startselector") or 0;

var start_time = props.globals.getValue(p ~ "start-time", 1);
var accu = props.globals.getValue(p ~ "accu", 1);

if (start_time == nil)
  start_time = 0;
if (accu == nil)
  accu = 0;

var r = props.globals.getNode(p ~ "running");
var running = r != nil ? r.getBoolValue() : 0;

var loop = func {
  if (running) {
    show(time.getValue() - start_time + accu);
    settimer(loop, 0.02);
  }
}

var begin = func {

  var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;

  if ((n1 >60) and (!running)) {
    start_time = time.getValue();
    running = 1;
    loop();
  }

  settimer(begin, 0.1);
}

begin();

var stop = func {
  var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
  if ((n1 < 50) and (running)) {
    running = 0;
    show(accu += time.getValue() - start_time);
  }

  settimer(stop, 0.1);
}

stop();

var reset = func{

  var trig = props.globals.getValue("controls/engines/engine/startselector") or 0;
  var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
  accu = 0;
  if ((trig >0) and (n1 >50) and (n1<60)){
    show(0);
  }

  settimer(reset, 0.1);
}

reset();

####OSGtext seems not to read var d. So work around####

var show = func(s) {
  var display_hr = props.globals.getNode("/sim/model/ec130/flight-duration/hr", 1);
  var display_mn = props.globals.getNode("/sim/model/ec130/flight-duration/mn", 1);
  var hours = s / 3600;
  var minutes = int(math.mod(s / 60, 60));
  var seconds = int(math.mod(s, 60));
  var msec = int(math.mod(s * 1000, 1000) / 100);
  var d = sprintf("%3d  %02d ", hours, minutes);
  display_hr.setValue(hours);
  display_mn.setValue(minutes);
}

if (running) {
  loop();
} else {
  if (accu == nil)
    accu = 0;
    show(accu);
}

props.globals.getNode(p ~ "start-time", 1).setDoubleValue(start_time);
props.globals.getNode(p ~ "running", 1).setBoolValue(running);
props.globals.getNode(p ~ "accu", 1).setDoubleValue(accu);
running = 0;  # stop display loop

#########################################

var trigger =0;

var flightnumber = {

  init:func{

    var last_fltn = props.globals.getValue("/sim/model/ec130/flightnumber") or 0;
    var fltn = props.globals.getNode("/sim/model/ec130/flightnumber", 1);
    var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;

    if (n1>60)
      trigger=1;

    var count_fltn = (last_fltn + trigger);

    fltn.setValue(count_fltn);
    trigger=0;

    last_fltn = count_fltn;
  }
};

setlistener("/controls/engines/engine/startselector", func {
  flightnumber.init();
});


##########################################
# mhab merged from roc.nas
##########################################
var get_delta=func (current,previous) {return (current-previous);}

var state = {
  new:func {
    return{parents:[state]};
  },
  n1_pct:0,
  trq_pct:0,
  t4_pct:0,
  timestamp:0,
};

var update_state = func {

  var s = state.new();
  s.n1_pct=props.globals.getValue("/engines/engine/n1-pct") or 0;
  s.trq_pct=props.globals.getValue("/sim/model/ec130/torque-pct") or 0;
  s.t4_pct=props.globals.getValue("/engines/engine/tot-degc") or 0;

  s.timestamp=systime();
  return s;

}

var tvario = {

  new: func {
    return {parents:[tvario]};
  },

  state:{
    previous:,current:
  },

  init: func {
    state.previous=state.new(); state.current=state.new();
  },

  update:func {

    state.current = update_state();

    var delta_t = get_delta(state.current.timestamp, state.previous.timestamp);

    var deltan1 = get_delta(state.current.n1_pct,state.previous.n1_pct) / delta_t;
    var deltatrq = get_delta(state.current.trq_pct,state.previous.trq_pct) / delta_t;
    var deltat4 = get_delta(state.current.t4_pct,state.previous.t4_pct) / delta_t;

    setprop("/instrumentation/VEMD/delta-n1",deltan1);
    setprop("/instrumentation/VEMD/delta-trq",deltatrq);
    setprop("/instrumentation/VEMD/delta-t4",deltat4);

    state.previous = state.current; # save current state for next call
    settimer(func me.update(), 1/20); # update rate
  }

};

var tv = tvario.new();
tv.init();
tv.update();

##############################
# mhab added
#

var VEMD = {

#  init: func{
#    return;
#  },

  scroll: func{
    screen.log.write("SCROLL was pushed");
    setprop("/instrumentation/VEMD/buttons/SCROLL",0);
  },

  reset: func{
    screen.log.write("RESET was pushed");
    setprop("/instrumentation/VEMD/buttons/RESET",0);
  }

};

setlistener("/instrumentation/VEMD/buttons/SCROLL", func {
  if ( getprop("/instrumentation/VEMD/buttons/SCROLL") ) {
    VEMD.scroll();
  }
});

setlistener("/instrumentation/VEMD/buttons/RESET", func {
  if ( getprop("/instrumentation/VEMD/buttons/RESET") ) {
    VEMD.reset();
  }
});
