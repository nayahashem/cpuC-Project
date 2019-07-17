//PROGRAM TO COMPUTE ONE CPUC INST
//define the vertical wires as appeared in your cpuC ordered left to right
//if there are several memory module define them one after the other
//the number of the unit u r using is passed as argument to its type-function, e.g. if you have two plus units 
//call plus1(0,x,y) for the first plus-op and plus(1,x,y) for the second op
#include <stdio.h>
#define width 4
#define Nreg	3	
#define Nplus	7	
#define Nminus	2	
#define Nmul	4
#define Nles	1
#define QmemA   4  //#address ports of Qmem module
#define QmemV   2  //#in-value ports of QMEM
#define QmemW   2
#define Qmem    4  //#out-ports of QMEM
#define Nmux	1
//compute number of vertical wires in the crossbar
#define W       Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+QmemA+QmemV+QmemW+Nmux*3
//Additional horisontal rows 
#define QmemM   4 
#define Nconst	7
#define H       Nreg+Nplus+Nminus+Nmul+Nles+Nconst+QmemM+Nmux
//these are the program constants, 
#define c0 1
#define c1 5 //M
#define c2 4  //N
#define c3 7
#define c4 4
#define c5 2
#define c6 0
FILE *prog1,*const1,*config;

int inst[H][W];   //The instruction

int C(int x){ return(Nreg+Nplus+Nminus+Nmul+Nles+x);}   //return the horisontal wire corresponding to the value of this constant
int R(int x){ return(x);}   //return the horisontal wire corresponding to the value of this register
int QM(int x){ return(Nreg+Nplus+Nminus+Nmul+Nles+Nconst+x);}   //return the horisontal wire corresponding to the value QMEM outputs
int vR(int x){ return(x);}   //return the vertical wire corresponding to this register

int plus(int op, int x, int y)      //the op-plus unit returns the horisontal wire holding the value of this plus
{
   inst[x][Nreg+2*op]=1;  //fuse first input
   inst[y][Nreg+2*op+1]=1;      //fuse second input
   return(Nreg+op);
}
int minus(int op, int x, int y)      //the op-minus unit returns the horisontal wire holding the value of this minus
{
   inst[x][Nreg+Nplus*2+2*op]=1;  //fuse first input
   inst[y][Nreg+Nplus*2+2*op+1]=1;      //fuse second input
   return(Nreg+Nplus+op);
}
int mull(int op, int x, int y)      //the op-mull unit returns the horisontal wire holding the value of this mull
{
   inst[x][Nreg+Nplus*2+Nminus*2+2*op]=1;  //fuse first input
   inst[y][Nreg+Nplus*2+Nminus*2+2*op+1]=1;      //fuse second input
   return(Nreg+Nplus+Nminus+op);
}
int les(int op, int x, int y)      //the op-les unit returns the horisontal wire holding the value of this les
{
   inst[x][Nreg+Nplus*2+Nminus*2+Nmul*2+2*op]=1;  //fuse first input
   inst[y][Nreg+Nplus*2+Nminus*2+Nmul*2+2*op+1]=1;      //fuse second input
   return(Nreg+Nplus+Nminus+Nmul+op);
}

int vQA(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+x);}   //return the vertical wire corresponding to this address port of Qmem
int vQV(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+QmemA+x);}   //return the vertical wire corresponding to this in value port of Qmem
int vQW(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+QmemA+QmemV+x);}   //return the vertical wire corresponding to this read/write  port of Qmem

int mux(int op, int x, int y, int z)      //the op-mux unit returns the horisontal wire holding the value of this mux
{
   inst[x][Nreg+Nplus*2+Nminus*2+Nmul*2+QmemA+QmemV+QmemW+3*op]=1;  //fuse first input
   inst[y][Nreg+Nplus*2+Nminus*2+Nmul*2+QmemA+QmemV+QmemW+3*op+1]=1;      //fuse second input
   inst[z][Nreg+Nplus*2+Nminus*2+Nmul*2+QmemA+QmemV+QmemW+3*op+2]=1;      //fuse second input
   return(Nreg+Nplus+Nminus+Nmul+Nles+Nconst+QmemM+op);
}
void ass(int x, int y)
{
   inst[y][x]=1;
}

//[PC=PC+C0 || R1=C0 ]
void inst1()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),plus(0,R(0),C(0)));  //PC=PC+C0
  ass(vR(1),C(0)); //R1=C0
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

//PC=PC+C0 || PC=Mux(PC+C0,PC+C3,R1<C1-1)
void inst2()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),plus(0,R(0),C(0))); //PC=PC+C0
  ass(vR(0),mux(0,plus(0,R(0),C(0)),plus(0,R(0),C(3)),les(0,R(1),minus(0,C(1),C(0)))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

//[PC=PC+C0 || R2=C0 ]
void inst3()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),plus(0,R(0),C(0)));  //PC=PC+C0
  ass(vR(2),C(0)); //R2=C0
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

//PC=PC+1 || PC=Mux(PC+1,PC+C4,R2<C2-1)
void inst4()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),plus(0,R(0),C(0))); //PC=PC+1
  ass(vR(0),mux(0,plus(0,R(0),C(0)),plus(1,R(0),C(4)),les(0,R(2),minus(0,C(2),C(0)))));  //PC=Mux(PC+1,PC+C4,R2<C2-1
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

// PC=PC+1 || A0 = (R1-1)*C2+R2 || A1=(R1+1)*C2+j || A2=R1*C2+R2-1 || A3=R1*C2+R2+1 || we1=C6 || we2=C6
void inst5()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),plus(0,R(0),C(0)));  //PC=PC+1
  ass(vQA(0), plus(1, mull(0, minus(0,R(1),C(0)), C(2)), R(2))); //A0 = (R1-1)*C2+R2
  ass(vQA(1), plus(3, mull(1, plus(2,R(1),C(0)), C(2)), R(2))); //A1=(R1+1)*C2+j
  ass(vQA(2), plus(4, mull(2, R(1),C(2)), minus(1,R(2),C(0)))); //A2=R1*C2+R2-1
  ass(vQA(3), plus(5, mull(3, R(1),C(2)), plus(6,R(2),C(0)))); //A3=R1*C2+R2+1 
  ass(vQW(0),C(6));                                              //we1=C6 
  ass(vQW(1),C(6));                                              //we2=C6 
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}
//PC=PC+C0 || A0 = R1*C3+R2 || QV0=M1+M2+M3+M4 || we1=C0 || we2=C6
void inst6()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),plus(0,R(0),C(0)));  //PC=PC+C0
  ass(vQA(0), plus(1, mull(0,R(1),C(2)),R(2))); //A0 = R1*C2+R2
  ass(vQV(0), plus(3,QM(0),plus(2,QM(1),plus(4,QM(2),QM(3))))); //QV0=M1+M2+M3+M4
  ass(vQW(0),C(0));                                              //we1=C0 
  ass(vQW(1),C(6));                                              //we2=C6 
}

//[R2=R2+C0 || PC=C5 ]
void inst7()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(2),plus(0,R(2),C(0)));  //R2=R2+C0
  ass(vR(0),C(4)); //PC=C4
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}
//[R1=R1+C0 || PC=C5 ]
void inst8()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(1),plus(0,R(1),C(0)));  //R1=R1+C0
  ass(vR(0),C(5)); //PC=C5
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

void myprintrow(int x)
{
if(x == 0) printf("PC ");
else if(x < Nreg) printf("R%2d",x);
else if(x < Nreg+Nplus*2 ) printf("+%2d",(x-Nreg)/2);
else if(x < Nreg+Nplus*2+Nmul*2) printf("*%2d",(x-Nreg-Nplus*2)/2);
else if(x < Nreg+Nplus*2+Nmul*2+Nminus*2) printf("-%2d",(x-Nreg-Nplus*2-Nmul*2)/2);
else if(x < Nreg+Nplus*2+Nmul*2+Nminus*2+Nles*2) printf("<%2d",(x-Nreg-Nplus*2-Nmul*2-Nminus*2)/2);
else printf("%3d",x);
}

void niceprint()
{ int i,j;
  printf("INST H=%d W=%d\n",H,W);
  printf("   ");
  for(j=0;j<W;j++) myprintrow(j); printf("\n");
  for(i=0;i<H;i++)
  {
    printf("%2d|",i);
    for(j=0;j<W;j++)
     printf("%3d",inst[i][j]);
    printf("\n");
  }
}
void printcofig()
{
fprintf(config,"`define W %d\n",width);
fprintf(config,"`define PC 0\n");
fprintf(config,"\n");
fprintf(config,"`define prog_size 8");
fprintf(config,"\n");
fprintf(config,"`define Nplus %d\n",Nplus);
fprintf(config,"`define Nminus %d\n",Nminus);
fprintf(config,"`define Nmul %d\n",Nmul);
fprintf(config,"`define Nles %d\n",Nles);
fprintf(config,"`define Nop `Nplus + `Nminus + `Nmul + `Nles\n");
fprintf(config,"\n");
fprintf(config,"`define Nreg %d\n",Nreg);
fprintf(config,"`define Nconst %d\n",Nconst);
fprintf(config,"`define Nmem %d\n",1);
fprintf(config,"`define Nmux %d\n",Nmux);
fprintf(config,"\n");
fprintf(config,"`define M 256 // memory size\n");
fprintf(config,"\n");
fprintf(config,"`define CONST_FILE \",my_const.mem\"\n");
fprintf(config,"`define PROGRAM_FILE \"my_program.mem\"\n");
}

void main()
{
  prog1=fopen("myprog.mem","w");
  const1 = fopen("mycon.mem","w"); 
  config = fopen("params.vh","w"); 
  int i,j,k;
  inst1();
  inst2();
  inst3();
  inst4();
  inst5();
  niceprint();
  inst6();
  inst7();
  inst8();
  printcofig();
  fclose(prog1); fclose(const1); fclose(config);
}
