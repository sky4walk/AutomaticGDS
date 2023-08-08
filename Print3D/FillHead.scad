// Andre Betz
// github@AndreBetz.de

use <threadlib/threadlib.scad>;
$fn=100;

rundung      = 0.1;
WuerfelX     = 50;
WuerfelY     = 45;
WuerfelZ     = 60;
HalterungD   = 6;
moveX        = 2;
HalterungX1  = 12.5+moveX;
HalterungX2  = HalterungX1+25.0;
HalterungY1  = 27.5;
HalterungY2  = HalterungY1+20.0;
TestStiftX   = 5;
TestStiftY   = 10;
TestStiftZ   = 20;
FlaschRohrH  = 10;
FlaschRohrDa = 16;
ZylinderUH   = 20;
ZylinderUD   = 12;
ZylinderO1D  = 8;
ZylinderO2H  = 43-ZylinderUH;
ZylinderO2D  = 2;
ZylinderS1D  = 10;
ZylinderS2D  = 3; // M3
Nut14H       = 8;
Nut14D       = 16;//15;
Nut14Windung = 5.48;
Uebergang    = 3;
OPos1 = (ZylinderUD-ZylinderO1D)/2;
OPos2 = (ZylinderUD-ZylinderO2D)/2;

module Innereien()
{
    // Halterungen
    rotate([-90,0,0])
        translate([HalterungX1,-HalterungY1,-rundung])
            cylinder(d=HalterungD,h=WuerfelY+2*rundung);
    rotate([-90,0,0])
        translate([HalterungX1,-HalterungY2,-rundung])
            cylinder(d=HalterungD,h=WuerfelY+2*rundung);
    rotate([-90,0,0])
        translate([HalterungX2,-HalterungY1,-rundung])
            cylinder(d=HalterungD,h=WuerfelY+2*rundung);
    rotate([-90,0,0])
        translate([HalterungX2,-HalterungY2,-rundung])
            cylinder(d=HalterungD,h=WuerfelY+2*rundung);
    // Teststift
    translate([-rundung,WuerfelY/2-TestStiftY/2,WuerfelZ-TestStiftZ+rundung])
        cube([TestStiftX+rundung,TestStiftY,TestStiftZ+rundung]);
    translate([-rundung,WuerfelY/2,WuerfelZ-TestStiftZ+rundung])
        rotate([0,90,0])
            cylinder(d=TestStiftY,h=TestStiftX+rundung);
    translate([WuerfelX/2-OPos2,WuerfelY/2,ZylinderUH-rundung])
        cylinder(d=ZylinderO2D-rundung,h=ZylinderO2H+2*rundung);       
    rotate([0,90,0])
        translate([-WuerfelZ+TestStiftZ,WuerfelY/2,TestStiftX-rundung])
            cylinder(d=ZylinderS2D,h=WuerfelX/2-OPos2-TestStiftX+2*rundung);
    // Rohr zur Flasche unten
    translate([WuerfelX/2,WuerfelY/2,-FlaschRohrH-rundung])
        cylinder(d=ZylinderUD,h=ZylinderUH+FlaschRohrH+rundung);    
    // Rohr zum EIngang oben
    translate([WuerfelX/2+OPos1,WuerfelY/2,ZylinderUH-rundung])
        cylinder(d=ZylinderO1D,h=WuerfelZ-ZylinderUH+2*rundung);
    // Gewinde ausschnitt oben
    translate([WuerfelX/2+OPos1,WuerfelY/2,WuerfelZ-Nut14H-rundung])
        cylinder(d1=Nut14D,d2=Nut14D,h=Nut14H+2*rundung);
    // Verbundung oben Gewinde 
    translate([WuerfelX/2+OPos1,WuerfelY/2,WuerfelZ-Nut14H-Uebergang-rundung])
        cylinder(d1=ZylinderO1D,d2=Nut14D,h=Uebergang+2*rundung);
    // verbindung ausgang seitlich zum gewinde
    rotate([90,90,0])
        translate([-2*ZylinderUH/3,WuerfelX/2,-WuerfelY/2-rundung])
            cylinder(d=ZylinderS1D,h=WuerfelY/2+2*rundung);
    // aussparung gewinde seitlich
     rotate([90,90,0])
        translate([-2*ZylinderUH/3,WuerfelX/2,-Nut14H-rundung])
            cylinder(d=Nut14D,h=Nut14H+2*rundung);


}

module Aussereien()
{    
    cube([WuerfelX,WuerfelY,WuerfelZ],false);
    translate([WuerfelX/2,WuerfelY/2,-FlaschRohrH])
        cylinder(d=FlaschRohrDa,h=FlaschRohrH);
}

module Gewinde()
{
    translate([WuerfelX/2+OPos1,WuerfelY/2,WuerfelZ-Nut14H])
        nut("G1/4", turns=Nut14Windung,Douter=Nut14D);
    rotate([90,90,0])
        translate([-2*ZylinderUH/3,WuerfelX/2,-Nut14H])
            nut("G1/4", turns=Nut14Windung,Douter=Nut14D);
    rotate([0,90,0])
        translate([-WuerfelZ+TestStiftZ,WuerfelY/2,TestStiftX+3*rundung])
            nut("M3x0.5", turns=27, Douter=ZylinderO2D+rundung);
}

module FuellKopf()
{
    difference()
    {
        Aussereien();
        Innereien();
    }
    Gewinde();
}
FuellKopf();