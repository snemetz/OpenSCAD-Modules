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
//
// build: 10 x 4 or 5 x 2 x4

// START CUSTOMIZER
// Number of rack slots
Slots   = 2; // [1:12]
SlotHeight = 23; // Space between slots or space including slot
// Length
PlateX  = 112;
// Width
PlateY  = 80;
// Mount plate thickness
PlateZ  = 1.5;
// ? CaseDesign - Yes for the 2 ends
/* [Hidden] */
Ledge = 4;
Wall  = 2;
PlateDim = [PlateX, PlateY, PlateZ];
PostHeight = 5;
BoardHeight = 18; // RPiB+
//U = BoardHeight + ledge + PlateZ + PostHeight; // + headroom
// 18 + 1.5 + 5 = 24.5 // Board + plate height

//preview[view:east, tilt:top]

/* [Hidden] */
port_height=11;
port_len=61;

//  Rack ends
//    TODO:
//      cutout designs
//      module clips (hole/clip)
module rackEnd(plateDim, wall) {
  cube([plateDim[1]+2*wall, plateDim[0]+wall*4, wall]);
}
//
//    plateDim
//    ledge
//    wall
//    side - need to move cut and end clip
module rack_slide_top(plateDim, ledge, wall, left) {
  offsetCut  = (left) ? 0 : ledge-wall/2;
  offsetClip = (left) ? wall/2 : 0;
  union() {
    difference() {
      cube([ledge,plateDim[0]+4*wall,wall]);
      // cut slot, so end can flex
      translate([offsetCut,-0.01,-0.01]) // x= 0 or wall/2
        cube([wall/2+0.02,30,wall+0.02]);
    }
    // cylinder(h,r,center) - cube
    // Add end clip
    translate([offsetClip,wall,0]) rotate([90,0,90]) //x=wall/2 or 0
      difference() {
        // height = flex clip width
        cylinder(r=wall, h=ledge-wall/2, center=false, $fn=50);
        translate([-wall,-0,-0.01])
          cube([wall*2,wall*2,wall*4]);
      }
  }
}

// both sides, back (fully open), & bottom of slide
// 1 side mostly open w/ cut in slide
// 1 side mostly open rect cutout
module rack1U(plateDim, wall, uHeight, ledge) {
  // ? port_height, port_len
  union() {
    difference(){
      // 1 U block
      cube([plateDim[1]+2*wall,plateDim[0]+wall*4,uHeight]);
      // cut out main area. Turn into a tray. No top
      translate([wall,-wall*2,wall])
        cube([plateDim[1],plateDim[0]+wall*4,uHeight]);
      // cut out floor. Only leave ledge
      translate([wall+ledge,-wall,-wall])
        cube([plateDim[1]-2*ledge,plateDim[0]+wall*3,3*wall]);
      // cut out back. Full remove. Only edges left
      translate([wall+1,plateDim[0],ledge*2+plateDim[2]])
        cube([plateDim[1]-2,5*wall,uHeight-1-2*wall]);
      // cut out top ports. Right side slot with open end
      translate([plateDim[1],-wall,wall*3.5+plateDim[2]])
        cube([5*wall,port_len+wall*4,port_height]);
      // cut out bottom ports. Left hole
      translate([-wall,wall*2,wall*3.5+plateDim[2]])
        cube([3*wall,port_len-wall*3,port_height]);
    }
    // Add slides with flex clip ends to hold plate
    translate([wall,0,2*wall*plateDim[2]])
      rack_slide_top(plateDim, ledge, wall, true);
    translate([plateDim[1]-ledge/2,0,2*wall*plateDim[2]])
      rack_slide_top(plateDim, ledge, wall, false);
  }
}

module rack(plateDim, wall, slots, slotHeight, ledge) {
  translate([])
    rackEnd(plateDim, wall);
  translate([0,0,wall])
    for(i=[1:slots]){
      translate([0,0,(i-1)*slotHeight])
      rack1U(plateDim, wall, slotHeight, ledge);
    }
  translate([0,0,slots*slotHeight+wall])
    rackEnd(plateDim, wall);
}

// Testing
//translate([-(plateDim[0]/2 + 2*wall),-(plateDim[1]/2 + 2*wall),0]) // w/o rotate
// rotate to make printable
translate([(Slots*SlotHeight)/2,-(PlateDim[1]+2*Wall)/2,PlateDim[0]+4*Wall])
  rotate([-90,0,90])
    rack(PlateDim, Wall, Slots, SlotHeight, Ledge);

// END
