// Standoff Module
//
// Author: Steven Nemetz
//
/*
	REVISION HISTORY
	v0.1 Added hollow style
	Initial code refactored from :
		eriqjo's Standoff Customizer v1.0
			http://www.thingiverse.com/thing:351092
		and Kevin Osborn's Snap in PCB Standoff
*/
// TODO: Future Feature Ideas
//	flanges: top and/or bottom
//	flange styles:
//	bottom styles: support all top styles - rotate 180 and translate top
//	Look at adding features from http://www.thingiverse.com/thing:79944
//		or original http://www.thingiverse.com/thing:44894

//CUSTOMIZER VARIABLES

//Type of standoff(s) to generate
Generate = 3; // [1:Single, 2:Array-Same, 3:Array-Samples]
//Choose shape of the main body
Shape = 3; // [1:Round, 2:Square, 3:Hex]
//Select height of the main body,  mm
BaseHeight = 15; // [0:50]
//Select diameter of the main body, mm
BaseDia = 6; // [0:30]
//Choose style of the top section
Style = 1; // [1:Male, 2:Snap-In, 3:Flat, 4:Female, 5:Hollow]
//Select height of the top, mm
TopHeight = 4; // [2:20]
//Select diameter of the top, mm
TopDia = 2; // [1:25]
//For array: Space between standoffs, X mm
X_Offset = 15; // [2:30]
//For array: Space between standoffs, Y mm
Y_Offset = 10; // [2:30]

//CUSTOMIZER VARIABLES END

// Internal variables
Shapes = [1:3]; // All valid shapes
Styles = [1:5]; // All valid styles

$fn=50; // number of facet fragments for arcs
// Parameters: style, height, diameter, Thread_Height
module standoffTop(style, baseHeight, topHeight, diameter) {
	radius = diameter/2;
	if (style == 1) { //male
		translate([0,0, baseHeight + topHeight/2 - 0.1])
			cylinder(topHeight + 0.1, r = radius, $fn = 50, center = true);
	} else if (style == 2) { // snapin
		$fn=50; // number of facet fragments for arcs
		// large top height - this is above base
		notchW = radius/1.5;//width of the flexy notch in terms of peg radius
		translate([0,0, baseHeight - 0.1]) // -2 needs to be a calc
			difference() {
				union() {
					// top standoff
					cylinder(r= radius,h = topHeight+1); //master peg
					// underside slant
					translate([0,0,topHeight])cylinder(r1=radius,r2= radius+.5, h =1);// relief for overhang
					// top slant
					translate([0,0,topHeight+1])cylinder(r1=radius+.5,r2= radius-.25, h =1); // insertion cone
					// base - Will remove
					//cylinder(r = (pegR)+1, h=baseHeight); //standoff is always 2mm> post size (Diameter)
					} //union
				// Internal cylinder cutout
				cylinder(r= radius-.5, h = topHeight+3);
				translate([-(diameter+2)/2,-notchW/2,-0.1])cube([diameter+2,notchW,topHeight+2.2]);//notch for insertion flex
			} //difference
	} else if (style == 3) { // flat - No top
	} else if (style == 4) { // female
		translate([0,0, baseHeight - topHeight/2 + 0.1])
			cylinder(topHeight + 0.1, r = radius, $fn = 12, center = true);
	} else if (style == 5) { // hollow
		translate([0,0, baseHeight/2])
			cylinder(baseHeight + 0.1, r = radius, $fn = 50, center = true);
	}
};
// Parameters: shape, height, diameter
module standoffBase(shape, height, diameter) {
	radius = diameter/2;
	if (shape == 1) { // round
		translate([0, 0, height/2])
			cylinder(height, r = radius, center = true, $fn = 50);
	} else if (shape == 2) { // square
		translate([0,0, height/2])
			cube([diameter, diameter, height], center = true);
	} else if (shape == 3) { // hex
		cylinder(h = height, r = radius, center = false, $fn = 6);
	}
};
// Parameters: shape, style, Body_Diameter, Body_Height, Thread_Height, Thread_Dia
module standoff(shape, baseHeight, baseDiameter, style, topHeight, topDiameter) {
	if (style == 1 || style == 2) { // male or snap-in
		union() {
			standoffBase(shape, baseHeight, baseDiameter);
			standoffTop(style, baseHeight, topHeight, topDiameter);
		}
	} else if (style == 4 || style == 5) { // female or hollow
		difference() {
			standoffBase(shape, baseHeight, baseDiameter);
			standoffTop(style, baseHeight, topHeight, topDiameter);
		}
	} else if (style==3) { // flat - no top
		standoffBase(shape, baseHeight, baseDiameter);
	}
};

function range2vector(r) = [ for (i=r) i];

//
ShapesV = range2vector(Shapes);
StylesV = range2vector(Styles);
if (Generate == 1) { // single
	standoff(Shape,BaseHeight,BaseDia,Style,TopHeight,TopDia);
} else if (Generate == 2) { // array all same
} else if (Generate == 3) { // array Samples
	translate([-(X_Offset * (len(StylesV)+1))/2, -(Y_Offset * (len(ShapesV)+1))/2, 0])
		union(){
			for (shape = Shapes) {     // Rows of styles = row of a shape
				translate([0,shape * Y_Offset,0])
					for( style = Styles) {   // Columns of shapes = column of a style
						translate([style * X_Offset,0,0])
							standoff(shape, BaseHeight, BaseDia, style, TopHeight, TopDia);
					} // for
			} // for
		}; // union
};

// END
