TRY #1

PC=PC+1 || R1=0//for(r=0; r<C1; r++)
PC = MUX(PC+1, PC+C9, R1<C1)//here is C13

    PC=PC+1 || R2=0 //for(m=0; m<C3; m++)
    PC = Mux(PC+1, PC+C10, R2<C3)//here is C14


        PC=PC+1 || R3=0 || R3` = R2*C2 || R1` = R1*C8//for(k=0; k<C1; k++)
        PC = Mux(PC+1, PC+C11, R3<C1)//here is C15

            PC=PC+1 || R4 = R3`+R3 || R2` = R1`+R3
            [
                PC=PC+1 ||
                Radd0in_layer = R4 || Radd1in_layer = R4+C2 || Radd2in_layer = R4+2*C2 ||
                Radd3in_layer = R4+3*C2 || Radd4in_layer = R4+4*C2 || Radd5in_layer = R4+5*C2 ||
                Radd0weight   = R2` || Radd1weight   = R2`+C1 || Radd2weight   = R2`+2*C1 ||
                Radd3weight   = R2`+3*C1 || Radd4weight   = R2`+4*C1 || Radd5weight   = R2`+5*C1
            ]
            [
                PC=PC+1 ||
                R4 =
               (Rout0in_layer*Rout0weight + Rout1in_layer*Rout1weight + Rout2in_layer*Rout2weight) +
               (Rout3in_layer*Rout3weight + Rout4in_layer*Rout4weight + Rout5in_layer*Rout5weight)
            ]

            R5 = Mux(R4, R5, R3==0)
            R6 = Mux(R4, R6, R3==1)
            R7 = Mux(R4, R7, R3==2)
            R8 = Mux(R4, R8, R3==3)
            R9 = Mux(R4, R9, R3==4)
            R10 = Mux(R4, R10, R3==5)

            R3=R3+1 || PC=C15 //go back to for k
            //here is C11


        [ PC=PC+1 || R11 = R5+R6+R7+R8+R9+R10 || R3=0 ]
        [ PC=PC+1 || R1` = R2*C2+C1/*R1`=R3`+C1*/ || R2` = R1*C8-1/*R2`=R1`-1*/]

        [
            PC=PC+1 ||
            Radd0in_layer = R1` || Radd1in_layer = R1`+C2 || Radd2in_layer = R1`+2*C2 ||
            Radd3in_layer = R1`+3*C2 || Radd4in_layer = R1`+4*C2 || Radd5in_layer = R1`+5*C2 ||
            Radd0weight   = R2`+C1 || Radd1weight   = R2`+2*C1 || Radd2weight   = R2`+3*C1 ||
            Radd3weight   = R2`+4*C1 || Radd4weight   = R2`+5*C1 || Radd5weight   = R2`+6*C1
        ]


        //for(n=0; n<C2; n++)
        Mux(PC+1, PC+C12, R3<C2)//here is C16

            [
                PC=PC+1 ||
                R4 =
                    (Rout0in_layer*Rout0weight + Rout1in_layer*Rout1weight + Rout2in_layer*Rout2weight) +
                    (Rout3in_layer*Rout3weight + Rout4in_layer*Rout4weight + Rout5in_layer*Rout5weight)
                || R1` = R1`+1 ||
            ]
            [
               `PC=Pc+1 ||
                Radd0in_layer = R1` || Radd1in_layer = R1`+C2 || Radd2in_layer = R1`+2*C2 ||
                Radd3in_layer = R1`+3*C2 || Radd4in_layer = R1`+4*C2 || Radd5in_layer = R1`+5*C2 ||
                Radd0weight   = R2`+C1 || Radd1weight   = R2`+2*C1 || Radd2weight   = R2`+3*C1 ||
                Radd3weight   = R2`+4*C1 || Radd4weight   = R2`+5*C1 || Radd5weight   = R2`+6*C1
            ]

            [
                PC=PC+1 ||
                y[R1*C6+R2*C2+R3] += R11 ||
                R11 = R11-R5+R4 ||
                R5=R6|| R6=R7|| R7=R8|| R8=R9|| R9=R10|| R10=R4
            ]


            R3=R3+1 || PC=C16
            //here is C12
        R2=R2+1 || PC=C14
    //here is C10
    R1=R1+1 || PC=C13
//here is C9





TRY #2

PC=PC+1 || R1=0//for(r=0; r<C1; r++)
PC = MUX(PC+1, PC+C9, R1<C1)//here is C13

    PC=PC+1 || R2=0 //for(m=0; m<C3; m++)
    PC = Mux(PC+1, PC+C10, R2<C3)//here is C14

        R1` = R1*C8
        [
                PC=PC+1 ||
                Radd0in_layer = R2*C2 || Radd1in_layer = (R2+1)*C2 || Radd2in_layer = (R2+2)*C2 ||
                Radd3in_layer = (R2+3)*C2 || Radd4in_layer = (R2+4)*C2 || Radd5in_layer = (R2+5)*C2 ||
                Radd0weight   = R1` || Radd1weight   = R1`+C1 || Radd2weight   = R1`+2*C1 ||
                Radd3weight   = R1`+3*C1 || Radd4weight   = R1`+4*C1 || Radd5weight   = R1`+5*C1
        ]
        PC=PC+1 || R3=0 //for(k=0; k<C1; k++)
        PC = Mux(PC+1, PC+C11, R3<C1)//here is C15

            [
                PC=PC+1 ||
                Radd0in_layer = Radd0in_layer+1 || Radd1in_layer = Radd1in_layer+1 || Radd2in_layer = Radd1in_2ayer+1 ||
                Radd3in_layer = Radd3in_layer+1 || Radd4in_layer = Radd4in_layer+1 || Radd5in_layer = Radd5in_layer+1 ||
                Radd0weight   = Radd0weight+1 || Radd1weight   = Radd1weight+1 || Radd2weight   = Radd2weight+1 ||
                Radd3weight   = Radd3weight+1 || Radd4weight   = Radd4weight+1 || Radd5weight   = Radd5aweight+1
            ]
            [
                PC=PC+1 ||
                R4 =
               (Rout0in_layer*Rout0weight + Rout1in_layer*Rout1weight + Rout2in_layer*Rout2weight) +
               (Rout3in_layer*Rout3weight + Rout4in_layer*Rout4weight + Rout5in_layer*Rout5weight)
            ]


            R5 = Mux(R4, R5, R3==0)
            R6 = Mux(R4, R6, R3==1)
            R7 = Mux(R4, R7, R3==2)
            R8 = Mux(R4, R8, R3==3)
            R9 = Mux(R4, R9, R3==4)
            R10 = Mux(R4, R10, R3==5)

            R3=R3+1 || PC=C15 //go back to for k
            //here is C11


        [ PC=PC+1 || R11 = R5+R6+R7+R8+R9+R10 || R3=0]

        [
            PC=PC+1 ||
            Radd0in_layer = (R2+0)*C2+R3+C1 || Radd1in_layer = (R2+1)*C2+R3+C1 || Radd2in_layer = (R2+2)*C2+R3+C1 ||
            Radd3in_layer = (R2+3)*C2+R3+C1 || Radd4in_layer = (R2+4)*C2+R3+C1 || Radd5in_layer = (R2+5)*C2+R3+C1 ||
            Radd0weight   = R1*C8+0*C1+C1-1 || Radd1weight   = R1*C8+1*C1+C1-1 || Radd2weight   = R1*C8+2*C1+C1-1 ||
            Radd3weight   = R1*C8+3*C1+C1-1 || Radd4weight   = R1*C8+4*C1+C1-1 || Radd5weight   = R1*C8+5*C1+C1-1
        ]


        //for(n=0; n<C2; n++)
        Mux(PC+1, PC+C12, R3<C2)//here is C16

            [
                PC=PC+1 ||
                R4 =
                    (Rout0in_layer*Rout0weight + Rout1in_layer*Rout1weight + Rout2in_layer*Rout2weight) +
                    (Rout3in_layer*Rout3weight + Rout4in_layer*Rout4weight + Rout5in_layer*Rout5weight)
                ||
                Radd0in_layer = (R2+0)*C2+R3+1+C1 || Radd1in_layer = (R2+1)*C2+R3+1+C1 || Radd2in_layer = (R2+2)*C2+R3+1+C1 ||
                Radd3in_layer = (R2+3)*C2+R3+1+C1 || Radd4in_layer = (R2+4)*C2+R3+1+C1 || Radd5in_layer = (R2+5)*C2+R3+1+C1 ||
                Radd0weight   = R1*C8+0*C1+C1-1 || Radd1weight   = R1*C8+1*C1+C1-1 || Radd2weight   = R1*C8+2*C1+C1-1 ||
                Radd3weight   = R1*C8+3*C1+C1-1 || Radd4weight   = R1*C8+4*C1+C1-1 || Radd5weight   = R1*C8+5*C1+C1-1
            ]

            [
                PC=PC+1 ||
                y[R1*C6+R2*C2+R3] += R11 ||
                R11 = R11-R5+R4 ||
                R5=R6|| R6=R7|| R7=R8|| R8=R9|| R9=R10|| R10=R4
            ]


            R3=R3+1 || PC=C16
            //here is C12
        R2=R2+1 || PC=C14
    //here is C10
    R1=R1+1 || PC=C13
//here is C9

