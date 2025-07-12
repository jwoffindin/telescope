include <BOSL2/std.scad>
include <BOSL2/screws.scad>

include <dimensions.scad>
include <joiner.scad>
include <basePlateAttachment.scad>

$fn = 200; // Increase for smoother curves in the rotation


module baseWall() {
    // --- Calculated Parameters ---
    inner_radius = MIRROR_INTERNAL_DIAMETER / 2;
    outer_radius = inner_radius + WALL_THICKNESS;
    // The crucial change: ledge_inner_radius is now calculated by subtracting intrusion from inner_radius
    ledge_inner_radius = inner_radius - LEDGE_INTRUSION;

    // --- Main Assembly ---

    // Define the 2D L-shape profile as a polygon
    // The points are (X-coordinate, Z-coordinate)
    // X-coordinate represents the radial distance from the center of rotation (Z-axis).
    // Z-coordinate represents the height.
    // We are defining the 'L' starting from its bottom-most, *outermost* point.

    l_shape_profile_points = [
        // Point 1: Bottom-outer corner of the cylindrical wall (at Z=0)
        [outer_radius, 0],
        [outer_radius+15,0],
        [outer_radius+15,LEDGE_THICKNESS*4],
        [outer_radius,LEDGE_THICKNESS*6],
        // Point 2: Top-outer corner of the cylindrical wall
        [outer_radius, CYLINDER_HEIGHT + LEDGE_THICKNESS],
        // Point 3: Top-inner corner of the cylindrical wall
        [inner_radius, CYLINDER_HEIGHT + LEDGE_THICKNESS],
        // Point 4: Inner corner of the cylindrical wall at the top of the ledge
        [inner_radius, LEDGE_THICKNESS],
        // Point 5: The innermost point of the ledge
        [ledge_inner_radius, LEDGE_THICKNESS],
        // Point 6: The bottom-most and innermost point of the ledge (at Z=0)
        [ledge_inner_radius, 0]
        // Then back to Point 1 (implicit in polygon for closed shape)
    ];

    // Use rotate_extrude with the 'angle' parameter to create the specific segment
    rotate_extrude(angle = SEGMENT_ANGLE) {
        polygon(points = l_shape_profile_points);
    }
    
    // mirror plate attachment (WIP)
    rotate([0,0,90+60]) translate([0, -inner_radius+37.5,0]) linear_extrude(height = LEDGE_THICKNESS) {
      basePlateAttachment(5);
    }

}

module truss() {
  cylinder(r=TRUSS_DIAMETER/2, h=1000);
}



module segment() {
    difference() {
      union() {
        difference() {
          baseWall();
          // right-side joiner cut-out
          translate([MIRROR_INTERNAL_DIAMETER/2-JOINER_BUFFER, 0, 0]) rotate([0,0,-270.5]) joiner(mirror=true,fudge=0.1); 
        }
        // right-side joiner
        translate([MIRROR_INTERNAL_DIAMETER/2-JOINER_BUFFER, 0, 0]) rotate([0,0,-270]) {
          joinerWithScrewHole();
        }
        
        // left-side joiner
        rotate([0,0,-270+120]) translate([0, -MIRROR_INTERNAL_DIAMETER/2, 0]) joinerWithScrewHole(flip=true, mirror=true);
      }
      
      // Cut-out truss inserts
      truss_rotation=7;
      rotate([0, 0, truss_rotation]) translate([MIRROR_INTERNAL_DIAMETER/2+WALL_THICKNESS, TRUSS_DIAMETER, -0.01]) truss();           
      rotate([0, 0, 120+truss_rotation]) translate([MIRROR_INTERNAL_DIAMETER/2+WALL_THICKNESS, TRUSS_DIAMETER, -0.01]) truss();           

      
      // Cutout entire cylinder from within to remove the straight-sides of the joiners
      translate([0, 0, LEDGE_THICKNESS+0.05]) cylinder(d=MIRROR_INTERNAL_DIAMETER+0, h=CYLINDER_HEIGHT);
    }
}

//joinerWithScrewHole();


segment();