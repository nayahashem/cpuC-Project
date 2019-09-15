`include "params.vh"
//hexaram for mem I
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

module hexaram ( input [`W-1:0] data_a, data_b, input [`W-1:0] addr_a, addr_b,addr_c, addr_d, addr_e, addr_f
        input we_a, we_b, clk, output wire [`W-1:0] q_a, q_b,q_c, q_d, q_e, q_f);
        
wire [`W-1:0] addr_x, addr_y;
//for second dualram
assign addr_x = (we_a)?addr_a : addr_c;
assign addr_y = (we_b)?addr_b : addr_d;
//for third dualram
assign addr_z = (we_a)?add_a : addr_e;
assign addr_w = (we_b)?add_b : addr_f;

dualram mem1(data_a, data_b, addr_a, addr_b, we_a, we_b, clk, q_a, q_b);
dualram mem2(data_a, data_b, addr_x, addr_y, we_a, we_b, clk, q_c, q_d);
dualram mem3(data_a, data_b, addr_z, addr_w, we_a, we_b, clk, q_e, q_f);

endmodule
