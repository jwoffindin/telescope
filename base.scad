include <BOSL2/std.scad>
include <BOSL2/screws.scad>

include <dimensions.scad>
include <joiner.scad>
include <basePlateAttachment.scad>

//translate([8, 25, -40]) rotate([0, 0, 180]) import("reference/metric_conversion-Leavitt_Upper_sight.stl");
// color("orange", 0.3) rotate([0, 0, -40]) translate([-155, -155, 0]) rotate([0, 0, 0]) import("reference/metric_conversion-LTA_Segment.stl");
// color("orange", 0.3) rotate([0, 0, 60]) translate([-155, -155, 0]) rotate([0, 0, 0]) import("reference/metric_conversion-LTA_Segment.stl");
// color("gold", 0.3) translate([-229.5, -209.9, -10]) import("reference/metric_conversion-Leavitt_Primary_cell.stl");
// color("orange", 0.3) rotate([0,0, -30]) translate([-5110,-529,LEDGE_THICKNESS]) import("reference/primary-cell-new.stl");
//translate([0, 0, -20]) cylinder(d=110, h=CYLINDER_HEIGHT);

$fn = 180; // Increase for smoother curves in the rotation

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
    [outer_radius + OUTER_LIP_DEPTH, 0],
    [outer_radius + OUTER_LIP_DEPTH, OUTER_LIP_HEIGHT],
    [outer_radius, OUTER_LIP_HEIGHT + (OUTER_LIP_DEPTH * 0.7)],
    // Point 2: Top-outer corner of the cylindrical wall
    [outer_radius, CYLINDER_HEIGHT + LEDGE_THICKNESS],
    // Point 3: Top-inner corner of the cylindrical wall
    [inner_radius, CYLINDER_HEIGHT + LEDGE_THICKNESS],
    // Point 4: Inner corner of the cylindrical wall at the top of the ledge
    [inner_radius, LEDGE_THICKNESS],
    // Point 5: The innermost point of the ledge
    [ledge_inner_radius, LEDGE_THICKNESS],
    // Point 6: The bottom-most and innermost point of the ledge (at Z=0)
    [ledge_inner_radius, 0],
    // Then back to Point 1 (implicit in polygon for closed shape)
  ];

  // Rotate extrude the L-shaped outer wall
  rotate_extrude(angle=SEGMENT_ANGLE) {
    polygon(points=l_shape_profile_points);
  }

  // mirror plate attachment (WIP). The rotation "60" puts
  rotate([0, 0, 90 + 60]) translate([0, -81, 0]) linear_extrude(height=LEDGE_THICKNESS) {
        #basePlateAttachment();
      }
}

module truss() {
  cylinder(r=TRUSS_DIAMETER / 2, h=1000);
}

module placedTruss() {
  truss_fudge_factor_for_screw = 2; // 20mm
  translate([MIRROR_INTERNAL_DIAMETER / 2 + WALL_THICKNESS + (TRUSS_DIAMETER / 2) + truss_fudge_factor_for_screw, TRUSS_DIAMETER, -0.01])
    truss();
}

function angle_from_center_to_edge_from_origin(object_center_distance_x, object_width_W) =
    atan2(object_width_W / 2, object_center_distance_x);

module placeJoiner(rotation=0, fudge=0) {
  d = MIRROR_INTERNAL_DIAMETER / 2;
  a = angle_from_center_to_edge_from_origin(d+WALL_THICKNESS, JOINER_WIDTH);

  rotate([0, 0, rotation+a])
    translate([d, 0, 0])
      rotate([0,0,90])
        translate([-JOINER_WIDTH/2, +5, 0])
          children();
}

module segment() {
  difference() {
    union() {
      difference() {
        baseWall();
        placeJoiner(fudge=0.1) joiner(fudge=0.1, flip=true, mirror=true);
      }
      // right-side joiner
      placeJoiner() joinerWithScrewHole();
      // left-side joiner
      placeJoiner(rotation=120) joinerWithScrewHole(flip=true, mirror=true);
    }

    // Cut-out truss inserts
    truss_rotation = 4.5;

    rotate([0, 0, truss_rotation]) placedTruss();
    rotate([0, 0, 120 + truss_rotation]) placedTruss();

    // Cutout entire cylinder from within to remove the straight-sides of the joiners
    translate([0, 0, LEDGE_THICKNESS + 0.05]) cylinder(d=MIRROR_INTERNAL_DIAMETER + 0, h=CYLINDER_HEIGHT);

    // Do a clean cut against the clockwise end as we have some artifacts from joiner
    // rotation which I'm not overly sure about
    translate([0, -5, 0]) cube([MIRROR_INTERNAL_DIAMETER+JOINER_DEPTH, 5, LEDGE_THICKNESS+CYLINDER_HEIGHT]);

    for (a = [30,90]) {
      rotate([0,0,a])
        translate([(MIRROR_INTERNAL_DIAMETER-LEDGE_INTRUSION)/2, 0, -0.1])
          screw_hole("m4", length=LEDGE_THICKNESS+0.2, anchor="bot");
    }
  }
}

module testJoiner() {
    // Cut-out truss inserts
    truss_rotation = 4.5;

    difference() {
      placeJoiner() joinerWithScrewHole(mirror=true, slice=true);
      rotate([0, 0, truss_rotation]) placedTruss();
    }
}

//translate([-JOINER_WIDTH/2, JOINER_DEPTH, 0]) joinerWithScrewHole();

// testJoiner();

rotate([0,0,0]) color("red") segment();
rotate([0,0,120]) color("blue", 0.1) segment();
rotate([0,0,240]) color("blue", 0.1) segment();

// color("orange") rotate([0,0,120]) segment();
// color("yellow") rotate([0,0,240]) segment();
