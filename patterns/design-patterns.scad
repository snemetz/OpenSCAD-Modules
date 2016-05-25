/*
**
** Design Patterns Library
**
*/
// Programmatic design patterns
//
// Author: Steven Nemetz
//
// Designs are centered on the origin
//
// Current version GitHub: https://github.com/snemetz/OpenSCAD-Modules/
// Thingiverse Customizable: http://www.thingiverse.com/thing:
/*
  REVISION HISTORY
  v0.2 Add spiral & voronoi
  v0.1 Hex/Honeycomb & Grid patterns
*/
// TODO:
//    round holes w/ box option ??
//  More Design Patterns:
//    look at Fibonacci
//    snowflake- can have multiple ones - issues when not square/round
//    convex pentagons - can have multiple ones

Width     = 40;
Height    = 40;
Diameter  = 6;
Spacing   = 1.2;
Thickness = 2;

// Library Modules
//    standardize Parameters & resulting object size, location, etc
// gridCutout(width, height, cubeSize, spacing, thick)
// honeycombCutout(width, height, diameter, spacing, thick)
// spiralCutout(width, height, thick)
// voronoiCutout(width, height, thick)

/*
** Grid
*/
module gridCutout(width, height, cubeSize, spacing, thick) {
  offset = cubeSize + spacing;
  cols = width / offset;
  rows = height / offset;
  translate([-width/2, -height/2, 0])
  resize([width, height, 0])
    for (i=[0:rows-1]) {
      for (j=[0:cols-1]) {
        translate([j*offset, i*offset, 0])
          cube([cubeSize, cubeSize, thick]);
      }
    }
}

/*
** Honeycomb
*/
module hexHoles(width, height, hexDia, spacing, thick) {
  hOffset = hexDia + spacing;
  vOffset = sqrt(pow(hOffset,2)-pow(hOffset/2,2));
  cols = width / hOffset;
  rows = height / vOffset;
  translate([hexDia/2, hexDia/2, 0])
    for (i=[0:rows-1]) {
      for (j=[0:cols-1]) {
        translate([j*hOffset+i%2*(hOffset/2), i*vOffset, 0])
          cylinder(h=thick, r=hexDia/2, $fn=6);
      }
    }
}
module honeycombCutout(width, height, diameter, spacing, thick) {
  translate([-width/2, -height/2, 0])
  difference() {
    cube([width, height, thick]);
    translate([-0.01,-0.01,-0.01])
      difference(){
        cube([width+1, height+1, thick+2]);
        translate([-diameter/2, -diameter/2, -0.01])
          hexHoles(width+diameter+spacing, height+diameter+spacing, diameter, spacing, thick);
      }
  }
}

/*
** Spiral
*/
// spirals   = how many spirals
// thickness = how thick you want the arms to be
// rmax      = maximum radius
// FIX: Has errors at certain values. First and last circle errors with small rmax
// FIX: Larger than max radius
module archimedean_spiral(spirals=1, thickness=1, rmax = 100) {
    s = spirals*360;
    t = thickness;
    a = sqrt(pow(rmax,2)/(pow(s,2)*(pow(cos(s),2) + pow(sin(s),2))));
    points=[
        for(i = [0:$fa:s]) [
            (i*a)*cos(i),
            (i*a)*sin(i)
        ]
    ];
    points_inner=[
        for(i = [s:-$fa:0]) [
            (((i*a)+t)*cos(i)),
            (((i*a)+t)*sin(i))
        ]
    ];
    polygon(concat(points,points_inner));
}
module spiralCutout(width, height, thick) {
  translate([-thick/2, 0, 0])
    linear_extrude(thick) resize([width, height, 0])
      archimedean_spiral(5,5,50);
}

/*
** Voronoi
*/
// (c)2013 Felipe Sanches <juca@members.fsf.org>
// licensed under the terms of the GNU GPL version 3 (or later)
function normalize(v) = v/(sqrt(v[0]*v[0] + v[1]*v[1]));

module voronoi(points, L=200, thickness=1, round=6, nuclei=true) {
	for (p=points) {
		difference() {
			minkowski() {
			  intersection_for(p1=points) {
				  if (p!=p1) {
            angle=90+atan2(p[1]-p1[1], p[0]-p1[0]);
					  translate((p+p1)/2 - normalize(p1-p) * (thickness+round))
					 	  rotate([0,0,angle])
						    translate([-L,-L])
						      square([2*L, L]);
				  } // if
			  } // intersection_for
		    circle(r=round, $fn=20);
		  } // minkowski
		  if (nuclei)
			  translate(p) circle(r=1, $fn=20);
		} // difference
	} // for
} // end module

module random_voronoi(n=20, nuclei=true, L=200, thickness=1, round=6, min=0, max=100, seed=42){
	x = rands(min, max, n, seed);
	y = rands(min, max, n, seed+1);
	for (i=[0:n-1]) {
		difference() {
			minkowski() {
			  intersection_for(j=[0:n-1]) {
          if (i!=j) {
            p=[x[i],y[i]];
            p1=[x[j],y[j]];
            angle=90+atan2(p[1]-p1[1], p[0]-p1[0]);
					  translate((p+p1)/2 - normalize(p1-p) * (thickness+round))
							rotate([0,0,angle])
							  translate([-L,-L])
							    square([2*L, L]);
				  }
			  }
			  circle(r=round, $fn=20);
			}
			if (nuclei)
			  translate([x[i],y[i]]) circle(r=1, $fn=20);
		}
	}
}
module voronoiCutout(width, height, thick) {
  // adjust seed: prime? 13, 17
  translate([-width/2, -height/2, 0])
  difference() {
    cube([width, height, thick]);
    translate([-0.01,-0.01,-0.01])
      difference(){
        cube([width+1, height+1, thick+2]);
        translate([width/6, height/10, -0.01]) resize([width+5, height+5, thick])
          linear_extrude(thick+3)
            random_voronoi(n=40, round=5, min=10, max=300, thickness=4, nuclei=false);
     }
  }
}

/*
** Display design patterns
*/

// Grid
translate([Width/2, Height/2, 0])
  gridCutout(Width, Height, Diameter, Spacing, Thickness);
// Honeycomb
translate([-Width/2, Height/2, 0])
  honeycombCutout(Width, Height, Diameter, Spacing, Thickness);
// Spiral
translate([-Width/2, -Height/2, 0])
  spiralCutout(Width, Height, Thickness);
// Voronoi
translate([Width/2, -Height/2, 0])
  voronoiCutout(Width, Height, Thickness);





//
