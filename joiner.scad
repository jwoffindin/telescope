include <BOSL2/std.scad>
include <BOSL2/screws.scad>

include <dimensions.scad>

module screwInsertWithHeatInsert() {
  union() {
    // screw shaft
    translate([0, 0, 38]) screw_hole("m4", length=25, anchor=TOP);

    // space for screw head
    translate([0, 0, 16.5]) screw_hole("m8", length=25, anchor=TOP);

    // heat insert
    translate([0, 0, 28]) screw_hole("m6", length=9, anchor=TOP, $slop=-0.1);
  }
}

module joiner(flip = false, mirror = false, slice = true, fudge = 0) {
  module box() {
    difference() {
      cuboid(
        [JOINER_WIDTH + fudge, JOINER_DEPTH + fudge, CYLINDER_HEIGHT + LEDGE_THICKNESS + fudge],
        rounding=5,
        edges=[FRONT + LEFT, FRONT + RIGHT],
        anchor=BACK + BOTTOM + LEFT,
        $fn=24
      );
    }
  }

  module slice(flip, mirror) {
    rot = flip ? 0 : 1;
    mir = mirror ? 1 : 0;
    translate([JOINER_WIDTH/2, -JOINER_DEPTH/2, (CYLINDER_HEIGHT + LEDGE_THICKNESS) / 2])
      rotate([-30, -30, 0])
        mirror([0, 0, mir])
          linear_extrude(height=200)
            square(200, center=true);
  }

  difference() {
    box();
    if (slice) slice(flip, mirror);
    // if (fudge == 0) #screwHole();
  }
}

// There are 4 screws on the outside of the joiner - two at the top and two
// at the bottom, placed 12mm apart. These are "standard mounts" for Leavitt
// accessories that are screwed onto
module mountScrews() {
  screwHoleTolerance=0.1;
  // Screw holes
  mountScrewType = "m4";
  mountScrewLength = 20;

  // heat inserts are ~5mm diameter by 8mm deep
  mountScrewHeatInsertType = "m6";
  mountScrewHeatInsertLength = 8;

  for (p=[-6,6]) {
    translate([p, 0, 0]) rotate([90, 0, 0]) {
      screw_hole(mountScrewType, length=mountScrewLength, anchor="top", bevel2=true);
      screw_hole(mountScrewHeatInsertType, length=mountScrewHeatInsertLength, anchor="top", bevel2=true, $slop=-0.1); // , tolerance=-0.1);
    }
  }
}

module magnetSlot() {
  translate([2, -20, CYLINDER_HEIGHT+LEDGE_THICKNESS-2]) cube([8,12,1]);
}
module joinerWithScrewHole(flip = false, mirror = false, slice = true, fudge = 0) {
  difference() {
    joiner(flip=flip, mirror=mirror, slice=slice, fudge=fudge);
    translate([JOINER_WIDTH / 2, -JOINER_DEPTH / 2 + 2, (CYLINDER_HEIGHT + LEDGE_THICKNESS) / 2 + 17])
      rotate([-30, -30, 0])
        translate([-12, -5, -33.5 + 0.05])
          screwInsertWithHeatInsert();

    // Screw inserts for mounting accessories
    translate([JOINER_WIDTH / 2, 0 - JOINER_DEPTH, 15]) mountScrews();
    translate([JOINER_WIDTH / 2, 0 - JOINER_DEPTH, CYLINDER_HEIGHT-5]) mountScrews();

    // Magnet
   // magnetSlot();
  }
}

// joinerWithScrewHole(slice=true);

//screwInsertWithHeatInsert();
