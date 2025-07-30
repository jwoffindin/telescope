// Base plate attachment (2d), hole is centered at (0,0)
include <Round-Anything/polyround.scad>
// include <BOSL2/drawing.scad>
include <BOSL2/std.scad>

MIRROR_MOUNT_SCREW=4.2;

module basePlateAttachment(holeDiameter=MIRROR_MOUNT_SCREW) {
    radiiPoints=[
        [0, 0, 0   ],
        [0, 10, 0],
        [10,10,20 ],
        [20,40,10 ],
        [30,10,20 ],
        [40,10,0],
        [40,0,0],
        [0,0,0]
    ];

    difference() {
      union() {
        translate([-20,-15,0])
          polygon(polyRound(radiiPoints,30));
        circle(d=20);
      }
      circle(d=holeDiameter);
  }
}

module foo() {
DIAMETER=150;

difference() {
minkowski() {
  union() {
    circle(d=10,$fn=30);
    translate([DIAMETER/2-5, 0, 0]) {
      difference() {
        arc(d=DIAMETER+10, start=170, angle=20, wedge=true, n=60);
        circle(d=DIAMETER);
      }
      // arc(d=DIAMETER, angle=[-10,0], thickness=5);
      // arc(d=DIAMETER, angle=[0,10], thickness=10);
    }
  }
  circle(2);
}
  circle(2);
}
}

//basePlateAttachment(5);
