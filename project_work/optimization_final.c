/*0*/PC=PC+1 || R1=0 || R30=0 || R31=C1 || R32=2*C1 || R33=3*C1 || R34=4*C1 || R35=5*C1//for(r=0; r<C1; r++)
/*1*/PC = MUX(PC+1, PC+C9, R1<C1)//here is C13

/*2*/    PC=PC+1 || R2=0 || R20=0 || R21=C2 || R22=2*C2 || R23=3*C2 || R24=4*C2 || R25=5*C2 //for(m=0; m<C3; m++)
/*3*/    PC = Mux(PC+1, PC+C10, R2<C3)//here is C14

/*4*/        PC=PC+1 || R3=0 //for(k=0; k<C1; k++)
/*5*/        PC = Mux(PC+1, PC+C11, R3<C1)//here is C15

/*6*/            [
                    PC=PC+1 ||
                    Radd0in_layer = R20 || Radd1in_layer = R21 || Radd2in_layer = R22 ||
                    Radd3in_layer = R23 || Radd4in_layer = R24 || Radd5in_layer = R25 ||
                    Radd0weight   = R30 || Radd1weight   = R31 || Radd2weight   = R32 ||
                    Radd3weight   = R33 || Radd4weight   = R34 || Radd5weight   = R35
                ]
/*7*/           [
                    PC=PC+1 ||
                    R4 =
                    (Rout0in_layer*Rout0weight + Rout1in_layer*Rout1weight + Rout2in_layer*Rout2weight) +
                    (Rout3in_layer*Rout3weight + Rout4in_layer*Rout4weight + Rout5in_layer*Rout5weight)
                ]

/*8*/           [
                    R5 = Mux(R4, R5, R3==0)
                    R6 = Mux(R4, R6, R3==1)
                    R7 = Mux(R4, R7, R3==2)
                    R8 = Mux(R4, R8, R3==3)
                    R9 = Mux(R4, R9, R3==4)
                    R10 = Mux(R4, R10, R3==5)
                ]


/*9*/          R3=R3+1 || PC=C15 || R20=+=1 || R21+=1 || R22+=1 || R23+=1 || R24+=1 || R25+=1 || R30+=1 || R31+=1 || R32+=1 || R33+=1 || R34+=1 || R35+=1//go back to for k
            //here is C11

/*10*/          [
                    PC=PC+1 || R11 = R5+R6+R7+R8+R9+R10 || R3=0
                    Radd0in_layer = R20 || Radd1in_layer = R21 || Radd2in_layer = R22 ||
                    Radd3in_layer = R23 || Radd4in_layer = R24 || Radd5in_layer = R25 ||
                    Radd0weight   = R30-=1 || Radd1weight   = R31-=1 || Radd2weight   = R32-=1 ||
                    Radd3weight   = R33-=1 || Radd4weight   = R34-=1 || Radd5weight   = R35-=1
                ]


        //for(n=0; n<C2; n++)
/*11*/      PC = Mux(PC+1, PC+C12, R3<C2)//here is C16

/*12*/          [
                    PC=PC+1 ||
                        R4 =
                    (Rout0in_layer*Rout0weight + Rout1in_layer*Rout1weight + Rout2in_layer*Rout2weight) +
                    (Rout3in_layer*Rout3weight + Rout4in_layer*Rout4weight + Rout5in_layer*Rout5weight)
                    ||
                    Radd0in_layer = R20+=1 || Radd1in_layer = R21+=1 || Radd2in_layer = R22+=1 ||
                    Radd3in_layer = R23+=1 || Radd4in_layer = R24+=1 || Radd5in_layer = R25+=1 ||
                    Radd0weight   = R30 || Radd1weight   = R31 || Radd2weight   = R32 ||
                    Radd3weight   = R33 || Radd4weight   = R34 || Radd5weight   = R35
                ]

/*13*/          [
                    PC=PC+1 ||
                    y[R1*C6+R2*C2+R3] += R11 ||
                    R11 = R11-R5+R4 ||
                    R5=R6|| R6=R7|| R7=R8|| R8=R9|| R9=R10|| R10=R4
                ]


/*14*/            R3=R3+1 || PC=C16
            //here is C12
/*15*/        R2=R2+1 || PC=C14 || R20-=C1 || R21-=C1 || R22-=C1 || R23-=C1 || R24-=C1 || R25-=C1
    //here is C10
/*16*/    R1=R1+1 || PC=C13 || R30=R30-C1+1+C8 || R31=R31-C1+1+C8 || R32=R32-C1+1+C8 || R33=R33-C1+1+C8 || R34=R34-C1+1+C8 || R35=R35-C1+1+C8
//here is C9
