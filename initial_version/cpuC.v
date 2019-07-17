/* 
 * CPUc - Switches module
 */

`include "params.vh"

module CPUC #(parameter Nop = `Nop, Nplus = `Nplus, Nminus = `Nminus, Nmul = `Nmul, Nles = `Nles, Nreg = `Nreg, Nconst = `Nconst, Nmem = `Nmem, Nmux = `Nmux) (
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

wire [0:(2*Nop+Nreg+8*Nmem+3*Nmux)*(Nop+Nreg+Nconst+4*Nmem+Nmux)-1] crossbar_con;

wire [`W-1:0]  Rh_wires  [Nreg-1:0];
wire [`W-1:0]  OPh_wires [Nop-1:0];
wire [`W-1:0]  Ch_wires  [Nconst-1:0];

wire [`W-1:0]  Rv_wires  [Nreg-1:0];
wire [`W-1:0]  OPv_wires [2*Nop-1:0];

wire [`W-1:0]  A1v_wires  [Nmem-1:0];
wire [`W-1:0]  A2v_wires  [Nmem-1:0];
wire [`W-1:0]  A3v_wires  [Nmem-1:0];
wire [`W-1:0]  A4v_wires  [Nmem-1:0];

wire [`W-1:0]  V1v_wires  [Nmem-1:0];
wire [`W-1:0]  V2v_wires  [Nmem-1:0];

wire [`W-1:0]  W1v_wires  [Nmem-1:0];
wire [`W-1:0]  W2v_wires  [Nmem-1:0];

wire [`W-1:0]  muxAv_wires  [Nmux-1:0];
wire [`W-1:0]  muxBv_wires  [Nmux-1:0];
wire [`W-1:0] muxSelv_wires  [Nmux-1:0];

wire [`W-1:0]  M1h_wires  [Nmem-1:0];
wire [`W-1:0]  M2h_wires  [Nmem-1:0];
wire [`W-1:0]  M3h_wires  [Nmem-1:0];
wire [`W-1:0]  M4h_wires  [Nmem-1:0];
wire [`W-1:0]  tmp_val  [Nmem-1:0];

wire [`W-1:0]  muxh_wires  [Nmux-1:0];

reg  [`W-1:0]  Regs [Nreg-1:0];      // word_size = `W
reg  [0:`W-1]  consts [0:Nconst-1];  // word_size = `W

reg  [0:(2*Nop+Nreg+8*Nmem+3*Nmux)*(Nop+Nreg+Nconst+4*Nmem+Nmux)-1] program1 [0:(`prog_size-1)];
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
  end
endgenerate


generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regreg(Rv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+X]);
	  end
    end
  end
endgenerate

generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 opreg(Rv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+X]);
	  end
    end
  end
endgenerate

generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regop(OPv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+X]);
	  end
    end
  end
endgenerate

generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
        bufif1 opop(OPv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+X]);
      end
	end
  end
endgenerate

generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constreg(Rv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+X]);
	  end
    end
  end
endgenerate

generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constop(OPv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+X]);
	  end
    end
  end
endgenerate

//Rv[X] = M1h[Y]
//Rv[X] = M2h[Y]
//Rv[X] = M3h[Y]
//Rv[X] = M4h[Y]
generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nmem; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 memreg1(Rv_wires[X][Z], M1h_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+X]);
		bufif1 memreg2(Rv_wires[X][Z], M2h_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst+1)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+X]);
		bufif1 memreg3(Rv_wires[X][Z], M3h_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst+2)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+X]);
		bufif1 memreg4(Rv_wires[X][Z], M4h_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst+3)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+X]);
	  end
    end
  end
endgenerate

//Rv[X] = muxh[Y]
generate
  for (X = 0; X < Nreg; X = X+1) begin
    for ( Y = 0; Y < Nmux; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 muxreg(Rv_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst+4*Nmem)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+X]);
	  end
    end
  end
endgenerate

//Opv[X] = M1h[Y]
//Opv[X] = M2h[Y]
//Opv[X] = M3h[Y]
//Opv[X] = M4h[Y]
generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nmem; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 memop1(OPv_wires[X][Z], M1h_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+X]);
		bufif1 memop2(OPv_wires[X][Z], M2h_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst+1)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+X]);
		bufif1 memop3(OPv_wires[X][Z], M3h_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst+2)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+X]);
		bufif1 memop4(OPv_wires[X][Z], M4h_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst+3)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+X]);
	  end
    end
  end
endgenerate

//Opv[X] = muxh[Y]
generate
  for (X = 0; X < 2*Nop; X = X+1) begin
    for ( Y = 0; Y < Nmux; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 muxop(OPv_wires[X][Z], muxh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop+Nconst+4*Nmem)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+X]);
	  end
    end
  end
endgenerate



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
		bufif1 regmem1(A1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X]);
		bufif1 regmem2(A2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+1]);
		bufif1 regmem3(A3v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+2]);
		bufif1 regmem4(A4v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+3]);
		bufif1 regmem5(V1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+4]);
		bufif1 regmem6(V2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+5]);
		bufif1 regmem7(W1v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+6]);
		bufif1 regmem8(W2v_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+7]);
	  end
    end
  end
endgenerate

//muxAv[X]   = Rh[Y]
//muxBv[X]   = Rh[Y]
//muxSelv[X] = Rh[Y]
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < Nreg; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 regmux1(muxAv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+8*Nmem+X]);
		bufif1 regmux2(muxBv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+8*Nmem+X+1]);
		bufif1 regmux3(muxSelv_wires[X][Z], Rh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+8*Nmem+X+2]);
	  end
    end
  end
endgenerate


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
        bufif1 opmem1(A1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X]);
        bufif1 opmem2(A2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+1]);
        bufif1 opmem3(A3v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+2]);
        bufif1 opmem4(A4v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+3]);
        bufif1 opmem5(V1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+4]);
        bufif1 opmem6(V2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+5]);
        bufif1 opmem7(W1v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+6]);
        bufif1 opmem8(W2v_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+7]);
      end
	end
  end
endgenerate

//muxAv[X]   = Oph[Y]
//muxBv[X]   = Oph[Y]
//muxSelv[X] = Oph[Y]
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < Nop; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
        bufif1 opmux1(muxAv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+8*Nmem+X]);
        bufif1 opmux2(muxBv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+8*Nmem+X+1]);
        bufif1 opmux3(muxSelv_wires[X][Z], OPh_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*Nreg+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+8*Nmem+X+2]);
      end
	end
  end
endgenerate

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
		bufif1 constmem1(A1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X]);
		bufif1 constmem2(A2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+1]);
		bufif1 constmem3(A3v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+2]);
		bufif1 constmem4(A4v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+3]);
		bufif1 constmem5(V1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+4]);
		bufif1 constmem6(V2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+5]);
		bufif1 constmem7(W1v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+6]);
		bufif1 constmem8(W2v_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+X+7]);
	  end
    end
  end
endgenerate

//muxAv[X]   = Ch[Y]
//muxBv[X]   = Ch[Y]
//muxSelv[X] = Ch[Y]
generate
  for (X = 0; X < Nmux; X = X+1) begin
    for ( Y = 0; Y < Nconst; Y = Y+1) begin
	  for ( Z = `W-1; Z >= 0 ; Z = Z-1) begin
		bufif1 constmux1(muxAv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+8*Nmem+X]);
		bufif1 constmux2(muxBv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+8*Nmem+X+1]);
		bufif1 constmux3(muxSelv_wires[X][Z], Ch_wires[Y][Z], crossbar_con[(Nreg+2*Nop+8*Nmem+3*Nmux)*(Nreg+Nop)+(Nreg+2*Nop+8*Nmem+3*Nmux)*Y+Nreg+2*Nop+8*Nmem+X+2]);
	  end
    end
  end
endgenerate


// mem
for ( X = 0; X < Nmem; X = X+1) begin
    quadram qram( V1v_wires[X], V2v_wires[X], A1v_wires[X], A2v_wires[X],A3v_wires[X], A4v_wires[X],
        W1v_wires[X][0], W2v_wires[X][0], clk, M1h_wires[X], M2h_wires[X], M3h_wires[X], M4h_wires[X]);
        
end

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

