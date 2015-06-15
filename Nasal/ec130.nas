# (c) Melchior FRANZ  < mfranz # flightgear : org > Thanks for it- currently there is no better solutionout there!

#print("\x1b[35m
print("\x1b
  ______   _____      __   ____     ___       ____    _  _
 |  ____| /  ___|    /_ | |__  \   / _ \     |  _ \  | || |
 | |__    | |         | |  __) |  | | | |    | |_) | | || |_
 |  __|   | |         | | |__ <   | | | |    |  _ <  |__   _|
 | |____  | |___      | |  __) |  | |_| |    | |_) |    | |
 |______| \_____|     |_| |____/   \___/     |____/     |_|
\x1b");


if (!contains(globals, "cprint"))
  var cprint = func nil;

var devel = !!getprop("devel");
var quickstart = !!getprop("quickstart");

var sin = func(a) math.sin(a * D2R);
var cos = func(a) math.cos(a * D2R);
var pow = func(v, w) math.exp(math.ln(v) * w);
var npow = func(v, w) v ? math.exp(math.ln(abs(v)) * w) * (v < 0 ? -1 : 1) : 0;
var clamp = func(v, min = 0, max = 1) v < min ? min : v > max ? max : v;
var normatan = func(x, slope = 1) math.atan2(x, slope) * 2 / math.pi;
var bell = func(x, spread = 2) pow(math.e, -(x * x) / spread);
var max = func(a, b) a > b ? a : b;
var min = func(a, b) a < b ? a : b;

# liveries =========================================================
# mhab: use index in listing liveries
aircraft.livery.init("/Aircraft/ec130/Models/Liveries", "/sim/model/livery/name", "/sim/model/livery/index");

# timers ============================================================
aircraft.timer.new("/sim/time/hobbs/helicopter", nil).start();

# strobes ===========================================================
var strobe_switch = props.globals.initNode("/controls/lighting/strobe", 1, "BOOL");
aircraft.light.new("/sim/model/ec130/lighting/strobe-top", [0.05, 1.00], strobe_switch);
aircraft.light.new("/sim/model/ec130/lighting/strobe-bottom", [0.05, 1.03], strobe_switch);

# beacons ===========================================================
var beacon_switch = props.globals.initNode("/controls/lighting/beacon", 1, "BOOL");
aircraft.light.new("/sim/model/ec130/lighting/beacon-top", [0.62, 0.62], beacon_switch);
aircraft.light.new("/sim/model/ec130/lighting/beacon-bottom", [0.63, 0.63], beacon_switch);

# nav lights ========================================================
var nav_light_switch = props.globals.initNode("/controls/lighting/nav-lights", 1, "BOOL");
var visibility = props.globals.getNode("/environment/visibility-m", 1);
var sun_angle = props.globals.getNode("/sim/time/sun-angle-rad", 1);
var nav_lights = props.globals.getNode("/sim/model/ec130/lighting/nav-lights", 1);

var nav_light_loop = func {
  if (nav_light_switch.getValue())
    nav_lights.setValue(visibility.getValue() < 5000 or sun_angle.getValue() > 1.4);
  else
    nav_lights.setValue(0);

  settimer(nav_light_loop, 3);
}

nav_light_loop();

# fuel ==============================================================

# density = 6.682 lb/gal [Flight Manual Section 9.2]
# avtur/JET A-1/JP-8
var FUEL_DENSITY = getprop("/consumables/fuel/tank/density-ppg"); # pound per gallon
var GAL2LB = FUEL_DENSITY;
var LB2GAL = 1 / GAL2LB;
var KG2GAL = KG2LB * LB2GAL;
var GAL2KG = 1 / KG2GAL;

var Tank = {
  new: func(n) {
    var m = { parents: [Tank] };
    m.capacity = n.getValue("capacity-gal_us");
    m.level_galN = n.initNode("level-gal_us", m.capacity);
    m.level_lbN = n.getNode("level-lbs");
    m.consume(0);
    return m;
  },
  level: func {
    return me.level_galN.getValue();
  },
  consume: func(amount) { # US gal (neg. values for feeding)
    var level = me.level();
    if (amount > level)
      amount = level;
    level -= amount;
    if (level > me.capacity)
      level = me.capacity;
    me.level_galN.setDoubleValue(level);
    me.level_lbN.setDoubleValue(level * GAL2LB);
    return amount;
  },
};

var fuel = {
  init: func {
    var fuel = props.globals.getNode("/consumables/fuel");
    me.pump_capacity = 6.6 * L2GAL / 60; # same pumps for transfer and supply; from ec135: 6.6 l/min
    me.total_galN = fuel.getNode("total-fuel-gals", 1);
    me.total_lbN = fuel.getNode("total-fuel-lbs", 1);
    me.total_normN = fuel.getNode("total-fuel-norm", 1);
    #me.supply = Tank.new(fuel.getNode("tank[1]"));
    me.main = Tank.new(fuel.getNode("tank[0]"));

    #var sw = props.globals.getNode("/controls/switches");
    #setlistener(sw.initNode("/fuel/transfer-pump[0]", 1, "BOOL"), func(n) me.trans1 = n.getValue(), 1);
    #setlistener(sw.initNode("/fuel/transfer-pump[1]", 1, "BOOL"), func(n) me.trans2 = n.getValue(), 1);
    setlistener("/sim/freeze/fuel", func(n) me.freeze = n.getBoolValue(), 1);
    me.capacity = me.main.capacity;
    #me.warntime = 0;
    #me.update(0);
  },
  update: func(dt) {
    # transfer pumps (feed supply from main)
    #var free = me.supply.capacity - me.supply.level();
    #if (free > 0) {
    #  var trans_flow = (me.trans1 + me.trans2) * me.pump_capacity;
    #  me.supply.consume(-me.main.consume(min(trans_flow * dt, free)));
    #}

    # low fuel warning [POH "General Description" 0.28a]
    #var time = elapsedN.getValue();
    #if (time > me.warntime and me.supply.level() * GAL2KG < 60) {
    #  screen.log.write("LOW FUEL WARNING", 1, 0, 0);
    #  me.warntime = time + screen.log.autoscroll * 2;
    #}

    var level = me.main.level();
    me.total_galN.setDoubleValue(level);
    me.total_lbN.setDoubleValue(level * GAL2LB);
    me.total_normN.setDoubleValue(level / me.capacity);
  },
  level: func {
    return me.main.level();
  },
  consume: func(amount) {
    return me.freeze ? 0 : me.main.consume(amount);
  }
};

# engines/rotor =====================================================
var rotor_rpm = props.globals.getNode("/rotors/main/rpm");
var torque = props.globals.getNode("/rotors/gear/total-torque", 1);
var collective = props.globals.getNode("/controls/engines/engine[0]/throttle");
var turbine = props.globals.getNode("/sim/model/ec130/turbine-rpm-pct", 1);
var torque_pct = props.globals.getNode("/sim/model/ec130/torque-pct", 1);
var target_rel_rpm = props.globals.getNode("/controls/rotor/reltarget", 1);
var max_rel_torque = props.globals.getNode("/controls/rotor/maxreltorque", 1);

var Engine = {
  new: func(n) {
    var m = { parents: [Engine] };
    m.in = props.globals.getNode("/controls/engines", 1).getChild("engine", n, 1);
    m.out = props.globals.getNode("engines", 1).getChild("engine", n, 1);
    m.airtempN = props.globals.getNode("/environment/temperature-degc");

    # input
    m.ignitionN = m.in.initNode("ignition", 0, "BOOL");
    m.starterN = m.in.initNode("starter", 0, "BOOL");
    m.powerN = m.in.initNode("power", 0);
    m.magnetoN = m.in.initNode("magnetos", 1, "INT");

    # output
    m.runningN = m.out.initNode("running", 0, "BOOL");
    m.n1_pctN = m.out.initNode("n1-pct", 0);
    m.n2_pctN = m.out.initNode("n2-pct", 0);
    m.n1N = m.out.initNode("n1-rpm", 0);
    m.n2N = m.out.initNode("n2-rpm", 0);
    m.totN = m.out.initNode("tot-degc", m.airtempN.getValue());

    m.starterLP = aircraft.lowpass.new(3);
    m.n1LP = aircraft.lowpass.new(4);
    m.n2LP = aircraft.lowpass.new(4);
    setlistener("/sim/signals/reinit", func(n) n.getValue() or m.reset(), 1);
    m.timer = aircraft.timer.new("/sim/time/hobbs/turbines[" ~ n ~ "]", 10);
    m.running = 0;
    m.fuelflow = 0;
    m.n1 = -1;
    m.up = -1;
    return m;
  },
  reset: func {
    me.magnetoN.setIntValue(1);
    me.ignitionN.setBoolValue(0);
    me.starterN.setBoolValue(0);
    me.powerN.setDoubleValue(0);
    me.runningN.setBoolValue(me.running = 0);
    me.starterLP.set(0);
    me.n1LP.set(me.n1 = 0);
    me.n2LP.set(me.n2 = 0);
  },
  update: func(dt, trim = 0) {
    var starter = me.starterLP.filter(me.starterN.getValue() * 0.19);  # starter 15-20% N1max
    me.powerN.setValue(me.power = clamp(me.powerN.getValue()));
    var power = me.power * 0.97 + trim;          # 97% = N2% in flight position

    if (me.running)
      power += (1 - collective.getValue()) * 0.03;      # droop compensator
    if (power > 1.12)
      power = 1.12;              # overspeed restrictor

    me.fuelflow = 0;
    if (!me.running) {
      if (me.n1 > 0.05 and power > 0.05 and me.ignitionN.getValue()) {
        me.runningN.setBoolValue(me.running = 1);
        me.timer.start();
      }

    } elsif (power < 0.05 or !fuel.level()) {
      me.runningN.setBoolValue(me.running = 0);
      me.timer.stop();

    } else {
      me.fuelflow = power;
    }

    var lastn1 = me.n1;
    me.n1 = me.n1LP.filter(max(me.fuelflow, starter));
    me.n2 = me.n2LP.filter(me.n1);
    me.up = me.n1 - lastn1;

    # temperature
    if (me.fuelflow > me.pos.idle)
      var target = 440 + (779 - 440) * (0.03 + me.fuelflow - me.pos.idle) / (me.pos.flight - me.pos.idle);
    else
      var target = 440 * (0.03 + me.fuelflow) / me.pos.idle;

    if (me.n1 < 0.4 and me.fuelflow - me.n1 > 0.001) {
      target += (me.fuelflow - me.n1) * 7000;
      if (target > 865)
        target = 865;
    }

    var airtemp = me.airtempN.getValue();
    if (target < airtemp)
      target = airtemp;

    var decay = (me.up > 0 ? 10 : me.n1 > 0.02 ? 0.01 : 0.001) * dt;
    me.totN.setValue((me.totN.getValue() + decay * target) / (1 + decay));

    # constant 130 kg/h for now (one turbines)
    fuel.consume(65 * KG2GAL * me.fuelflow * dt / 3600);

    # derived gauge values
    me.n1_pctN.setDoubleValue(me.n1 * 100);
    me.n2_pctN.setDoubleValue(me.n2 * 100);
    me.n1N.setDoubleValue(me.n1 * 50970);
    me.n2N.setDoubleValue(me.n2 * 33290);
  },
  setpower: func(v) {
    var target = (int((me.power + 0.15) * 3) + v) / 3;
    var time = abs(me.power - target) * 4;
    interpolate(me.powerN, target, time);
  },
  adjust_power: func(delta, mode = 0) {
    if (delta) {
      var power = me.powerN.getValue();
      if (me.power_min == nil) {
        if (delta > 0) {
          if (power < me.pos.idle) {
            me.power_min = me.pos.idle;
            me.power_max = me.pos.flight;
          } else {
            me.power_min = me.pos.idle;
            me.power_max = me.pos.flight;
          }
        } else {
          if (power > me.pos.idle) {
            me.power_max = me.pos.flight;
            me.power_min = me.pos.idle;
          } else {
            me.power_max = me.pos.flight;
            me.power_min = me.pos.idle;
          }
        }
      }
      me.powerN.setValue(power = clamp(power + delta, me.power_min, me.power_max));
      return power;
    } elsif (mode) {
      me.power_min = me.power_max = nil;
    }
  },
  pos: { cutoff: 0.0, idle: 0.63, flight: 1 },
};

var engines = {
  init: func {
    me.engine = [Engine.new(0), Engine.new(1)];
    me.trimN = props.globals.initNode("/controls/engines/power-trim");
    me.balanceN = props.globals.initNode("/controls/engines/power-balance");
    me.commonrpmN = props.globals.initNode("/engines/engine/rpm");
  },
  reset: func {
    me.engine[0].reset();
    me.engine[1].reset();
  },
  update: func(dt) {

    # update engines
    var trim = me.trimN.getValue() * 0.1;
    var balance = me.balanceN.getValue() * 0.1;
    me.engine[0].update(dt, trim - balance);
    me.engine[1].update(dt, trim + balance);

    # set rotor
    var n2relrpm =me.engine[0].n2;
    var n2max =me.engine[0].n2;
    target_rel_rpm.setValue(n2relrpm);
    max_rel_torque.setValue(n2max);

    me.commonrpmN.setValue(n2max * 33290); # attitude indicator needs pressure

  },
  adjust_powerm: func(delta, mode = 0) {
    # fix mhab only 1 engine
    if (!delta) {
      engines.engine[0].adjust_power(0, mode);
      #engines.engine[1].adjust_power(0, mode);
    } else {
      var p = 0;
      #var p = [0, 0];
      #for (var i = 0; i < 2; i += 1) {
      #  if (controls.engines[i].selected.getValue()) {
      #    p[i] = engines.engine[i].adjust_power(delta);
      #  }
      #}
      p = engines.engine[0].adjust_power(delta);
      gui.popupTip(sprintf("Twist Grip %d%%", 100 * p));
      # mhab
      if ( getprop("/controls/electric/external-power") ) {
        if (delta > 0) {
          settimer(func{ screen.log.write("Disconnect external power supply before Take-Off !!!"); },1.5);
        }
      }
    }
  },
  quickstart: func { # development only
    me.engine[0].n1LP.set(1);
    me.engine[0].n2LP.set(1);

    procedure.step = 1;
    procedure.next();
  },
};

var vert_speed_fpm = props.globals.initNode("/velocities/vertical-speed-fpm");

if (devel) {
  setprop("/instrumentation/altimeter/setting-inhg", getprop("/environment/pressure-inhg"));

  setlistener("/sim/signals/fdm-initialized", func {
    settimer(func {
      screen.property_display.x = 760;
      screen.property_display.y = 200;
      screen.property_display.format = "%.3g";
      screen.property_display.add(
        rotor_rpm,
        torque_pct,
        target_rel_rpm,
        max_rel_torque,
        "/controls/engines/power-trim",
        "/controls/engines/power-balance",
        "/consumables/fuel/total-fuel-gals",
        "L",
        engines.engine[0].runningN,
        engines.engine[0].ignitionN,
        "/controls/engines/engine[0]/power",
        engines.engine[0].n1_pctN,
        engines.engine[0].n2_pctN,
        engines.engine[0].totN,
        #engines.engine[0].n1N,
        #engines.engine[0].n2N,
        "R",
        "X",
        "/sim/model/gross-weight-kg",
        "/position/altitude-ft",
        "/position/altitude-agl-ft",
        "/instrumentation/altimeter/indicated-altitude-ft",
        "/environment/temperature-degc",
        vert_speed_fpm,
        "/velocities/airspeed-kt",
      );
    }, 1);
  });
}

var mouse = {
  init: func {
    me.x = me.y = nil;
    me.savex = nil;
    me.savey = nil;
    setlistener("/sim/startup/xsize", func(n) me.centerx = int(n.getValue() / 2), 1);
    setlistener("/sim/startup/ysize", func(n) me.centery = int(n.getValue() / 2), 1);
    setlistener("/devices/status/mice/mouse/mode", func(n) me.mode = n.getValue(), 1);
    setlistener("/devices/status/mice/mouse/button[1]", func(n) {
      me.mmb = n.getValue();
      if (me.mode)
        return;
      if (me.mmb) {
        engines.adjust_powerm(0.0, 1);
        me.savex = me.x;
        me.savey = me.y;
        gui.setCursor(me.centerx, me.centery, "none");
      } else {
        gui.setCursor(me.savex, me.savey, "pointer");
      }
    }, 1);
    setlistener("/devices/status/mice/mouse/x", func(n) me.x = n.getValue(), 1);
    setlistener("/devices/status/mice/mouse/y", func(n) me.update(me.y = n.getValue()), 1);
  },
  update: func {
    if (me.mode or !me.mmb)
      return;

    if (var dy = -me.y + me.centery)
      engines.adjust_powerm(dy * 0.005);

    gui.setCursor(me.centerx, me.centery);
  },
};

var power = func(v) {
  if (controls.engines[0].selected.getValue())
    engines.engine[0].setpower(v);
}

var startup = func {
  if (procedure.stage < 0) {
    procedure.step = 1;
    procedure.next();
  }
}

var shutdown = func {
  if (procedure.stage > 0) {
    procedure.step = -1;
    procedure.next();
  }
}

var procedure = {
        
  stage: -999,
  step: nil,
  loopid: 0,
  reset: func {
    me.loopid += 1;
    me.stage = -999;
    step = nil;
    engines.reset();
  },
  next: func(delay = 0) {
    if (crashed)
      return;
    if (me.stage < 0 and me.step > 0 or me.stage > 0 and me.step < 0)
      me.stage = 0;

    settimer(func { me.stage += me.step; me.process(me.loopid) }, delay * !quickstart);
  },
  process: func(id) {
    id == me.loopid or return;
    # startup
    if (me.stage == 1 ){
      cprint("", "1: press start button #1 -> spool up turbine #1 to N1 8.6--15%");
      engines.engine[0].ignitionN.setValue(1);
      engines.engine[0].starterN.setValue(1);


    } elsif (me.stage == 2) {

      cprint("", "2: move power lever #1 forward -> fuel injection");
      engines.engine[0].powerN.setValue(0.13);
      me.next(2.5);

    } elsif (me.stage == 3) {
      cprint("", "3: turbine #1 ignition (wait for EGT stabilization)");
      me.next(4.5);

    } elsif (me.stage == 4) {
      cprint("", "4: move power lever #1 to idle position -> engine #1 spools up to N1 63%");
      engines.engine[0].powerN.setValue(0.63);
      me.next(5);

    } elsif (me.stage == 5) {
      cprint("", "5: release start button #1\n");
      engines.engine[0].starterN.setValue(0);
      engines.engine[0].ignitionN.setValue(0);
      me.next(3);

    # shutdown
    } elsif (me.stage == -1) {
      cprint("", "-1: engines shut down");
      engines.engine[0].starterN.setValue(0);
      engines.engine[0].ignitionN.setValue(0);
      engines.engine[0].powerN.setValue(0);

      me.next(40);

    }
  },
};

# toggle floats (inflate/repack)
# mhab 20131104
toggle_floats = func () {

  if ( getprop("/sim/model/ec130/emerg_floats") ) {
    if ( getprop("/controls/gear/floats-inflat") ) {
      if ( getprop("/gear/gear[0]/wow") or getprop("/gear/gear[1]/wow") or getprop("/gear/gear[2]/wow") or getprop("/gear/gear[3]/wow") ) {
        setprop("/controls/gear/floats-inflat",0);
        setprop("/controls/gear/floats-armed",0);
      } else {
        screen.log.write("Repack only possible on ground !!!");
      }
    } else {
      if ( getprop("/controls/gear/floats-armed") ) {
        setprop("/controls/gear/floats-inflat",1);
      } else {
        screen.log.write("Floats are not armed !!!");
      }
    }
  }
}

# toggle_powersupply
# mhab 20130606
toggle_powersupply = func () {

  var p = getprop("/controls/electric/external-power");

  if ( p or getprop("/rotors/main/rpm") < 300 ) {
    setprop("/controls/electric/external-power", !p);
  } else {
    screen.log.write("External power cannot be connected when Rotor RPM 300+ !!!");
  }

}

# autostart routine
# mhab 20130606
autostart = func () {

  var ready_msg = func () {
    # switch off FUEL P
    setprop("/controls/fuel/tank/boost-pump", 0);
    # startup complete
    gui.popupTip("use Twist Grip for 100% ... Take-off when Rotor RPM 370+", 5);

    settimer(func {
      #print ("rotor reach 275 rpm wait loop");
      if (getprop("/rotors/main/rpm") > 275) {
        settimer(func { setprop("/controls/electric/avionics-switch", 1);              },0.5);
        settimer(func { setprop("/controls/electric/gyrocompass", 1);                  },1.0);
        settimer(func { setprop("/instrumentation/attitude-indicator/serviceable", 1); },1.5);
        settimer(func { setprop("/controls/anti-ice/pitot-heat", 1);                   },2.0);
        settimer(func { setprop("/controls/lighting/beacon", 1);                       },2.5);
        settimer(func { setprop("/controls/lighting/strobe", 1);                       },3.0);
      } else {
        settimer(thisfunc(), 1);
      }
    }, 1); # check once per second

    settimer(func {
      #print ("rotor reach 340 rpm wait loop");
      if (getprop("/rotors/main/rpm") > 339) {
        setprop("/controls/electric/horn", 1);
      } else {
        settimer(thisfunc(), 1);
      }
    }, 1); # check once per second
  }

  var fuellines_filled = func () {
    # start selector and switch guard
    setprop("/controls/engines/engine/startselector", 1);
    # switch guard delayed for 1 sec, looks more realistic
    settimer(func {
      setprop("/controls/engines/engine/switchguard", 1);
    },1);
    gui.popupTip("Fuel pipes are filled, Rotor is started ...",40);
    if ( getprop("/rotors/main/rpm") > 165 ) {
      ready_msg ();
    } else {
      settimer(func {
      #  print ("ready message wait loop");
        if ( getprop("/rotors/main/rpm") > 165 ) {
          ready_msg ();
        } else {
          settimer(thisfunc(), 1);
        }
      }, 1); # check once per second
    }
  }

  # check if autostart enabled
  if ( getprop("/sim/model/ec130/flightnumber") >= getprop("/sim/model/ec130/minflights") ) {
    if ( !getprop("/controls/electric/emergency-switch") ) {
      if ( getprop("/controls/electric/external-power")) {
        gui.popupTip("Automatic startup routine ... please wait ...  ",20);
        # release rotorbreak
        settimer(func { setprop("/controls/rotor/brake-locked", 0);                },0.3);
        settimer(func { interpolate("/controls/rotor/brake", 0, 1);                },0.5);
        settimer(func { setprop("/controls/rotor/brake-locked", 1);                },1.7);
        # release cutoff lever
        settimer(func { interpolate("/controls/engines/engine/cutoff-norm", 0, 1); },1.2);
        settimer(func { setprop("/controls/engines/engine/cutoff", 0);             },2.0);
        settimer(func { setprop("/controls/engines/engine/cutoff_guard", 1);       },2.2);
        # activate all buttons
        settimer(func { setprop("/controls/electric/directbat-switch", 1);         },2.5);
        settimer(func { setprop("/controls/electric/battery-switch", 1);           },3.0);
        settimer(func { setprop("/controls/electric/engine/generator", 1);         },3.5);
        settimer(func { setprop("/controls/fuel/tank/boost-pump", 1);              },4.0);
        settimer(func { setprop("/controls/lighting/nav-lights", 1);               },4.5);
        settimer(func { setprop("/controls/lighting/taxi-light", 1);               },5.0);
        settimer(func { setprop("/controls/lighting/dome-light", 1);               },5.5);
        settimer(func { setprop("/controls/lighting/instrument-lights", 1);        },6.0);
        settimer(func { setprop("/controls/lighting/instrument-lights2", 1);       },6.5);

        if ( getprop("/controls/fuel/tank/fuellines_filled") > 0.98 ) {
          fuellines_filled ();
        } else {
          settimer(func {
          #  print ("fuellines filled wait loop");
            if (getprop("/controls/fuel/tank/fuellines_filled") > 0.98) {
              fuellines_filled ();
            } else {
              settimer(thisfunc(), 1);
            }
          }, 1); # check once per second
        }
      } else {
        screen.log.write("External power supply (Alt-p) is necessary for startup !!!");
      }
    } else {
      screen.log.write("Emergency Shutdown is active !!!");
    }
  }
}

# autoshutdown routine
# mhab
autoshutdown = func () {

  var rotor_slow_enough_to_brake = func () {
    gui.popupTip("Rotor is slow enough ...",40);
    # set cutoff lever
    settimer(func { setprop("/controls/engines/engine/cutoff_guard", 0);           },0.3);
    settimer(func { setprop("/controls/engines/engine/cutoff", 1);                 },0.5);
    settimer(func { interpolate("/controls/engines/engine/cutoff-norm", 1, 1);     },0.5);
    # set rotorbreak
    settimer(func { setprop("/controls/rotor/brake-locked", 0);                    },0.8);
    settimer(func { interpolate("/controls/rotor/brake", 1, 1);                    },1.0);
    settimer(func { setprop("/controls/rotor/brake-locked", 1);                    },2.2);
    # shutoff almost all buttons
    settimer(func { setprop("/controls/fuel/tank/boost-pump", 0);                  },2.5);
    settimer(func { setprop("/controls/lighting/beacon", 0);                       },3.0);
    settimer(func { setprop("/controls/lighting/strobe", 0);                       },3.5);
    settimer(func { setprop("/controls/anti-ice/pitot-heat", 0);                   },4.0);
    settimer(func { setprop("/instrumentation/attitude-indicator/serviceable", 0); },4.5);
    settimer(func { setprop("/controls/electric/gyrocompass", 0);                  },5.0);
    settimer(func { setprop("/controls/electric/avionics-switch", 0);              },5.5);
    settimer(func { setprop("/controls/lighting/nav-lights", 0);                   },6.0);
    settimer(func { setprop("/controls/lighting/taxi-light", 0);                   },6.5);
    settimer(func { setprop("/controls/lighting/instrument-lights2", 0);           },7.0);
    settimer(func { setprop("/controls/lighting/instrument-lights", 0);            },7.5);
    settimer(func { setprop("/controls/lighting/dome-light", 0);                   },8.0);
    settimer(func { setprop("/controls/electric/directbat-switch", 0);             },8.5);
    settimer(func { setprop("/controls/electric/engine/generator", 0);             },9.0);

    if ( getprop("/rotors/main/rpm") < 70 ) {
      # avoid display if everything is already off
      if ( getprop("/controls/electric/battery-switch") ) {
        gui.popupTip("Flight Report visible on VEMD", 20);
      }
    } else {
      settimer(func {
      #  print ("rotor slow down wait loop2");
        if (getprop("/rotors/main/rpm") < 70) {
          gui.popupTip("Flight Report visible on VEMD", 20);
        } else {
          settimer(thisfunc(), 1);
        }
      }, 1); # check once per second
    }
    if ( getprop("/controls/electric/battery-switch") ) {
      # shutdown complete after 20 sec
      settimer(func {
        setprop("/controls/electric/battery-switch", 0);
        gui.popupTip("Shutdown complete !", 4);
      },20);
    } else {
      screen.log.write("Everything is in shut down state !!!");
    }
  }

  # check if autoshutdown enabled
  if ( getprop("/sim/model/ec130/flightnumber") >= getprop("/sim/model/ec130/minflights") ) {
    gui.popupTip("Automatic shutdown routine ... please wait ...  ",30);
    # switch guard
    setprop("/controls/engines/engine/switchguard", 0);
    # start selector delayed for 1 sec, otherwise switch guard gets blocked, reason unclear
    settimer(func { setprop("/controls/engines/engine/startselector", 0); },1);
    # switch off horn to avoid nerve wrecking alarm
    settimer(func { setprop("/controls/electric/horn", 0); },1.5);
    if ( getprop("/rotors/main/rpm") < 170 ) {
      rotor_slow_enough_to_brake();
    } else {
      settimer(func {
      #  print ("rotor slow down wait loop");
        if (getprop("/rotors/main/rpm") < 170) {
          rotor_slow_enough_to_brake();
        } else {
          settimer(thisfunc(), 1);
        }
      }, 1); # check once per second
    }
  }
}

# torquemeter
var torque_val = 0;
torque.setDoubleValue(0);

var update_torque = func(dt) {
  var f = dt / (0.2 + dt);
  torque_val = torque.getValue() * f + torque_val * (1 - f);
  torque_pct.setDoubleValue(torque_val / 5300);
}

# blade vibration absorber pendulum
var pendulum = props.globals.getNode("/sim/model/ec130/absorber-angle-deg", 1);
var update_absorber = func {
  pendulum.setDoubleValue(90 * clamp(abs(rotor_rpm.getValue()) / 90));
}

var vibration = { # and noise ...
  init: func {
    me.lonN = props.globals.initNode("/rotors/main/vibration/longitudinal");
    me.latN = props.globals.initNode("/rotors/main/vibration/lateral");
    me.soundN = props.globals.initNode("/sim/sound/vibration");
    # mhab fix
    me.airspeedN = props.globals.getValue("/velocities/airspeed-kt") or 0;
    if ( me.airspeedN == nil ) me.airspeedN=0;
    me.vertspeedN = props.globals.getValue("/velocities/vertical-speed-fps") or 0;
    if ( me.vertspeedN == nil ) me.vertspeedN=0;

    me.groundspeedN = props.globals.getNode("/velocities/groundspeed-kt");
    me.speeddownN = props.globals.getNode("/velocities/speed-down-fps");
    me.angleN = props.globals.initNode("/velocities/descent-angle-deg");
    me.dir = 0;
  },
  update: func(dt) {
    var airspeed = me.airspeedN;
    # fix mhab
    if ( airspeed == nil ) airspeed=0;

    # fix mhab added
    me.vertspeedN = props.globals.getValue("/velocities/vertical-speed-fps") or 0;
    if ( me.vertspeedN == nil ) me.vertspeedN=0;

    if (airspeed > 160) { # overspeed vibration
      var frequency = 2000 + 500 * rand();
      var v = 0.49 + 0.5 * normatan(airspeed - 160, 10);
      var intensity = v;
      var noise = v * internal;

    } elsif (airspeed > 30) { # Blade Vortex Interaction (BVI)    8 deg, 65 kts max?
      var frequency = rotor_rpm.getValue() * 4 * 60;

      # fix mhab
      #var down = me.speeddownN.getValue() * FT2M;
      var down = me.speeddownN.getValue();
      if ( down == nil ) down=0;
      down = down * FT2M;

      # fix mhab
      #var level = me.groundspeedN.getValue() * NM2M / 3600;
      var level = me.groundspeedN.getValue();
      if ( level == nil ) level=0;
      level = level * NM2M / 3600;

      me.angleN.setDoubleValue(var angle = math.atan2(down, level) * R2D);
      var speed = math.sqrt(level * level + down * down) * MPS2KT;
      angle = bell(angle - 9, 13);
      speed = bell(speed - 65, 450);
      var v = angle * speed;
      var intensity = v * 0.10;
      var noise = v * (1 - internal * 0.4);

    } else { # hover
      var rpm = rotor_rpm.getValue();
      var frequency = rpm * 4 * 60;
      var coll = bell(collective.getValue(), 0.5);
      var ias = bell(airspeed, 600);
      var vert = bell(me.vertspeedN * 0.5, 400);
      var rpm = 0.477 + 0.5 * normatan(rpm - 350, 30) * 1.025;
      var v = coll * ias * vert * rpm;
      var intensity = v * 0.10;
      var noise = v * (1 - internal * 0.4);
    }

    me.dir += dt * frequency;
    me.lonN.setValue(cos(me.dir) * intensity);
    me.latN.setValue(sin(me.dir) * intensity);
    me.soundN.setValue(noise);
  },
};

# sound =============================================================

# stall sound
var stall = props.globals.getNode("/rotors/main/stall", 1);
var stall_filtered = props.globals.getNode("/rotors/main/stall-filtered", 1);

var stall_val = 0;
stall.setDoubleValue(0);

var update_stall = func(dt) {
  var s = stall.getValue();
  if (s < stall_val) {
    var f = dt / (0.3 + dt);
    stall_val = s * f + stall_val * (1 - f);
  } else {
    stall_val = s;
  }
  var c = collective.getValue();
  stall_filtered.setDoubleValue(stall_val + 0.006 * (1 - c));
}

# skid slide sound
var Skid = {
  new: func(n) {
    var m = { parents: [Skid] };
    var soundN = props.globals.getNode("/sim/model/ec130/sound", 1).getChild("slide", n, 1);
    var gearN = props.globals.getNode("gear", 1).getChild("gear", n, 1);

    m.compressionN = gearN.getNode("compression-norm", 1);
    m.rollspeedN = gearN.getNode("rollspeed-ms", 1);
    m.frictionN = gearN.getNode("ground-friction-factor", 1);
    m.wowN = gearN.getNode("wow", 1);
    m.volumeN = soundN.getNode("volume", 1);
    m.pitchN = soundN.getNode("pitch", 1);

    m.compressionN.setDoubleValue(0);
    m.rollspeedN.setDoubleValue(0);
    m.frictionN.setDoubleValue(0);
    m.volumeN.setDoubleValue(0);
    m.pitchN.setDoubleValue(0);
    m.wowN.setBoolValue(1);
    m.self = n;
    return m;
  },
  update: func {
    me.wow = me.wowN.getValue();
    if (me.wow < 0.5)
      return me.volumeN.setDoubleValue(0);

    var rollspeed = abs(me.rollspeedN.getValue());
    me.pitchN.setDoubleValue(rollspeed * 0.6);

    var s = normatan(20 * rollspeed);
    var f = clamp((me.frictionN.getValue() - 0.5) * 2);
    var c = clamp(me.compressionN.getValue() * 2);
    var vol = s * f * c;
    me.volumeN.setDoubleValue(vol > 0.1 ? vol : 0);
    #if (!me.self) {
    #  cprint("33;1", sprintf("S=%0.3f  F=%0.3f  C=%0.3f  >>  %0.3f", s, f, c, s * f * c));
    #}
  },
};

var skids = [];
for (var i = 0; i < 4; i += 1)
  append(skids, Skid.new(i));

var update_slide = func {
  foreach (var s; skids)
    s.update();
}

var internal = 1;
setlistener("/sim/current-view/view-number", func {
  internal = getprop("/sim/current-view/internal");
}, 1);

var volume = props.globals.getNode("/sim/model/ec130/sound/volume", 1);

# crash handler =====================================================

var crash = func {
  if (arg[0]) {
    # crash
    setprop("/sim/model/ec130/tail-angle-deg", 35);
    setprop("/sim/model/ec130/shadow", 0);
    setprop("/rotors/tail/rpm", 0);
    setprop("/rotors/main/rpm", 0);
    setprop("/rotors/main/blade[0]/flap-deg", -60);
    setprop("/rotors/main/blade[1]/flap-deg", -50);
    setprop("/rotors/main/blade[2]/flap-deg", -40);
    #setprop("/rotors/main/blade[3]/flap-deg", -30);
    setprop("/rotors/main/blade[0]/incidence-deg", -30);
    setprop("/rotors/main/blade[1]/incidence-deg", -20);
    setprop("/rotors/main/blade[2]/incidence-deg", -50);
    #setprop("/rotors/main/blade[3]/incidence-deg", -55);
    setprop("/sim/model/ec130/doors/frontl/position-norm", 0.9);
    setprop("/sim/model/ec130/doors/frontr/position-norm", 0.5);
    setprop("/sim/model/ec130/doors/passengerl/position-norm", 0.4);
    setprop("/sim/model/ec130/doors/passengerr/position-norm", 0.7);
    setprop("/sim/model/ec130/doors/luggagel/position-norm", 0.3);
    setprop("/sim/model/ec130/doors/luggager/position-norm", 0.5);
    strobe_switch.setValue(0);
    beacon_switch.setValue(0);
    nav_light_switch.setValue(0);
    engines.engine[0].n2_pctN.setValue(0);
    #engines.engine[1].n2_pctN.setValue(0);
    torque_pct.setValue(torque_val = 0);
    stall_filtered.setValue(stall_val = 0);

  } else {
    # uncrash (for replay)
    setprop("/sim/model/ec130/tail-angle-deg", 0);
    setprop("/sim/model/ec130/shadow", 1);

    setprop("/rotors/tail/rpm", 2219);
    setprop("/rotors/main/rpm", 442);
    for (i = 0; i < 4; i += 1) {
      setprop("/rotors/main/blade[" ~ i ~ "]/flap-deg", 0);
      setprop("/rotors/main/blade[" ~ i ~ "]/incidence-deg", 0);
    }
    strobe_switch.setValue(1);
    beacon_switch.setValue(1);
    engines.engine[0].n2_pct.setValue(100);
    #engines.engine[1].n2_pct.setValue(100);
  }
}

# "manual" rotor animation for flight data recorder replay ============
var rotor_step = props.globals.getNode("/sim/model/ec130/rotor-step-deg");
var blade1_pos = props.globals.getNode("/rotors/main/blade[0]/position-deg", 1);
var blade2_pos = props.globals.getNode("/rotors/main/blade[1]/position-deg", 1);
var blade3_pos = props.globals.getNode("/rotors/main/blade[2]/position-deg", 1);
var blade4_pos = props.globals.getNode("/rotors/main/blade[3]/position-deg", 1);
var rotorangle = 0;

var rotoranim_loop = func {
  var i = rotor_step.getValue();
  if (i >= 0.0) {
    blade1_pos.setValue(rotorangle);
    blade2_pos.setValue(rotorangle + 120);
    blade3_pos.setValue(rotorangle + 240);
#   fix mhab: only 3 rotor blades
#    blade4_pos.setValue(rotorangle + 270);
    rotorangle += i;
    settimer(rotoranim_loop, 0.1);
  }
}

var init_rotoranim = func {
  if (rotor_step.getValue() >= 0.0)
    settimer(rotoranim_loop, 0.1);
}

# view management ===================================================

var elapsedN = props.globals.getNode("/sim/time/elapsed-sec", 1);
var flap_mode = 0;
var down_time = 0;
controls.flapsDown = func(v) {
  if (!flap_mode) {
    if (v < 0) {
      down_time = elapsedN.getValue();
      flap_mode = 1;
      dynamic_view.lookat(
          5,     # heading left
          -20,   # pitch up
          0,     # roll right
          0.2,   # right
          0.6,   # up
          0.85,  # back
          0.2,   # time
          55,    # field of view
      );
    } elsif (v > 0) {
      flap_mode = 2;
      gui.popupTip("AUTOTRIM", 1e10);
      aircraft.autotrim.start();
    }

  } else {
    if (flap_mode == 1) {
      if (elapsedN.getValue() < down_time + 0.2)
        return;

      dynamic_view.resume();
    } elsif (flap_mode == 2) {
      aircraft.autotrim.stop();
      gui.popdown();
    }
    flap_mode = 0;
  }
}

# register function that may set me.heading_offset, me.pitch_offset, me.roll_offset,
# me.x_offset, me.y_offset, me.z_offset, and me.fov_offset
#
dynamic_view.register(func {
  var lowspeed = 1 - normatan(me.speedN.getValue() / 50);
  var r = sin(me.roll) * cos(me.pitch);

  me.heading_offset =                            # heading change due to
    (me.roll < 0 ? -50 : -30) * r * abs(r);      #    roll left/right

  me.pitch_offset =                                        # pitch change due to
    (me.pitch < 0 ? -50 : -50) * sin(me.pitch) * lowspeed  #    pitch down/up
    + 15 * sin(me.roll) * sin(me.roll);                    #    roll

  me.roll_offset =                               # roll change due to
    -15 * r * lowspeed;                          #    roll
});

var adjust_fov = func {
  var w = getprop("/sim/startup/xsize");
  var h = getprop("/sim/startup/ysize");
  var ar = clamp(max(w, h) / min(w, h), 0, 2);
  var fov = 60 + (ar - (4 / 3)) * 10 / (16 / 9 - 4 / 3);
  setprop("/sim/view/config/default-field-of-view-deg", fov);
  if (internal)
    setprop("/sim/current-view/config/default-field-of-view-deg", fov);
}

setlistener("/sim/startup/xsize", adjust_fov);
setlistener("/sim/startup/ysize", adjust_fov, 1);

###############################################################################
# view handler for "Searchlight Follow View"
# mhab
var searchlight_follow_view_handler = {
    view_name : "Searchlight Follow View",
    init : func {
        me.view_name = "Searchlight Follow View";
        me.view  = view.views[view.indexof(me.view_name)];
        me.shown = 0;
    },
    start  : func {
        if (!me.shown) {
        }
        me.shown = 1;
    },
    stop   : func {
        if (me.shown) {
        }
        me.shown = 0;
    },
    update : func {
        var cur = props.globals.getNode("/sim/current-view");
        var head = getprop("/sim/model/searchlight/heading-deg");
        var elev = getprop("/sim/model/searchlight/elevation-deg");

        var sx16 = getprop("/sim/model/ec130/searchlight");
        var trak = getprop("/sim/model/ec130/searchlight_a800");
        var stabi = getprop("/sim/model/searchlight/stabi-active");

        # A800 is stowed in reverse direction
        if ( trak ) { head=head+180; }

        # sync view direction with searchlight
        cur.getNode("heading-offset-deg").setValue(head);
        cur.getNode("pitch-offset-deg").setValue(elev);
        cur.getNode("roll-offset-deg").setValue(0.0);

        # position view for SX16
        if ( sx16 ) {
          cur.getNode("x-offset-m").setValue(1.471);
          cur.getNode("y-offset-m").setValue(-1.268);
          cur.getNode("z-offset-m").setValue(-2.390);
        }

        # position view for A800
        if ( trak ) {
          cur.getNode("x-offset-m").setValue(-1.200);
          cur.getNode("y-offset-m").setValue(-1.220);
          cur.getNode("z-offset-m").setValue(-4.940);
        }

        return 0.0;
    }
};

view.manager.register(view.indexof(searchlight_follow_view_handler.view_name),
                                                   searchlight_follow_view_handler);

###############################################################################
# view handler for "Searchlight Watch View"
# mhab
var searchlight_watch_view_handler = {
    view_name : "Searchlight Watch View",
    init : func {
        me.view_name = "Searchlight Watch View";
        me.view  = view.views[view.indexof(me.view_name)];
        me.shown = 0;
    },
    start  : func {
        if (!me.shown) {
        }
        me.shown = 1;
    },
    stop   : func {
        if (me.shown) {
        }
        me.shown = 0;
    },
    update : func {
        var cur = props.globals.getNode("/sim/current-view");
        var sx16 = getprop("/sim/model/ec130/searchlight");
        var trak = getprop("/sim/model/ec130/searchlight_a800");

        # position view for SX16
        if ( sx16 ) {
          cur.getNode("x-offset-m").setValue(1.471);
          cur.getNode("y-offset-m").setValue(-0.600);
          cur.getNode("z-offset-m").setValue(-0.900);
        }

        # position view for A800
        if ( trak ) {
          cur.getNode("x-offset-m").setValue(-1.100);
          cur.getNode("y-offset-m").setValue(-0.600);
          cur.getNode("z-offset-m").setValue(-3.500);
        }

        return 0.0;
    }
};

view.manager.register(view.indexof(searchlight_watch_view_handler.view_name),
                                                   searchlight_watch_view_handler);

##############################################
# mhab merged from woolthread.nas
# Simple vibrating yawstring

var yawstring = func {

  var airspeed = getprop("/velocities/airspeed-kt");
  # mhab fix
  if ( airspeed == nil ) airspeed=0;
  var rpm = getprop("/rotors/main/rpm");
  var severity = 0;

  if ( (airspeed < 137) and (rpm >170)) {
    severity = ( math.sin (math.pi*airspeed/137) * (rand()*12) ) ;
  }

  var position = getprop("/orientation/side-slip-deg") + severity ;
  setprop("/instrumentation/yawstring",position);
  settimer(yawstring,0);

}

# Start the yawstring ASAP
yawstring();

##############################################
# mhab merged from lightmap.nas
#### this small script handles the intensity of the lightmap effect

call_lightmap = func {

  TAXI = getprop("/systems/electrical/outputs/taxi-light") or 0;
  BL = getprop("/systems/electrical/outputs/beacon") or 0;
  LaL = getprop("/systems/electrical/outputs/landing-light") or 0;

  SUN_ANGLE = getprop("/sim/time/sun-angle-rad");


  setprop("/systems/electrical/outputs/taxi-light-itensity",(SUN_ANGLE * (TAXI * 0.0357)));
  setprop("/systems/electrical/outputs/beacon-itensity",(SUN_ANGLE * (BL * 0.010625)));
  setprop("/systems/electrical/outputs/landing-light-intensity",(SUN_ANGLE * (LaL * 0.0357)));

  settimer(call_lightmap, 0.0);
}

init = func {
  settimer(call_lightmap, 0.0);
}

init();

###############################################
## mhab merged from mousehandlerx.nas
#var MouseHandlerX = {
#  new : func() {
#    var obj = { parents : [ MouseHandlerX ] };
#
#    obj.property = nil;
#    obj.factor = 1.0;
#
#    obj.YListenerId = setlistener( "devices/status/mice/mouse/accel-x",
#      func(n) { obj.YListener(n); }, 1, 0 );
#
#    return obj;
#  },
#
#  YListener : func(n) {
#    me.property == nil and return;
#    me.factor == 0 and return;
#    n == nil and return;
#    var v = n.getValue();
#    v == nil and return;
#    fgcommand("property-adjust", props.Node.new({
#      "offset" : v,
#      "factor" : me.factor,
#      "property" : me.property
#    }));
#  },
#
#  set : func( property = nil, factor = 1.0 ) {
#    me.property = property;
#    me.factor = factor;
#  },
#
#};
#
#var mouseHandlerX = MouseHandlerX.new();

##############################################
# mhab merged from mousehandlery.nas
var MouseHandlerY = {
  new : func() {
    var obj = { parents : [ MouseHandlerY ] };

    obj.property = nil;
    obj.factor = 1.0;

    obj.YListenerId = setlistener( "devices/status/mice/mouse/accel-y",
      func(n) { obj.YListener(n); }, 1, 0 );

    return obj;
  },

  YListener : func(n) {
    me.property == nil and return;
    me.factor == 0 and return;
    n == nil and return;
    var v = n.getValue();
    v == nil and return;
    fgcommand("property-adjust", props.Node.new({
      "offset" : v,
      "factor" : me.factor,
      "property" : me.property
    }));
  },

  set : func( property = nil, factor = 1.0 ) {
    me.property = property;
    me.factor = factor;
  },

};

var mouseHandlerY = MouseHandlerY.new();

##############################################
# mhab merged from rotor.nas
# functions for main rotor handling
# mhab 20131023

#
# cycle wake strength limit
# if
# 0: off
# 1: low
# 2: medium
# 3: high
#
cycle_wakes = func () {

  var p = getprop("/rotors/main/wakevisible");
  if ( p < 3 ) {
    p = p + 1;
  } else {
    p = 0;
  }
  setprop("/rotors/main/wakevisible", p);
  setprop("/rotors/main/wake_flag_0",0);
  setprop("/rotors/main/wake_flag_1",0);
  setprop("/rotors/main/wake_flag_2",0);
  setprop("/rotors/main/wake_flag_3",0);

  if ( p == 0 ) {
    setprop("/rotors/main/wake_flag_0",1);
    gui.popupTip("Wake invisible");
  }
  if ( p == 1 ) {
    setprop("/rotors/main/wake_flag_1",1);
    gui.popupTip("Wake low");
  }
  if ( p == 2 ) {
    setprop("/rotors/main/wake_flag_2",1);
    gui.popupTip("Wake medium");
  }
  if ( p == 3 ) {
    setprop("/rotors/main/wake_flag_3",1);
    gui.popupTip("Wake heavy");
  }
}

##############################################
# mhab merged from rotorloads.nas
# rotorloads
# simulating the force of the rotor due to Rotor-RPM, blade-incidence, g-forces and airpressure
# To-Do: calculate forces for each control, add airpressure
# very, very, very simplified- engineers: please make me right!

var incidence = 0;
var rpm_norm = 0;

var run = func {

  var incidence = props.globals.getNode("/rotors/main/incidence", 1);
  var rpm_norm = props.globals.getNode("/rotors/main/rpm_norm", 1);
  var rotor_load = props.globals.getNode("/rotors/main/rotor_load", 1);

  var rrpm = props.globals.getValue("/rotors/main/rpm") or 0;
  var incidence = props.globals.getValue("/rotors/main/incidence") or 0;
  var rpm_norm = props.globals.getValue("/rotors/main/rpm_norm") or 0;

  var g = getprop("/accelerations/pilot-g");
  # mhab fix
  if ( g == nil ) g=0;
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

##############################################
# mhab merged from savestate.nas
# added some settings, but they don't work if
# they are part of the livery specific xml file
################
# saving states so it makes it all a bit more realistic
################

var save_list = [ "/sim/model/fuel/tank[0]/level-gal_us",
		 "/engines/engine/oil-temperature-degc-filter",
		 "/sim/model/ec130/flightnumber",
#		 "/sim/model/ec130/antenna_left",
#		 "/sim/model/ec130/antenna_tail_front",
#		 "/sim/model/ec130/vor_2_roof",
#		 "/sim/model/ec130/adf_bottom",
#		 "/sim/model/ec130/adf_roof",
#		 "/sim/model/ec130/VUHF",
#		 "/sim/model/ec130/VUHF_front",
#		 "/sim/model/ec130/antenna_flat_tail",
#		 "/sim/model/ec130/antenna_square_tail",
#		 "/sim/model/ec130/DME",
#		 "/sim/model/ec130/DME_small",
#		 "/sim/model/ec130/copilot_controls",
#		 "/sim/model/ec130/interior_passengers",
#		 "/sim/model/ec130/show_gsdi",
#		 "/sim/model/ec130/wirecutter",
#		 "/sim/model/ec130/mirror",
#		 "/sim/model/ec130/FLIR",
#		 "/sim/model/ec130/emerg_floats",
#		 "/sim/model/ec130/basket_left",
#		 "/sim/model/ec130/basket_right",
#		 "/sim/model/ec130/searchlight_a800",
#		 "/sim/model/ec130/searchlight",
#		 "/sim/model/ec130/searchlight_filter",
#		 "/sim/model/ec130/snowshoes",
#		 "/sim/model/ec130/hoist",
#		 "/sim/model/ec130/gear_strobe",
#		 "/sim/model/ec130/gear_light",
#		 "/sim/model/ec130/luggage_wide",
];

aircraft.data.add(save_list);

# Load saved fuel level on sim initialization

var tank_0 = props.globals.getNode("/consumables/fuel/tank[0]/level-gal_us", 1);
var copy_0 = props.globals.getNode("/sim/model/fuel/tank[0]/level-gal_us", 1);

var update_fuel = func {

  if (copy_0.getValue() != nil) {
    tank_0.setValue(copy_0.getValue());
  }

  setlistener("/consumables/fuel/tank[0]/level-gal_us", func {
    copy_0.setValue(tank_0.getValue());
  });

}

var loadup = func{

  var copy_0 = props.globals.getValue("/sim/model/fuel/tank[0]/level-gal_us") or 0;
  var tank_0 = props.globals.getNode("/consumables/fuel/tank[0]/level-gal_us", 1);

  tank_0.setValue(copy_0);
}

# Load saved fuel level on sim initialization
var load = setlistener("/sim/signals/fdm-initialized", func {
  update_fuel();
  loadup();
  removelistener(load);
});

##############################################
# mhab merged from weights.nas
##external sores and weights##

var external_weights = func {

  wirecutter = props.globals.getNode("/sim/model/ec130/external/wirecutter/weight-lb", 1);
  mirror = props.globals.getNode("/sim/model/ec130/external/mirror/weight-lb", 1);
  searchlight_a800 = props.globals.getNode("/sim/model/ec130/external/searchlight_a800/weight-lb", 1);

  FLIR = props.globals.getNode("/sim/model/ec130/external/FLIR/weight-lb", 1);
  searchlight = props.globals.getNode("/sim/model/ec130/external/searchlight/weight-lb", 1);

  basket_left = props.globals.getNode("/sim/model/ec130/external/basket_left/weight-lb", 1);
  basket_right = props.globals.getNode("/sim/model/ec130/external/basket_right/weight-lb", 1);

  luggage_left_wide = props.globals.getNode("/sim/model/ec130/external/luggage_left_wide/weight-lb", 1);
  luggage_right_wide = props.globals.getNode("/sim/model/ec130/external/luggage_right_wide/weight-lb", 1);

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

  if ( getprop("/sim/model/ec130/searchlight_a800") ){
    searchlight_a800.setValue(60);
  }else{
    searchlight_a800.setValue(0);
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

  if ( getprop("/sim/model/ec130/luggage_wide") ){
    luggage_left_wide.setValue(22);
    luggage_right_wide.setValue(22);
  }else{
    luggage_left_wide.setValue(0);
    luggage_right_wide.setValue(0);
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
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/searchlight_a800/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/FLIR/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/searchlight/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/basket_left/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/basket_right/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/luggage_left_wide/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/luggage_right_wide/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/float_deflated_left/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/float_deflated_right/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/float_inflated_left/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/float_inflated_right/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/snowshoe_left/weight-lb");
  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/snowshoe_right/weight-lb");

  weight_equipment=weight_equipment+getprop("/sim/model/ec130/external/hoist/weight-lb");

  setprop("/sim/weight[13]/weight-lb",weight_equipment);

  # mhab deactivated
  #  settimer(weights,0.1);
}

external_weights();

##############################################
# mhab merged from dialog.nas
# dialogs

var options_dialog = gui.Dialog.new("/sim/gui/dialogs/ec130/options/dialog", "Aircraft/ec130/Dialogs/ec130-options-dialog.xml");
var config_dialog = gui.Dialog.new("/sim/gui/dialogs/ec130/config/dialog", "Aircraft/ec130/Dialogs/ec130-config-dialog.xml");
var antenna_config_dialog = gui.Dialog.new("/sim/gui/dialogs/ec130/antenna/dialog", "Aircraft/ec130/Dialogs/ec130-antenna-config-dialog.xml");
var help_config_dialog = gui.Dialog.new("/sim/gui/dialogs/ec130/help_config/dialog", "Aircraft/ec130/Dialogs/ec130-help-config-dialog.xml");
var model_info_dialog = gui.Dialog.new("/sim/gui/dialogs/ec130/model_info/dialog", "Aircraft/ec130/Dialogs/ec130-model-info-dialog.xml");

##seats weights and views##

var set_seats = func {

  if ( getprop("/sim/weight[0]/weight-lb") < 30 ) { setprop("/sim/weight[0]/weight-lb",30) }
  if ( getprop("/sim/weight[1]/weight-lb") < 30 ) { setprop("/sim/weight[1]/weight-lb",30) }
  if ( getprop("/sim/weight[2]/weight-lb") < 30 ) { setprop("/sim/weight[2]/weight-lb",30) }
  if ( getprop("/sim/weight[3]/weight-lb") < 30 ) { setprop("/sim/weight[3]/weight-lb",30) }
  if ( getprop("/sim/weight[4]/weight-lb") < 30 ) { setprop("/sim/weight[4]/weight-lb",30) }
  if ( getprop("/sim/weight[5]/weight-lb") < 30 ) { setprop("/sim/weight[5]/weight-lb",30) }
  if ( getprop("/sim/weight[6]/weight-lb") < 30 ) { setprop("/sim/weight[6]/weight-lb",30) }
  if ( getprop("/sim/weight[7]/weight-lb") < 30 ) { setprop("/sim/weight[7]/weight-lb",30) }

  var p = getprop("/sim/model/ec130/interior_passengers");

  # pilot or co-pilot must be present (min weight 30+90lbs)
  if ( getprop("/sim/weight[0]/weight-lb") < 120 ) {
    if ( getprop("/sim/weight[1]/weight-lb") < 120 ) {
      setprop("/sim/weight[0]/weight-lb",180)
    }
  }

  # 5 seats
  if ( p == 5 ) {
    # disable weight
    # front left seat
    setprop("/sim/weight[2]/weight-lb",0);
  }

  # 6 seats
  if ( p == 6 ) {
    # set min weight if seats were activated from smaller configuration
    if ( getprop("/sim/weight[2]/weight-lb") == 0 ) {
      setprop("/sim/weight[2]/weight-lb",30);
    }
    if ( getprop("/sim/weight[7]/weight-lb") == 0 ) {
      setprop("/sim/weight[7]/weight-lb",30);
    }
  }

  # rescue config
  if ( p == 4 ) {

    # set weights
    setprop("/sim/weight[2]/weight-lb",0);
    setprop("/sim/weight[3]/weight-lb",30);
    setprop("/sim/weight[7]/weight-lb",0);

    if ( getprop("/sim/weight[6]/weight-lb") == 0 ) {
      setprop("/sim/weight[6]/weight-lb",50);
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

var set_searchview = func {

  var searchw   = "sim/view[110]/enabled";
  var searchv   = "sim/view[111]/enabled";

  setprop(searchw,0);
  setprop(searchv,0);

  if ( getprop("/sim/model/ec130/searchlight") or getprop("/sim/model/ec130/searchlight_a800") ) {
    if ( getprop("/sim/view[110]/enabled_flag") ) setprop(searchw,1);
    if ( getprop("/sim/view[111]/enabled_flag") ) setprop(searchv,1);
  }

}

var set_menu = func {

  # cross-check menubar definition
  if ( !getprop("/sim/model/ec130/emerg_floats") ) {
    setprop("/sim/menubar/default/menu[10]/item[6]/enabled",0);
  } else {
    setprop("/sim/menubar/default/menu[10]/item[6]/enabled",1);
  }

}

##############################################
# mhab merged from systems.nas
### some systems like hydraulics and engineoil, maingearboxoil etc...####

###create oil pressure###
var oilpressure =  func {

  oilpres_low = props.globals.getNode("/engines/engine/oil-pressure-low", 1);
  oilpres_norm = props.globals.getNode("/engines/engine/oil-pressure-norm", 1);
  oilpres_bar = props.globals.getNode("/engines/engine/oil-pressure-bar", 1);

  var rpm = props.globals.getValue("/engines/engine/rpm") or 0;

  if ( rpm > 0 ) oilpres_low.setDoubleValue((15-22000/rpm)*0.0689);
  if ( rpm > 0 ) oilpres_norm.setDoubleValue((60-22000/rpm)*0.0689);

  settimer(oilpressure, 0);
}

oilpressure();

##############

var oilpressurebar = func{

  oilpres_bar = props.globals.getNode("/engines/engine/oil-pressure-bar", 1);

  var rpm = props.globals.getValue("/engines/engine/rpm") or 0;
  var oilpres_low = props.globals.getValue("/engines/engine/oil-pressure-low") or 0;
  var oilpres_norm = props.globals.getValue("/engines/engine/oil-pressure-norm") or 0;

  if ((rpm > 0) and (rpm < 23000)){
    interpolate ("/engines/engine/oil-pressure-bar", oilpres_low, 1.5);
  }elsif (rpm > 23000) {
    interpolate ("/engines/engine/oil-pressure-bar", oilpres_norm, 2);
  }

  settimer(oilpressurebar, 0.1);
}

oilpressurebar();

##################
var oiltemp = func{

  var OAT = props.globals.getValue("/environment/temperature-degc") or 0;
  var oilpres_bar = props.globals.getValue("/engines/engine/oil-pressure-bar-filter") or 0;
  var rpm = props.globals.getValue("/engines/engine/rpm") or 0;
  ot = props.globals.getNode("/engines/engine/oil-temperature-degc", 1);

  if (oilpres_bar >1){
    ot.setDoubleValue(((25-22000/rpm)*oilpres_bar)+OAT);
  } else {
    ot.setDoubleValue(OAT);
  }

  settimer( oiltemp, 0);
}

oiltemp();

#########################################
###main gear box oil pressure###
var mgbp =  func {

  #create oilpressure#
  mgb_oilpres_low = props.globals.getNode("/rotors/gear/mgb-oil-pressure-low", 1);
  mgb_oilpres_norm = props.globals.getNode("/rotors/gear/mgb-oil-pressure-norm", 1);
  mgb_oilpres_bar = props.globals.getNode("/rotors/gear/mgb-oil-pressure-bar", 1);

  var rpm = props.globals.getValue("/rotors/main/rpm") or 0;

  if ( rpm > 0 ) mgb_oilpres_low.setDoubleValue((15-230/rpm)*0.0689);
  if ( rpm > 0 ) mgb_oilpres_norm.setDoubleValue((60-230/rpm)*0.0689);

  settimer(mgbp, 0);
}

mgbp();

##############

var mgbp_bar = func{

  mgb_oilpres_bar = props.globals.getNode("/rotors/gear/mgb-oil-pressure-bar", 1);

  var rpm = props.globals.getValue("/rotors/main/rpm") or 0;
  mgb_oilpres_low = props.globals.getValue("/rotors/gear/mgb-oil-pressure-low") or 0;
  mgb_oilpres_norm = props.globals.getValue("/rotors/gear/mgb-oil-pressure-norm") or 0;

  if ((rpm > 0) and (rpm < 280)){
    interpolate ("/rotors/gear/mgb-oil-pressure-bar",mgb_oilpres_low, 1.5);
  }elsif (rpm > 280) {
    interpolate ("/rotors/gear/mgb-oil-pressure-bar",mgb_oilpres_norm, 2);
  }

  settimer(mgbp_bar, 0.1);
}

mgbp_bar();

##############################################
# mhab merged from flightcontrols.nas
# contains flightcontrol and hydraulics-system
#
# Force Trim Release#
##############
# Due to hydraulic boost of the controls the pilot woulden't feel any force feedback on the controls.
# That's why there is a spring which produce artificial force feel. This force can be set to zero by pressing
# the FTR-button at each stick position by some clutches and electric motors. The clutches holds the
# cyclic-controls, and the spring is moved to a force free position.
#
# As FlightGear doesn't support Force Feedback, and anyway there is no good hardware for that, we cannot simulate
# this approach. We could use the already implemented AutoTrim but this isn't really suitable to helicopters and
# seems even wrong to me. See also data/nasal/aircraft.nas ->autotrim
#
# We use another approach: While pressing the FTR-button ("t-key"), the inputs from Joystick/Mouse are interrupted
# and keep the Cyclic position in the sim to its current state. Now the Joystick/Mouse can be moved into a new
# position (like centered or any other position liked). When the button is released, inputs flow again.
# Some helis, the EC130 as an option on demand, has a 4-way trim switch. This will move the controlls in small
# steps in the wished direction, so the heli is correctly trimmed it can be flown just with this little inputs.
#
# the EC130 here will only make use by FTR. Sorry, no money left for extra gadgets! ;-)#
# that's how to use it:
#	(1) move the stick such that the heli is in an orientation that
#	    you want to trim for (forward flight, hover, ...)
#	(2) press FTR button (f-key)and keep it pressed
#	(3) move stick/yoke to neutral position (center)
#	(4) release FTR button (f-key)
#

var cyclaileron =props.globals.getNode("/controls/flight/aileron", 1);
var cyclelevator =props.globals.getNode("/controls/flight/elevator", 1);

ftr_start = func {
  cyclaileron.setAttribute("writable", 0);
  cyclelevator.setAttribute("writable", 0);
}

ftr_stop = func {
  cyclaileron.setAttribute("writable", 1);
  cyclelevator.setAttribute("writable", 1);
}

######

#Hydraulic system                    #
#system 1 driven by MGB (rotor-rpm)  #
#system 2 driven by engine (n2)      #

update_hydr = func{

  var rpm =  props.globals.getValue("/rotors/main/rpm") or 0;
  var n2 = props.globals.getValue("/engines/engine/n2-rpm") or 0;
  hpump1 = props.globals.getNode("/systems/hydraulics/pump-psi", 1);
  hpump2  = props.globals.getNode("/systems/hydraulics[1]/pump-psi", 1);
  servosp = props.globals.getNode("/systems/hydraulic_servos/servosp", 1);

  var hpsi1 = rpm*2;
  var hpsi2 = n2/40;

  if (hpsi1>508)hpsi1 = 508;
  if (hpsi2>508)hpsi2 = 508;

  hpump1.setValue(hpsi1);
  hpump2.setValue(hpsi2);

  servosp.setValue((hpsi1 + hpsi2)/60);

  settimer(update_hydr, 0.1);
}

init = func {
  settimer(update_hydr, 0.0);
}

init();

#simulation interaction rotorload and cyclic#
var interaction = func{

  rl = props.globals.getValue("/rotors/main/rotor_load") or 0;
  servosp = props.globals.getValue("/systems/hydraulic_servos/servosp") or 0;
  dst1aileron = props.globals.getNode("/controls/flight/aileron_dst1",1);
  dst1elevator = props.globals.getNode("/controls/flight/elevator_dst1",1);
  dst0aileron = props.globals.getNode("/controls/flight/aileron_dst0",1);
  dst0elevator = props.globals.getNode("/controls/flight/elevator_dst0",1);

  if (rl > servosp){
    dst1aileron.setValue(1-(rl - 18) / (26 - 18));
    dst1elevator.setValue(1-(rl - 18) / (26 - 18));
    dst0aileron.setValue(-1-(rl - 18) / (26 - 18));
    dst0elevator.setValue(-1-(rl - 18) / (26 - 18));
  }else{
    dst1aileron.setValue(1);
    dst1elevator.setValue(1);
    dst0aileron.setValue(-1);
    dst0elevator.setValue(-1);
  }

settimer(interaction, 0.1);

}

init = func {
  settimer(interaction, 0.0);
}
init();

##############
var emerg_floats = func {

  EF= getprop("/sim/model/ec130/emerg_floats");

  if (EF == "false"){
    setprop("/controls/gear/floats-inflat", "false");
  }

  settimer(emerg_floats, 0.1);

}

emerg_floats();

##############################################
# mhab merged from fadec.nas
###FADEC###
#simple hack- needs some work to look more professionell#

###Cycle of enginefuelpumps###
#simple hack#
var engfuelpumps =  func {

  fuelpump = props.globals.getNode("/controls/engines/engine/fuel-pump", 1);
  flines_filled = props.globals.getNode("/controls/fuel/tank/fuellines_filled", 1);
  fuelfilter = props.globals.getNode("/controls/fuel/tank/fuelfilter", 1);
  var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
  var CUTOFF = props.globals.getValue("/controls/engines/engine/cutoff") or 0;
  var fp = props.globals.getValue("/controls/engines/engine/fuel-pump") or 0;

  fuelfilter.setValue(0);

  if (n1 > 60){
    fuelpump.setValue(1);
  }else{
    fuelpump.setValue(0);
  }

  if ((fp <1) and (CUTOFF==1)){
    interpolate ("/controls/fuel/tank/fuellines_filled",0, 3);
  }

  settimer(engfuelpumps, 0.1);
}

engfuelpumps();

###State of fuellines - if filled up engine can run - if not engine cuts off###
#simpel hack - known issue: boost-pump runs even without power

var boostpumps = func {

  flines_filled = props.globals.getNode("/controls/fuel/tank/fuellines_filled", 1);
  var boostpump = props.globals.getValue("/controls/fuel/tank/boost-pump") or 0;
  var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
  var CUTOFF = props.globals.getValue("/controls/engines/engine/cutoff") or 0;
  var VOLTS = props.globals.getValue("/systems/electrical/volts") or 0;
  var bp_pwr = getprop("/systems/electrical/outputs/boost-pump");

  if (n1 <60) {
    if  ((boostpump >0) and (bp_pwr >22)){
      interpolate ("/controls/fuel/tank/fuellines_filled",1, 5);
    }else{
      interpolate ("/controls/fuel/tank/fuellines_filled",0, 3);
    }
  }
  if (CUTOFF==1){
    interpolate ("/controls/fuel/tank/fuellines_filled",0, 3);
  }

  settimer(boostpumps, 0.1);
}

boostpumps();

#####################################################
###Engine Start###

##starter cycle##
# var StartSelector
var start = func {

  var ignition = props.globals.getNode("/controls/engines/engine/ignition", 1);
  var starter = props.globals.getNode("/controls/engines/engine/starter", 1);
  var fuelpump = props.globals.getNode("/controls/fuel/tank/boost-pump", 1);
  var power = props.globals.getNode("/controls/engines/engine/power", 1);
  var starting = props.globals.getNode("/controls/engines/engine/starting", 1);
  var injection = props.globals.getNode("/controls/engines/engine/injection", 1);

  var CUTOFF = props.globals.getValue("/controls/engines/engine/cutoff") or 0;
  var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
  var VOLTS = props.globals.getValue("/systems/electrical/volts") or 0;
  var SEL = props.globals.getValue("/controls/engines/engine/startselector") or 0;

  if ((SEL == 1) and (n1 < 63)) {
    if (VOLTS > 22){
      starter.setValue (1);
    }
  }else{
    starter.setValue (0);
  }

  ###ignition cycle###

  if ((SEL == 1) and (n1 > 17) and (n1 < 63)) {
    if (VOLTS > 22){
      ignition.setValue (1);
    }
  }else{
    ignition.setValue(0);
  }

  if ((n1 > 17) and (n1 < 63)) {
    starting.setValue(1.0);
  }

  settimer(start, 0.2);
}

start();

###fuel injection ###

var injection = {
  init: func {

    var injection = props.globals.getNode("/controls/engines/engine/injection", 1);
    var power = props.globals.getNode("/controls/engines/engine/power", 1);

    var flines_filled = props.globals.getValue("/controls/fuel/tank/fuellines_filled") or 0;

    var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;

    if (flines_filled >0.90) {
      power.setValue (0.13);
    }else{
      power.setValue(0.0);
    }

    if ((n1 > 18) and (n1 < 63)) {
      injection.setValue(1.0);
    }
  }
};

setlistener("/controls/engines/engine/starting", func {
  injection.init();
});

###idle ###

var idle= {
  init: func {

    var power = props.globals.getNode("/controls/engines/engine/power", 1);

    var flines_filled = props.globals.getValue("/controls/fuel/tank/fuellines_filled") or 0;

    var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
    var CUTOFF = props.globals.getValue("/controls/engines/engine/cutoff") or 0;

    if (CUTOFF==0) {
      power.setValue (0.71);
    }
  }
};

setlistener("/controls/engines/engine/injection", func {
  idle.init();
});

###flight###

var flight = func {

  var flines_filled = props.globals.getValue("/controls/fuel/tank/fuellines_filled") or 0;

  var n1 = props.globals.getValue("/engines/engine/n1-pct") or 0;
  var power = props.globals.getNode("/controls/engines/engine/power", 1);
  var SEL = props.globals.getValue("/controls/engines/engine/startselector") or 0;
  var ebt = props.globals.getValue("/controls/engines/engine/ebcautest") or 0;

  if ((n1 > 1) and (flines_filled <0.90)) {
    power.setValue(0);
  }

  if ((n1 > 1) and (SEL == 0)) {
    power.setValue(0);
  }

  settimer(flight, 0.2);
}

flight();

##automatic variable main rotor speed system to reduce external noise = rotor-noise-signature reduction feature##
var avrs = func {

  var n2function = props.globals.getNode("/controls/engines/power-trim", 1);
  var trimvalue = props.globals.getValue("/controls/engines/power-trim") or 0;
  #var catabtn = props.globals.getValue("/controls/rotor/cata") or 0;
  var asp = props.globals.getValue("/instrumentation/airspeed-indicator/indicated-speed-kt") or 0;
  # mhab added
  var ebt = props.globals.getValue("/controls/engines/engine/ebcautest") or 0;
  if (    getprop("/gear/gear[0]/wow") or getprop("/gear/gear[1]/wow")
       or getprop("/gear/gear[2]/wow") or getprop("/gear/gear[3]/wow") )
  { var ground = 1;
  } else {
    ground = 0;
  }

  if ( ground ) {
    if ( ebt ) {
      interpolate( n2function, 0.4, 2 );
    } else {
      interpolate( n2function, 0, 6 );
    }
  } else {
    if ( (asp > 0) and (asp <= 20) ) {
      interpolate( n2function, 0.20, 6 );
    }
    if ( (asp > 20) and (asp <= 40) ) {
      interpolate( n2function, 0.10, 6 );
    }
    if ( (asp > 40) and (asp <= 70) ) {
      interpolate( n2function, 0.0, 6 );
    }
    if ( (asp > 70) and (asp <= 120) ) {
      interpolate( n2function, -0.10, 6 );
    }
    if ( (asp > 120) and (asp < 210) ) {
      interpolate( n2function, -0.20, 6 );
    }
  }

  settimer(avrs, 0);
}

avrs();

###########################
# mhab added
var toggle_ebcautest = func () {

  var ebt = getprop("/controls/engines/engine/ebcautest");
  var rpm = getprop("/rotors/main/rpm");

  if ( !ebt ) {
    if ( rpm > 360 ) {
      if (    getprop("/gear/gear[0]/wow") or getprop("/gear/gear[1]/wow")
           or getprop("/gear/gear[2]/wow") or getprop("/gear/gear[3]/wow") )
      {
        setprop("/controls/engines/engine/ebcautest",1);
        # deactivate governor so gov warnings go on
        setprop("/controls/engines/engine/governor",0);
      } else {
        screen.log.write("ATTENTION EBCAU TEST only ground !!!");
      }
    } else {
      screen.log.write("EBCAU TEST requires full powered engine !!!");
    }
  } else {
    setprop("/controls/engines/engine/ebcautest",0);
    # reactivate governor
    setprop("/controls/engines/engine/governor",1);
  }
}

###########################
# mhab added
var adjust_twist_grip = func (delta) {

  var p = getprop("/controls/engines/engine/power");

  if ( delta > 0 ) {

    delta=0.03;
    p +=delta;

    if ( p > 0.60 ) {
      if ( p > 1 ) p = 1;
      setprop("/controls/engines/engine/power", p);

      if ( getprop("/controls/electric/external-power") ) {
        settimer( func{ screen.log.write("Disconnect external power supply before Take-Off !!!"); },3);
      }

    } else {
      setprop("/controls/engines/engine/power", 0.63);
    }

  } else {

    delta=-0.03;
    p +=delta;

    if ( p > 0.59 ) {
      if ( p < 0.63 ) p = 0.63;
      setprop("/controls/engines/engine/power", p);
    } else {
      setprop("/controls/engines/engine/power", 0.63);
    }

  }

  p = getprop("/controls/engines/engine/power")*100;
  if ( p > 60 ) {
    gui.popupTip(sprintf("Twist Grip %d%%", p));
  }
  return p;

}

###########################
# mhab added
var adjust_inst1 = func (delta) {

  var p = getprop("/controls/lighting/instrument-lights-norm");

  p +=delta;

  if ( p > 1 ) p = 1;
  if ( p < 0 ) p = 0;

  setprop("/controls/lighting/instrument-lights-norm", p);

  return p*100;

}

###########################
# mhab added
var adjust_inst2 = func (delta) {

  var p = getprop("/controls/lighting/instrument-lights2-norm");

  p +=delta;

  if ( p > 1 ) p = 1;
  if ( p < 0 ) p = 0;

  setprop("/controls/lighting/instrument-lights2-norm", p);

  return p*100;

}

###########################
# mhab added
var adjust_vemd = func (delta) {

  var p = getprop("/controls/lighting/instrument-lights-vemd-norm");

  p +=delta;

  if ( p > 1 ) p = 1;
  if ( p < 0 ) p = 0;

  setprop("/controls/lighting/instrument-lights-vemd-norm", p);

  return p*100;

}

###########################
# mhab added
var adjust_rpm = func (delta) {

  var p = getprop("/controls/lighting/tach-light-norm");

  p +=delta;

  if ( p > 1 ) p = 1;
  if ( p < 0 ) p = 0;

  setprop("/controls/lighting/tach-light-norm", p);

  return p*100;

}

###########################
# mhab added
var adjust_heading = func (delta) {

  var p = getprop("/instrumentation/kcs55/ki525/selected-heading-deg");

  p +=delta;

  if ( p > 360 ) p -= 360;
  if ( p < 0 )   p += 360;

  setprop("/instrumentation/kcs55/ki525/selected-heading-deg", p);

  return p;

}

###########################
# mhab added
var adjust_obs = func (delta) {

  var p = getprop("/instrumentation/kcs55/ki525/selected-course-deg");

  p +=delta;

  if ( p > 360 ) p -= 360;
  if ( p < 0 )   p += 360;

  setprop("/instrumentation/kcs55/ki525/selected-course-deg", p);

  return p;

}

###########################
# mhab added
var adjust_horizon_offset = func (delta) {

  var p = 0;

  # only if horizob is active
  if ( getprop("/instrumentation/attitude-indicator/serviceable") ) {

    p = getprop("/instrumentation/attitude-indicator/horizon-offset-deg");
    p +=delta;

    setprop("/instrumentation/attitude-indicator/horizon-offset-deg", p);

    return p;

  }

}

###########################
# mhab added
var adjust_altimeter = func (delta) {

  var p = getprop("/instrumentation/altimeter/setting-inhg");

  p +=delta;

  if ( p > 31.0  ) p = 31.0;
  if ( p < 27.50 ) p = 27.50;

  setprop("/instrumentation/altimeter/setting-inhg", p);

  return p;

}

###########################
# mhab added
var adjust_stretcher = func (delta) {

  var p = getprop("/controls/seat/stretcher/position-deg");

  p +=delta;

  if ( p > 50.0  ) p = 50.0;
  if ( p < 0.0 ) p = 0.0;

  setprop("/controls/seat/stretcher/position-deg", p);

  return p;

}

###########################
# mhab added
var toggle_all_doors = func () {

  doors.doorsystem.frontlexport();
  doors.doorsystem.frontrexport();
  doors.doorsystem.passengerlexport();
  doors.doorsystem.luggagerexport();
  doors.doorsystem.doorbexport();
  doors.doorsystem.basketlexport();

}

###########################
# mhab added
var switch_startselector = func () {

  var p = getprop("/controls/engines/engine/startselector");
  var g = getprop("/controls/engines/engine/switchguard");
  var r = getprop("/controls/rotor/brake");
  var s = getprop("/sim/sound/click");

  if (p == 0) {
    if ( !r ) {
      # rotorbrake inhibits starter
      setprop("/controls/engines/engine/startselector", 1);
      setprop("/sim/sound/click", !s);
    } else {
      screen.log.write("Rotorbrake is active !!!");
    }
  } else {
    if ( !g ) {
      setprop("/controls/engines/engine/startselector", 0);
      setprop("/sim/sound/click", !s);
    }
  }

}

###########################
# mhab added
#
var unlock_emergency = func () {

  if ( getprop("/controls/electric/emergency-switch-locked") == 1 ) {
    setprop("/controls/electric/emergency-switch-locked",0);
    screen.log.write("Emergency Switch is UNLOCKED !!!");
    screen.log.write("ATTENTION Emergency Switch CANNOT be RESET !!!");
  } else {
    screen.log.write("Emergency Switch is UNLOCKED !!!");
  }
}

###########################
# mhab added
#
var switch_emergency = func () {

  if ( getprop("/controls/electric/emergency-switch-locked") == 0) {
    setprop("/controls/electric/emergency-switch",1);
    screen.log.write("Emergency Switch is SET !!! No RESET possible !!!");
    inhibit_emergency();
  } else {
    if ( getprop("/controls/electric/emergency-switch") == 0 ) {
      screen.log.write("Unlock Emergency Switch first !!!");
    } else {
      screen.log.write("Emergency Switch CANNOT be RESET !!!");
    }
  }
}

var inhibit_emergency = func () {

    # disable systems
    # engine
    setprop("/controls/engines/engine/cutoff_guard",0);
    setprop("/controls/engines/engine/cutoff",1);
    setprop("/controls/engines/engine/cutoff-norm",1);
    setprop("/controls/engines/engine/switchguard",0);
    setprop("/controls/engines/engine/startselector", 0);
    setprop("/controls/electric/engine[0]/generator",0);
    setprop("/controls/fuel/tank/boost-pump",0);
    # instruments
    setprop("/controls/electric/horn",0);
    setprop("/controls/electric/avionics-switch",0);
    setprop("/controls/anti-ice/pitot-heat",0);
    setprop("/instrumentation/attitude-indicator/serviceable",0);
    setprop("/controls/electric/gyrocompass",0);
    # lights
    setprop("/controls/lighting/beacon",0);
    setprop("/controls/lighting/strobe", 0);
    setprop("/controls/lighting/nav-lights",0);
    setprop("/controls/lighting/taxi-light",0);
    setprop("/controls/lighting/landing-lights",0);
    setprop("/controls/lighting/instrument-lights",0);
    # keep on for emergency
    #setprop("/controls/lighting/dome-light",0);
    #setprop("/controls/lighting/instrument-lights2",0);

    settimer(inhibit_emergency,0.1);

}

###########################
# mhab added
var ELT_test = func () {

  if ( !getprop("/ELT/test") ) {
    setprop("/ELT/armed",0);
    setprop("/ELT/test",1);
    settimer(func { setprop("/ELT/test",0);},2);
  } 
}

###########################
# mhab added
var toggle_rotorbrake = func () {

  var l = getprop("/controls/rotor/brake-locked");
  var b = getprop("/controls/rotor/brake");

  if ( !l ) {

    interpolate("/controls/rotor/brake",!b,1);

    if ( getprop("/controls/rotor/brake") > 0.1 ) {
      gui.popupTip("Rotorbrake opening ...",1);
    } else {
      gui.popupTip("Rotorbrake closing ...",1);
    }
    settimer(func { gui.popupTip("Rotorbrake " ~ (b ? "released !" : "engaged !"));},1.1);
  } else {
    screen.log.write("Rotorbrake is locked !!!");
  }

}

###########################
# mhab added
var toggle_cutoff = func () {

  var l = getprop("/controls/engines/engine/cutoff_guard");
  var b = getprop("/controls/engines/engine/cutoff");
  var n = getprop("/controls/engines/engine/cutoff-norm");

  if ( !l ) {

    interpolate("/controls/engines/engine/cutoff-norm",!b,1);
    interpolate("/controls/engines/engine/cutoff",!b,1);

    if ( getprop("/controls/engines/engine/cutoff-norm") > 0.1 ) {
      gui.popupTip("Cutoff opening ...",1);
    } else {
      gui.popupTip("Cutoff closing ...",1);
    }
    settimer(func { gui.popupTip("Cutoff " ~ (b ? "inactive !" : "active !"));},1.1);

  } else {
    screen.log.write("Cutoff is guarded, unlock first !!!");
  }

}

##############################################

# main() ============================================================
var delta_time = props.globals.getNode("/sim/time/delta-sec", 1);
var hi_heading = props.globals.getNode("/instrumentation/heading-indicator/indicated-heading-deg", 1);
var vertspeed = props.globals.initNode("/velocities/vertical-speed-fps");
var gross_weight_lb = props.globals.initNode("/yasim/gross-weight-lbs");
var gross_weight_kg = props.globals.initNode("/sim/model/gross-weight-kg");
props.globals.getNode("/instrumentation/adf/rotation-deg", 1).alias(hi_heading);

var main_loop = func {
  props.globals.removeChild("autopilot");
  if (replay)
    setprop("/position/gear-agl-m", getprop("/position/altitude-agl-ft") * 0.3 - 1.2);
  # mhab fix
  #vert_speed_fpm.setDoubleValue(vertspeed.getValue() * 60);
  var vspeed=vertspeed.getValue();
  if ( vspeed == nil ) vspeed=0;
  vert_speed_fpm.setDoubleValue(vspeed * 60);
  gross_weight_kg.setDoubleValue(gross_weight_lb.getValue() * LB2KG);

  var dt = delta_time.getValue();
  update_torque(dt);
  update_stall(dt);
  update_slide();

  update_absorber();
  fuel.update(dt);
  engines.update(dt);
  vibration.update(dt);

  settimer(main_loop, 0);
}

var replay = 0;
var crashed = 0;

setlistener("/sim/signals/fdm-initialized", func {
  gui.menuEnable("autopilot", 0);
  init_rotoranim();
  vibration.init();
  engines.init();
  fuel.init();
  mouse.init();
  # mhab
  setprop("/sim/model/sound/volume", 1.0);

  collective.setDoubleValue(1);

  setlistener("/sim/signals/reinit", func(n) {
    n.getBoolValue() and return;
    cprint("32;1", "reinit");
    procedure.reset();
    collective.setDoubleValue(1);
    aircraft.livery.rescan();
# reconfigure is undefined
#    reconfigure();
    crashed = 0;
  });

  setlistener("/sim/crashed", func(n) {
    cprint("31;1", "crashed ", n.getValue());
    engines.engine[0].timer.stop();
    engines.engine[1].timer.stop();
    if (n.getBoolValue())
      crash(crashed = 1);
  });

  setlistener("/sim/freeze/replay-state", func(n) {
    replay = n.getValue();
    cprint("33;1", replay ? "replay" : "pause");
    if (crashed)
      crash(!n.getBoolValue())
  });

  main_loop();
  if (devel and quickstart)
    engines.quickstart();

# activate sound after a delay to avoid
# "crushing" sound samples in cockpit at startup
  settimer(func { setprop("/sim/sound/enabled",1); }, 3);

});
