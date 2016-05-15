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
  v0.1 Initial working version
*/

// Future ideas:
//  known board/hd U heights
//  see about designing to not need support
//  Known cutout designs: all solid, only back full open, ...
//  modular with clips: 1 side holes, 1 side clips - do for side & top/bottom
//    options: either, both, none. Only clips/holes for ends
//  port cutouts: left, right, back
//
// build: 10 x 4 or 5 x 2 x4

// START CUSTOMIZER
// Number of rack slots
Slots   = 2; // [1:12]
SlotHeight = 28.5; // Space between slots or space including slot
/* [Mount Plate Info] */
// Length
PlateX  = 112;
// Width
PlateY  = 80;
// Thickness
PlateZ  = 1.5;
/* [Info on what is mounted on plate] */

// ? CaseDesign - Yes for the 2 ends
/* [Hidden] */
Ledge = 4;
Wall  = 2;
BackWall = Wall*2;
PlateDim = [PlateX, PlateY, PlateZ];
PostHeight = 5;
BoardHeight = 18; // RPiB+
//U = BoardHeight + wall + PlateZ + PostHeight; // + headroom
// 18 + 1.5 + 5 = 24.5 // Board + plate height
// + wall*2 = 28.5

//preview[view:east, tilt:top]

/* [Hidden] */
port_height=11;
port_len=61;

//  Rack ends
//    TODO:
//      cutout designs
//      module clips (hole/clip)
module rackEnd(plateDim, wall, backWall, tolerance) {
  // clip = wall*2 // don't be relative to wall
  cube([plateDim[1]+2*wall+tolerance, plateDim[0]+wall*2+backWall, wall]);
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
module rack1U(plateDim, wall, backWall, uHeight, ledge, tolerance=0.25) {
  // ? port_height, port_len
  // Allow some freedom: +0.25 to width and space beteen slide rails ?
  //tolerance = 0.25; // add to width, uheight, & slide spacing
  // back is wall*3
  // TODO: Reduce wall thickness by wall
  boardLen    = 85; //Rpi 92 //BPi
  //portHeight  = 12; // cacl same as back height
  postHeight  = 5;
  minSlideGap = 2.15;
  gap = (plateDim[2]+tolerance < minSlideGap) ? minSlideGap - plateDim[2] : tolerance;
  clip = wall*2;

  union() {
    difference(){
      // 1 U block
      cube([plateDim[1]+2*wall+tolerance, plateDim[0]+clip+backWall, uHeight]);
      // cut out main area. Turn into a tray. No top
      translate([wall, -0.001, wall])
        cube([plateDim[1]+tolerance, plateDim[0]+clip+wall, uHeight]); // why wall*3 ? -> clip
      // cut out floor. Only leave ledge
      translate([wall+ledge, -wall, -wall])
        cube([plateDim[1]-2*ledge, plateDim[0]+wall*4, 3*wall]); // why wall*4 ? -> clip
      // cut out back. Full remove. Only edges left
      translate([wall+ledge, plateDim[0]+wall*2+0.001, wall+gap+postHeight+plateDim[2]])
        cube([plateDim[1]-ledge*2, backWall, uHeight-gap-wall-postHeight]);
      // FIX: lower sides & back slightly and increase height- Reduce by 1?
      // cut out top ports. Right hole
      translate([plateDim[1]+wall, plateDim[0]-boardLen+clip+wall, wall+plateDim[2]+gap+postHeight])
        cube([2*wall, boardLen, uHeight-gap-wall-postHeight]);
      // cut out bottom ports. Left hole
      translate([-0.001, plateDim[0]-boardLen+clip+wall, wall+plateDim[2]+gap+postHeight])
        cube([2*wall, boardLen, uHeight-gap-wall-postHeight]);
    }
    // Add slides with flex clip ends to hold plate
    translate([wall, 0, gap+wall+plateDim[2]])
      rack_slide_top(plateDim, ledge, wall, backWall, true);
    translate([wall+plateDim[1]+tolerance-ledge, 0, gap+wall+plateDim[2]])
      rack_slide_top(plateDim, ledge, wall, backWall, false);
  }
}

module rack(plateDim, wall, backWall, slots, slotHeight, ledge) {
  tolerance = 0.25;
  translate([])
    rackEnd(plateDim, wall, backWall, tolerance);
  translate([0,0,wall])
    for(i=[1:slots]){
      translate([0,0,(i-1)*slotHeight])
      rack1U(plateDim, wall, backWall, slotHeight, ledge, tolerance);
    }
  translate([0,0,slots*slotHeight+wall])
    rackEnd(plateDim, wall, backWall, tolerance);
}

// Testing
//translate([-(plateDim[0]/2 + 2*wall),-(plateDim[1]/2 + 2*wall),0]) // w/o rotate
// rotate to make printable
translate([(Slots*SlotHeight)/2,-(PlateDim[1]+2*Wall)/2,PlateDim[0]+BackWall+Wall*2])
  rotate([-90,0,90])
    rack(PlateDim, Wall, BackWall, Slots, SlotHeight, Ledge);

// END
