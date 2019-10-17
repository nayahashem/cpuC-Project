`include "params.vh"
//dualram for mem Y
module dualram ( input [`W-1:0] data_x, data_y, input [`W-1:0] addr_x, addr_y, input we_x, we_y, clk, output reg [`W-1:0] q_x, q_y);
    integer i,j;
        reg [`W-1:0] ram[`M-1:0];
        initial begin
            for (i=0; i<`M; i=i+1)
                ram[i] = 0;
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

