//PROGRAM TO COMPUTE ONE CPUC INST
//define the vertical wires as appeared in your cpuC ordered left to right
//if there are several memory module define them one after the other
//the number of the unit u r using is passed as argument to its type-function, e.g. if you have two plus units
//call plus1(0,x,y) for the first plus-op and plus(1,x,y) for the second op
#include <stdio.h>
#define width 4
#define Nreg	23
#define Nplus	7
#define Nminus	6
#define Nmul	6
#define Nles	1
#define Nequ    6
/*
#define QmemA   4  //#address ports of Qmem module
#define QmemV   2  //#in-value ports of QMEM
#define QmemW   2
#define Qmem    4  //#out-ports of QMEM
*/

#define ImemA   6  //#address ports of Qmem module
#define ImemV   2  //#in-value ports of QMEM
#define ImemW   2
//#define Imem    6  //#out-ports of QMEM

#define WmemA   6  //#address ports of Qmem module
#define WmemV   2  //#in-value ports of QMEM
#define WmemW   2
//#define Wmem    6  //#out-ports of QMEM

#define YmemA   2  //#address ports of Qmem module
#define YmemV   2  //#in-value ports of QMEM
#define YmemW   2
//#define Ymem    2  //#out-ports of QMEM

#define NmemA ImemA + WmemA + YmemA
#define NmemV ImemV + WmemV + YmemV
#define NmemW ImemW + WmemW + YmemW
//#define Nmem Imem + Wmem + Ymem //we dont use this anywhere


#define Nmux	6
//compute number of vertical wires in the crossbar
#define W       Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+NmemV+NmemW
//Additional horisontal rows
/*
#define QmemM   4
*/


#define ImemM   6
#define WmemM   6
#define YmemM   2

#define NmemM ImemM + WmemM + YmemM

#define Nconst	24
#define H       Nreg+Nplus+Nminus+Nmul+Nles+Nequ+Nconst+Nmux+NmemM
//these are the program constants,
#define c0 5
#define c1 6 //M
#define c2 6  //N
#define c3 6
#define c4 16
#define c5 2
#define c6 36
#define c7 32
#define c8 36
#define c9  //end of loop 1
#define c10  //end of loop 2
#define c11  //end of loop 3.1
#define c12  //end of loop 3.2
#define c13  //start of loop 1
#define c14  //start of loop 2
#define c15  //start of loop 3.1
#define c16  //start of loop 3.2
#define c17 0
#define c18 1
#define c19 2
#define c20 3
#define c21 4
#define c22 5
#define c23 6

FILE *prog1,*const1,*config;

int placement(int i, char mem, char wire);


int inst[H][W];   //The instruction

int C(int x){ return(Nreg+Nplus+Nminus+Nmul+Nles+Nequ+x);}   //return the horisontal wire corresponding to the value of this constant
int R(int x){ return(x);}   //return the horisontal wire corresponding to the value of this register
//int QM(int x){ return(Nreg+Nplus+Nminus+Nmul+Nles+Nequ+Nconst+Nmux+x);}   //return the horisontal wire corresponding to the value QMEM outputs

int M_I(int x){ return(Nreg+Nplus+Nminus+Nmul+Nles+Nequ+Nconst+Nmux+x);}   //return the horisontal wire corresponding to the value QMEM outputs
int M_W(int x){ return(Nreg+Nplus+Nminus+Nmul+Nles+Nequ+Nconst+Nmux+ImemM+x);}   //return the horisontal wire corresponding to the value QMEM outputs
int M_Y(int x){ return(Nreg+Nplus+Nminus+Nmul+Nles+Nequ+Nconst+Nmux+ImemM+WmemM+x);}   //return the horisontal wire corresponding to the value QMEM outputs


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

int equ(int op, int x, int y)
{
    inst[x][Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+2*op]=1;
    inst[y][Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+2*op+1]=1;
    return(Nreg+Nplus+Nminus+Nmul+Nles+op);
}
/*
the old from vr3
int vQA(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+x);}   //return the vertical wire corresponding to this address port of Qmem
int vQV(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+QmemA+x);}   //return the vertical wire corresponding to this in value port of Qmem
int vQW(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+QmemA+QmemV+x);}   //return the vertical wire corresponding to this read/write  port of Qmem
*/


int vA_I(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+x);}   //return the vertical wire corresponding to this address port of Imem
int vA_W(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+ImemA+x);}   //return the vertical wire corresponding to this address port of Wmem
int vA_Y(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+ImemA+WmemA+x);}   //return the vertical wire corresponding to this address port of Ymem


int vV_I(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+x);}   //return the vertical wire corresponding to this in value port of Imem
int vV_W(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+ImemV+x);}   //return the vertical wire corresponding to this in value port of Wmem
int vV_Y(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+ImemV+WmemV+x);}   //return the vertical wire corresponding to this in value port of Ymem


int vW_I(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+NmemV+x);}   //return the vertical wire corresponding to this read/write  port of Imem
int vW_W(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+NmemV+ImemW+x);}   //return the vertical wire corresponding to this read/write  port of Wmem
int vW_Y(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+NmemV+ImemW+WmemW+x);}   //return the vertical wire corresponding to this read/write  port of Ymem

/*
int vA_I(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+placement(x,'A','I'));}   //return the vertical wire corresponding to this address port of Imem
int vA_W(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+placement(x,'A','W'));}   //return the vertical wire corresponding to this address port of Wmem
int vA_Y(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+placement(x,'A','Y'));}   //return the vertical wire corresponding to this address port of Ymem


int vV_I(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+placement(x,'V','I'));}   //return the vertical wire corresponding to this in value port of Imem
int vV_W(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+placement(x,'V','W'));}   //return the vertical wire corresponding to this in value port of Wmem
int vV_Y(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+placement(x,'V','Y'));}   //return the vertical wire corresponding to this in value port of Ymem


int vW_I(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+NmemV+placement(x,'W','I'));}   //return the vertical wire corresponding to this read/write  port of Imem
int vW_W(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+NmemV+placement(x,'W','W'));}   //return the vertical wire corresponding to this read/write  port of Wmem
int vW_Y(int x){ return(Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+Nmux*3+NmemA+NmemV+placement(x,'W','Y'));}   //return the vertical wire corresponding to this read/write  port of Ymem
*/


int mux(int op, int x, int y, int z)      //the op-mux unit returns the horisontal wire holding the value of this mux
{
   inst[x][Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+3*op]=1;        //fuse first input
   inst[y][Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+3*op+1]=1;      //fuse second input
   inst[z][Nreg+Nplus*2+Nminus*2+Nmul*2+Nles*2+Nequ*2+3*op+2]=1;      //fuse second input
   return(Nreg+Nplus+Nminus+Nmul+Nles+Nequ+Nconst+op);
}

void ass(int x, int y)
{
   inst[y][x]=1;
}


//PC=PC+1 || R1=0 || R30=C0 || R31=C1+C0 || R32=2*C1+C0 || R33=3*C1+C0 || R34=4*C1+C0 || R35=5*C1+C0//for(r=0; r<C1; r++)
void inst1()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),plus(0,R(0),C(18)));  //PC=PC+C0
  ass(vR(1),C(17)); //R1=0
  ass(vR(18),C(0));
  ass(vR(19),plus(1,C(1),C(0)));
  ass(vR(20),plus(2,mull(0,C(1),C(5)),C(0)));
  ass(vR(21),plus(3,mull(1,C(1),C(20)),C(0)));
  ass(vR(22),plus(4,mull(2,C(1),C(21)),C(0)));
  ass(vR(23),plus(5,mull(3,C(1),C(22)),C(0)));
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

//PC = MUX(PC+1, PC+C9, R1<C1)
void inst2()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),mux(0,plus(0,R(0),C(18)),plus(1,R(0),C(9)),les(0,R(1),C(1))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

//[PC=PC+C0 || R2=C0 ]
void inst3()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),plus(0,R(0),C(18)));  //PC=PC+C0
  ass(vR(2),C(17)); //R1=0
  ass(vR(12),C(17));
  ass(vR(13),C(2));
  ass(vR(14),mull(0,C(2),C(19)));
  ass(vR(15),mull(1,C(2),C(20)));
  ass(vR(16),mull(2,C(2),C(21)));
  ass(vR(17),mull(3,C(2),C(22)));
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

//PC=PC+1 || PC=Mux(PC+1,PC+C4,R2<C2-1)
void inst4()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),mux(0,plus(0,R(0),C(18)),plus(1,R(0),C(10)),les(0,R(2),C(3))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

// PC=PC+1 || A0 = (R1-1)*C2+R2 || A1=(R1+1)*C2+j || A2=R1*C2+R2-1 || A3=R1*C2+R2+1 || we1=C6 || we2=C6
void inst5()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),plus(0,R(0),C(18)));  //PC=PC+C0
  ass(vR(3),C(17)); //R1=0
  ass(vR(18),minus(0,R(18),C(0)));
  ass(vR(19),minus(1,R(19),C(0)));
  ass(vR(20),minus(2,R(20),C(0)));
  ass(vR(21),minus(3,R(21),C(0)));
  ass(vR(22),minus(4,R(22),C(0)));
  ass(vR(23),minus(5,R(23),C(0)));                       //we2=C6
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}
//PC=PC+C0 || A0 = R1*C3+R2 || QV0=M1+M2+M3+M4 || we1=C0 || we2=C6
void inst6()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(0),mux(0,plus(0,R(0),C(18)),plus(1,R(0),C(11)),les(0,R(3),C(1))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
                                                //we2=C6
}


void inst7()
{
    int i,j;
    for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;

    ass(vR(0),plus(0,R(0),C(18)));

    ass(vW_I(0), C(17));
    ass(vW_I(1), C(17));
    ass(vW_I(2), C(17));
    ass(vW_W(0), C(17));
    ass(vW_W(1), C(17));
    ass(vW_W(2), C(17));

    ass(vA_I(0), R(12));
    ass(vA_I(1), R(13));
    ass(vA_I(2), R(14));
    ass(vA_I(3), R(15));
    ass(vA_I(4), R(16));
    ass(vA_I(5), R(17));

    ass(vA_W(0), R(18));
    ass(vA_W(1), R(19));
    ass(vA_W(2), R(20));
    ass(vA_W(3), R(21));
    ass(vA_W(4), R(22));
    ass(vA_W(5), R(23));
}

void inst8()
{
    int i,j;
    for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;

    ass(vR(0), plus(0,R(0),C(18)));
    ass(vR(4), plus(5,plus(4,plus(1,mull(0,M_I(0),M_W(0)),mull(1,M_I(1),M_W(1))),plus(2,mull(2,M_I(2),M_W(2)),mull(3,M_I(3),M_W(3)))),plus(3,mull(4,M_I(4),M_W(4)),mull(5,M_I(5),M_W(5)))));

    for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

void inst9()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(5),mux(0,R(4),R(5),equ(0,R(3),C(17))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
  ass(vR(6),mux(1,R(4),R(6),equ(1,R(3),C(18))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
  ass(vR(7),mux(2,R(4),R(7),equ(2,R(3),C(19))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
  ass(vR(8),mux(3,R(4),R(8),equ(3,R(3),C(20))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
  ass(vR(9),mux(4,R(4),R(9),equ(4,R(3),C(21))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
  ass(vR(10),mux(5,R(4),R(10),equ(5,R(3),C(22))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)

  ass(vR(12),minus(0,R(12),C(18)));
  ass(vR(13),minus(1,R(13),C(18)));
  ass(vR(14),minus(2,R(14),C(18)));
  ass(vR(15),minus(3,R(15),C(18)));
  ass(vR(16),minus(4,R(16),C(18)));
  ass(vR(17),minus(5,R(17),C(18)));
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
                                                //we2=C6
}

void inst10()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(3) ,plus(0,R(3),C(18)));
  ass(vR(0) ,C(15));

  ass(vR(18) ,plus(1,R(18),C(18)));
  ass(vR(19) ,plus(2,R(19),C(18)));
  ass(vR(20) ,plus(3,R(20),C(18)));
  ass(vR(21) ,plus(4,R(21),C(18)));
  ass(vR(22) ,plus(5,R(22),C(18)));
  ass(vR(23) ,plus(6,R(23),C(18)));
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");                                         //we2=C6
}

void inst11()
{
    int i,j;
    for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;

    ass(vR(0),plus(0,R(0),C(18)));
    ass(vR(11),plus(5,plus(4,plus(1,R(5),R(6)),plus(2,R(7),R(8))),plus(3,R(9),R(10))));
    ass(vR(3),C(17));

    ass(vW_I(0), C(17));
    ass(vW_I(1), C(17));
    ass(vW_I(2), C(17));
    ass(vW_W(0), C(17));
    ass(vW_W(1), C(17));
    ass(vW_W(2), C(17));

    ass(vA_I(0), R(12));
    ass(vA_I(1), R(13));
    ass(vA_I(2), R(14));
    ass(vA_I(3), R(15));
    ass(vA_I(4), R(16));
    ass(vA_I(0), R(17));

    ass(vA_W(0), minus(0,R(18),C(18)));
    ass(vR(18), minus(0,R(18),C(18)));

    ass(vA_W(1), minus(1,R(19),C(18)));
    ass(vR(19), minus(1,R(19),C(18)));

    ass(vA_W(2), minus(2,R(20),C(18)));
    ass(vR(20), minus(2,R(20),C(18)));

    ass(vA_W(3), minus(3,R(21),C(18)));
    ass(vR(21), minus(3,R(21),C(18)));

    ass(vA_W(4), minus(4,R(22),C(18)));
    ass(vR(22), minus(4,R(22),C(18)));

    ass(vA_W(5), minus(5,R(23),C(18)));
    ass(vR(23), minus(5,R(23),C(18)));

    for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

void inst12()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;

  ass(vR(0),mux(0,plus(0,R(0),C(18)),plus(1,R(0),C(12)),les(0,R(3),C(2))));  //PC=Mux(PC+C0,PC+C2,R1<C1-1)
  ass(vW_Y(0), C(17));
  ass(vA_Y(0), plus(2,mull(0,R(1),C(6)),plus(3,mull(1,R(2),C(2)),R(3))));

  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");                                         //we2=C6
                                    //we2=C6
}

void inst13()
{
    int i,j;
    for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;

    ass(vR(0),  plus(0,R(0),C(18)));
    ass(vR(4),  plus(5,plus(4,plus(1,mull(0,M_I(0),M_W(0)),mull(1,M_I(1),M_W(1))),plus(2,mull(2,M_I(2),M_W(2)),mull(3,M_I(3),M_W(3)))),plus(3,mull(4,M_I(4),M_W(4)),mull(5,M_I(5),M_W(5)))));
    ass(vR(11), plus(6,R(11),M_Y(0)));

    for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

void inst14()
{
    int i,j;
    for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;

    ass(vR(0),  plus(0,R(0),C(18)));
    ass(vV_Y(0), R(11));

    ass(vA_I(0), plus(1,R(12),C(18)));
    ass(vR(12), plus(1,R(12),C(18)));

    ass(vA_I(1), plus(2,R(13),C(18)));
    ass(vR(13), plus(2,R(13),C(18)));

    ass(vA_I(2), plus(3,R(14),C(18)));
    ass(vR(14), plus(3,R(14),C(18)));

    ass(vA_I(3), plus(4,R(15),C(18)));
    ass(vR(15), plus(4,R(15),C(18)));

    ass(vA_I(4), plus(5,R(16),C(18)));
    ass(vR(16), plus(5,R(16),C(18)));

    ass(vA_I(0), plus(6,R(17),C(18)));
    ass(vR(17), plus(6,R(17),C(18)));

    ass(vA_W(0), R(18));
    ass(vA_W(1), R(19));
    ass(vA_W(2), R(20));
    ass(vA_W(3), R(21));
    ass(vA_W(4), R(22));
    ass(vA_W(5), R(23));

    ass(vW_I(0), C(17));
    ass(vW_I(1), C(17));
    ass(vW_I(2), C(17));
    ass(vW_W(0), C(17));
    ass(vW_W(1), C(17));
    ass(vW_W(2), C(17));



    ass(vW_Y(0), C(18));

    for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}

void inst15()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(3),plus(0,R(3),C(18)));
  ass(vR(0),C(16));
  ass(vR(11),plus(1,R(4),minus(0,R(11),R(5))));
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");                                         //we2=C6
}

void inst16()
{ int i,j;
  for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;
  ass(vR(2),plus(0,R(2),C(18)));
  ass(vR(0),C(14));
  ass(vR(12),minus(0,R(12),C(1)));
  ass(vR(13),minus(1,R(13),C(1)));
  ass(vR(14),minus(2,R(14),C(1)));
  ass(vR(15),minus(3,R(15),C(1)));
  ass(vR(16),minus(4,R(16),C(1)));
  ass(vR(17),minus(5,R(17),C(1)));
  for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");                                         //we2=C6
}

void inst17()
{
    int i,j;
    for(i=0;i<H;i++) for(j=0;j<W;j++) inst[i][j]=0;

    ass(vR(0),C(13));
    ass(vR(1),plus(0,R(1),C(18)));

    ass(vR(18),plus(1,R(18),C(8)));
    ass(vR(19),plus(2,R(19),C(8)));
    ass(vR(20),plus(3,R(20),C(8)));
    ass(vR(21),plus(4,R(21),C(8)));
    ass(vR(22),plus(5,R(22),C(8)));
    ass(vR(23),plus(6,R(23),C(8)));

    for(i=0;i<H;i++) for(j=0;j<W;j++) fprintf(prog1,"%1d",inst[i][j]); fprintf(prog1,"\n");
}






void myprintrow(int x)
{
if(x == 0) printf("PC ");
else if(x < Nreg) printf("R%d ",x);
else if(x < Nreg+Nplus*2 ) printf("+%d ",(x-Nreg)/2);
else if(x < Nreg+Nplus*2+Nmul*2) printf("*%d ",(x-Nreg-Nplus*2)/2);
else if(x < Nreg+Nplus*2+Nmul*2+Nminus*2) printf("-%d ",(x-Nreg-Nplus*2-Nmul*2)/2);
else if(x < Nreg+Nplus*2+Nmul*2+Nminus*2+Nles*2) printf("<%d ",(x-Nreg-Nplus*2-Nmul*2-Nminus*2)/2);
else printf("%d ",x);
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
fprintf(config,"`define Nequ %d\n",Nequ);
fprintf(config,"`define Nop `Nplus + `Nminus + `Nmul + `Nles + `Nequ\n");
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
  prog1=fopen("myprogram.mem","w");
  const1 = fopen("myconst.mem","w");
  config = fopen("params1.vh","w");
  int i,j,k;
  inst1();
  niceprint();
  inst2();
  inst3();
  inst4();
  inst5();
  inst6();
  inst7();
  inst8();
  printcofig();
  fclose(prog1); fclose(const1); fclose(config);
}
