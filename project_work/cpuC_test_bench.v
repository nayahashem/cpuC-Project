`include "params.vh"

// Testbench
module cpuC_TestBench #(parameter Nop = `Nop, Nplus = `Nplus, Nminus = `Nminus, Nmul = `Nmul, Nles = `Nles, Nreg = `Nreg, Nconst = `Nconst, Nmem = `Nmem, Nmux = `Nmux);

reg clk;
reg rst;
reg [`W-1:0] in;
wire [`W-1:0] out1;
wire [`W-1:0] out2;

CPUC #(Nop, Nplus, Nminus, Nmul, Nles, Nreg, Nconst, Nmem) cpuC ( clk, rst, in, out1, out2);

initial begin
    in = 0;
    rst = 1;
    clk = 1;
    toggle_clk;
         
  	rst = 0;
  
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;
    toggle_clk;            
end

  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask

endmodule
