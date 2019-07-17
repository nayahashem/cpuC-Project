#include <stdio.h>
#define C1 6 // conv in y number
#define C2 6 // elements in line fro y
#define C3 6 // lines in conv in y
#define C4 (C2+2)*2 // = 16
#define C5 2
#define C6 C2*C3 // = 36
#define C7 C4*2 // = 32
#define C8 C1*C1 // = 36 ,
int weight[C1*C8]; // size = 36*6 = 216 , this the the matrix of the convolution 3-D
int y[C1*C6]; // size = 6*36 = 216, this matrix is for the results.
int in_layer[8*C6]; // size = 8*36 = 288 , I think this is the image matrix
void init()
{ int r,k,l,m,n;
  // intialization to be realized by readmem in the memory modules
  for(r=0; r<C1; r++)
    for(k=0; k<C1; k++)
      for(l=0; l<C1; l++) weight[r*C8+k*C1+l] = r+1;
      /*
      this is what weight looks like :

      conv 1 :  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
      conv 2 :  2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
      conv 3 :  3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3
      conv 4 :  4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4
      conv 5 :  5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5
      conv 6 :  6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6

      */
  for(r=0; r<C1; r++)
   for(m=0; m<C3; m++)
    for(n=0; n<C2; n++)
      y[r*C6+m*C2+n] = 0;
   for(m=0; m<C3*8; m++)
    for(n=0; n<C2; n++)
       in_layer[m*C2+n] = 1;

}
void display()
{
 // Printing the results using dispaly instructions
 int r, m, n;
 printf("printing the results :\n\n");

  for(r=0; r<C1; r++)
   for(m=0; m<C3; m++)
   {
    for(n=0; n<C2; n++)
      printf("%d-%d-%d %d| ",r,m,n,y[r*C6+m*C2+n]);
    printf("|\n");
   }
}
void main()
{
  int r,k,l,m,n,s,z,s0,s1,s2,s3,s4,s5,s6;
  init();
  /*
  weight   : it look like its shown up there.

  y        : its bits of 0, Its for the results of the convolution

  in_layer : its bits of 1, This is the image
  */
  // actual convolutional code to be realized in cpuC instructions
  for(r=0; r<C1; r++)
    { //for each convolution
        for(m=0; m< C3; m++) //shift input window over image
        {//m is for the image rows
            for(k=0; k<C1; k++)
            {//computing the first s0,..,s5 for a row m in the image with conv layer = r.
                s=0;
                for(l=0; l<C1; l++) s += in_layer[(m+l)*C2+k] * weight[r*C8+l*C1+k];
                // r=number of convolution page, k= we are now computing sk, l=is passing between lines in each line there is one item of sk
                // m=image row we are doing the conv on.

                if(k == 0) s0=s; if(k == 1) s1=s; if(k == 2) s2=s; if(k == 3) s3=s; if(k == 4) s4=s; if(k == 5) s5=s;
                //as we said for the first computation in a row for a cov we compute every si.
            }
            z = s0+s1+s2+s3+s4+s5; // this is the result of the first element in the row m of the image. (for conv = r).
            for(n=0; n<C2; n++)
            {//the image has c2=6 columns, for each element after the first we compute the conv using the previous elements value
                s = 0;
                for(l=0; l<6; l++) s += in_layer[(m+l)*C2+n+C1] * weight[r*C8+l*C1+C1-1];
                        //calculating s5 for the next element (n+1) in row m
                y[r*C6+m*C2+n] += z;//save conv value with layer r, in row m, for element n.
                z = z-s0+s;//changing z to be conv value of element n+1 or the next element
                s0 =s1; s1=s2; s2=s3; s3=s4; s4=s5; s5=s;   //shift previouse values
                // we need them because each round we need s0 to calc z
            }
        }
    }
  display();
}

//  Giedlines for translating the code into cpuC assembly
//  We can use an hexaram module that supports six parallel load instructions using the following module
/* dualram is as described in mem.v
module hexaram ( input [`W:0] data_a, data_b, input [`W:0] addr_a, addr_b,addr_c, addr_d, addr_e, addr_f,
        input we_a, we_b, clk, output wire [`W:0] q_a, q_b,q_c, q_d, q_e,q_f);
wire [`W:0] addr_x, addr_y, addr_z, addr_w;
assign addr_x = (we_a)?addr_a : addr_c;
assign addr_y = (we_b)?addr_b : addr_d;
assign addr_z = (we_a)?addr_a : addr_e;
assign addr_w = (we_b)?addr_b : addr_f;
dualram mem1(data_a, data_b, addr_a, addr_b,we_a, we_b, clk, q_a, q_b);
dualram mem2(data_a, data_b, addr_x, addr_y,we_a, we_b, clk, q_c, q_d);
dualram mem3(data_a, data_b, addr_z, addr_w,we_a, we_b, clk, q_e, q_f);
endmodule
*/

//  We use the followig memory modules:
//        in_layer[C2*C3] a hexaram,
//        weight[C1*C1] a hexaram,
//        y[C2*C3] a singleram.
// indexes x,r,m,n,k  and values s,z are mapped to distinct registers.
// This code does not include the code for the for-loops
// if(k == 2) s2=s is realized by a mux-op

    for(r=0; r<C1; r++){
    for(m=0; m< C3; m++) //shift input window over image
    {
      for(k=0; k<C1; k++)
      {
        [
	    Radd0in_layer = (m+0)*C2+k || Radd1in_layer = (m+1)*C2+k || Radd2in_layer = (m+2)*C2+k ||
	    Radd3in_layer = (m+3)*C2+k || Radd4in_layer = (m+4)*C2+k || Radd5in_layer = (m+5)*C2+k ||
	    Radd0weight   = r*C8+0*C1+k] || Radd1weight   = r*C8+1*C1+k] || Radd2weight   = r*C8+2*C1+k] ||
	    Radd3weight   = r*C8+3*C1+k] || Radd4weight   = r*C8+4*C1+k] || Radd5weight   = r*C8+5*C1+k]
        ]
        [ s =
	       (Rout0in_layer*Rout0weight + Rout1in_layer*Rout1weight + Rout2in_layer*Rout2weight) +
	       (Rout3in_layer*Rout3weight + Rout4in_layer*Rout4weight + Rout5in_layer*Rout5weight)
        ]
        [ if(k == 0) s0=s || if(k == 1) s1=s || if(k == 2) s2=s || if(k == 3) s3=s || if(k == 4) s4=s || if(k == 5) s5=s ]
      }
      [ z = s0+s1+s2+s3+s4+s5 ]

      [
	    Radd0in_layer = (m+0)*C2+n+C1 || Radd1in_layer = (m+1)*C2+n+C1 || Radd2in_layer = (m+2)*C2+n+C1 ||
	    Radd3in_layer = (m+3)*C2+n+C1 || Radd4in_layer = (m+4)*C2+n+C1 || Radd5in_layer = (m+5)*C2+n+C1 ||
	    Radd0weight   = r*C8+0*C1+C1-1] || Radd1weight   = r*C8+1*C1+C1-1] || Radd2weight   = r*C8+2*C1+C1-1] ||
	    Radd3weight   = r*C8+3*C1+C1-1] || Radd4weight   = r*C8+4*C1+C1-1] || Radd5weight   = r*C8+5*C1+C1-1]
      ]
      for(n=0; n<C2; n++)
      {

          //We use the load values to compute s and in the same cycle put the addresses for the loads of the next iteration
        [s =
	       (Rout0in_layer*Rout0weight + Rout1in_layer*Rout1weight + Rout2in_layer*Rout2weight) +
	       (Rout3in_layer*Rout3weight + Rout4in_layer*Rout4weight + Rout5in_layer*Rout5weight)
	    ||
	    Radd0in_layer = (m+0)*C2+n+1+C1 || Radd1in_layer = (m+1)*C2+n+1+C1 || Radd2in_layer = (m+2)*C2+n+1+C1 ||
	    Radd3in_layer = (m+3)*C2+n+1+C1 || Radd4in_layer = (m+4)*C2+n+1+C1 || Radd5in_layer = (m+5)*C2+n+1+C1 ||
	    Radd0weight   = r*C8+0*C1+C1-1] || Radd1weight   = r*C8+1*C1+C1-1] || Radd2weight   = r*C8+2*C1+C1-1] ||
	    Radd3weight   = r*C8+3*C1+C1-1] || Radd4weight   = r*C8+4*C1+C1-1] || Radd5weight   = r*C8+5*C1+C1-1]
	 ]
	 [
            y[r*C6+m*C2+n] += z ||
            z = z-s0+s ||
            s0 =s1|| s1=s2|| s2=s3|| s3=s4|| s4=s5|| s5=s
	 ]
      }
    }
  }

 */
