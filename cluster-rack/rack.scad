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
  v0.3 Add modular connectors
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
// Add slot to allow units to connect to each other
Modular    = true; // [true, false]
/* [Mount Plate Info] */
// Length
PlateX  = 112;
// Width
PlateY  = 80;
// Thickness
PlateZ  = 1.5;
// Standoff posts height
PostHeight  = 5;
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
BoardHeight = 18; // RPiB+
//U = BoardHeight + wall + PlateZ + PostHeight; // + headroom
// 18 + 1.5 + 5 = 24.5 // Board + plate height
// + wall*2 = 28.5

//preview[view:east, tilt:top]
//port_height=11;
//port_len=61;

// END CUSTOMIZER DATA
use <../patterns/design-patterns.scad>;

// Design Cutouts
//	Parameters
//    design    : design name
//    width     : design width
//    length    : design length
//    thickness : design thickness
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

module connectorSlot() {}
// Parameters: wall thickness,
// TODO: change all to vars & Parameters & calc
module connectorClip(x,y,z)  {
  thickness = 2;
  union(){
    // back support - will be on solid wall, but might need to make thicker
    translate([0, 0, -z*1.5+thick/2])
      cube(size=[thickness, y, z*3]); // z too much
    //translate([0,y/2,0]) rotate ([0,90,0]) cylinder(h=z/2,r=y/2);
    // wall thickness to clip
    cube(size=[x, y, thickness]);
    // height of clip end
    translate([x, 0, 0])
      cube(size=[thickness, y, z]);
    // slant end for easier insertion
    translate([x, 0, z]) resize([thickness, y, thickness])
      rotate([180, -90, 90])
        linear_extrude(height=1)
          polygon([[0, 0], [0, 2.0], [1.5, 2.0]]);
  }
}
module dovetail(width=9, height=10, male=true) {
  w= (male==true) ? width*0.975 : width;
  translate([2.4, 0, 0])
    union(){
      rotate([0, 0, -30])
        translate([-w/2, -sqrt(3)*w/6, -height/2])
          linear_extrude(height=height)
            polygon(points=[[0,0],[w,0],[w/2,sqrt(3)*w/2]]);
      translate([-4.5, 0, 0])
        cube([4.2, width*1.5, height], center=true);
    }
}
//clip(7,20,20);
// Redo all calc if use. Need absolute sizing

//  Create a rack end
//    TODO:
//      module clips (hole/clip) to connect cases together
//      force design to Solid if clips are selected
//      look at possible connector designs
//        clip, lego, external clips (might be best - like CD drawers), slide joint(dovetail?)
//      Add space on ends to give space for modular connectors
//        union difference cube (same size as end) cube (center cutout just leave 4 edges)
//	Parameters
//    plateDim  : [x, y, z]
//    wall      : wall thickness
//    backWall  : back wall thickness
//    ledge     : rack slide width
//    tolerance : printer tolerance gap to ensure smooth sliding
//    design    : design name
module rackEnd(plateDim, wall, backWall, ledge, tolerance, design) {
  difference () {
    // clip = wall*2 // don't be relative to wall
    cube([plateDim[1]+2*wall+tolerance, plateDim[0]+wall*2+backWall, wall]);
    translate([wall+ledge, 2*wall, -0.001])
      design(design, plateDim[1]-2*ledge, plateDim[0], 2*wall);
  }
}
module modularSpacer(plateDim, wall, backWall, ledge, tolerance, height) {
  // create 4 sides to match walls
  // FIX: front wall may be too thick (4mm? reduce to 2 or 3?)
  difference () {
    cube([plateDim[1]+2*wall+tolerance, plateDim[0]+wall*2+backWall, height]); // z = spacer height
    translate([wall, backWall, -0.001])
      cube([plateDim[1]+tolerance, plateDim[0]+wall, height*2]); // z = spacer height *2
  }
}
// Create the top half of the rack slide
//	Parameters
//    plateDim  : [x, y, z]
//    ledge     : rack slide width
//    wall      : wall thickness
//    backWall  : back wall thickness
//    left      : Is this the left side? (Boolean)
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

// Create 1 unit of a rack case
//	Parameters
//    plateDim  : [x, y, z]
//    wall      : wall thickness
//    backWall  : back wall thickness
//    uHeight   : height of 1 unit
//    ledge     : rack slide width
//    tolerance : printer tolerance gap to ensure smooth sliding
//    designs   : Vector of design names [left, back, right, ends]
//    designLens: [left, right]
module rack1U(plateDim, wall, backWall, uHeight, ledge, tolerance=0.25, designs, designLens) {
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

// Cut slots for modular connection clips
//	Parameters
//    plateDim  : [x, y, z]
//    wall      : wall thickness
//    backWall  : back wall thickness
//    clip      : [clipLen, clipHeight, clipWall]
//    tolerance : side wall tolerance
//    top       : is placement of slots for top or bottom?
module modularSlots(plateDim, wall, backWall, clip, tolerance, top) {
  // TODO: fix exact placement
  offsetZ = (top) ? wall+clip[1]/2 : -clip[1]/2;
  // Side Modular Slots
  for (x=[wall+clip[2]-0.001, plateDim[1]+wall+clip[2]+2*tolerance]) {
    for (y=[10, plateDim[0]+backWall+2*wall-10-clip[0]]) {
      translate([x, y, offsetZ]) rotate([0, 0, 90])
        cube([clip[0], clip[2]+wall, clip[1]]);
    }
  }
  // Back Modular Slots
  for (x=[10, plateDim[1]+wall*2+tolerance*2-clip[0]-10]) {
    translate([x, plateDim[0]+backWall+wall-clip[2]+0.001, offsetZ])
      cube([clip[0], clip[2]+wall, clip[1]]);
  }
}

// Create a rack case
//	Parameters
//    plateDim  : [x, y, z]
//    wall      : wall thickness
//    backWall  : back wall thickness
//    slots     : number of rack slots
//    slotHeight: height of 1 unit
//    ledge     : rack slide width
//    designs   : Vector of design names [left, back, right, ends]
//    designLens: [left, right]
// ADD: modular
//  TODO:
//    add spacing at ends for clip space - create module for
//      match top wider part of clip depth = clipHeight/2
//    add cutouts for clips - if using external clips
//      12.5 from end X, 5 from end y
//      cut 12.1 x (clipLen+tolerance), clipHeight/2 z - match top wider part of clip depth
module rack(plateDim, wall, backWall, slots, slotHeight, ledge, designs, designLens, modular) {
  tolerance  = 0.25;
  clipHeight = 8;
  clipLen    = 11.5;
  clipWall   = 1.8;
  clip       = [clipLen, clipHeight, clipWall];
  translate([])
    difference() {
      union() {
        rackEnd(plateDim, wall, backWall, ledge, tolerance, designs[3]);
        translate([0,0,wall])
          modularSpacer(plateDim, wall, backWall, ledge, tolerance, clipHeight);
      }
      if (modular) modularSlots(plateDim, wall, backWall, clip, tolerance, false);
    }
  translate([0,0,wall+clipHeight])
    for(i=[1:slots]){
      translate([0,0,(i-1)*slotHeight])
      rack1U(plateDim, wall, backWall, slotHeight, ledge, tolerance, designs, designLens);
    }
  translate([0,0,slots*slotHeight+wall+clipHeight])
    difference() {
      union() {
        modularSpacer(plateDim, wall, backWall, ledge, tolerance, clipHeight);
        translate([0,0,clipHeight])
          rackEnd(plateDim, wall, backWall, ledge, tolerance, designs[3]);
      }
      if (modular) modularSlots(plateDim, wall, backWall, clip, tolerance, true);
    }
}

// External clips
module clipEndWall(clipLen, clipHeight, clipWall) {
  // add bumb to end to lock in place
  // round/slant top edge for easier insert ?
  rotate ([90,0,0])
    difference() {
      cube([clipLen, clipHeight, clipWall]);
      translate([clipLen, 5, -0.001]) rotate([0,0,45]) cube(5);
    }
}
module clipEnd(clipLen=11.5, clipHeight=8, clipWall=1.8, caseWall=2, center=false) {
  clipWidth = caseWall*2 + clipWall*2;
  centerCut = (center) ? 1 : 2;
  // sides
  translate([0,clipWall,0]) clipEndWall(clipLen, clipHeight, clipWall);
  translate([0,clipWidth,0]) clipEndWall(clipLen, clipHeight, clipWall);
  // top - 2
  difference() {
    cube([clipLen, clipWidth, clipHeight / 2]); // z ? clipHeight / 2 = 4 ~ (1.925) 4.15 ?
    // Cut center
    translate([1.4, clipWall+caseWall*0.25, centerCut])
      cube([clipLen, caseWall*1.5, clipHeight]);
    // Cut end
    translate([clipLen, clipWall+caseWall*0.25, 0])
      rotate([0,-45,0])
        cube(caseWall*1.5);
  }
}
module clipCenter(caseWall) {
  caseWall  = 2;
  clipWall  = 1.8;
  clipWidth = caseWall*2+clipWall*2;
  rotate([0,-90,0])
    clipEnd(caseWall=caseWall, center=true);
  translate([0, clipWidth, 0])
    rotate([0,-90,180])
      clipEnd(caseWall=caseWall, center=true);
}

// Customizer code

// rotate to make printable
//translate([(Slots*SlotHeight)/2,-(PlateDim[1]+2*Wall)/2,PlateDim[0]+BackWall+Wall*2])
  //rotate([-90,0,90])
    rack(PlateDim, Wall, BackWall, Slots, SlotHeight, Ledge, Designs, DesignLens, Modular);

// END
