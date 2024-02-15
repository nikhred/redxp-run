//------------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
//
// Copyright © 2024 Allola Nikhil Reddy
//
// Module: operators.sv
// Description: set of modules to compute the resources and max frequency for given 
// FPGA device/architecture. The metrics in a standalone setup might slightly vary from a
// larger design but they give an idea
// 
// Author: Nikhil Reddy (RedXP)
// Date: 15-02-2024
//------------------------------------------------------------------------------

module add2 #(
    parameter int DW = 8
)(
    input [DW - 1:0] a,
    input [DW - 1:0] b,
    output [DW + 1 - 1:0] q
);

assign q = a + b;

endmodule

module add4 #(
    parameter int DW = 8
)(
    input [DW - 1:0] a,
    input [DW - 1:0] b,
    input [DW - 1:0] c,
    input [DW - 1:0] d, 
    output [DW + 1 - 1:0] q
);

assign q = a + b + c + d;

endmodule

module add8 #(
    parameter int DW = 8
)(
    input [DW - 1:0] a,
    input [DW - 1:0] b,
    input [DW - 1:0] c,
    input [DW - 1:0] d, 
    input [DW - 1:0] e,
    input [DW - 1:0] f,
    input [DW - 1:0] g,
    input [DW - 1:0] h, 
    output [DW + 1 - 1:0] q
);

assign q = a + b + c + d + e + f + g + h;

endmodule

module mul #(
    parameter int DW = 8
)(
    input [DW - 1:0] a,
    input [DW - 1:0] b,
    output [2*DW - 1:0] c
);

assign c = a * b;

endmodule

module increment_by_n #(
    parameter int DW = 8,
    parameter logic [DW - 1:0] N = 1
)(
    input [DW - 1:0] a,
    output [DW + 1 - 1:0] q
);

assign q = a + N;

endmodule

module equal #(
    parameter int DW = 8
)(
    input [DW - 1:0] a,
    input [DW - 1:0] b,
    output s
);

assign s = (a == b);

endmodule

module greater #(
    parameter int DW = 8
)(
    input [DW - 1:0] a,
    input [DW - 1:0] b,
    output s
);

assign s = (a > b);

endmodule

module greater_equal #(
    parameter int DW = 8
)(
    input [DW - 1:0] a,
    input [DW - 1:0] b,
    output s
);

assign s = (a >= b);

endmodule

module ternary #(
    parameter int DW = 8
)(
    input [DW - 1:0] a,
    input [DW - 1:0] b,
    input s,
    output [DW + 1 - 1:0] q
);

assign q = (s == 1) ? a:b;

endmodule

module test_if #(
    parameter int DW = 8
)(
    input [DW - 1:0] a,
    input [DW - 1:0] b,
    input s,
    output logic [DW + 1 - 1:0] q
);

always_comb begin
    if(s == 1) begin
        q = a;
    end else begin
        q = b;
    end    
end

endmodule


module test_case #(
    parameter int DW = 8,
    parameter int NUM = 4,
    parameter int SW = $clog2(NUM)
)(
    input [DW * NUM - 1:0] a,
    input [SW - 1:0] s,
    output logic [DW + 1 - 1:0] q
);

always_comb begin
    case(s)

    endcase
end

endmodule