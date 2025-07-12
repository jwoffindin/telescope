include <BOSL2/std.scad>
include <BOSL2/screws.scad>

include <dimensions.scad>

module screwInsertWithHeatInsert() {
  union() {
    cylinder(h=25,d=10); // screw shaft
    translate([0, 0, 20]) cylinder(h=15,d=5); // space for screw head
    translate([0, 0, 30]) cylinder(h=8,d=10); // heat insert
  }
}

module joiner(flip=false,mirror=false, slice=true, fudge=0) {
    module box() {
       difference() {
          cuboid(
            [JOINER_WIDTH+fudge, JOINER_DEPTH+JOINER_BUFFER+fudge, CYLINDER_HEIGHT + LEDGE_THICKNESS+fudge], rounding=5,
            edges=[FRONT+LEFT, FRONT+RIGHT],
            anchor=BACK+BOTTOM+LEFT,
            $fn=24
          );
          
       }
    }
    
    module slice(flip, mirror) {
      rot=flip ? 180 : 1;
      mir=mirror ? 1 : 0;
      translate([JOINER_WIDTH/2, -(JOINER_DEPTH+JOINER_BUFFER)/2, (CYLINDER_HEIGHT + LEDGE_THICKNESS)/2])
      rotate([-45, -45, 0])
      mirror([0, 0, mir])
      linear_extrude(height=200)
      square(200, center = true);
    }

    difference() {
      box();
      if (slice) slice(flip, mirror);
      // if (fudge == 0) #screwHole();
    }
    
}

// Kind of in the right place
module screwHole() {
    translate([0, 0, CYLINDER_HEIGHT/2]) 
      rotate([-45, -45, 0]) 
      translate([0,-20,-20])
      screw_hole("m4,80",head="socket",counterbore=15);
}

module joinerWithScrewHole(flip=false, mirror=false, slice=true, fudge=0) {
    difference() {
        joiner(flip=flip, mirror=mirror, slice=slice, fudge=fudge);
        translate([JOINER_WIDTH/2, -(JOINER_DEPTH+JOINER_BUFFER)/2, (CYLINDER_HEIGHT + LEDGE_THICKNESS)/2]) rotate([-45,-45,0]) translate([-5,-5,-30+0.05]) screwInsertWithHeatInsert();
    }
}


// joinerWithScrewHole(slice=true);

//screwInsertWithHeatInsert();
