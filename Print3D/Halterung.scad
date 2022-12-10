/* mail@AndreBetz.de Zwieselbrau.de*/

GewindeG58 = 22.5+2.0;
GewindeM8  = 8.0+0.5;
HolderSizeX = 50;
HolderSizeY = 40;
HolderSizeZ = 25;
ConnSizeL = 35;
ConnSizeX = HolderSizeX+2*ConnSizeL;
ConnSizeY = 20;
ConnSizeZ = HolderSizeZ;
ConnDistance =  75;

$fn = 128;

difference() 
{
    translate ([0, 0, 0]) 
        cube ([HolderSizeX, HolderSizeY,HolderSizeZ],false);
    translate ([HolderSizeX/2,HolderSizeY/2, -0.1]) 
        cylinder(HolderSizeZ+0.2,GewindeG58/2,GewindeG58/2); 
}
difference() 
{
    translate ([-ConnSizeL, -ConnSizeY, 0])      
        cube ([ConnSizeX, ConnSizeY,ConnSizeZ],false);
    rotate([90,0,0])
        translate ([-ConnSizeL/2.5, ConnSizeZ/2, -1])      
            cylinder(HolderSizeZ+0.2,GewindeM8/2,GewindeM8/2); 
    rotate([90,0,0])
        translate ([-ConnSizeL/2.5+ConnDistance, ConnSizeZ/2, -1])      
            cylinder(HolderSizeZ+0.2,GewindeM8/2,GewindeM8/2);
}