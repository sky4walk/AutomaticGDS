// Halterung Arduino und Relais

gap          = .1;

BasisPlatteX = 140;
BasisPlatteY = 80;
BasisPlatteZ = 8;
SchraubeM4   = 4+gap;
SchraubeM5   = 5+gap;

RelaisPosX =  5;
RelaisPosY =  5;
RelaisX    = 45;
RelaisY    = 65;

ArduinoPosX = 60;
ArduinoPosY = 10;
ArduinoX    = 75;
ArduinoY1   = 30;
ArduinoY2   = 40;

NutDistance = 20;
NutPosX     = 65;
NutPosY     = 15;

difference()
{
    cube([BasisPlatteX,BasisPlatteY,BasisPlatteZ]);
    // Relais Mount
    translate([RelaisPosX,BasisPlatteY-RelaisPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    translate([RelaisPosX,BasisPlatteY-RelaisPosY-RelaisY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    translate([RelaisPosX+RelaisX,BasisPlatteY-RelaisPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    translate([RelaisPosX+RelaisX,BasisPlatteY-RelaisPosY-RelaisY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    // Arduino Mount
    translate([ArduinoPosX,BasisPlatteY-ArduinoPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    translate([ArduinoPosX+ArduinoX,BasisPlatteY-ArduinoPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    translate([ArduinoPosX,BasisPlatteY-ArduinoPosY-ArduinoY1,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    translate([ArduinoPosX+ArduinoX,BasisPlatteY-ArduinoPosY-ArduinoY2,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    // Profil Montage
    translate([NutPosX,NutPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM5,$fn=16);
    translate([NutPosX+NutDistance,NutPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM5,$fn=16);
    translate([NutPosX+NutDistance*2,NutPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM5,$fn=16);
    translate([NutPosX+NutDistance*3,NutPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM5,$fn=16);
    
    
}
