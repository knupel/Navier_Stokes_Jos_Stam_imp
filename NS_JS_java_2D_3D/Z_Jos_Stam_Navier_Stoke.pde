/**
NAVIER-STOKES
v 0.3.0
by Stan le Punk
http://stanlepunk.xyz
Processing implementation for Processing 3.3.5

Java implementation of the Navier-Stokes-Solver based on the Jos Tam's work :
http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf


*/
abstract class Navier_Stokes {
  int N;
  int iter;
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

  Navier_Stokes(int N, int iter, boolean three_Dimension_is) {
    build(N, iter, three_Dimension_is);
  }

  private void build(int N, int iter, boolean three_Dimension_is) {
    this.N = N ;
    this.iter = iter ;
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







































