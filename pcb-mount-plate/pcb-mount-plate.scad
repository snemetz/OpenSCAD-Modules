/*
**
** Mount Plate Module
**
*/
//
// Author: Steven Nemetz
//
// Current version GitHub: https://github.com/snemetz/OpenSCAD-Modules/tree/master/pcb-mount-plate
// Thingiverse Customizable: http://www.thingiverse.com/thing:1533164
/*
  REVISION HISTORY
  v0.4 Add support for Rack case
  v0.3 Add initial customizer code
  v0.2 Add known boards and a bunch of other work
  v0.1 Initial working version
*/
// TODO: Future Feature Ideas
//	add more designs
//  improve current designs
//  fix design resizing so work with non 4 post specs
//  add HD mounts w/ known drives and custom
//    3.5", 2.5" multiple heights
//    2.5" - SATA Data & Power, 4 side & 4 bottom mounts
//      clips - rasied off plate
//        small bumps to match both mount holes, slide drive in place
//        front flex clip t ensure stays in place
//      69.65-69.9 x 100.11-100.6 x 9,9.4
//  Storage drawers: full box, edges on front to cover rack, cutout in slide for lock clip
//    Open: top, left, right
//    Options: hole for nobe, raised label, sliding lid
//  Designs programatic: hex/honeycomb, grid, spiral

// ["BPiM1", "BPiM1+", "BPiM2", "BPiM3", "BPiM2+", "JaguarOne", "OdroidC2", "OdroidXU4", "OPiOne", "OPiPC", "OPiPlus", "OPi2", "OPiMini2", "OPiPlus2", "Pine64", "RPi1B", "RPi1B+", RPi2B, RPi3B, "RPiZero", "RPi1A+"]

// START Thingiverse Customizer code

// Create mounting plate for:
BoardName    = "RPi3B"; // [Custom, Custom-4Post, Custom-Array, BPiM1, BPiM1+, BPiM2, BPiM3, JaguarOne, OPiMini, OPiPlus, Pine64, RPi1B, RPi1B+, RPi2B, RPi3B, RPiZero, RPi1A+]
// Board locations
Placement = "Rack"; // [Center, Rack]
// Cutout design in mounting plate for known board
Design       = true; // [true, false]
/* [Mounting Plate Dimensions] */
// Length
PlateX = 112;
// Width
PlateY = 80;
// Thickness
PlateZ = 1.5;
/* [Standoffs Base] */
// Choose shape of the main body
BaseShape    = 3; // [1:Round, 2:Square, 3:Hex]
BaseHeight   = 6;
BaseDiameter = 5;
/* [Standoffs Top] */
// Choose style of the top section
TopStyle     = 1; // [1:Male, 2:Snap-In, 3:Flat, 4:Female, 5:Hollow]
TopHeight    = 6;
TopDiameter  = 2;
/* [PCB Board Dimensions] */
// Length
BoardX = 92;
// Width
BoardY = 60;
// Thickness
BoardZ = 1.25;
/* [Cutout Design] */
// Select cutout design for custom
Image  = "voronoi"; // [grid, honeycomb, spiral, voronoi, BPi:Banana Pi, Odroid, OPi:Orange Pi, Parallella, Pine64, RPi:Raspberry Pi]

// Label Text
Label  = "";
/* [Custom Array Standoffs] */
Rows    = 8;
OriginX = 3.5;
OffsetX = 13;
Columns = 7;
OriginY = 3.5;
OffsetY = 10;
/* [Custom 4 Posts Standoffs] */
Mount1X = 3.5;
Mount1Y = 3.5;
Mount2X = 3.5;
Mount2Y = 52.5;
Mount3X = 61.5;
Mount3Y = 3.5;
Mount4X = 61.5;
Mount4Y = 52.5;

/* [Hidden] */
PostBase = [BaseShape, (Placement == "Rack") ? 5 : BaseHeight, BaseDiameter];
PostTop  = [TopStyle,  TopHeight,  TopDiameter];
PlateDim = [PlateX, PlateY, PlateZ];
BoardDim = [BoardX, BoardY, BoardZ];

// END Thingiverse Customizer data

use <../standoffs/StandoffGenerator.scad>;
use <designs.scad>;
use <../patterns/design-patterns.scad>;

// If standoffs are hollow, plate needs holes
//	Parameters
//		locations: vector of x,y vectors of hole locations
//    diameter: size of the holes
//		depth: the depth of the holes in mm
// TODO: fix # of circle fragments
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
      standoff(postBase[0], postBase[1], postBase[2], postTop[0], postTop[1], postTop[2]);
  }
}

// Get design
//	Parameters
//    image: name of design to get. Require names matching known vector
module design(image) {
  // no match = [[]] - len(search)[0] == 0
  // match = undef
  // len(search([image], )[0]) != 0
  if (image == "Pine64") {design_pine64();
  } else if (len(search([image], ["BPi", "BPiM1","BPiM2+"])[0]) != 0) {
    design_bpi();
  } else if (len(search([image], ["Odroid", "OdroidC0", "OdroidC1+",  "OdroidC2", "OdroidXU4"])[0]) != 0) {
    design_odroid();
  } else if (len(search([image], ["OPi","OPiOne","OPiPC","OPiPlus","OPi2","OPiPlus2"])[0]) != 0) {
    design_opi();
  } else if (len(search([image], ["RPi","RPi1B","RPi1B+","RPiZero","RPi1A+"])[0]) != 0) {
    design_rpi();
  } else if (image == "Parallella") {
    design_parallella();
  };
}

// Setup design to merge into plate
//	Parameters
//    image: design name to place
//    locations: vector of x,y vectors of post locations
//    boardThick: thickness of the mount plate board
//    postDia: post diameter
//    z: z offset
// FIX: is max size to furthest points instead of min
//  BPi hits post
// Shrinkage not working right
// translate is a little off- without shrinkage a bit better? test more
// not for all designs - need beter way to cal translation
// start over at calc of x & y length
// then place based on image size (lengths) and post locations
//    make sure it is centered between posts
module design_placed(image, locations, boardThick, postDia, z) {
  shrinkage = postDia + postDia/2;
  len_x = max_x(locations)-min_x(locations);
  len_y = max_y(locations)-min_y(locations);
  // TODO fix translates for all program designs. Are not staying centered
  //    Check origin compared with logo images. Logo center origin, program origin lower left
  // y might be ok, x bad
  // x = -shrinkage/2 sometimes
  if (image == "grid") {
    translate([-(len_x-shrinkage)/2,shrinkage,z])
      gridCutout(len_x-shrinkage,len_y-shrinkage, 6, 1.2, boardThick+1);
  } else if (image == "honeycomb") {
    translate([-(len_x-shrinkage)/2,shrinkage,z])
      honeycombCutout(len_x-shrinkage,len_y-shrinkage, 6, 1.2, boardThick+1);
  } else if (image == "spiral") {
    translate([-(len_x-shrinkage)/2,shrinkage,z])
      spiralCutout(len_x-shrinkage,len_y-shrinkage, boardThick+1);
  } else if (image == "voronoi") {
    translate([-(len_x-shrinkage)/2,shrinkage,z])
      voronoiCutout(len_x-shrinkage,len_y-shrinkage, boardThick+1);
  } else {
    translate([len_x/2, len_y/2, z])
      resize([len_x-shrinkage, len_y-shrinkage, boardThick+1])
        rotate([0,0,90]) design(image);
  }
}

// Create mount board
//	Parameters
//    dimensions: board dimensions
//		locations: vector of x,y vectors of post locations
//		postBase: [shape, baseHeight, baseDiameter]
//    postTop: [style, topHeight, topDiameter]
module board(dimensions, locations, postBase, postTop) {
    difference() {
      union() {
        cube(dimensions, center=false);
        mountPosts(locations, dimensions[2], postBase, postTop);
      };
      if (postTop[0] == 5) { // hollow post - need holes in board
        mountHoles(locations, postTop[2], dimensions[2]*2);
      }
    }
}

// use write libary because available in customizer or text()
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text
// text("Help", size="10", font="Lobster Two");
//translate([0,0,10]) scale([1,1,20])
//text("Help", size="10", font="Liberation Sans:Style=Bold");
// Can do vertical & horizontal alignment, char spacing,
module label(txt) {
  text(txt, size="10", font="Liberation Sans:Style=Bold");
}

// Create mount plate
//	Parameters
//    plateDim: plate dimensions
//    boardDim: board dimensions
//		mountLocs: vector of x,y vectors of post locations
//    image: design to put in plate
//		postBase: [shape, baseHeight, baseDiameter]
//    postTop: [style, topHeight, topDiameter]
//    placement: board location: center (default), rack (center back)
module pcbMountPlate(plateDim, boardDim, mountLocs, rotateZ, image, postBase, postTop, placement, labelText) {
  translateY = (placement == "Rack") ? 0 : -(plateDim[0] - boardDim[0])/2;
  diff = plateDim[2] - boardDim[2];
  difference () {
    union() {
      translate ([translateY,-(plateDim[1]-boardDim[1])/2,-diff])
        cube(plateDim);
      if (rotateZ == 180 ) {
        translate([boardDim[0],boardDim[1],0])
        rotate([0,0,rotateZ])
        board(boardDim,mountLocs, postBase, postTop);
      } else {
        board(boardDim,mountLocs, postBase, postTop);
      }
    };
    // Cutout design
    //translate([boardDim[0],boardDim[1],0])
    //translate([boardDim[0]-max_x(mountLocs),0,0]) // mount to board end
    translate([boardDim[0]-max_x(mountLocs)+min_x(mountLocs)-postBase[2]/2,0,0])
      //rotate([0,0,180])
        design_placed(image, mountLocs, plateDim[2]*2, postBase[2], -diff-0.1);
    // Cutout label
    //translate([boardDim[0]+(plateDim[0]-boardDim[0]+postBase[2])/2,
    translate([boardDim[0]+(plateDim[0]-boardDim[0])/2,
            (plateDim[1] - boardDim[1])/4, -plateDim[2]/2])
      rotate([0,0,90])
        linear_extrude(plateDim[2]*2)
          resize([max_y(mountLocs)-min_y(mountLocs)-postBase[2],
                (plateDim[1] - boardDim[1])/2 - postBase[2], 1])
            label(labelText);
    if (postTop[0] == 5) { // hollow
      mountHoles(mountLocs, postTop[2], plateDim[2]*2);
    };
  };
}

//
//    placement: board location
module knownBoard(name, plate, postBase, postTop, design=true, placement) {
  // Get vector index for a board
  // will return empty vector if not found
  //	Parameters
  //    name: board name to find data for
  //    baords: vector of board data
  function findBoard(name,boards=boards) =
   (len(boards[search([name], boards)[0]]) == 2) ?
    search([boards[search([name], boards)[0]][1]], boards)[0] :
     search([name], boards)[0];

  // for generating selection list for customizer
  function getBoards(boards=boards) = [ for (board = boards) board[0] ];

  // Known boards specs
  // TODO: add rotation
  boards = [
    // [Name , rotation, [board dim], [hole dim] [mount holePos]]
    // ["name", 0, [x,y,z], [int, ext], [[x,y],[x,y],[x,y],[x,y]]],
    // [Alias, Name]
    // Ardunio
    // Banana Pi
      // TESTED
    ["BPiM1",  0, [92, 60, 1.15], [3,5.2], [[3,3],[3,57],[89,3],[89,52]]],
    ["BPiM1+", "BPiM1"],
    // M2 has 2 additional mount holes: [18.2,16.8],[76.75,28.35]
    ["BPiM2",  "BPiM1"],
    ["BPiM3",  "BPiM1"],
    ["BPiM2+", 0, [65, 65, 1.25], [], []],
    // Beaglebone
    // Jaguar boards
      // Have
    ["JaguarOne", 0, [102, 73.75, 1.6], [3,3.7], [[2.35,2.35],[2.35,99.85],[71.25,2.35],[71.25,99.85]]],
    // ODROID
    //OdroidC0
    //["OdroidC1+", [85, 56, 1.25],[]], // same as C2
      // Have
  	["OdroidC2",  0, [85, 56, 1.25], [3,5.5], [[23.5,3.6],[23.5,52.5],[81.5,3.6],[81.5,52.5]]],
  	["OdroidXU4", 0, [82, 58, 1.25], [], []],
    // Orange Pi
    ["OPi",      0, [112, 60, 1.2], [], []],
    ["OPiOne",   0, [69, 48, 1.2], [], []],
    ["OPiPC",    0, [85, 55, 1.2], [], []],
      // Have
    ["OPiPlus",  0, [108, 60, 1.2], [3,5], [[20.5,11.5],[20.5,48.3],[104.7,3.6],[104.5,56.7]]],
    ["OPi2",     0, [93, 60, 1.2], [], []],
    ["OPiMini2","OPi2"],
      // Have
    ["OPiMini",  0, [93.5, 60, 1.2], [3,5.1], [[2.8,2.8],[2.8,57.15],[90.6,2.9],[90.6,57.2]]],
    ["OPiPlus2", 0, [108, 67, 1.2], [], []],
    // Parallella
    // https://github.com/parallella/parallella-hw
    // Holes: Internal 0.125" = 3.175
    // 3.4" x 2.15" x .62" = 86.36, 54.61, 15.748
    ["Parallella", 0, [86.36, 54.61, 1.25], [3,4], []],
    // Pine
      // Have
    ["Pine64", 0, [127, 79.45, 1.2], [3,7], [[4.3,4.3],[4.3,75.2],[122.7,4.3],[122.7,75.2]]],
    // Raspberry Pi
      // REDO: calc from oposite origin
    ["RPi1B",  	180, [85, 56, 1.25], [], [[80, 43.5], [25, 17.5]]],
      // TESTED // REDO: calc from oposite origin
    ["RPi1B+",  180, [85, 56, 1.25], [2.75, 6.2], [[3.5, 3.5], [61.5, 3.5], [3.5, 52.5], [61.5, 52.5]]],
    ["RPi2B", "RPi1B+"],
    ["RPi3B", "RPi1B+"],
    ["RPiZero", 180, [65, 30, 1.25], [], [[3.5, 3.5], [61.5, 3.5], [3.5, 26.5], [61.5, 26.5]]],
    ["RPi1A+",  180, [65, 56, 1.25], [], [[3.5, 3.5], [61.5, 3.5], [3.5, 52.5], [61.5, 52.5]]]
  ];

  // Defaults
  holeInt = 3;
  holeExt = 6;

  // TODO:
  //    hole internal dia * 0.92 = top diameter - Can make a bit larger
  // Snap in shape could be better. Needs to insert better - more conic

  boardIndex = findBoard(name);
  // Customize standoffs with board data
  customTopHeight = (postTop[0] == 2) ?
    boards[boardIndex][2][2] : postTop[1];
  customPostBase = (len(boards[boardIndex][3]) == 2) ?
    [postBase[0], postBase[1], boards[boardIndex][3][1]] :
    [postBase[0], postBase[1], holeExt];
  customPostTop  = (len(boards[boardIndex][3]) == 2) ?
    // calibrate for male. Snapin might need to be smaller
    // Should tolerance be % (95) or fixed # (2.72-0.135)?  Probably -fixed 0.14
    // 3-0.15
    [postTop[0],  customTopHeight,  boards[boardIndex][3][0] * 0.95] :
    [postTop[0],  customTopHeight,  holeInt];

  // generate mount plate
  translate([-boards[boardIndex][2][0]/2,-boards[boardIndex][2][1]/2,0]) // this should be outside, but dim only known here
  pcbMountPlate(plate, boards[boardIndex][2], boards[boardIndex][4], boards[boardIndex][1],
    (design) ? boards[boardIndex][0] : "", customPostBase, customPostTop, placement, name);
}

// Create an array of post mount (post) locations (for customizer)
//	Parameters
//    row_data: [rows, x_origin, x_offset]
//    column_data: [columns, y_origin, y_offset]
function mountPoints(row_data, column_data) = [
  for (j = [1 : row_data[0]])
    for( i = [1 : column_data[0]])
      [(j-1) * row_data[2] + row_data[1], (i-1) * column_data[2] + column_data[1]]
];

/*
**
** END Mount Plate Module
**
*/

// Start Thingiverse Customizer code

//search("Custom","Custom-Array") returns [0,1,2,3,4,5]
// if len of string == len of match array
// This matchs the characters not the substring. So need to be careful with names used
// if (len("Custom") == len(search("Custom",BoardName)))
// Custom-Array, Custom-4Post
if (len("Custom") != len(search("Custom",BoardName))) { // Known board
  knownBoard(BoardName, PlateDim, PostBase, PostTop, Design, Placement);
} else if (BoardName == "Custom-4Post") { // 4 Standoffs mounts
  mountLocs = [[Mount1X,Mount1Y],[Mount2X,Mount2Y],[Mount3X,Mount3Y],[Mount4X,Mount4Y]];
  translate([-BoardDim[0]/2,-BoardDim[1]/2,0])
    pcbMountPlate(PlateDim, BoardDim, mountLocs, 0, Image, PostBase, PostTop, Placement, Label);
} else if (BoardName == "Custom-Array") { // array
  arrayX   = [Rows, OriginX, OffsetX];
  arrayY   = [Columns, OriginY, OffsetY];
  mountLocs = mountPoints(arrayX, arrayY);
  translate([-BoardDim[0]/2,-BoardDim[1]/2,0])
    pcbMountPlate(PlateDim, BoardDim, mountLocs, 0, Image, PostBase, PostTop, Placement, Label);
}

// END Customizer code
// END

// Testing

// do lots posts
//mountLocs = [[3.5, 3.5], [3.5, 12.5], [3.5, 22.5], [3.5, 32.5], [3.5, 42.5], [21.5, 3.5], [41.5, 3.5], [61.5, 3.5], [3.5, 52.5], [21.5, 52.5], [41.5, 52.5], [61.5, 52.5]];
//mountLocs = [[3.5, 3.5], [3.5, 12.5], [3.5, 22.5], [3.5, 32.5],[3.5, 42.5], [21.5, 3.5], [41.5, 3.5], [61.5, 3.5], [3.5, 52.5], [21.5, 52.5], [41.5, 52.5], [61.5, 52.5], [13.5, 22.5], [23.5, 22.5], [33.5, 22.5], [43.5, 22.5],  [50,5],[50,15],[50,30],[50,45]];

//mountLocs = mountPoints([9, 3.5, 13], [8, 3.5, 10]);
//boardDim = [110, 78, 1.25];
//plate = [112, 80, 1.5];
/*
// RPi
mountLocs = [[3.5, 3.5], [61.5, 3.5], [3.5, 52.5], [61.5, 52.5]];
boardDim = [92, 60, 1.25];
plate = [112, 80, 1.5];
// image = "Rpi";
// image = "opi";
// image = "bpi";
// image = "odroid";
// image = "parallella";
image = "Pine64";
board = "Pine64";
postBase = [1, 8, 5];
postTop = [5, 5, 2];
//translate([-boardDim[0]/2,-boardDim[1]/2,0])
//pcbMountPlate(plate, boardDim, mountLocs, image, postBase, postTop);

knownBoard(board, plate, postBase, postTop, design=true);
*/

// function flatten(l) = [ for (a = l) for (b = a) b ];


// Add libaries for customizer here
