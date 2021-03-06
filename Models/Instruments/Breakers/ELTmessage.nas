#Basic ELT (Emergency Locator Transmitter)
#Authors: Pavel Cueto, with A LOT of collaboration from Thorsten and AndersG

#Be sure to link this Nasal in -set file, typing:
#<nasal>
#  <ELT>
#    <file>YOUR/INSTRUMENT/FOLDER/ROUTE/HERE/ELTmessage.nas</file>
#  </ELT>
#</nasal>

print('Emergency Locator Transmitter (ELT) loaded');

#Aircraft ID definition
var aircraft = getprop("/sim/description");
var callsign = getprop("/sim/multiplay/callsign");
var aircraft_id = aircraft ~ ", " ~ callsign;

var ground = getprop("/position/altitude-agl-ft");

#Print an emergency auto-message when aircraft crashes
setlistener("/sim/crashed", func(msg) {
  if ((getprop("/sim/crashed")) and (ground < 1)) {
    var lat = getprop("/position/latitude-string");
    var lon = getprop("/position/longitude-string");
    var help_string = "ELT AutoMessage: " ~ aircraft_id ~ ", CRASHED AT " ~lat~" LAT "~lon~" LON, REQUESTING SAR SERVICE";
    setprop("/sim/multiplay/chat", help_string);
#    settimer(msg, 1);
  }
});

#Print an emergency message when pilot turns on the "armed" button
setlistener("/ELT/armed", func(alrm) {
  if (getprop("/ELT/armed")) {
    var lat = getprop("/position/latitude-string");
    var lon = getprop("/position/longitude-string");
    var help_string = "ELT Message: " ~ aircraft_id ~ ", DECLARING EMERGENCY AT " ~lat~" LAT, "~lon~" LON";
    setprop("/sim/multiplay/chat", help_string);
  }
});

#Print a message when pilot turns on the "test" button
setlistener("/ELT/test", func(alrm) {
  if (getprop("/ELT/test")) {
    var lat = getprop("/position/latitude-string");
    var lon = getprop("/position/longitude-string");
    var help_string = "ELT Message: " ~ aircraft_id ~ ", EMERGENCY TEST AT " ~lat~" LAT, "~lon~" LON";
    screen.log.write(help_string);
  }
});
