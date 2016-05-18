/*
**
** Design Patterns
**
*/
// Programmatic design patterns
//
// Author: Steven Nemetz
//
// Current version GitHub: https://github.com/snemetz/OpenSCAD-Modules/
// Thingiverse Customizable: http://www.thingiverse.com/thing:
/*
  REVISION HISTORY
  v0.1 Hex/Honeycomb & Grid patterns
*/
// TODO:
//    spiral
//    Hex add option for cropped at box edge (cut hexes)

Width     = 40;
Height    = 40;
Diameter  = 6;
Spacing   = 1.2;
Thickness = 2;

module gridHoles(width, height, cubeSize, spacing, thick) {
  offset = cubeSize + spacing;
  cols = width / offset;
  rows = height / offset;
  translate([0, -thick, 0])
    for (i=[0:rows-1]) {
      for (j=[0:cols-1]) {
        translate([j*offset, 0, i*offset])
          cube([cubeSize, thick, cubeSize]);
      }
    }
}
module hexHoles(width, height, hexDia, spacing, thick) {
  // If boxed: add 1 to columns, then crop (x) left & right
  hOffset = hexDia + spacing;
  vOffset = sqrt(pow(hOffset,2)-pow(hOffset/2,2));
  cols = width / hOffset;
  rows = height / vOffset;
  translate([hexDia/2, 0, hexDia/2])
    for (i=[0:rows-1]) {
      for (j=[0:cols-1]) {
        translate([j*hOffset+i%2*(hOffset/2), 0, i*vOffset])
          rotate([90,90,0]) cylinder(h=thick, r=hexDia/2, $fn=6);
      }
    }
}

//hexHoles(Width, Height, Diameter, Spacing, Thickness);
gridHoles(Width, Height, Diameter, Spacing, Thickness);
