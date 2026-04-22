`timescale 1ns / 10ps

import i2c_operations_pkg::*;

module dut (
    input logic [15:0] addr_in,
    input  logic        clk,
    input  logic        rst_n,
    input  operation_t  op_sel,
    input  logic        start,
    input  logic [7:0]  write_data_in,
    output logic [23:0] read_data,
    output logic        busy,
    output logic        done
);
    tri1 scl; 
    tri1 sda;

    controller i_ctrl (
        .addr_in   (addr_in),
        .clk       (clk),
        .rst_n     (rst_n),
        .op_sel       (op_sel),
        .start     (start),
        .write_data_in  (write_data_in), 
        .read_data (read_data),
        .busy      (busy),
        .done      (done),
        .scl       (scl),
        .sda       (sda)
    );

    M24CSM01 i_model (
        .A1(1'b0), 
        .A2(1'b0), 
        .WP(1'b0),
        .SDA(sda), 
        .SCL(scl),
        .RESET(!rst_n)
    );
endmodule