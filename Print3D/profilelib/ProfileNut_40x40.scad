// Andre Betz
// github@AndreBetz.de
module Nut_Profile(zoom)
{
    scale (zoom) polygon([ [0, -3], [3, -3], [3, 0], [9.5, 0], [9.5, 3.5], [3, 9], [0, 9] ]);
}

module sliding_nut(length=10.5,zoom=1.0)
{
    rotate([90, 0, 0]) translate([0, 0, -length/2]) linear_extrude(height=length) union() 
    {
        Nut_Profile(zoom);
        rotate([0, 180, 0]) Nut_Profile(zoom);
    }
}

module cutout(m=2) 
{
    translate([0, 0, 3.7-(m*0.8)]) union() 
    {
        translate([0, 0, -10]) cylinder(h=10, d=0.2+m, $fn=16);
        cylinder(h=10, d=0.78+(m*2), $fn=6);
    }
}

module ProfileNut(zoom=1.0)
{
    translate([0,0,-9])
    difference() 
    {
        sliding_nut(20,zoom);
        cutout(m=2);
    }
}
