Readme File for handling of Formations in Flightgear
====================================================

Introduction:
------------
Flightgear has the so called AI system for handling aircraft traffic, etc.
AI is short for "A"rtificial "I"ntelligence ...

One use of this system is to configure and fly an aircraft in formation with
other aircraft, without using Multi-Player functionality.

See more details at: http://wiki.flightgear.org/Howto:Add_wingmen

Formations:
----------
In order to fly formations you need three things:

  1) A wingman model to use in scenarios/formations
  2) A scenario which places one or more wingmen relative to
     the parent aircraft.
  3) enable AI models in FG (startup option)


1) Wingman Model Installation:
------------------------------
For installation of the wingman do the following:

  a) Copy the original aircraft folder:

     from: "[your aircraft folder]\[aircraft_name]"
       to: "[FG_HOME]\data\AI\Aircraft\[aircraft_name]"

     Remark: To minimize disk usage only copy the "Models" subfolder.

  b) Copy the wingman model XML file "[aircraft_name]-wingman.xml" ...

     from: "[your aircraft folder]\[aircraft_name]\AI"
       to: "[FG_HOME]\data\AI\Aircraft\[aircraft_name]\Models"


2) Scenario Installation:
------------------------
For installation copy scenario file(s) ...

   from: "[your aircraft folder]\[aircraft_name]\AI"
     to: "[FG_HOME]\data\AI"

For the EC130 four different formation scenarios are defined:

  - EC130_wingman_demo_1L.xml
  - EC130_wingman_demo_1R.xml
  - EC130_wingman_demo_2L_ship.xml
  - EC130_wingman_demo_2R_ship.xml


3) Choosing a scenario
----------------------
In order to use a formation you need to

3a) Choose one or more scenarios at FG startup.
Each scenario has a description. Scenarios can be combined, if they do not contain
aircraft at the same location.

Remark: You can also choose scenarios from within FG --> see Menu AI/AI Settings

3b) Enable AI models through command line option (startup option).


4) Limitations:
--------------

Flight behaviour:
----------------
FG wingman and formation support is currently optimized for aeroplanes.

Flight behaviour for helicopters is very different and so there are various
flight situations, when the helicopter wingmen move in very unrealistic ways.
i.e. especially at low speed and hovering situations.

Best results are achieved for steady moving forward flight at reasonable speed.

Formation Control:
-----------------
EC130 formation/wingman does NOT support formation control through
"formation.nas", due to limitations in current FG formation control.

Wingman visibility:
------------------
With FG version 3.4 AI model visibility depends on LOD options.

Min-Size: If the AI model is smaller than a certain number of pixel it becomes invisible.
--> see Menu "View/Adjust LOD Ranges" option "AI/MP aircraft"

Max-Size: Also it may happen that the aircraft disappears if it is nearer than a certain
distance (or bigger than a certain ammount of pixels). This seems to be a bug in late
FG versions.

