// Halterung Arduino und Relais

gap          = .1;

BasisPlatteX = 150;
BasisPlatteY = 90;
BasisPlatteZ = 5;
SchraubeM4   = 4+gap;
SchraubeM5   = 5+gap;

ArduinoPosX = 10;
ArduinoPosY = 5;
ArduinoX1   = 0;
ArduinoY1   = 0;
ArduinoX2   = 50.8;
ArduinoY2   = -15.2;
ArduinoX3   = ArduinoX2;
ArduinoY3   = ArduinoY2-27.9;
ArduinoX4   = 0;
ArduinoY4   = -48.2;

RelaisPosX =  ArduinoPosX+ArduinoX2+15;
RelaisPosY =  5;
RelaisX    = 65;
RelaisY    = 45;

NutDistance = 20;
NutPosX1    = 20;
NutPosX2    = 65;
NutPosY     = 20;

difference()
{
    cube([BasisPlatteX,BasisPlatteY,BasisPlatteZ]);
    // Relais Mount    
    translate([RelaisPosX,BasisPlatteY-RelaisPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    translate([RelaisPosX,BasisPlatteY-RelaisPosY-RelaisY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    translate([RelaisPosX+RelaisX,BasisPlatteY-RelaisPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    translate([RelaisPosX+RelaisX,BasisPlatteY-RelaisPosY-RelaisY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    
    // Arduino Mount
    translate([ArduinoPosX,BasisPlatteY-ArduinoPosY,0])
    {
        translate([ArduinoX1,ArduinoY1,-gap])   
            cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
        
        translate([ArduinoX2,ArduinoY2,-gap])   
            cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
        
        translate([ArduinoX3,ArduinoY3,-gap])   
            cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
        
        translate([ArduinoX4,ArduinoY4,-gap])   
            cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM4,$fn=16);
    }
    // Profil Montage
    translate([NutPosX1,NutPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM5,$fn=16);
    translate([NutPosX1+NutDistance,NutPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM5,$fn=16);
    translate([NutPosX2+NutDistance*2,NutPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM5,$fn=16);
    translate([NutPosX2+NutDistance*3,NutPosY,-gap])   cylinder(h=BasisPlatteZ+2*gap,d=SchraubeM5,$fn=16);
    
    
}
