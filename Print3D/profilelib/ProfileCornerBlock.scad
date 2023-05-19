// Corner blocks for T slot profiles

// --------------User Input-------------

/* [Specifications] */

// --Shape Specifications-------

//  (All Dimensions in mm}
Edge_Length = 60;

// Block Thickness.
Thickness = 28;

// --Hole Specifications-----

// Bolt Hole Size
Hole_Diameter = 7.5;

// Number of Holes on each edge.
Hole_Count =2;
// Distance from edge to first Hole center
First_Hole_Distance = 25        ;
// Distance between holes
Between_Holes = 18;
// Size of Counter Bore. Use 0 for no counterbore
Counter_Bore_Diameter = 16;
// Distance from edge to bottom of Counterbore
Edge_to_Counterbore_Bottom = 9.2;

// Tap Locations
Tab_Location = "Both Sides"; // [Both Sides, One Side,No Tab ]
//Width of tab on edges.  Use 0 for no tab
Tab_Width = 8.1;
//Depth of tab on edges.
Tab_Depth = 1.5;
// Print with Base or Slope on build plate?
Print_Orientation = "Base Down"; // [Base_Down, Slope_Down]



// ------Fixed Values and Calculated Variables -------

/* [Hidden] */

$fn=100;

Between_Holes_Adj =
    // Adjust space since not manifold if Between_Holes = Counterbore_Diameter
    (
    Between_Holes == Counter_Bore_Diameter ?
        Counter_Bore_Diameter - 0.001
    :
    Between_Holes
    );
    
// ---Constructed Objects -------------------


//---module to  Construct and position the Wedge Shape

module Differenced_Shape()
{  
    translate([Edge_Length/2, Edge_Length/2, 0])
   difference()
    {
    cube([Edge_Length, Edge_Length, Thickness], center=true);
     
    translate([Edge_Length * cos(45), Edge_Length *cos(45), 0])  
    rotate([0,0,45])
    cube([2*Edge_Length, 4*Edge_Length, 
        1.1 * Thickness], center = true);
    }
}

//---modules to Construct component shapes 

module Hole_With_Counterbore_Knockout()  
    union()
      {  
        //Create the hole
            cylinder(h = 2.5*Edge_Length, d=Hole_Diameter, center = true);
            
        //Create the counterbore
            cylinder(h = Edge_Length, d=Counter_Bore_Diameter, center = true);
      } 
      
    
module KnockOutSet1()  
    for(index = [0: 1: Hole_Count-1])
        {
            rotate([90,0,0])
            translate([(First_Hole_Distance + (index * Between_Holes_Adj)),
            0, 
            (-Edge_to_Counterbore_Bottom - (0.5 * Edge_Length))])
           
                Hole_With_Counterbore_Knockout();            
        };
       
module KnockOutSet2()
    {
        union()
        {
            for(index = [0: 1: Hole_Count-1])
                {
                    rotate([0,90,0])
                    translate([0, 
                    (First_Hole_Distance + (index * Between_Holes_Adj)), 
                    (Edge_to_Counterbore_Bottom + (0.5 * Edge_Length))])
                    
                    Hole_With_Counterbore_Knockout();
                }
        }
    };    
   
   module Tab()
    {
        translate([0,-Tab_Depth, -Tab_Width/2])
        cube([Edge_Length, Tab_Depth, Tab_Width]);
    };
   
 
    module Tabs()
    {
         if( Tab_Location =="No Tab")
            { }
         if( Tab_Location =="One Side")
            {Tab();}
         
        if( Tab_Location =="Both Sides")
              union()
              {
                  Tab();
                translate([-Tab_Depth, 0,0]) rotate([0,0,90]) Tab();
              }  
    };

    module ShapeWithTabs()
    
    {
       union()
       {
           Tabs();
           Differenced_Shape();
       }  
    };
    
    
//------------Create the Object ---------------------
    
 module CombinedShape()
    {
            difference()
        {              
         ShapeWithTabs();
         KnockOutSet1();
         KnockOutSet2();
        }; 
    };
    
        
//-----------Rotate to Print Slope Down ---------
    
    
   Rotate_Matrix_1 =
    (
        Print_Orientation == "Slope_Down" ?
        [0,0,45]
        :
        [90,0,0]
    );
    
   Rotate_Matrix_2 =
    (
        Print_Orientation == "Slope_Down" ?
        [0,90,0]
        :
        [0,0,0]
    );
    
   Rotate_Matrix_3 =
    (
        Print_Orientation == "Slope_Down" ?
        [-90,0,0]
        :
        [0,0,0]
    );
    
    Translate_Matrix =
    (
        Print_Orientation == "Slope_Down" ?
        [0,0, Edge_Length * cos(45)]
        :
        [0,0,0]
    );
    
 //--------Position the Object ---------
    
 translate(Translate_Matrix) 
    rotate(Rotate_Matrix_3) 
    rotate(Rotate_Matrix_2) 
    rotate(Rotate_Matrix_1) CombinedShape();
  

