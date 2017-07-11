/**
Navier_Stokes_3D 
2017-2017
v 0.0.2
*/

public class Navier_Stokes_3D extends Navier_Stokes {
  /**
  constructor
  */
  public Navier_Stokes_3D(int N) {
    super(N, 20, true);
  }
  public Navier_Stokes_3D(int N, int solver_Iterations) {
    super(N, solver_Iterations, true);
  }







  /**
  public method
  */
  /**
get
*/
  public float get_dx(int x, int y, int z) {
    return s[IX(x+1, y+1, z+1)];
  }

  public float get_dy(int x, int y, int z) {
    return t[IX(x+1, y+1, z+1)];
  }

  public float get_dz(int x, int y, int z) {
    return p[IX(x+1, y+1, z+1)];
  }






/** 
apply force
*/
  public void apply_force(int cell_x, int cell_y, int cell_z, float vx, float vy, float vz) {
    cell_x += 1;
    cell_y += 1;
    cell_z += 1;
    int which_one = IX(cell_x, cell_y, cell_z) ;

    if(which_one < s.length) {
      float dx = s[which_one];
      s[which_one] = (vx != 0) ? 
      lerp(vx, dx, 0.85f) : 
      dx;
    }

    if(which_one < t.length) {
      float dy = t[which_one];
      t[which_one] = (vy != 0) ? 
      lerp(vy,dy, .85f) : 
      dy;
    }

    if(which_one < p.length) {
      float dz = p[which_one];
      p[which_one] = (vz != 0) ? 
      lerp(vz, dz, .85f) : 
      dz;
    }   
  }







/**
update
*/
  public void update(float dt, float visc, float diff) {
    vel_step(s, t, p, s_prev, t_prev, p_prev, visc, dt);
    dens_step(dst, dst_prev, s, t, p, diff, dt);
  }
  
  private void vel_step(float[] s, float[] t, float[] p, float[] s0, float[] t0, float[] p0, float visc, float dt) {
    // step 0
    add_source(s, s0, dt); // x
    add_source(t, t0, dt); // y
    add_source(p, p0, dt); // z
    // step 1
    SWAP(s0, s); // s
    diffuse(1, s, s0, visc, dt); // s
    SWAP(t0, t); // t
    diffuse(2, t, t0, visc, dt); // t
    SWAP(p0, p); // p
    diffuse(3, p, p0, visc, dt); // p

    project(s, t, p, s0, t0);
    

    // step 2
    SWAP(s0, s); // x
    SWAP(t0, t); // y
    SWAP(p0, p); // z
    advect(1, s, s0, s0, t0, p0, dt); // x
    advect(2, t, t0, s0, t0, p0, dt); // y
    advect(3, p, p0, s0, t0, p0, dt); // z
    project(s, t, p, s0, t0);
  }


  private void dens_step(float[] x, float[] x0, float[] s, float[] t, float[] p, float diff, float dt) {
    add_source(x, x0, dt);
    SWAP(x0, x);
    diffuse(0, x, x0, diff, dt);
    SWAP(x0, x);
    advect(0, x, x0, s, t, p, dt);
  }




  /**
  main method
  */

  /**
  diffusion
  */
  private void diffuse(int b, float[] x, float[] x0, float diff, float dt) {
    float a = dt * diff *N *N;
    float c = 1 +6 *a ;
    linear_solver(b, x, x0, a, c);
  }





  /**
  advect
  */
  private void advect(int b, float[] d, float[] d0, float[] s, float[] t, float[] p, float dt) {
    int i, j, k;
    int i0, j0, k0;
    int i1, j1, k1;
    float x, y, z ;
    float s0, t0, p0 ;
    float s1, t1, p1 ;
    float dt0 = dt *N;
 
    for (i = 1; i <= N; i++) {
      for (j = 1; j <= N; j++) {
        for (k = 1; k <= N; k++) {
          x = i - dt0 * s[IX(i, j, k)];
          y = j - dt0 * t[IX(i, j, k)];
          z = k - dt0 * p[IX(i, j, k)];
          //
          if (x < 0.5) x = 0.5;
          if (x > N +.5) x = N +.5;
          if (y < 0.5) y = 0.5;
          if (y > N +.5) y = N +.5;
          if (z < 0.5) z = 0.5;
          if (z > N +.5) z = N +.5;
          //
          i0= (int)x;
          i1= i0+1;
          j0= (int)y;
          j1= j0+1;
          k0= (int)z;
          k1= k0+1;
          
          s1= x-i0;
          s0= 1-s1;
          t1= y-j0;
          t0= 1-t1;
          p1= z-k0;
          p0= 1-p1;

          float arg_0 = t0 *p0 *dst_prev[IX(i0,j0,k0)] 
                       +t1 *p0 *dst_prev[IX(i0,j1,k0)] 
                       +t0 *p1 *dst_prev[IX(i0,j0,k1)] 
                       +t1 *p1 *dst_prev[IX(i0,j1,k1)];

          float arg_1 = t0 *p0 *dst_prev[IX(i1,j0,k0)] 
                       +t1 *p0 *dst_prev[IX(i1,j1,k0)] 
                       +t0 *p1 *dst_prev[IX(i1,j0,k1)] 
                       +t1 *p1 *dst_prev[IX(i1,j1,k1)];

          d[IX(i,j,k)] = s0 *arg_0 +s1 *arg_1;

        }
      }
    }
    set_bnd(b, d);
  }
  /**
  boundary
  */
  private void set_bnd(int flag, float[] x) {

    for (int a = 1; a <= N ; a++) {
      for (int b = 1; b <= N ; b++) {
  
        if(flag == 1) {
          x[IX(0,a,b)] = -x[IX(1,a,b)] ;
          x[IX(N+1,a,b)] = -x[IX(N,a,b)] ;
        } else {
          x[IX(0,a,b)] = x[IX(1,a,b)] ;
          x[IX(N+1,a,b)] = x[IX(N,a,b)] ;
        }

        if(flag == 2) {
          x[IX(a,0,b)] = -x[IX(a,1,b)] ;
          x[IX(a,N+1,b)] = -x[IX(a,N,b)] ;
        } else {
          x[IX(a,0,b)]  = x[IX(a,1,b)] ;
          x[IX(a,N+1,b)] = x[IX(a,N,b)] ;
        }

        if(flag == 3) {
          x[IX(a,0,b)] = -x[IX(a,1,b)] ;
          x[IX(a,N+1,b)] = -x[IX(a,N,b)] ;
        } else {
          x[IX(a,0,b)]  = x[IX(a,1,b)] ;
          x[IX(a,N+1,b)] = x[IX(a,N,b)] ;
        }
      }
    }
    x[IX(0,0,0)] = (float)(1. /3. *(x[IX(1,0,0)] +x[IX(0,1,0)] +x[IX(0,0,1)]));
    x[IX(0,N+1,0)] = (float)(1. /3. *(x[IX(1,N+1,0)] +x[IX(0,N,0)] +x[IX(0,N+1,1)]));
    
    x[IX(N+1,0,0)] =( float)(1. /3. *(x[IX(N,0,0)] +x[IX(N+1,1,0)] +x[IX(N+1,0,1)]));
    x[IX(N+1,N+1,0)] = (float)(1. /3. *(x[IX(N,N+1,0)] +x[IX(N+1,N,0)] +x[IX(N+1,N+1,1)]));
    
    x[IX(0,0,N+1)] = (float)(1. /3. *(x[IX(1,0,N+1)] +x[IX(0,1,N+1)] +x[IX(0,0,N)]));
    x[IX(0,N+1,N+1)] = (float)(1. /3. *(x[IX(1,N+1,N+1)] +x[IX(0,N,N+1)] +x[IX(0,N+1,N)]));
    
    x[IX(N+1,0,N+1)] = (float)(1. /3. *(x[IX(N,0,N+1)] +x[IX(N+1,1,N+1)] +x[IX(N+1,0,N)]));
  }



  

  /**
  project
  */
    private void project(float[] s, float[] t, float[] p, float[] s0, float[] t0) {
    float h = 1. / N;
    // wht work only on s0 and t0 not with p0 ?????
    for (int i = 1; i <= N; i++) {
      for (int j = 1; j <= N; j++) {
        for (int k = 1; k <= N; k++) {
          float step_1 = s[IX(i+1,j,k)] -s[IX(i-1,j,k)] 
                        +t[IX(i,j+1,k)] -t[IX(i,j-1,k)]
                        +p[IX(i,j,k+1)] -p[IX(i,j,k-1)];
          t0[IX(i,j,k)] = -.5f *h *step_1;
          p[IX(i, j, k)] = 0;
        }
      }
    }
    set_bnd(0, t0);
    set_bnd(0, s0);

    linear_solver(0, s0, t0, 1, 4) ;

    for (int i = 1; i <= N; i++) {
      for (int j = 1; j <= N; j++) {
        for (int k = 1; k <= N; k++) {
          s[IX(i,j,k)] -= .5 *(s0[IX(i+1,j,k)] -s0[IX(i-1,j,k)]) /h;
          t[IX(i,j,k)] -= .5 *(s0[IX(i,j+1,k)] -s0[IX(i,j-1,k)]) /h;
          p[IX(i,j,k)] -= .5 *(s0[IX(i,j,k+1)] -s0[IX(i,j,k-1)]) /h;
        }
      }
    }

    set_bnd(1, s);
    set_bnd(2, t);
    set_bnd(3, p);
  }

  /**
  util
  */
  private void linear_solver(int b, float[] x, float[] x0, float a, float c) {
    for (int inc = 0; inc < solver_Iterations; inc++) {
      for (int i = 1; i <= N; i++) {
        for (int j = 1; j <= N; j++) {
          for (int k = 1; k <= N; k++) {
            float step_1 = x[IX(i-1,j,k)] +x[IX(i+1,j,k)] 
                          +x[IX(i,j-1,k)] +x[IX(i,j+1,k)] 
                          +x[IX(i,j,k-1)] +x[IX(i,j,k+1)];
            float step_2 = a *step_1 +x0[IX(i,j,k)];
            x[IX(i,j,k)] = step_2 /c;
          }
        }
      }
      set_bnd(b, x);
    }
  }

  // method used to be 'static' since this class is not a top level type
  private int IX(int i, int j, int k) {
    return i +(N+2) *j + (N+2)*(N+2)*k;
    // return i +(N+2) *j +(N+2) *k +(N+2) ;
  }

        // same applies to the swap operation ^^ 
  private void SWAP(float[] x0, float[] x) {
    float[] tmp = new float[num_cell];
    arraycopy(x0, 0, tmp, 0, num_cell);
    arraycopy(x, 0, x0, 0, num_cell);
    arraycopy(tmp, 0, x, 0, num_cell);
  }
}