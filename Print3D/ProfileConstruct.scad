// Andre Betz
// github@AndreBetz.de

use <profilelib/Profile_40x40.scad>;
use <profilelib/ProfileNut_40x40.scad>;

lengthProfile = 150;
zoomNut=1;

//linear_extrude(height=lengthProfile)    profile();
//translate([-35, 0, 0]) rotate([180,0,0]) ProfileNut(zoomNut);
//translate([50, 0, 0]) connector();
//double_t_bracket();
//small_corner();
//connector();
//translate([15, 25, 38]) rotate([90,0,0]) QuadProfileNut();
//translate([40, -10, 25]) rotate([180,90,90]) QuadProfileNutScrewM5();
//QuadProfileNutScrewM5();
CubeDouble_40x40();