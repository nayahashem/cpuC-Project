`include "params.vh"

module dualram ( input [`W-1:0] data_x, data_y, input [`W-1:0] addr_x, addr_y, input we_x, we_y, clk, output reg [`W-1:0] q_x, q_y);
    integer i,j;
        reg [`W-1:0] ram[`M-1:0];
        initial begin
            for (i=0; i<`M; i=i+1)
                ram[i] = 1;
        end
        always @ (posedge clk) begin
            if(we_x !== `W'bz && we_y !== `W'bz) begin
                if(we_x) begin ram[addr_x] <= data_x; end else  q_x <= ram[addr_x]; end
            end
        always @ (posedge clk) begin
            if(we_x !== `W'bz && we_y !== `W'bz) begin 
                if(we_y) begin ram[addr_y] <= data_y; end else q_y <= ram[addr_y]; end
            end
endmodule

module quadram ( input [`W-1:0] data_a, data_b, input [`W-1:0] addr_a, addr_b,addr_c, addr_d,
        input we_a, we_b, clk, output wire [`W-1:0] q_a, q_b,q_c, q_d);
        
wire [`W-1:0] addr_x, addr_y;
assign addr_x = (we_a)?addr_a : addr_c;
assign addr_y = (we_b)?addr_b : addr_d;
dualram mem1(data_a, data_b, addr_a, addr_b,we_a, we_b, clk, q_a, q_b);
dualram mem2(data_a, data_b, addr_x, addr_y,we_a, we_b, clk, q_c, q_d);
endmodule
