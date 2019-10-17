/* 
 * CPUc - Switches module
 */

`include "params.vh"

module CPUC #(parameter Nop = `Nop, Nplus = `Nplus, Nminus = `Nminus, Nmul = `Nmul, Nles = `Nles,Nequ = `Nequ, Nreg = `Nreg, Nconst = `Nconst, Imem = `Imem, Wmem = `Wmem, Ymem = `Ymem, Nmem = `Nmem, Nmux = `Nmux, NA = `NA, NV = `NV, NW = `NW, first = `first, second = `second) (
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

wire [`W-1:0]  V1v_wires  [Nmem-1:0];
wire [`W-1:0]  V2v_wires  [Nmem-1:0];

wire [`W-1:0]  W1v_wires  [Nmem-1:0];
wire [`W-1:0]  W2v_wires  [Nmem-1:0];


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
//done1

generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 opreg(Rv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+X]);
	  end
    end
  end
endgenerate
//done1

generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regop(OPv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+X]);
	  end
    end
  end
endgenerate
//done1

generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
        bufif1 opop(OPv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+X]);
      end
	end
  end
endgenerate
//done1

generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constreg(Rv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+X]);
	  end
    end
  end
endgenerate
//done1

generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constop(OPv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+X]);
	  end
    end
  end
endgenerate
//done1

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
//done1


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
//done1


//Rv[X] = M1h[Y]
//Rv[X] = M2h[Y]
//Rv[X] = M3h[Y]
//Rv[X] = M4h[Y]
//Rv[X] = M5h[Y]
//Rv[X] = M6h[Y]
generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < 14; Y = Y+6) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 memreg1(Rv_wires[X][Z], M1h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux)+(first)*Y+X]);
		bufif1 memreg2(Rv_wires[X][Z], M2h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+1)+(first)*Y+X]);
		if(Y != 12) begin //the third mem is dualram, it has only M1h and M2h
			bufif1 memreg3(Rv_wires[X][Z], M3h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+2)+(first)*Y+X]);
			bufif1 memreg4(Rv_wires[X][Z], M4h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+3)+(first)*Y+X]);
			bufif1 memreg5(Rv_wires[X][Z], M5h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+4)+(first)*Y+X]);
			bufif1 memreg6(Rv_wires[X][Z], M6h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+5)+(first)*Y+X]);
	  	end
	  end
    end
  end
endgenerate
//done1

//Opv[X] = M1h[Y]
//Opv[X] = M2h[Y]
//Opv[X] = M3h[Y]
//Opv[X] = M4h[Y]
//Opv[X] = M5h[Y]
//Opv[X] = M6h[Y]
generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < 14; Y = Y+6) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 memop1(OPv_wires[X][Z], M1h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux)+(first)*Y+Nreg+X]);
		bufif1 memop2(OPv_wires[X][Z], M2h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+1)+(first)*Y+Nreg+X]);
		if(Y != 12) begin
			bufif1 memop3(OPv_wires[X][Z], M3h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+2)+(first)*Y+Nreg+X]);
			bufif1 memop4(OPv_wires[X][Z], M4h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+3)+(first)*Y+Nreg+X]);
			bufif1 memop3(OPv_wires[X][Z], M5h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+4)+(first)*Y+Nreg+X]);
			bufif1 memop4(OPv_wires[X][Z], M6h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+5)+(first)*Y+Nreg+X]);
		end
	  end
    end
  end
endgenerate
//done1


//A1v[X] = Rh[Y]
//A2v[X] = Rh[Y]
//A3v[X] = Rh[Y]
//A4v[X] = Rh[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regmema1(A1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+X*6]);
		bufif1 regmema2(A2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+X*6+1]);
		if(X!=2)
		{
			bufif1 regmema3(A3v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+X*6+2]);
			bufif1 regmema4(A4v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+X*6+3]);
			bufif1 regmema5(A5v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+X*6+4]);
			bufif1 regmema6(A6v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+X*6+5]);

		}
	  end
    end
  end
endgenerate
//done1


//V1v[X] = Rh[Y]
//V2v[X] = Rh[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
			bufif1 regmemv1(V1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+NA+X*2]);
			bufif1 regmemv2(V2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+NA+X*2+1]);
			
	  end
    end
  end
endgenerate
//done1


//W1v[X] = Rh[Y]
//W2v[X] = Rh[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
			bufif1 regmemw1(W1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+NA+NV+X*2]);
			bufif1 regmemw2(W2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+3*Nmux+NA+NV+X*2+1]);
	  end
    end
  end
endgenerate
//done1

//muxAv[X]   = Rh[Y]
//muxBv[X]   = Rh[Y]
//muxSelv[X] = Rh[Y]
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regmux1(muxAv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X*3]);
		bufif1 regmux2(muxBv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X*3+1]);
		bufif1 regmux3(muxSelv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(first)*Y+Nreg+2*Nop+X*3+2]);
	  end
    end
  end
endgenerate
//done1


//A1v[X] = Oph[Y]
//A2v[X] = Oph[Y]
//A3v[X] = Oph[Y]
//A4v[X] = Oph[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
        bufif1 opmema1(A1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+X*6]);
        bufif1 opmema2(A2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+1]);
		if(X!=2)
		{
			bufif1 opmema3(A3v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+2]);
       		bufif1 opmema4(A4v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+3]);
       	 	bufif1 opmema5(A5v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+4]);
        	bufif1 opmema6(A6v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+5]);
        
		}
      end
	end
  end
endgenerate
//done1


//V1v[X] = Oph[Y]
//V2v[X] = Oph[Y]
//V3v[X] = Oph[Y]
//V4v[X] = Oph[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 opmemv1(V1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+NA+X*2]);
        bufif1 opmemv2(V2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+NA+X*2+1]);
      end
	end
  end
endgenerate
//done1


//W1v[X] = Oph[Y]
//W2v[X] = Oph[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
     	bufif1 opmemw1(W1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+NA+NV+X*2]);
    	bufif1 opmemw2(W2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+3*Nmux+NA+NV+X*2+1]);		
      end
	end
  end
endgenerate
//done1

//muxAv[X]   = Oph[Y]
//muxBv[X]   = Oph[Y]
//muxSelv[X] = Oph[Y]
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
        bufif1 opmux1(muxAv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X*3]);
        bufif1 opmux2(muxBv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X*3+1]);
        bufif1 opmux3(muxSelv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(first)*Nreg+(first)*Y+Nreg+2*Nop+X*3+2]);
      end
	end
  end
endgenerate
//done1

//A1v[X] = Ch[Y]
//A2v[X] = Ch[Y]
//A3v[X] = Ch[Y]
//A4v[X] = Ch[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constmema1(A1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6]);
		bufif1 constmema2(A2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+1]);
		if(X!=2)
		{
			bufif1 constmema3(A3v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+2]);
			bufif1 constmema4(A4v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+3]);
			bufif1 constmema5(A5v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+4]);
			bufif1 constmema6(A6v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+5]);
	
		}
	  end
    end
  end
endgenerate
//done1


//V1v[X] = Ch[Y]
//V2v[X] = Ch[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constmemv1(V1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+NA+X*2]);
		bufif1 constmemv2(V2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+NA+X*2+1]);

	  end
    end
  end
endgenerate
//done1

//W1v[X] = Ch[Y]
//W2v[X] = Ch[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constmemw1(W1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+NA+NV+X*2]);
		bufif1 constmemw2(W2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+3*Nmux+NA+NV+X*2+1]);
	  end
    end
  end
endgenerate
//done1

//muxAv[X]   = Ch[Y]
//muxBv[X]   = Ch[Y]
//muxSelv[X] = Ch[Y]
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constmux1(muxAv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X*3]);
		bufif1 constmux2(muxBv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X*3+1]);
		bufif1 constmux3(muxSelv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop)+(first)*Y+Nreg+2*Nop+X*3+2]);
	  end
    end
  end
endgenerate
//done1


//A1v[X] = muxh[Y]
//A2v[X] = muxh[Y]
//A3v[X] = muxh[Y]
//A4v[X] = muxh[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nmux; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 muxmema1(A1v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6]);
		bufif1 muxmema2(A2v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+1]);
		if(X!=2)
		{
			bufif1 muxmema3(A3v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+2]);
			bufif1 muxmema4(A4v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+3]);
			bufif1 muxmema5(A5v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+4]);
			bufif1 muxmema6(A6v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+X*6+5]);
	
		}
	  end
    end
  end
endgenerate
//done1

//V1v[X] = muxh[Y]
//V2v[X] = muxh[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nmux; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 muxmemv1(V1v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+NA+X*2]);
		bufif1 muxmemv2(V2v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+NA+X*2+1]);

	  end
    end
  end
endgenerate
//done1


//W1v[X] = muxh[Y]
//W2v[X] = muxh[Y]
generate
  for (X = 0; X < Nmem; X = X+1) begin
    for ( Y = 0; Y < Nmux; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 muxmemw1(W1v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+NA+NV+X*2]);
		bufif1 muxmemw2(W2v_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst)+(first)*Y+Nreg+2*Nop+3*Nmux+NA+NV+X*2+1]);
	  end
    end
  end
endgenerate
//done1


//muxAv[X]   = M1h[Y]
//muxBv[X]   = M1h[Y]
//muxSelv[X] = M1h[Y]
//muxAv[X]   = M2h[Y]
//muxBv[X]   = M2h[Y]
//muxSelv[X] = M2h[Y]
//muxAv[X]   = M3h[Y]
//muxBv[X]   = M3h[Y]
//muxSelv[X] = M3h[Y]
//....
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < 14; Y = Y+6) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin

		bufif1 memmux11(muxAv_wires[X][Z], M1h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux)+(first)*Y+Nreg+2*Nop+X*3]);
        bufif1 memmux12(muxBv_wires[X][Z], M1h_wires[Y][Z], crossbar_con[((first)*(Nreg+Nop+Nconst+Nmux)+(first)*Y+Nreg+2*Nop+X*3+1]);
        bufif1 memmux13(muxSelv_wires[X][Z], M1h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux)+(first)*Y+Nreg+2*Nop+X*3+2]);

		bufif1 memmux21(muxAv_wires[X][Z], M2h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+1)+(first)*Y+Nreg+2*Nop+X*3]);
        bufif1 memmux22(muxBv_wires[X][Z], M2h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+1)+(first)*Y+Nreg+2*Nop+X*3+1]);
        bufif1 memmux23(muxSelv_wires[X][Z], M2h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+1)+(first)*Y+Nreg+2*Nop+X*3+2]);

		if(Y != 12) begin
			bufif1 memmux31(muxAv_wires[X][Z], M3h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+2)+(first)*Y+Nreg+2*Nop+X*3]);
        	bufif1 memmux32(muxBv_wires[X][Z], M3h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+2)+(first)*Y+Nreg+2*Nop+X*3+1]);
    		bufif1 memmux33(muxSelv_wires[X][Z], M3h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+2)+(first)*Y+Nreg+2*Nop+X*3+2]);

			bufif1 memmux41(muxAv_wires[X][Z], M4h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+3)+(first)*Y+Nreg+2*Nop+X*3]);
        	bufif1 memmux42(muxBv_wires[X][Z], M4h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+3)+(first)*Y+Nreg+2*Nop+X*3+1]);
        	bufif1 memmux43(muxSelv_wires[X][Z], M4h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+3)+(first)*Y+Nreg+2*Nop+X*3+2]);

			bufif1 memmux51(muxAv_wires[X][Z], M5h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+4)+(first)*Y+Nreg+2*Nop+X*3]);
        	bufif1 memmux52(muxBv_wires[X][Z], M5h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+4)+(first)*Y+Nreg+2*Nop+X*3+1]);
        	bufif1 memmux53(muxSelv_wires[X][Z], M5h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+4)+(first)*Y+Nreg+2*Nop+X*3+2]);

			bufif1 memmux61(muxAv_wires[X][Z], M6h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+5)+(first)*Y+Nreg+2*Nop+X*3]);
        	bufif1 memmux62(muxBv_wires[X][Z], M6h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+5)+(first)*Y+Nreg+2*Nop+X*3+1]);
        	bufif1 memmux63(muxSelv_wires[X][Z], M6h_wires[Y][Z], crossbar_con[(first)*(Nreg+Nop+Nconst+Nmux+5)+(first)*Y+Nreg+2*Nop+X*3+2]);
		end
      end
	end
  end
endgenerate
//done1





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

