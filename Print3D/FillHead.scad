// Andre Betz
// github@AndreBetz.de

use <threadlib.scad>;
$fn=80;

WuerfelX = 50;
WuerfelY = 45;
WuerfelZ = 60;
HalterungD   = 6;
HalterungX1  = 12.5;
HalterungX2  = HalterungX1+25.0;
HalterungY1  = 27.5;
HalterungY2  = HalterungY1+20.0;

module Innereien()
{
    rotate([-90,0,0])
        translate([HalterungX1,-HalterungY1,-.5])
            cylinder(d=HalterungD,h=WuerfelY+1);
    rotate([-90,0,0])
        translate([HalterungX1,-HalterungY2,-.5])
            cylinder(d=HalterungD,h=WuerfelY+1);
    rotate([-90,0,0])
        translate([HalterungX2,-HalterungY1,-0.5])
            cylinder(d=HalterungD,h=WuerfelY+1);
    rotate([-90,0,0])
        translate([HalterungX2,-HalterungY2,-0.5])
            cylinder(d=HalterungD,h=WuerfelY+1);
}

difference()
{
    cube([WuerfelX,WuerfelY,WuerfelZ],false);
    Innereien();
}
