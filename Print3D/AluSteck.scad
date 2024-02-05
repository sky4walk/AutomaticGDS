len = 25;
height = 20;

module alusteck_profile(length=25) {
    k1 = length/2;
    cd = 1.5;
    di = 1;
    polygon(points=[
        [0,0],[0,k1-cd],
        [cd*(1.-cos(45)),k1-cd*(1.-cos(45))], //ecke
        [cd,k1],[k1,k1],
        [k1,k1-di],[cd,k1-di],
        [di,k1-cd],[di,0]
    ]);
}


linear_extrude(height) alusteck_profile();
translate([len/2,-len/2,0]) rotate([0,0,90]) linear_extrude(height) alusteck_profile();
translate([len,0,0]) rotate([0,0,180]) linear_extrude(height) alusteck_profile();
translate([len/2,len/2,0]) rotate([0,0,-90]) linear_extrude(height) alusteck_profile();
