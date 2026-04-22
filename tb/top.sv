`timescale 1ns / 10ps

module top();
    wire clk, rst_n;
    operation_t op_sel;
    wire start;
    wire [7:0] wdata;
    wire [23:0] read_data;
    wire busy, done;

    tb_top i_tb (
        .clk(clk),
        .rst_n(rst_n),
        .op_sel(op_sel), 
        .start(start),
        .write_data_in  (wdata), 
        .read_data(read_data), 
        .busy(busy), 
        .done(done)
    );

    dut i_dut (
        .clk(clk), 
        .rst_n(rst_n),
        .op_sel(op_sel), 
        .start(start),
        .write_data_in  (wdata), 
        .read_data(read_data), 
        .busy(busy), 
        .done(done)
    );
    initial begin
        `ifdef DUMP_WAVES
            $dumpfile("dump.vcd");
            $dumpvars(0, top);
        `endif
    end

endmodule