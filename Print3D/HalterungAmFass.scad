/* mail@AndreBetz.de Zwieselbrau.de*/

GewindeG58   = 22.5+2.0;
Surround     = 10;
Thickness    = 5;
HolderHight  = 61;
HolderSizeX  = GewindeG58;
HolderSizeY  = GewindeG58+Surround;
PodestThick  = 25;
PodestLength = 30;

$fn = 128;

difference() 
{
    translate ([0, 0, 0]) 
        cube ([HolderSizeX, HolderSizeY,Thickness],false);
    translate ([HolderSizeX/2,HolderSizeY/2, -0.1]) 
        cylinder(Thickness+0.2,GewindeG58/2,GewindeG58/2); 
}
//Length of holder
translate ([HolderSizeX, 0, 0])
    cube ([Surround, HolderSizeY,Thickness],false);
translate ([HolderSizeX, 0, 0])
    cube ([Surround, HolderSizeY,Thickness],false);
translate ([-HolderHight, 0, 0])
    cube ([HolderHight, HolderSizeY,Thickness],false);
//Podest
translate ([-HolderHight, 0, 0])
    cube ([Thickness, HolderSizeY,PodestThick+2*Thickness],false);
translate ([-HolderHight-PodestLength, 0, 0])
    cube ([PodestLength, HolderSizeY,Thickness],false);
translate ([-HolderHight-PodestLength, 0, PodestThick+Thickness])
    cube ([PodestLength, HolderSizeY,Thickness],false);

