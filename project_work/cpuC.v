/* 
 * CPUc - Switches module
 */

`include "params.vh"

module CPUC #(parameter Nop = `Nop, Nplus = `Nplus, Nminus = `Nminus, Nmul = `Nmul, Nles = `Nles,Nequ = `Nequ, Nreg = `Nreg, Nconst = `Nconst, Imem = `Imem, Wmem = `Wmem, Ymem = `Ymem, Nmem = `Nmem, Nmux = `Nmux, first = `first, second = `second) (
clk, // clock
reset,
in,
out1,
out2
);
input clk;
input reset;
input in;
output out1;
output out2;

wire [`W-1:0] in;
wire clk;
wire reset;
wire [`W-1:0] out1;
wire [`W-1:0] out2; 

wire [0:(first)*(second)-1] crossbar_con; // first is horizontal --> '-', second is vertical --> '|', refering to the place in the crossbar not the wire 
/* 
hexaram 
	Horizontal : A0..A5, V0..V1, We0..We2 -> 6+2+3 = 11
	Vertical : M0..M5 -> 6

dualram 
	Horizontal : A0..A1, V0..V1, We0..We1 -> 2+2+1 = 5
	Vertical : M0..M1 -> 2

*/

wire [`W-1:0]  Rh_wires  [Nreg-1:0]; //an array of wires, there is Nreg wires, each is W`-bit
wire [`W-1:0]  OPh_wires [Nop-1:0];
wire [`W-1:0]  Ch_wires  [Nconst-1:0];

wire [`W-1:0]  Rv_wires  [Nreg-1:0];
wire [`W-1:0]  OPv_wires [2*Nop-1:0];

 
wire [`W-1:0]  A1v_wires  [Nmem-1:0];
wire [`W-1:0]  A2v_wires  [Nmem-1:0];
wire [`W-1:0]  A3v_wires  [Nmem-2:0];
wire [`W-1:0]  A4v_wires  [Nmem-2:0];
wire [`W-1:0]  A5v_wires  [Nmem-2:0];
wire [`W-1:0]  A6v_wires  [Nmem-2:0];
/*
// Generating the 
wire [`W-1:0]  A0v_I_wires  [Nmem-1:0];
wire [`W-1:0]  A1v_I_wires  [Nmem-1:0];
wire [`W-1:0]  A2v_I_wires  [Nmem-1:0];
wire [`W-1:0]  A3v_I_wires  [Nmem-1:0];
wire [`W-1:0]  A4v_I_wires  [Nmem-1:0];
wire [`W-1:0]  A5v_I_wires  [Nmem-1:0];

wire [`W-1:0]  A0v_W_wires  [Nmem-1:0];
wire [`W-1:0]  A1v_W_wires  [Nmem-1:0];
wire [`W-1:0]  A2v_W_wires  [Nmem-1:0];
wire [`W-1:0]  A3v_W_wires  [Nmem-1:0];
wire [`W-1:0]  A4v_W_wires  [Nmem-1:0];
wire [`W-1:0]  A5v_W_wires  [Nmem-1:0];

wire [`W-1:0]  A0v_Y_wires  [Nmem-1:0];
wire [`W-1:0]  A1v_Y_wires  [Nmem-1:0];
*/


wire [`W-1:0]  V1v_wires  [Nmem-1:0];
wire [`W-1:0]  V2v_wires  [Nmem-1:0];
/*
wire [`W-1:0]  V0v_I_wires  [Nmem-1:0];
wire [`W-1:0]  V1v_I_wires  [Nmem-1:0];

wire [`W-1:0]  V0v_W_wires  [Nmem-1:0];
wire [`W-1:0]  V1v_W_wires  [Nmem-1:0];

wire [`W-1:0]  V0v_Y_wires  [Nmem-1:0];
wire [`W-1:0]  V1v_Y_wires  [Nmem-1:0];
*/


wire [`W-1:0]  W1v_wires  [Nmem-1:0];
wire [`W-1:0]  W2v_wires  [Nmem-1:0];
wire [`W-1:0]  W3v_wires  [Nmem-2:0];
/*
wire [`W-1:0]  W0v_I_wires  [Nmem-1:0];
wire [`W-1:0]  W1v_I_wires  [Nmem-1:0];
wire [`W-1:0]  W2v_I_wires  [Nmem-1:0];

wire [`W-1:0]  W0v_W_wires  [Nmem-1:0];
wire [`W-1:0]  W1v_W_wires  [Nmem-1:0];
wire [`W-1:0]  W2v_W_wires  [Nmem-1:0];

wire [`W-1:0]  W0v_Y_wires  [Nmem-1:0];
*/



wire [`W-1:0]  muxAv_wires  [Nmux-1:0];
wire [`W-1:0]  muxBv_wires  [Nmux-1:0];
wire [`W-1:0] muxSelv_wires  [Nmux-1:0];

wire [`W-1:0]  M1h_wires  [Nmem-1:0];
wire [`W-1:0]  M2h_wires  [Nmem-1:0];
wire [`W-1:0]  M3h_wires  [Nmem-2:0];
wire [`W-1:0]  M4h_wires  [Nmem-2:0];
wire [`W-1:0]  M5h_wires  [Nmem-2:0];
wire [`W-1:0]  M6h_wires  [Nmem-2:0];
wire [`W-1:0]  tmp_val  [Nmem-1:0]; //what is it used for?

wire [`W-1:0]  muxh_wires  [Nmux-1:0];

reg  [`W-1:0]  Regs [Nreg-1:0];      // word_size = `W
reg  [0:`W-1]  consts [0:Nconst-1];  // word_size = `W

reg  [0:0:(first)*(second)-1] program1 [0:(`prog_size-1)];
reg  [`W-1:0] rout;


integer i;

initial
begin
$readmemb(`CONST_FILE, consts);
$readmemb(`PROGRAM_FILE, program1); 
end

assign crossbar_con = program1[Regs[`PC]];

assign out1 = Regs[1];   //output the value in reg[1]
assign out2 = rout;

genvar X,Y,Z;

generate
  for (Y = 0; Y < Nreg; Y = Y+1) begin
    assign Rh_wires[Y] = Regs[Y];  // Connecting the registers to the horizontal output
  end
endgenerate


generate
  for (Y = 0; Y < Nconst; Y = Y+1) begin
	assign Ch_wires[Y] = consts[Y];  // Connecting the constants to the horizontal output
  end
endgenerate


generate
  for (Y = 0; Y < Nop; Y = Y+1) begin
	if (Nplus > 0 && Y < Nplus) begin
	   // Applying the '+' operation
	   assign OPh_wires[Y] = OPv_wires[2*Y] + OPv_wires[2*Y+1];
	end 
    else if (Nminus > 0 && Y < Nplus+Nminus) begin
	   // Applying the '-' operation
	   assign OPh_wires[Y] = OPv_wires[2*Y] - OPv_wires[2*Y+1];
	end
	else if (Nmul > 0 && Y < Nplus+Nminus+Nmul) begin
	   // Applying the '*' operation
	   assign OPh_wires[Y] = OPv_wires[2*Y] * OPv_wires[2*Y+1];
	end
	else if(Nles > 0 && Y < Nplus+Nminus+Nmul+Nles ) begin 
	   // Applying the '<' operation
	   assign OPh_wires[Y] = OPv_wires[2*Y] < OPv_wires[2*Y+1];
	end
	else if(Nequ > 0 && Y < Nplus+Nminus+Nmul+Nles+Nequ) begin
		// Applying the '==' operation
		assign OPh_wires[Y] = OPv_wires[2*Y] == OPv_wires[2*Y+1];
	end
  end
endgenerate
//done


generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regreg(Rv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+X]);
	  end
    end
  end
endgenerate
//done

generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 opreg(Rv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+X]);
	  end
    end
  end
endgenerate
//done

generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regop(OPv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+X]);
	  end
    end
  end
endgenerate
//done

generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
        bufif1 opop(OPv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+X]);
      end
	end
  end
endgenerate
//done

generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constreg(Rv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+X]);
	  end
    end
  end
endgenerate
//done

generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constop(OPv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+X]);
	  end
    end
  end
endgenerate
//done

//Rv[X] = muxh[Y]
generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nmux; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 muxreg(Rv_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+X]);
	  end
    end
  end
endgenerate
//done


//Opv[X] = muxh[Y]
generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nmux; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 muxop(OPv_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+X]);
	  end
    end
  end
endgenerate
//done


//Rv[X] = M1h[Y]
//Rv[X] = M2h[Y]
//Rv[X] = M3h[Y]
//Rv[X] = M4h[Y]
//Rv[X] = M5h[Y]
//Rv[X] = M6h[Y]
generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nmem; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 memreg1(Rv_wires[X][Z], M1h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux)+(first)*Y+X]);
		bufif1 memreg2(Rv_wires[X][Z], M2h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+1)+(first)*Y+X]);
		if(Y != 2) begin //the third mem is dualram, it has only M1h and M2h
			bufif1 memreg3(Rv_wires[X][Z], M3h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+2)+(first)*Y+X]);
			bufif1 memreg4(Rv_wires[X][Z], M4h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+3)+(first)*Y+X]);
			bufif1 memreg5(Rv_wires[X][Z], M5h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+4)+(first)*Y+X]);
			bufif1 memreg6(Rv_wires[X][Z], M6h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+5)+(first)*Y+X]);
	  	end
	  end
    end
  end
endgenerate
//done

//Opv[X] = M1h[Y]
//Opv[X] = M2h[Y]
//Opv[X] = M3h[Y]
//Opv[X] = M4h[Y]
//Opv[X] = M5h[Y]
//Opv[X] = M6h[Y]
generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nmem; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 memop1(OPv_wires[X][Z], M1h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux)+(first)*Y+Nreg+X]);
		bufif1 memop2(OPv_wires[X][Z], M2h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+1)+(first)*Y+Nreg+X]);
		if(Y != 2) begin
			bufif1 memop3(OPv_wires[X][Z], M3h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+2)+(first)*Y+Nreg+X]);
			bufif1 memop4(OPv_wires[X][Z], M4h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+3)+(first)*Y+Nreg+X]);
			bufif1 memop3(OPv_wires[X][Z], M5h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+4)+(first)*Y+Nreg+X]);
			bufif1 memop4(OPv_wires[X][Z], M6h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+5)+(first)*Y+Nreg+X]);
		end
	  end
    end
  end
endgenerate
//done


//A1v[X] = Rh[Y]
//A2v[X] = Rh[Y]
//A3v[X] = Rh[Y]
//A4v[X] = Rh[Y]
//V1v[X] = Rh[Y]
//V2v[X] = Rh[Y]
//W1v[X] = Rh[Y]
//W2v[X] = Rh[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regmem1(A1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X]);
		bufif1 regmem2(A2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+1]);
		if(Y!=2)
		{
			bufif1 regmem3(A3v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+2]);
			bufif1 regmem4(A4v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+3]);
			bufif1 regmem5(A5v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+4]);
			bufif1 regmem6(A6v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+5]);

		}
		
		if(Y==2)
		{
			bufif1 regmem5(V1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+4]);
			bufif1 regmem6(V2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+5]);
			bufif1 regmem7(W1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+6]);
			bufif1 regmem8(W2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+7]);
		}
		else
		{
			bufif1 regmem7(V1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+6]);
			bufif1 regmem8(V2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+7]);
			
			bufif1 regmem9(W1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+8]);
			bufif1 regmem10(W2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+9]);
		}
		
	  end
    end
  end
endgenerate
//done

//muxAv[X]   = Rh[Y]
//muxBv[X]   = Rh[Y]
//muxSelv[X] = Rh[Y]
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regmux1(muxAv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X]);
		bufif1 regmux2(muxBv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+1]);
		bufif1 regmux3(muxSelv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X+2]);
	  end
    end
  end
endgenerate
//done


//A1v[X] = Oph[Y]
//A2v[X] = Oph[Y]
//A3v[X] = Oph[Y]
//A4v[X] = Oph[Y]
//V1v[X] = Oph[Y]
//V2v[X] = Oph[Y]
//V3v[X] = Oph[Y]
//V4v[X] = Oph[Y]
//W1v[X] = Oph[Y]
//W2v[X] = Oph[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
        bufif1 opmem1(A1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X]);
        bufif1 opmem2(A2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+1]);
		if(X!=2)
		{
			bufif1 opmem3(A3v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+2]);
       		bufif1 opmem4(A4v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+3]);
       	 	bufif1 opmem5(A5v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+4]);
        	bufif1 opmem6(A6v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+5]);
        
		}
        
		if(X==2)
		{
			bufif1 opmem3(V1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+2]);
        	bufif1 opmem4(V2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+3]);
        	bufif1 opmem5(W1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+4]);
			bufif1 opmem6(W2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+5]);
		}
		else
		{
			bufif1 opmem7(V1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+6]);
        	bufif1 opmem8(V2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+7]);
        	bufif1 opmem9(W1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+8]);
        	bufif1 opmem10(W2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+9]);
		}
		
      end
	end
  end
endgenerate
//done

//muxAv[X]   = Oph[Y]
//muxBv[X]   = Oph[Y]
//muxSelv[X] = Oph[Y]
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
        bufif1 opmux1(muxAv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X]);
        bufif1 opmux2(muxBv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+1]);
        bufif1 opmux3(muxSelv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X+2]);
      end
	end
  end
endgenerate
//done

//A1v[X] = Ch[Y]
//A2v[X] = Ch[Y]
//A3v[X] = Ch[Y]
//A4v[X] = Ch[Y]
//V1v[X] = Ch[Y]
//V2v[X] = Ch[Y]
//W1v[X] = Ch[Y]
//W2v[X] = Ch[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constmem1(A1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X]);
		bufif1 constmem2(A2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+1]);
		if(X!=2)
		{
			bufif1 constmem3(A3v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+2]);
			bufif1 constmem4(A4v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+3]);
			bufif1 constmem5(A5v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+4]);
			bufif1 constmem6(A6v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+5]);
	
		}
		
		if(X==2)
		{
			bufif1 constmem3(V1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+2]);
			bufif1 constmem4(V2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+3]);
			bufif1 constmem5(W1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+4]);
			bufif1 constmem6(W2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+5]);
		}
		else
		{
			bufif1 constmem7(V1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+6]);
			bufif1 constmem8(V2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+7]);
			bufif1 constmem9(W1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+8]);
			bufif1 constmem10(W2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+9]);
		}
		
	  end
    end
  end
endgenerate
//done

//muxAv[X]   = Ch[Y]
//muxBv[X]   = Ch[Y]
//muxSelv[X] = Ch[Y]
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constmux1(muxAv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X]);
		bufif1 constmux2(muxBv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+1]);
		bufif1 constmux3(muxSelv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X+2]);
	  end
    end
  end
endgenerate

/*
// mem
for ( X = 0; X < Nmem; X = X+1) begin
    quadram qram( V1v_wires[X], V2v_wires[X], A1v_wires[X], A2v_wires[X],A3v_wires[X], A4v_wires[X],
        W1v_wires[X][0], W2v_wires[X][0], clk, M1h_wires[X], M2h_wires[X], M3h_wires[X], M4h_wires[X]);
        
end
*/
//what is W1v_wires[X][0]

hexaram1 I( V1v_wires[X], V2v_wires[X], A1v_wires[X], A2v_wires[X],A3v_wires[X], A4v_wires[X], A5v_wires[X], A6v_wires[X],
        W1v_wires[X][0], W2v_wires[X][0], clk, M1h_wires[X], M2h_wires[X], M3h_wires[X], M4h_wires[X], M5h_wires[X], M6h_wires[X]);

hexaram2 W( V1v_wires[X], V2v_wires[X], A1v_wires[X], A2v_wires[X],A3v_wires[X], A4v_wires[X], A5v_wires[X], A6v_wires[X],
        W1v_wires[X][0], W2v_wires[X][0], clk, M1h_wires[X], M2h_wires[X], M3h_wires[X], M4h_wires[X], M5h_wires[X], M6h_wires[X]);

dualram Y( V1v_wires[X], V2v_wires[X], A1v_wires[X], A2v_wires[X], W1v_wires[X][0], W2v_wires[X][0],
		clk, M1h_wires[X], M2h_wires[X] );


// mux
for ( X = 0; X < Nmux; X = X+1) begin
    muxmodule mm(muxAv_wires[X],muxBv_wires[X], muxSelv_wires[X][0], muxh_wires[X]);    
end

always @(posedge clk)
begin
	if(reset == 1) begin
	   for ( i = 0; i < Nreg; i = i+1) begin
	     if (i == `PC) begin
	       Regs[`PC] <= in;
	     end
	     else begin
	       Regs[i] <= 0;
	     end
	   end
	end
	else begin
	   for ( i = 0; i < Nreg; i = i+1) begin
		 if (Rv_wires[i] !== `W'bz) begin // ignore z values that are generated from the bufif
           Regs[i] <= Rv_wires[i];
          end
		end
	   rout <= consts[0];
	end
end

endmodule

