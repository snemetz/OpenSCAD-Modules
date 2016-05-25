/*
**
** Rack Module
**
*/
// Generic computer rack by using mounting plates that can support any small computer boards
//
// Author: Steven Nemetz
//
// Current version GitHub: https://github.com/snemetz/OpenSCAD-Modules/tree/master/cluster-rack
// Thingiverse Customizable: http://www.thingiverse.com/thing:1538381
/*
  REVISION HISTORY
  v0.2 Add cutout designs and cutout controls
  v0.1 Initial working version
*/

// Future ideas:
//  known board/hd U heights
//  see about designing to not need support
//  modular with clips: 1 side holes, 1 side clips - do for side & top/bottom
//    options: either, both, none. Only clips/holes for ends
//
// build: 10 x 4 or 5 x 2 x4

// START CUSTOMIZER DATA

// Number of rack slots
Slots      = 2; // [1:12]
SlotHeight = 28.5; // Space between slots or space including slot
/* [Mount Plate Info] */
// Length
PlateX  = 112;
// Width
PlateY  = 80;
// Thickness
PlateZ  = 1.5;
/* [Info on what is mounted on plate] */

/* [Case Designs] */
// Left side cutout design
LeftDesign  = "Open"; // [Open, Grid, Honeycomb, Solid, Voronoi]
// Length: only applies to Open design
LeftLength  = 85;
// Right side cutout design
RightDesign = "Open"; // [Open, Grid, Honeycomb, Solid, Voronoi]
// Length: only applies to Open design
RightLength = 85;
// Back cutout design
BackDesign  = "Open"; // [Open, Grid, Honeycomb, Solid, Voronoi]
// Top and Bottom End cutout design
EndDesign   = "Solid"; // [Grid, Honeycomb, Solid, Voronoi]

/* [Hidden] */
Ledge = 4;
Wall  = 2;
BackWall    = Wall*2;
Designs     = [LeftDesign, BackDesign, RightDesign, EndDesign];
DesignLens  = [LeftLength, RightLength];
PlateDim    = [PlateX, PlateY, PlateZ];
PostHeight  = 5;
BoardHeight = 18; // RPiB+
//U = BoardHeight + wall + PlateZ + PostHeight; // + headroom
// 18 + 1.5 + 5 = 24.5 // Board + plate height
// + wall*2 = 28.5

//preview[view:east, tilt:top]

port_height=11;
port_len=61;

// END CUSTOMIZER DATA
use <../patterns/design-patterns.scad>;

// Design Cutouts
module design(design, width, length, thickness) {
  //echo(str("D:",design,"\tW:",width,"\tL:",length,"\tT:",thickness));
  if (design == "Open") {
    cube([width, length, thickness]);
  } else if (design == "Grid") {
    translate([width/2, length/2, 0])
      gridCutout(width, length, 6, 1.8, thickness);
  } else if (design == "Honeycomb") {
    translate([width/2, length/2, 0])
      honeycombCutout(width, length, 6, 1.2, thickness);
  } else if (design == "Voronoi") {
    translate([width/2, length/2, 0])
      voronoiCutout(width, length, thickness);
  }
}

//  Rack ends
//    TODO:
//      cutout designs
//      module clips (hole/clip)
module rackEnd(plateDim, wall, backWall, ledge, tolerance, design) {
  difference () {
    // clip = wall*2 // don't be relative to wall
    cube([plateDim[1]+2*wall+tolerance, plateDim[0]+wall*2+backWall, wall]);
    translate([wall+ledge, 2*wall, -0.001])
      design(design, plateDim[1]-2*ledge, plateDim[0], 2*wall);
  }
}
//
//    plateDim
//    ledge
//    wall
//    side - need to move cut and end clip
module rack_slide_top(plateDim, ledge, wall, backWall, left) {
  // TODO: make thicker or widther top slide to make flex clip stronger
  // clip = wall*2 // r = wall // don't be relative to wall
  cutWidth = 0.5;
  cutLen   = 30;
  offsetCut  = (left) ? 0 : ledge-cutWidth;
  offsetClip = (left) ? cutWidth : 0;
  union() {
    difference() {
      cube([ledge, plateDim[0]+wall*2+backWall, wall]);
      // cut slot, so end can flex
      translate([offsetCut, -0.01, -0.01])
        cube([cutWidth, cutLen, wall+0.02]);
    }
    // Add end clip
    translate([offsetClip,wall,0]) rotate([90,0,90])
      difference() {
        // height = flex clip width
        cylinder(r=wall, h=ledge-cutWidth, center=false, $fn=50);
        translate([-wall, -0, -0.01])
          cube([wall*2, wall*2, wall*4]);
      }
  }
}

// both sides, back (fully open), & bottom of slide
// 1 side mostly open w/ cut in slide
// 1 side mostly open rect cutout
//  designs [left, back, right, ends]
//  designLens [left, right]
module rack1U(plateDim, wall, backWall, uHeight, ledge, tolerance=0.25, designs, designLens) {
  // ? port_height, port_len
  // Allow some freedom: +0.25 to width and space beteen slide rails ?
  //tolerance = 0.25; // add to width, uheight, & slide spacing
  // back is wall*3
  // TODO: Reduce wall thickness by wall
  //boardLen    = 85; //Rpi 92 //BPi
  //portHeight  = 12; // cacl same as back height
  postHeight  = 5;
  minSlideGap = 2.15;
  gap = (plateDim[2]+tolerance < minSlideGap) ? minSlideGap - plateDim[2] : tolerance;
  clip = wall*2;

  union() {
    difference(){
      // 1 U block
      cube([plateDim[1]+2*wall+tolerance, plateDim[0]+clip+backWall, uHeight]);
      // Main Area cut out. Turn into a tray. No top or front
      translate([wall, -0.001, wall])
        cube([plateDim[1]+tolerance, plateDim[0]+clip+wall, uHeight]); // why wall*3 ? -> clip
      // Floor cut out. Only leave ledge
      translate([wall+ledge, -wall, -wall])
        cube([plateDim[1]-2*ledge, plateDim[0]+wall*4, 3*wall]); // why wall*4 ? -> clip
      // Back cut out
      translate([wall+ledge, plateDim[0]+wall*2+0.001, wall+gap+postHeight+plateDim[2]])
        rotate([0,-90,-90])
          design(designs[1], uHeight-gap-wall-postHeight, plateDim[1]-ledge*2, 2*backWall);
      // FIX: lower sides & back slightly and increase height- Reduce by 1?
      // Right cut out
      rightLen = (designs[2] == "Open") ? designLens[1] : plateDim[0];
      translate([plateDim[1]+2*wall+1, plateDim[0]-rightLen+clip+wall, wall+plateDim[2]+gap+postHeight])
        rotate([0,-90,0])
          design(designs[2], uHeight-gap-wall-postHeight, rightLen, 2*wall);
      // Left cut out
      leftLen = (designs[0] == "Open") ? designLens[0] : plateDim[0];
      translate([wall+0.001, plateDim[0]-leftLen+clip+wall, wall+plateDim[2]+gap+postHeight])
        rotate([0,-90,0])
          design(designs[0], uHeight-gap-wall-postHeight, leftLen, 2*wall);
    }
    // Add slides with flex clip ends to hold plate
    translate([wall, 0, gap+wall+plateDim[2]])
      rack_slide_top(plateDim, ledge, wall, backWall, true);
    translate([wall+plateDim[1]+tolerance-ledge, 0, gap+wall+plateDim[2]])
      rack_slide_top(plateDim, ledge, wall, backWall, false);
  }
}

module rack(plateDim, wall, backWall, slots, slotHeight, ledge, designs, designLens) {
  tolerance = 0.25;
  translate([])
    rackEnd(plateDim, wall, backWall, ledge, tolerance, designs[3]);
  translate([0,0,wall])
    for(i=[1:slots]){
      translate([0,0,(i-1)*slotHeight])
      rack1U(plateDim, wall, backWall, slotHeight, ledge, tolerance, designs, designLens);
    }
  translate([0,0,slots*slotHeight+wall])
    rackEnd(plateDim, wall, backWall, ledge, tolerance, designs[3]);
}

// Testing
//translate([-(plateDim[0]/2 + 2*wall),-(plateDim[1]/2 + 2*wall),0]) // w/o rotate
// rotate to make printable
translate([(Slots*SlotHeight)/2,-(PlateDim[1]+2*Wall)/2,PlateDim[0]+BackWall+Wall*2])
  rotate([-90,0,90])
    rack(PlateDim, Wall, BackWall, Slots, SlotHeight, Ledge, Designs, DesignLens);

// END
