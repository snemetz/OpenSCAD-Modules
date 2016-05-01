// Mount Plate Module
//
// Author: Steven Nemetz
//
// Current version: https://github.com/snemetz/OpenSCAD-Modules/tree/master/pcb-mount-plate
// TODO: Customizable: http://www.thingiverse.com/thing:
/*
	REVISION HISTORY
	v0.1 Initial working version
*/
// TODO: Future Feature Ideas
//	add more designs
//  improve current designs
//  none of board data works. Figure out how to store in module
//  plate may need some changes as case for it to mount into is designed

//CUSTOMIZER VARIABLES

//CUSTOMIZER VARIABLES END

/* [Hidden] */

use <../standoffs/StandoffGenerator.scad>;
use <designs.scad>;

// If standoffs are hollow, plate needs holes
//	Parameters
//		locations: vector of x,y vectors of hole locations
//    diameter: size of the holes
//		depth: the depth of the holes in mm
module mountHoles(locations, diameter = 2.8, depth = 5) {
  for(holePos = locations) {
    translate([holePos[0], holePos[1], -depth/2+0.1]) cylinder(d=diameter, h=depth);
  }
}

// Create and place standoffs
//	Parameters
//		locations: vector of x,y vectors of post locations
//		boardThick: thickness of the mount plate board
//		postBase: [shape, baseHeight, baseDiameter]
//    postTop: [style, topHeight, topDiameter]
module mountPosts(locations, boardThick, postBase, postTop) {
  for (postPos = locations) {
    translate([postPos[0], postPos[1], boardThick])
      standoff(postBase[0], postBase[1], postBase[2], postTop[0], postTop[2], postTop[3]);
  }
}

// Get design
//	Parameters
//    image: name of design to get
module design(image) {
  if (image == "pine64") {design_pine64();
  } else if (image == "rpi") {design_rpi();
  } else if (image == "opi") {design_opi();
  } else if (image == "parallella") {design_parallella();};
}

// Setup design to merge into plate
//	Parameters
//    image: design name to place
//    locations: vector of x,y vectors of post locations
//    boardThick: thickness of the mount plate board
//    postDia: post diameter
//    z: z offset
module design_placed(image, locations, boardThick, postDia, z) {
  shrinkage = postDia/2;
  len_x = max_x(locations)-min_x(locations);
  len_y = max_y(locations)-min_y(locations);
  translate([len_x/2+shrinkage,len_y/2+shrinkage,z])
  resize([len_x-shrinkage,len_y-shrinkage,boardThick+1])
    design(image);
}

// Create mount board
//	Parameters
//    dimensions: board dimensions
//		locations: vector of x,y vectors of post locations
//		postBase: [shape, baseHeight, baseDiameter]
//    postTop: [style, topHeight, topDiameter]
module board(dimensions, locations, postBase, postTop) {
  if (postTop[0] == 5) { // hollow post - need holes in board
    difference() {
      union() {
        cube(dimensions, center=false);
        mountPosts(locations, dimensions[2], postBase, postTop);
      };
      mountHoles(locations, postTop[2], dimensions[2]*2);
    }
  } else {
    union() {
      cube(dimensions, center=false);
      mountPosts(locations, dimensions[2], postBase, postTop);
    }
  }
}

// Create mount plate
//	Parameters
//    plateDim: plate dimensions
//    boardDim: board dimensions
//		mountLocs: vector of x,y vectors of post locations
//    image: design to put in plate
//		postBase: [shape, baseHeight, baseDiameter]
//    postTop: [style, topHeight, topDiameter]
module pcbMountPlate(plateDim, boardDim, mountLocs, image, postBase, postTop) {
  diff = plateDim[2] - boardDim[2];
  difference () {
    union() {
      translate ([-(plateDim[0] - boardDim[0])/2,-(plateDim[1]-boardDim[1])/2,-diff])
        cube(plateDim);
      board(boardDim,mountLocs, postBase, postTop);
    };
    design_placed(image, mountLocs, plateDim[2]*2, postBase[1], -diff-0.1);
    if (postTop[0] == 5) { // hollow
      mountHoles(mountLocs, postTop[2], plateDim[2]*2);
    };
  };

}

// Testing
// RPi
mountLocs = [[3.5, 3.5], [61.5, 3.5], [3.5, 52.5], [61.5, 52.5]];
boardDim = [92, 60, 1.25];
plate = [112, 80, 1.5];
// image = "rpi";
// image = "opi";
// image = "parallella";
image = "pine64";
postBase = [1, 8, 5];
postTop = [5, 5, 2];

translate([-boardDim[0]/2,-boardDim[1]/2,0])
pcbMountPlate(plate, boardDim, mountLocs, image, postBase, postTop);

// END

// beyond here i sboard data
// still figuring out how to get this into module in a usable and maintainable way

boards = [
 // Name , dim, mount holePos
 // Alias, Name
// ["name", [x,y,z],[[x,y],[x,y],[x,y],[x,y]]],
// ["name2", [x,y,z],[[x,y],[x,y],[x,y],[x,y]]],
 ["name3","name2"],
 ["RPi1B+",[85, 56, 1.25],[[3.5, 3.5], [61.5, 3.5], [3.5, 52.5], [61.5, 52.5]]],
 ["RPi2B", "RPi1B+"],
 ["RPi3B", "RPi1B+"],
 ];
// May not work
/*
function dim (name="RPi3B") = (
	// Can't have for here ?
  for (board = boards) {
    if (len(board) == 2) {find = board[1]}
		else {find = board[0]}
		if (find == name) { dims = board[1] }
	}
	dims
)
*/
// echo(dim());

// Sample part for test fitting
//translate([-7.5,-7.5,0])cube([15,15,1]);
//translate([0,0,1])boardmount(HoleD = 2.7, BoardThick = 1.70, lift=5);

//get vector of [x,y] vectors of locations of mounting holes based on Pi version
function HoleLocations (board="3B") =
	(board=="1A+" || board=="1B+" || board=="2B" || board=="3B") ?
		[[3.5, 3.5], [61.5, 3.5], [3.5, 52.5], [61.5, 52.5]] : //pi 1B+, 2B, 3B
	(board=="Zero") ?
		[[3.5, 3.5], [61.5, 3.5], [3.5, 26.5], [61.5, 26.5]] : //pi zero
	(board=="1B") ?
		[[80, 43.5], [25, 17.5]] :
	[]; //invalid board

// get vector of [x,y,z] dimensions of board
//  dimensions are for PCB only, not ports or anything else
function boardDim (board="RPi3B") =
  // Banana Pi
	(board == "BPiM1" || board == "BPiM1+" || board == "BPiM2" || board == "BPiM3") ?
	  [92, 60, 1.25] :
  (board == "BPiM2+") ?
    [65, 65, 1.25] :
	(board == "JaguarOne") ?
	  [101.9, 64.5, 1.6] :
	// Orange Pi
	(board == "OPiOne") ?
	  [69, 48, 1.25] :
	(board == "OPiPC") ?
	  [85, 55, 1.25] :
	(board == "OPiPlus") ?
	  [108, 60, 1.25] :
	(board == "OPi2" || board == "OPiMini2") ?
	  [93, 60, 1.25] :
	(board == "OPiPlus2") ?
	  [108, 67, 1.25] :
	// ODROID
	(board == "OdroidC2") ?
	  [85, 56, 1.25] :
	(board == "OdroidXU4") ?
	  [82, 58, 1.25] :
	(board == "Pine64") ?
	  [127, 79, 1.25] :
	// Raspberry Pi
	(board == "RPi1B" || board=="RPi1B+" || board=="RPi2B" || board=="RPi3B") ?
		[85, 56, 1.25] :
	(board == "RPiZero") ?
		[65, 30, 1.25] :
	(board == "RPi1A+") ?
		[65, 56, 1.25] :
	[0,0,0];  // Unknown board
