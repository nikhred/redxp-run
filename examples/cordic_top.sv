//------------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
//
// Copyright © 2024 Allola Nikhil Reddy
//
// Module: cordic_top.sv
// Description: 
// 
// Author: Nikhil Reddy (redxp)
// Date: 20-03-2024
//------------------------------------------------------------------------------

module cordic_top (
    input clk,
    input reset_n,

    input logic [31:0] s_tdata,
    input logic s_tvalid,
    input logic s_tlast,
    output logic s_tready,

    output logic m_tdata,
    output logic m_tvalid,
    output logic m_tlast,
    input logic m_tready
);

cordic_0 i_cordic (
  .aclk(clk),                                        // input wire aclk
  .aresetn(reset_n),                                  // input wire aresetn

  .s_axis_cartesian_tvalid(s_tvalid),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tready(s_tready),  // output wire s_axis_cartesian_tready
  .s_axis_cartesian_tlast(s_tlast),    // input wire s_axis_cartesian_tlast
  .s_axis_cartesian_tdata(s_tdata),    // input wire [31 : 0] s_axis_cartesian_tdata

  .m_axis_dout_tvalid(m_tvalid),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tready(m_tready),            // input wire m_axis_dout_tready
  .m_axis_dout_tlast(m_tlast),              // output wire m_axis_dout_tlast
  .m_axis_dout_tdata(m_tdata)              // output wire [15 : 0] m_axis_dout_tdata
);

endmodule
