// Andre Betz
// github@AndreBetz.de

use <../threadlib/threadlib.scad>;

NutDistance=20;
thickness=2.5;
gap=.8;
screwM3=3;
screwM5=5;
wandDicke=5;
ProfileSize=40;
screwDrewS=10;

module Nut_Profile(nutTiefe = 3)
{
    breiteOben   = 15 / 2;
    breiteUnten  =  7 / 2;
    hoeheSeite   =  3;
    nutBreite    =  7 / 2;
//    nutTiefe     =  3;
    hoheProfil   =  7;
    polygon([ 
                [0, -nutTiefe], 
                [nutBreite, -nutTiefe], 
                [nutBreite, 0], 
                [breiteOben, 0], 
                [breiteOben, hoeheSeite], 
                [breiteUnten, hoheProfil], 
                [0, hoheProfil] 
    ]);
}

module Corner_Profile(size1,size2)
{
    polygon([[0,0],[size1,0],[0,size2]]);
}

module Corner_40x40x2_M5()
{
    difference()
    {
        rotate([90, 0, 0]) translate([0,0,-ProfileSize]) 
            linear_extrude(height=ProfileSize) Corner_Profile(NutDistance*5/2,NutDistance*5/2);
        translate([NutDistance, ProfileSize/2, -.1])
            cylinder(h=NutDistance*2,d=screwM5+gap,$fn=16);
        translate([NutDistance*2, ProfileSize/2, -.1])
            cylinder(h=NutDistance*2,d=screwM5+gap,$fn=16);
        translate([-0.1, ProfileSize/2, NutDistance])rotate([0, 90, 0])
            cylinder(h=NutDistance*2,d=screwM5+gap,$fn=16);
        translate([-0.1, ProfileSize/2, NutDistance*2])rotate([0, 90, 0])
            cylinder(h=NutDistance*2,d=screwM5+gap,$fn=16);
        //ausschnitt
        translate([wandDicke, ProfileSize/2-screwM5*2,wandDicke])
            cube([NutDistance*2,screwM5*4,NutDistance*2]);
    }
}

module CornerTriangle_40x40x2_M5()
{
    profileSize=40;
    difference()
    {
        linear_extrude(height=wandDicke) Corner_Profile(profileSize+NutDistance*2,profileSize+NutDistance*4);
        
        translate([NutDistance/2, NutDistance/2 , -.1])
            cylinder(h=wandDicke*2,d=screwM5+gap,$fn=16);
        translate([NutDistance/2*3, NutDistance/2 , -.1])
            cylinder(h=wandDicke*2,d=screwM5+gap,$fn=16);
        translate([NutDistance/2*5, NutDistance/2 , -.1])
            cylinder(h=wandDicke*2,d=screwM5+gap,$fn=16);
        translate([NutDistance/2*6, -.1, -.1])  cube([NutDistance,NutDistance*2,wandDicke+.2]);
        
        translate([NutDistance/2, NutDistance*2 , -.1])
            cylinder(h=wandDicke*2,d=screwM5+gap,$fn=16);
        translate([NutDistance/2, NutDistance*3 , -.1])
            cylinder(h=wandDicke*2,d=screwM5+gap,$fn=16);
        translate([NutDistance/2, NutDistance*4 , -.1])
            cylinder(h=wandDicke*2,d=screwM5+gap,$fn=16);
        translate([-0.1,NutDistance/2*9,-.1])    cube([NutDistance,NutDistance*2,wandDicke+.2]);
    }
}

module sliding_nut()
{
    rotate([90, 0, 0]) translate([0, 0, -NutDistance/2]) linear_extrude(height=NutDistance) union() 
    {
        Nut_Profile(0);
        rotate([0, 180, 0]) Nut_Profile(0);
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
//    translate([0, 0, -11]) nut("M3x0.5", turns=17, Douter=1);
    translate([0, 0, -8.8]) nut("M5x0.5", turns=13, Douter=1);
}
module ProfileNutScrewM5()
{
    hight = 4;
    difference() 
    {
        translate([0,0,-9]) sliding_nut();
        translate([0, 0, -20]) cylinder(h=21, d=0.2+5, $fn=16);
    }
//    translate([0, 0, -11]) nut("M3x0.5", turns=17, Douter=1);
    translate([0, 0, -8.8]) nut("M5x0.5", turns=13, Douter=1);
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

module PanelSide_40x40(d=thickness,r=thickness)
{
    
    difference()
    {
        cube([NutDistance*2,ProfileSize+2*r+gap,d]);
        translate([NutDistance/2, (ProfileSize+2*r+gap)/2, -gap]) cylinder(h=d+2*gap, d=0.2+screwM5+1, $fn=16);
        translate([NutDistance/2+NutDistance, (ProfileSize+2*r+gap)/2, -gap]) cylinder(h=d+2*gap, d=0.2+screwM5+1, $fn=16);
    }
}
module ConnectorOneSide_40x40()
{
    PanelSide_40x40();
    translate([NutDistance*2,0,0]) PanelSide_40x40();
}
module Cube_40x40(d=thickness)
{
    PanelSide_40x40(d);
    translate([0,0,ProfileSize+gap+d]) PanelSide_40x40(d);
    translate([0,d,0]) rotate([90,0,0]) PanelSide_40x40(d);
    translate([0,d*2+gap+ProfileSize,0]) rotate([90,0,0]) PanelSide_40x40(d);
}
module CubeDouble_40x40()
{
    Cube_40x40();
    translate([NutDistance*2,0,0]) Cube_40x40();
}

module FuellKopfCube_40x40()
{
    distanceFuellKopf=70;
    dicke = 5;
    rundung = gap;
    dim=20;
    WuerfelX     = 50;
    WuerfelY     = 45;
    WuerfelZ     = 60-dim;
    HalterungD   = 6;
    moveX        = 2;
    HalterungX1  = 12.5+moveX;
    HalterungX2  = HalterungX1+25.0;
    HalterungY1  = 27.5;
    HalterungY2  = HalterungY1+20.0;


    translate([-distanceFuellKopf,dicke/2,ProfileSize]) rotate([0,90,90])
    {
        Cube_40x40(dicke);
        translate([0,-distanceFuellKopf,0]) cube([40,distanceFuellKopf,dicke]);
        translate([0,-distanceFuellKopf,ProfileSize+gap+dicke]) cube([40,distanceFuellKopf,dicke]);
    }    
    difference()
    {
        cube([WuerfelX+dicke*2,WuerfelY+dicke*2,WuerfelZ],false);

        translate([dicke-gap,dicke-gap,-gap]) cube([WuerfelX+2*gap,WuerfelY+2*gap,WuerfelZ+2*gap],false);
    
        translate([0,0,-3])
        {
            rotate([-90,0,0])
                translate([HalterungX1+dicke,-HalterungY1+dim,-rundung])
                    cylinder(d=HalterungD,h=WuerfelY+2*rundung+dicke*2);
            rotate([-90,0,0])
                translate([HalterungX1+dicke,-HalterungY2+dim,-rundung])
                    cylinder(d=HalterungD,h=WuerfelY+2*rundung+dicke*2);
            rotate([-90,0,0])
                translate([HalterungX2+dicke,-HalterungY1+dim,-rundung])
                    cylinder(d=HalterungD,h=WuerfelY+2*rundung+dicke*2);
            rotate([-90,0,0])
                translate([HalterungX2+dicke,-HalterungY2+dim,-rundung])
                    cylinder(d=HalterungD,h=WuerfelY+2*rundung+dicke*2);
        }
    }
}
module Cube_40x40_VentilHolder()
{
    yDistMount=24;
    xDistMount=17;
    xDistMount2=22;
    dMount=6;
    hightMount=yDistMount+2*dMount;
    xStartPos=(NutDistance*2-xDistMount)/2;
    yStartPos=(hightMount-yDistMount)/2;   
    thickMount=8;//ProfileSize/3;
    
    PanelSide_40x40(thickMount,0);
    //Cube_40x40();
    difference()
    {
        translate([0,-hightMount,0]) cube([NutDistance*2,hightMount,thickMount]);        
        //translate([xStartPos,-yStartPos,-gap]) cylinder(d=dMount,h=hightMount+2*gap,$fn=16);       
        translate([xStartPos+xDistMount,-yStartPos,-gap]) cylinder(d=dMount,h=hightMount+2*gap,$fn=16);
        translate([xStartPos,-yStartPos-yDistMount,-gap]) cylinder(d=dMount,h=hightMount+2*gap,$fn=16);
        translate([xStartPos,-yStartPos-yDistMount/2,-gap]) cylinder(d=dMount,h=hightMount+2*gap,$fn=16);
        translate([xStartPos+xDistMount,-yStartPos-yDistMount/2,-gap]) cylinder(d=dMount,h=hightMount+2*gap,$fn=16);
        // Halterung reduzierventil
        //translate([xStartPos+xDistMount2,-yStartPos-yDistMount,-gap]) cylinder(d=dMount,h=hightMount+2*gap,$fn=16);        
        translate([xStartPos,-yStartPos-yDistMount+xDistMount2,-gap]) cylinder(d=dMount,h=hightMount+2*gap,$fn=16);        
    }
}
//Nut_Profile(0);
//ProfileNutScrewM5();
Cube_40x40_VentilHolder();