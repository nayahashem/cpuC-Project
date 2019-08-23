`include "params.vh"

module  muxmodule(
input [`W-1:0] a, b,
input sel,
output [`W-1:0] out
);

assign out = (sel) ? a : b;

endmodule
