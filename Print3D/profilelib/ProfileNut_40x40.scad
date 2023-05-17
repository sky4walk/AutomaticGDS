// Base shapes for v slot t nut.
// Copyright 2019 a.j.buxton@gmail.com
// CC BY-SA 2.5

module profile()
{
    polygon([ [0, -1.5], [3, -1.5], [3, 0], [5.25, 0], [5.25, 1.4], [3, 3.9], [0, 3.9] ]);
}


module rotating_nut()
{
    union() 
    {
        rotate([90, 0, 0]) linear_extrude(height=3) profile();
        rotate([0, 0, 180]) rotate([90, 0, 0]) linear_extrude(height=3) profile();
        intersection() 
        {
            rotate_extrude($fn=32) profile();
            translate([-5.25, -3, -10]) cube([10.5, 6, 20]);
        }
    }
}

module sliding_nut(length=10.5)
{
    rotate([90, 0, 0]) translate([0, 0, -length/2]) linear_extrude(height=length) union() 
    {
        profile();
        rotate([0, 180, 0]) profile();
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

rotate([90, 0, 0]) difference() 
{
    sliding_nut();
    cutout(m=2);
}
