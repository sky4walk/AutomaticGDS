slot_type = "I"; // ["B","I"]
flat_sides = "NONE"; // ["None","A","AB","ABC","ABCD", "AC"] 

corner_radius = 2;
nut_size = 7.5;
slot_opening = 8;
profile_face_thickness = 3;

profile_x = 40;
profile_y = 40;
$fn=128;

module slot() {
    outer_radius = corner_radius;
    r = outer_radius/3;
   
    slot_width = 20;
    slot_depth = 10;

    wing_length = (slot_width - slot_opening) / 2;
    
    difference() {
        translate([-slot_opening/2, -profile_face_thickness]){
            square([slot_opening,profile_face_thickness]);
            hull() {
                translate([-wing_length + r, -r])circle(r);
                translate([slot_opening + wing_length -r, -r])circle(r);
                translate([slot_opening + wing_length -r, -4])circle(r);
                translate([slot_opening - 0.5, -slot_depth+r])circle(r);
                translate([0.5, -slot_depth+r])circle(r);
                translate([-5, -slot_depth+r +5])circle(r);            
            }
       }
       
       if (slot_type == "I") {
           translate([4,-5])square([2.5,2]);
           translate([-6.5,-5])square([2.5,2]);
       }
   }
}

module smooth_face() {
    translate([profile_x/2-profile_face_thickness,-slot_opening/2])square([profile_face_thickness,slot_opening+2]);
}

module profile() {
    r = corner_radius;
    x_max = profile_x/2 -r;
    y_max = -profile_y/2 +r;
    difference() {
        
        // Basic Square Frame
        hull() {
            translate([x_max, y_max])circle(r);
            translate([x_max, -y_max])circle(r); 
            translate([-x_max, y_max])circle(r); 
            translate([-x_max, -y_max])circle(r); 
        }

        // Add Slots
        for (side_index = [0 : 3] ){
            rotate([0,0,90 * side_index])translate([0,profile_y/2])slot();
        }

       // Center Hole
        circle(r=nut_size/2);        
    }
    
    // Flat sides
    if (len(search("A", flat_sides))) {
        rotate([0,0,0])smooth_face();
    }
    if (len(search("B", flat_sides))) {
        rotate([0,0,90])smooth_face();
    }
    if (len(search("C", flat_sides))) {
        rotate([0,0,180])smooth_face();
    }
    if (len(search("D", flat_sides))) {
        rotate([0,0,270])smooth_face();
    }
    
}

module extrusion_profile(size=30, height=10, radius=1.5, step=1) {

	linear_extrude(height=height) {
		union() {
			sub_extrusion_profile(size, radius, step);
			rotate([0,0,90])  sub_extrusion_profile(size, radius, step);
			rotate([0,0,180]) sub_extrusion_profile(size, radius, step);
			rotate([0,0,270]) sub_extrusion_profile(size, radius, step);
		}
	}
}

module sub_extrusion_profile(size=30, radius = 1.5, step=0.5) {

	reSize = size/30; // Scalling

	k0 = 0;
	k2 = 3.65*reSize;
	k1 = k2*cos(45);

	k3 = 4*reSize;
	k4 = 6*reSize;
	k5 = 8.25*reSize; k5_2 = k5 + k4 - k3;
	k6 = 12.8*reSize;
	k7 = 15*reSize;

	polygon(points=[
		[k1,k1],[0,k2], // Center hole
		[0,k4],[k3,k4],[k5,k5_2],[k5,k6],[k3,k6],
		[k3,k7-step],[k3+step,k7-step],[k3+step,k7], //Step
		[k7-radius,k7],[k7-radius*(1.-cos(45)),k7-radius*(1.-cos(45))],[k7,k7-radius],// Corner
		[k7,k3+step],[k7-step,k3+step],[k7-step,k3], // Step
		[k6,k3],[k6,k5],[k5_2,k5],[k4,k3],[k4,0],
		[k2,0]  // Center hole
	]);
}

module Profile_40x40x150()
{
    linear_extrude(height=15)    profile();
}
Profile_40x40x150();
