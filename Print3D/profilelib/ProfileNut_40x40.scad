// Andre Betz
// github@AndreBetz.de

use <../threadlib/threadlib.scad>;

NutDistance=20;
thickness=3;
gap=.8;
screwM3=3;
screwM5=5;
ProfileSize=40;

module Nut_Profile()
{
    polygon([ [0, -3], [3, -3], [3, 0], [9.5, 0], [9.5, 3.5], [3, 9], [0, 9] ]);
}

module Corner_Profile()
{
    d=NutDistance*2;
    polygon([[0,0],[d,0],[0,d]]);
}

module Corner_40x40x2_M5()
{
    difference()
    {
        rotate([90, 0, 0]) translate([0,0,-ProfileSize])
            linear_extrude(height=ProfileSize) Corner_Profile();
        translate([NutDistance/2, ProfileSize/2, -.1])
            cylinder(h=ProfileSize,d=screwM5+gap,$fn=16);
        translate([NutDistance/2*3, ProfileSize/2, -.1])
            cylinder(h=ProfileSize,d=screwM5+gap,$fn=16);
    }
}

module sliding_nut()
{
    rotate([90, 0, 0]) translate([0, 0, -NutDistance/2]) linear_extrude(height=NutDistance) union() 
    {
        Nut_Profile();
        rotate([0, 180, 0]) Nut_Profile();
    }
}

module cutout(m=2) 
{
    hight = 4;
    translate([0, 0,0]) union() 
    {
        translate([0, 0, -20]) cylinder(h=21, d=0.2+m, $fn=16);
        translate([0, 0, -hight+0.5]) cylinder(h=hight, d=0.78+(m*2), $fn=6);
    }
}

module ProfileNut()
{
    difference() 
    {
        translate([0,0,-9]) sliding_nut();
        cutout(m=screwM3);
    }
}
module ProfileNutScrewM3()
{
    hight = 4;
    difference() 
    {
        translate([0,0,-9]) sliding_nut();
        translate([0, 0, -20]) cylinder(h=21, d=0.2+screwM3, $fn=16);
    }
    translate([0, 0, -11.5]) nut("M3x0.5", turns=22, Douter=1);
}
module ProfileNutScrewM5()
{
    hight = 4;
    difference() 
    {
        translate([0,0,-9]) sliding_nut();
        translate([0, 0, -20]) cylinder(h=21, d=0.2+5, $fn=16);
    }
    translate([0, 0, -11.5]) nut("M5x0.5", turns=22, Douter=1);
}
module DoubleProfileNut()
{
    translate([0,-NutDistance/2,0])ProfileNut();
    translate([0,+NutDistance/2,0])ProfileNut();
}
module QuadProfileNut()
{
    translate([0,-NutDistance,0])DoubleProfileNut();
    translate([0,+NutDistance,0])DoubleProfileNut();
}
module DoubleProfileNutScrewM3()
{
    translate([0,-NutDistance/2,0])ProfileNutScrewM3();
    translate([0,+NutDistance/2,0])ProfileNutScrewM3();
}
module QuadProfileNutScrewM3()
{
    translate([0,-NutDistance,0])DoubleProfileNutScrewM3();
    translate([0,+NutDistance,0])DoubleProfileNutScrewM3();
}
module DoubleProfileNutScrewM5()
{
    translate([0,-NutDistance/2,0])ProfileNutScrewM5();
    translate([0,+NutDistance/2,0])ProfileNutScrewM5();
}
module QuadProfileNutScrewM5()
{
    translate([0,-NutDistance,0])DoubleProfileNutScrewM5();
    translate([0,+NutDistance,0])DoubleProfileNutScrewM5();
}

module PanelSide_40x40()
{
    
    difference()
    {
        cube([NutDistance*2,ProfileSize+2*thickness+gap,thickness]);
        translate([NutDistance/2, (ProfileSize+2*thickness+gap)/2, -gap]) cylinder(h=thickness+2*gap, d=0.2+screwM5, $fn=16);
        translate([NutDistance/2+NutDistance, (ProfileSize+2*thickness+gap)/2, -gap]) cylinder(h=thickness+2*gap, d=0.2+screwM5, $fn=16);
    }
}
module ConnectorOneSide_40x40()
{
    PanelSide_40x40();
    translate([NutDistance*2,0,0]) PanelSide_40x40();
}
module Cube_40x40()
{
    PanelSide_40x40();
    translate([0,0,ProfileSize+gap+thickness]) PanelSide_40x40();
    translate([0,thickness,0]) rotate([90,0,0]) PanelSide_40x40();
    translate([0,thickness*2+gap+ProfileSize,0]) rotate([90,0,0]) PanelSide_40x40();
}
module CubeDouble_40x40()
{
    Cube_40x40();
    translate([NutDistance*2,0,0]) Cube_40x40();
}

Corner_40x40x2_M5();