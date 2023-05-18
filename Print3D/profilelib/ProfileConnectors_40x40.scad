// parametric extrusion brackets
// Scott Alfter
// 20 July 2018

nominal_extrusion_width=40; 
screw_diameter=5;
gap=0.8; // adjust for a snug fit
thickness=2.8; 

tw=(nominal_extrusion_width+gap+2*thickness); // total width
iw=(nominal_extrusion_width+gap+thickness)/2; // dimension from center of cube to center of hole
sleeve_gap=gap+.2; // looser fit for alignment sleeves

// top-level modules

module corner_bracket()
{
	corner();
	translate([0,tw,0])  tube();
	translate([tw,0,0])  rotate([0,0,90]) tube();
	translate([0,0,tw])  rotate([90,0,0]) tube();
	translate([tw,0,tw]) brace();
	translate([0,tw,tw]) rotate([0,0,90])  brace();
	translate([tw,tw,0]) rotate([-90,0,0]) brace();
}

module connector()
{
    translate([0,0,1.5*tw]){
//	translate([0,0,tw])  rotate([90,0,0]) tube();
//	translate([0,0,0])   rotate([90,0,0]) tube();
	translate([0,0,-tw]) rotate([90,0,0]) tube();
    }
}

module t_bracket()
{
	t();
	translate([0,0,tw])  rotate([90,0,0]) tube();
	translate([0,0,-tw]) rotate([90,0,0]) tube();
	translate([tw,0,0])  rotate([0,0,90]) tube();
	translate([tw,0,tw]) brace();
	translate([tw,0,-tw])rotate([180,0,0])brace();
}
module small_corner() // three panels and three edges in a corner
{
    translate([0,0,iw+thickness/2]){
        t();   
        translate([0,0,tw])  rotate([90,0,0]) tube();
        translate([tw,0,0])  rotate([0,0,90]) tube();
        translate([tw,0,tw]) brace();
        translate([0,0,-iw]) panel();
    }
}
module double_t_bracket()
{
	dt();
	translate([0,0,tw])   rotate([90,0,0])   tube();
	translate([0,0,-tw])  rotate([90,0,0])   tube();
	translate([tw,0,0])   rotate([0,0,90])   tube();
	translate([0,tw,0])   tube();
	translate([tw,0,tw])  brace();
	translate([tw,0,-tw]) rotate([180,0,0])  brace();
	translate([0,tw,tw])  rotate([0,0,90])   brace();
	translate([0,tw,-tw]) rotate([180,0,90]) brace();
	translate([tw,tw,0])  rotate([-90,0,0])  brace();
}

module brace() // a pair of braces
{
	d=tw/2-4;
	translate([0,-d,0]) brace_sub();
	translate([0,d,0])  brace_sub();
}

module tube() // four panels to make a tube
{
	translate([0,0,-iw])    panel();
	translate([0,0,iw])     panel();
	translate([-iw,0,0])    rotate([0,90,0])    panel();
	translate([iw,0,0])     rotate([0,90,0])    panel();
}

module corner() // three panels and three edges in a corner
{
	translate([0,iw,iw])    edge();
	translate([iw,0,iw])    rotate([0,0,90])    edge();
	translate([iw,iw,0])    rotate([0,90,0])    edge();
	translate([0,0,-iw])    panel();
	translate([0,-iw,0])    rotate([90,0,0])    panel();
	translate([-iw,0,0])    rotate([0,90,0])    panel();
}



module t() // three panels and two edges in a T
{
	translate([iw,0,iw])    rotate([0,0,90])    edge();
	translate([iw,0,-iw])	rotate([0,0,90])    edge();
	translate([0,-iw,0])    rotate([90,0,0])    panel();
	translate([0,iw,0])     rotate([90,0,0])    panel();
	translate([-iw,0,0])    rotate([0,90,0])    panel();
}

module dt() // two panels and four edges in a double-T
{
	translate([0,iw,iw])    edge();
	translate([0,iw,-iw])   edge();
	translate([iw,0,iw])	rotate([0,0,90])    edge();
	translate([iw,0,-iw])	rotate([0,0,90])    edge();
	translate([0,-iw,0])	rotate([90,0,0])    panel();
	translate([-iw,0,0])    rotate([0,90,0])    panel();
}

// basic components

module panel() // basic unit: a square plate with a hole, centered on the origin
{
	d=tw/2;
	translate([0,0,-thickness/2])
	linear_extrude(thickness, convexity=10)
	difference()
	{
		polygon([[-d,-d],[-d,d],[d,d],[d,-d]]);
		circle(d=screw_diameter+gap, $fn=45);
	}
}

module edge() // a stick to fill in the corners where panels meet
{
	d1=tw/2;
	d2=thickness/2;
	translate([0,0,-d2])
	linear_extrude(thickness, convexity=10)
		polygon([[-d1,-d2],[d1,-d2],[d1,d2],[-d1,d2]]);
}

module brace_sub() // a diagonal brace
{
	d=tw/2;
	translate([0,thickness/2,0])
	rotate([90,0,0])
	linear_extrude(thickness, convexity=10)
	polygon([[-d,-d],[d-3,-d],[-d,d-3]]);
}
