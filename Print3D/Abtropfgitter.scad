// Abtropfgitter

laenge   = 130;
breite   = 130;
hoehe    = 20;
dicke    = 3;
abstandD = 5;
loecherD = 4;


stepsX = ( breite - loecherD ) / (loecherD * 2);
stepsY = ( laenge - loecherD ) / (loecherD * 2);

difference() {
    cube([laenge,breite,dicke]);
    
    for ( j = [0:1:stepsY-1] ) {
        for ( i = [0:1:stepsX-1] ) {
            translate([loecherD*2*(1+i),loecherD*2*(1+j),-.1])
                cylinder(h=dicke+0.2,d=loecherD,$fn=16);    
            
        }
    }
}
translate([breite/4  ,laenge/4  ,0]) cylinder(h=hoehe+dicke,d=abstandD*2,$fn=16);
translate([breite/4*3,laenge/4*3,0]) cylinder(h=hoehe+dicke,d=abstandD*2,$fn=16);
translate([breite/4  ,laenge/4*3,0]) cylinder(h=hoehe+dicke,d=abstandD*2,$fn=16);
translate([breite/4*3,laenge/4  ,0]) cylinder(h=hoehe+dicke,d=abstandD*2,$fn=16);

