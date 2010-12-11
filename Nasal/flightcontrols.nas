#contains flightcontrol and hydraulics-system#

#Force Trim Release#
##############
#Due to hydraulic boost of the controls the pilot woulden't feel any force feedback on the controls. That's why there is a spring which produce artificial force feel. This force can be set to zero by pressing the FTR-button at each stick position by some clutches and electric motors. The clutches holds the cyclic-controls, and the spring is moved to a force free position.
#As FlightGear dosen't support Force Feedback, and anyway there is no good hardware for that, we cannot simulate this approach. We could use the already implemented AutoTrim but this isn't really suitable to helicopters and seems even wrong to me. See also data/nasal/aircraft.nas ->autotrim
#We use another approach: While pressing the FTR-button ("t-key"), the inputs from Joystick/Mouse are interrupted and keep the Cyclic position in the sim to its current state. Now the Joystick/Mouse can be moved into a new position (like centered or any other position liked). When the button is released, inputs flow again.
#Some helis, the Ec130 as an option on demand, has a 4-way trim switch. This will move the controlls in small steps in the wished direction, so the heli is correctly trimmed it can be flown just with this little inputs. 

#the EC130 here will only make use by FTR. Sorry, no money left for extra gadgets! ;-)#
#that's how to use it:
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

#Hydraulic system#
#system1 driven by MGB (rotor-rpm)#
#system 2 driven by engine (n2)#

update_hydr = func{
var rpm =  props.globals.getNode("/rotors/main/rpm").getValue() or 0;
var n2 = props.globals.getNode("/engines/engine/n2-rpm").getValue() or 0;
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

#hpump1 = props.globals.getNode("/systems/hydraulics/pump-psi").getValue() or 0;
#hpump2  = props.globals.getNode("/systems/hydraulics[1]/pump-psi").getValue() or 0;

rl = props.globals.getNode("/rotors/main/rotor_load").getValue() or 0;
servosp = props.globals.getNode("/systems/hydraulic_servos/servosp").getValue() or 0;
dst1aileron = props.globals.getNode("/controls/flight/aileron_dst1",1);
dst1elevator = props.globals.getNode("/controls/flight/elevator_dst1",1);
dst0aileron = props.globals.getNode("/controls/flight/aileron_dst0",1);
dst0elevator = props.globals.getNode("/controls/flight/elevator_dst0",1);

#if (rl > servosp){
#dst1aileron.setValue(1-(rl - 18) / (22 - 18));
#dst1elevator.setValue(1-(rl - 18) / (22 - 18));
#dst0aileron.setValue(-1-(rl - 18) / (22 - 18));
#dst0elevator.setValue(-1-(rl - 18) / (22 - 18));
#}else{
#dst1aileron.setValue(1);
#dst1elevator.setValue(1);
#dst0aileron.setValue(-1);
#dst0elevator.setValue(-1);
#}

settimer(interaction, 0.1);
}

init = func {
   settimer(interaction, 0.0);
}
init();


