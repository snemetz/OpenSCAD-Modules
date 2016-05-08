// START Thingiverse Customizer code


// Create mounting plate for:
BoardName    = "RPi3B"; // [Custom, Custom-4Post, Custom-Array, Pine64, RPi1B, RPi1B+, RPi2B, RPi3B, RPiZero, RPi1A+]
// Board locations
Placement = "Rack"; // [Center, Rack]
// Cutout design in mounting plate for known board
Design       = true; // [true, false]
/* [Mounting Plate Dimensions] */
PlateX = 112;
PlateY = 80;
PlateZ = 1.5;
/* [Standoffs Base] */
//Choose shape of the main body
BaseShape    = 3; // [1:Round, 2:Square, 3:Hex]
BaseHeight   = 6;
BaseDiameter = 5;
/* [Standoffs Top] */
//Choose style of the top section
TopStyle     = 1; // [1:Male, 2:Snap-In, 3:Flat, 4:Female, 5:Hollow]
TopHeight    = 6;
TopDiameter  = 2;
/* [PCB Board Dimensions] */
BoardX = 92;
BoardY = 60;
BoardZ = 1.25;
/* [Cutout Design] */
Image  = "RPi"; // [BPi:Banana Pi, Odroid, OPi:Orange Pi, Parallella, Pine64, RPi:Raspberry Pi]
/* [Standoffs Array] */
Rows    = 8;
OriginX = 3.5;
OffsetX = 13;
Columns = 7;
OriginY = 3.5;
OffsetY = 10;
/* [Standoffs 4 mounts] */
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
