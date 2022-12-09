/* mail@AndreBetz.de Zwieselbrau.de*/

AdapterAussen = 35;
AdapterH      =  5;
AdapterL      = 20;
VichyDInnen   = 25;

$fn = 128;

difference() 
{
    union()
    {
        cylinder(AdapterH,AdapterAussen/2,AdapterAussen/2); 
        translate ([-AdapterAussen/2,0, 0])      
            cube ([AdapterAussen,AdapterL, AdapterH],false);
    }
    translate ([0,0,-0.1])
        cylinder(AdapterH+0.2,VichyDInnen/2,VichyDInnen/2); 
    translate ([-VichyDInnen/2,0,-0.1])      
        cube ([VichyDInnen,AdapterL+0.1, AdapterH+0.2],false);

}