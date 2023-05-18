// Andre Betz
// github@AndreBetz.de

use <threadlib/threadlib.scad>;
use <profilelib/Profile_40x40.scad>;
use <profilelib/ProfileConnectors_40x40.scad>;
use <profilelib/ProfileNut_40x40.scad>;

lengthProfile = 150;
zoomNut=1;

//linear_extrude(height=lengthProfile)    profile();
//translate([-35, 0, 0]) rotate([180,0,0]) ProfileNut(zoomNut);
//translate([50, 0, 0]) connector();
//double_t_bracket();
small_corner();