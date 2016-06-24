
// Model of Belkin USB hub F4U039
hubLen=150;

module f4u039(hubLen) {
  union() {
    // Wide end
    translate([0, -5, 0]) cylinder(hubLen, r=13, $fn = 50);
    // Narrow end
    translate([-26, 0, 0]) cylinder(hubLen, r=8, $fn = 50);
    // Flat top
    translate([-34, 0, 0]) cube([34, 8, hubLen]);
    // Fill center
    translate([-26, -8, 0]) cube([26, 8, hubLen]);
    // Add botton angle cube ?
    translate([-28, -8, 0]) rotate([0, 0, -21]) cube([28, 8, hubLen]);
  }
}

// Model F4U041
// Same but more distance between cylinders

// Then print a short piece and check
//translate([0,50,0]) f4u039(150);
difference() {
    translate([-40, -25, 0.001]) cube([60, 40, 10]);
    f4u039(150);
}
