/**
SOLVER 2D/3D
* @see https://github.com/StanLepunK
v 0.2.0
2016-2019
Processing 3.5.2
*/


boolean three_dim_is = false ;

void setup() {
	int size_cell = 10 ;
	// check for the iteration number, it's like nothing change if it's more than one, 
	// so maybe it's good to say to one to be faster
	int iteration = 4;
	if(three_dim_is) {
		set_solder_3D(size_cell, iteration);
	} else {
		set_solder_2D(size_cell, iteration);
	}


	frameRate(160);
	size(1000, 1000, P3D);
	// fullScreen(P2D, 1);

	/*

	stroke(0);
	fill(0);
	*/

}




void draw() {
	// println(frameRate);

	background_rope(255);
    float frequence = 0.001 ; // is a dt variable in the Jos Stam / Navier-Stoke
	float viscosity = 0.01;
	float diffusion = 0.01;
  
  float z = cos(frameCount *.01) *height *.5 ;
	vec3 pos = vec3(mouseX, mouseY, z) ;
	vec3 size = vec3(width, height, width) ;
	// println(pos);

	 if(three_dim_is) {
	 	draw_solver_3D(pos, size, frequence, viscosity, diffusion);
  } else {
  	draw_solver_2D(pos, size, frequence, viscosity, diffusion);
  }
}











