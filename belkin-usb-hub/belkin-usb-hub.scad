
// Models of Belkin USB hubs
hubLen=150;

// Model of Belkin USB hub model F4U039
module f4u039(hubLen) {
  // This should be good
  // Total len: 25.9
  union() {
    // Wide end
    translate([0, -0.75, 0])
      cylinder(hubLen, r=8.13, $fn = 50);
    // Narrow end
    translate([-11, 0, 0])
      cylinder(hubLen, r=7.38, $fn = 50);
    // Flat top
    translate([-18.37, 0.6, 0])
      cube([19, 6.78, hubLen]);
    // Add botton angle cube
    translate([-12, -7.3, 0])
      rotate([0, 0, -8])
        cube([12, 6, hubLen]);
  }
}

// Model F4U041
module f4u041(hubLen) {
  // Same as f4u039 but more distance between cylinders
  // Large end is Same
  // Small end is Same
}

// Then print a short piece and check
difference() {
    translate([-20, -10, 0.001]) cube([30, 20, 4]);
    f4u039(hubLen);
}
