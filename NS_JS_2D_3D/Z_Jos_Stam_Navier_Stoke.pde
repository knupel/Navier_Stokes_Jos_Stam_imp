/**
NAVIER STOKE 2D
v 0.2.0
Java implementation of the Navier-Stokes-Solver from
http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf

Processing 3.3.5
Processing impllementation by Stan le Punk
http://stanlepunk.xyz/
*/
abstract class Navier_Stokes {
  // int M, O ;
  int N;
  int solver_Iterations;
  boolean three_Dimension_is ;
  float[] u, v ;
  float[] u_prev, v_prev ;

  float[] s, t, p ;
  float[] s_prev, t_prev, p_prev  ;

  int num_cell ;

  float[] dst ;
  float[] dst_prev ;


  Navier_Stokes(int N, boolean three_Dimension_is) {
    build(N, 20, three_Dimension_is);
  }

  Navier_Stokes(int N, int solver_Iterations, boolean three_Dimension_is) {
    build(N, solver_Iterations, three_Dimension_is);
  }

  private void build(int N, int solver_Iterations, boolean three_Dimension_is) {
    this.N = N ;
    this.solver_Iterations = solver_Iterations ;
    this.three_Dimension_is = three_Dimension_is ;

    if(!three_Dimension_is) {
      num_cell = (N +2) *(N +2);
      u = new float[num_cell];
      v = new float[num_cell];
      u_prev = new float[num_cell];
      v_prev = new float[num_cell];
    } else {
      num_cell = (N +2) *(N +2) *(N +2);
      s = new float[num_cell];
      t = new float[num_cell];
      p = new float[num_cell];
      s_prev = new float[num_cell];
      t_prev = new float[num_cell];
      p_prev = new float[num_cell];
    }

    
    dst = new float[num_cell];
    dst_prev = new float[num_cell];
  }


  protected void add_source(float[] x, float[] s, float dt) {
    for (int i = 0; i < num_cell; i++) {
      x[i] += dt * s[i];
    }
  }


  public int get_N() {
    return N;
  }
}







































