// Andre Betz
// github@AndreBetz.de

use <threadlib/threadlib.scad>;
use <profilelib/Profile_40x40.scad>;
use <profilelib/ProfileConnectors_40x40.scad>;
use <profilelib/ProfileNut_40x40.scad>;

lengthProfile = 50;
zoomNut=1.25;

linear_extrude(height=lengthProfile)    profile();
translate([-30, 0, 5]) rotate([180,0,0]) ProfileNut(zoomNut);
translate([50, 0, 0]) connector();
