/**
SOLVER 2D
*/
Navier_Stokes_2D ns_2D;

void set_solder_2D(int size_cell, int iteration) {
	ns_2D = new Navier_Stokes_2D(size_cell, iteration);
}


void draw_solver_2D(Vec p, Vec c, float frequence, float viscosity, float diffusion) {
	Vec2 pos = Vec2(p.x,p.y) ;
	Vec2 canvas = Vec2(c.x,c.y) ;
  handle_pos(ns_2D, pos, canvas);

	ns_2D.update(frequence, viscosity, diffusion);

	stroke(216);
	paintGrid(ns_2D, canvas);

		float scale = 100;
	stroke(0);
	paintMotionVector(ns_2D, scale, canvas);
}

/**
SOLVER 3D
*/
Navier_Stokes_3D ns_3D;

void set_solder_3D(int size_cell, int iteration) {
	ns_3D = new Navier_Stokes_3D(size_cell, iteration);
}



int pos_z ;
void draw_solver_3D(Vec p, Vec c, float frequence, float viscosity, float diffusion) {

	Vec3 pos = Vec3(p.x,p.y, p.z) ;
	Vec3 canvas = Vec3(c.x, c.y, c.z) ;
  handle_pos(ns_3D, pos, canvas);

	ns_3D.update(frequence, viscosity, diffusion);

	stroke(216);
	paintGrid(ns_3D, canvas);

		float scale = 100;
	stroke(0);
	paintMotionVector(ns_3D, scale, canvas);
}
















/**
common method
*/
/**
handle_pos
v 0.0.1
*/

// int pos_x_0, pos_y_0, pos_z_0 ;
Vec2 pos_2D_0 ;
Vec3 pos_3D_0 ;
void handle_pos(Navier_Stokes n, Vec p, Vec s) {
	float limitVelocity = 100;

	if(n instanceof Navier_Stokes_2D) {
		Navier_Stokes_2D ns = (Navier_Stokes_2D)n ;
		if(pos_2D_0 == null) pos_2D_0 = Vec2();
		Vec2 size = Vec2(s.x,s.y);
		Vec2 pos = Vec2(p.x,p.y);
		Vec2 cell = size.div(ns.get_N());

		pos.x = max(1, pos.x);
		pos.y = max(1, pos.y);

		float pos_dx = pos.x -pos_2D_0.x;
		float pos_dy = pos.y -pos_2D_0.y;

		int target_cell_x = floor(pos.x /cell.x);
		int target_cell_y = floor(pos.y /cell.y);

		pos_dx = (abs(pos_dx) > limitVelocity) ? 
		Math.signum(pos_dx) *limitVelocity : 
		pos_dx;
		pos_dy = (abs(pos_dy) > limitVelocity) ? 
		Math.signum(pos_dy) *limitVelocity : 
		pos_dy;
		
		ns.apply_force(target_cell_x, target_cell_y, pos_dx, pos_dy);

		pos_2D_0.set(pos);

	} else if(n instanceof Navier_Stokes_3D) {
		Navier_Stokes_3D ns = (Navier_Stokes_3D)n ;
		if(pos_3D_0 == null) pos_3D_0 = Vec3();
		Vec3 pos = Vec3(p.x,p.y,p.z);
    Vec3 size = Vec3(s.x,s.y,s.z);
		Vec3 cell = size.div(ns.get_N());

		pos.x = max(1, pos.x);
		pos.y = max(1, pos.y);
		pos.z = max(1, pos.z);

		float pos_dx = pos.x -pos_3D_0.x;
		float pos_dy = pos.y -pos_3D_0.y;
		float pos_dz = pos.z -pos_3D_0.z;

		int target_cell_x = floor(pos.x /cell.x);
		int target_cell_y = floor(pos.y /cell.y);
		int target_cell_z = floor(pos.z /cell.z);

		pos_dx = (abs(pos_dx) > limitVelocity) ? 
		Math.signum(pos_dx) *limitVelocity : 
		pos_dx;
		pos_dy = (abs(pos_dy) > limitVelocity) ? 
		Math.signum(pos_dy) *limitVelocity : 
		pos_dy;
		pos_dz = (abs(pos_dz) > limitVelocity) ? 
		Math.signum(pos_dz) *limitVelocity : 
		pos_dz;

		ns.apply_force(target_cell_x, target_cell_y, target_cell_z, pos_dx, pos_dy, pos_dz);

		pos_3D_0.set(pos);
	}
}



/**
paint vector field
*/
void paintMotionVector(Navier_Stokes n, float scale, Vec size) {
	if(n instanceof Navier_Stokes_2D) {
		Navier_Stokes_2D ns = (Navier_Stokes_2D)n ;

		float cell_w = size.x /ns.get_N();
		float cell_h = size.y /ns.get_N();

		for (int i = 0; i < ns.get_N() ; i++) {
			for (int j = 0; j < ns.get_N() ; j++) {
				float dx = ns.get_dx(i, j);
				float dy = ns.get_dy(i, j);

				float x = cell_w /2 +cell_w *i;
				float y = cell_h /2 +cell_h *j ;
				dx *= scale;
				dy *= scale;
//        printTempo(60, x,y,dx, dy);
				line(x, y, x +dx, y +dy);
			}
		}
	} else if(n instanceof Navier_Stokes_3D)	{
		Navier_Stokes_3D ns = (Navier_Stokes_3D)n ;

		float cell_w = size.x /ns.get_N();
		float cell_h = size.y /ns.get_N();
		float cell_d = size.z /ns.get_N();

		for (int i = 0; i < ns.get_N() ; i++) {
			for (int j = 0; j < ns.get_N() ; j++) {
				for (int k = 0; k < ns.get_N() ; k++) {
					float dx = ns.get_dx(i, j, k);
					float dy = ns.get_dy(i, j, k);
					float dz = ns.get_dz(i, j, k);

					float x = cell_w /2 +cell_w *i;
					float y = cell_h /2 +cell_h *j ;
					float z = cell_d /2 +cell_d *k ;
					dx *= scale;
					dy *= scale;
					dz *= scale;
          //printTempo(60, x,y,z, dx, dy, dz);
          strokeWeight(1) ;
					line(x, y, z, x +dx, y +dy, z +dz);

					// point(x,y,z) ;
				}
			}
		}

	}
}

private void paintGrid(Navier_Stokes n, Vec size) {
	if(n instanceof Navier_Stokes_2D) {
		Navier_Stokes_2D ns = (Navier_Stokes_2D)n ;

		float cell_w = size.x /ns.get_N();
		float cell_h = size.y /ns.get_N();

		for (int i = 1; i < ns.get_N(); i++) {
			line(0, cell_h * i, width, cell_h * i);
			line(cell_w * i, 0, cell_w * i, height);
		}
	} else if (n instanceof Navier_Stokes_3D) {
		Navier_Stokes_3D ns = (Navier_Stokes_3D)n ;
		float cell_w = size.x /ns.get_N();
		float cell_h = size.y /ns.get_N();
		float cell_d = size.z /ns.get_N();
		for (int i = 1; i < ns.get_N(); i++) {
			line(0, cell_h *i, size.x, cell_h *i);

			line(cell_w *i, 0, cell_w *i, size.y);

		}

	}
	
}








