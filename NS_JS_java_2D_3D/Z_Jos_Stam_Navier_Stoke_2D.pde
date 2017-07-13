/**
Navier_Stokes_2D
2017-2017
v 0.0.3.1
*/

public class Navier_Stokes_2D extends Navier_Stokes {
  /**
  constructor
  */
  public Navier_Stokes_2D(int N) {
    super(N, 20, false);
  }
  public Navier_Stokes_2D(int N, int iter) {
    super(N, iter, false);
  }





  /**
  public method
  */
/**
get
*/
  public float get_dx(int x, int y) {
    return u[IX(x+1, y+1)];
  }

  public float get_dy(int x, int y) {
    return v[IX(x+1, y+1)];
  }







/** 
apply force
v 0.0.3
*/
  public void apply_force(int cell_x, int cell_y, float vx, float vy) {
    cell_x += 1;
    cell_y += 1;
    int which_one = IX(cell_x, cell_y);

    if(which_one >= 0) {
      if(which_one < u.length) {
        float dx = u[which_one];
        u[which_one] = (vx != 0) ? 
        lerp(vx,dx,.85f) : 
        dx;
      }

      if(which_one < v.length) {
        float dy = v[which_one];
        v[which_one] = (vy != 0) ? 
        lerp(vy,dy,.85f) : 
        dy;
      }
    } 
  }



/**
update
*/
  public void update(float dt, float visc, float diff) {
    vel_step(u, v, u_prev, v_prev, visc, dt, iter, N);
    dens_step(dst, dst_prev, u, v, diff, dt, iter, N);
  }
  private void vel_step(float[] u, float[] v, float[] u0, float[] v0, float visc, float dt, int iter, int N) {
    // step 0
    add_source(u, u0, dt);
    add_source(v, v0, dt);
    // step 1
    SWAP(u0, u);
    diffuse(1, u, u0, visc, dt, iter, N);
    SWAP(v0, v);
    diffuse(2, v, v0, visc, dt, iter, N);

    project(u, v, u0, v0, iter, N);

    // step 2
    SWAP(u0, u);
    SWAP(v0, v);
    advect(1, u, u0, u0, v0, dt, N);
    advect(2, v, v0, u0, v0, dt, N);
    project(u, v, u0, v0, iter, N);
  }


  private void dens_step(float[] x, float[] x0, float[] u, float[] v, float diff, float dt, int iter, int N) {
    add_source(x, x0, dt);
    SWAP(x0, x);
    diffuse(0, x, x0, diff, dt, iter, N);
    SWAP(x0, x);
    advect(0, x, x0, u, v, dt, N);
  }


  



  /**
  main method
  */

  /**
  diffusion
  */
  private void diffuse(int b, float[] x, float[] x0, float diff, float dt, int iter, int N) {
    float a = dt *diff *N *N;
    float c = 1 +4 *a ;
    lin_solve(b, x, x0, a, c, iter, N);
  }



  /**
  advect
  */
  private void advect(int b, float[] d, float[] d0, float[] u, float[] v, float dt, int N) {
    int i, j;
    int  i0, j0;
    int i1, j1;
    float x, y ;
    float s0, t0;
    float s1, t1;
    float dt0 = dt *N;

    for (i = 1; i <= N; i++) {
      for (j = 1; j <= N; j++) {
        x = i - dt0 * u[IX(i,j)];
        y = j - dt0 * v[IX(i,j)];
        //
        if (x < 0.5) x = 0.5;
        if (x > N +.5) x = N +.5;
        if (y < .5) y = .5;
        if (y > N +.5) y = N +.5;

        i0 = (int) x;
        i1 = i0 +1;
        j0 = (int) y;
        j1 = j0 +1;

        s1 = x -i0;
        s0 = 1 -s1;
        t1 = y -j0;
        t0 = 1 -t1;
        
        float arg_0 = t0 *d0[IX(i0, j0)] +t1 *d0[IX(i0, j1)];
        float arg_1 = t0 *d0[IX(i1, j0)] +t1 *d0[IX(i1, j1)];

        d[IX(i, j)] = s0 *(arg_0) +s1 *(arg_1);
      }
    }
    set_bnd(b, d, N);
  }
  /**
  boundary
  v 0.0.2
  */
  private void set_bnd(int b, float[] x, int N) {
    for (int i = 1; i <= N ; i++) {
      if(i <= N) {
        x[IX(0, i)] = b == 1 ? -x[IX(1, i)] : x[IX(1, i)];
        x[IX(N + 1, i)] = b == 1 ? -x[IX(N, i)] : x[IX(N, i)];
      }


      x[IX(i, 0)] = b == 2 ? -x[IX(i, 1)] : x[IX(i, 1)];
      x[IX(i, N + 1)] = b == 2 ? -x[IX(i, N)] : x[IX(i, N)];
    }

    x[IX(0, 0)] = 0.5 * (x[IX(1, 0)] + x[IX(0, 1)]);
    x[IX(0, N +1)] = 0.5 * (x[IX(1, N +1)] + x[IX(0, N)]);

    x[IX(N +1, 0)] = 0.5 * (x[IX(N, 0)] +x[IX(N +1, 1)]);
    x[IX(N +1, N +1)] = 0.5 * (x[IX(N, N + 1)] + x[IX(N +1, N)]);
  }


  

  /**
  project
  v 0.0.2
  */
  private void project(float[] u, float[] v, float[] u0, float[] v0, int iter, int N) {
    float h = 1. / N;
    
    for (int i = 1; i <= N; i++) {
      for (int j = 1; j <= N; j++) {
        float step_1 = u[IX(i+1,j)] -u[IX(i-1,j)] 
                      +v[IX(i,j+1)] -v[IX(i,j-1)];
        v0[IX(i, j)] = -.5f *h *step_1;
        u0[IX(i, j)] = 0;
      }
    }
    set_bnd(0, v0, N);
    set_bnd(0, u0, N);

    lin_solve(0, u0, v0, 1, 4, iter, N) ;

    for (int i = 1; i <= N; i++) {
      for (int j = 1; j <= N; j++) {
        u[IX(i,j)] -= .5 *(u0[IX(i+1,j)] -u0[IX(i-1,j)]) /h;
        v[IX(i,j)] -= .5 *(u0[IX(i,j+1)] -u0[IX(i,j-1)]) /h;
      }
    }
    set_bnd(1, u, N);
    set_bnd(2, v, N);
  }






  /**
  util
  v 0.0.2
  */
  private void lin_solve(int b, float[] x, float[] x0, float a, float c, int iter, int N) {
    for (int inc = 0; inc < iter; inc++) {
      for (int i = 1; i <= N; i++) {
        for (int j = 1; j <= N; j++) {
          float step_1 = x[IX(i-1,j)] +x[IX(i+1,j)] 
                        +x[IX(i,j-1)] +x[IX(i,j+1)];
          float step_2 = a *step_1 +x0[IX(i,j)];
          x[IX(i, j)] = step_2 /c;
        }
      }
      set_bnd(b, x, N);
    }
  }

  // method used to be 'static' since this class is not a top level type
  private int IX(int x, int y) {
    return x +(N+2) *y;
  }

        // same applies to the swap operation ^^ 
  private void SWAP(float[] x0, float[] x) {
    float[] tmp = new float[num_cell];
    arraycopy(x0, 0, tmp, 0, num_cell);
    arraycopy(x, 0, x0, 0, num_cell);
    arraycopy(tmp, 0, x, 0, num_cell);
  }
}