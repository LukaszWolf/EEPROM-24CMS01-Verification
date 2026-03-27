module top();
    logic clk_wire;
    logic rstn_wire;
    logic [3:0] count_wire;

    // Połączenie TB -> DUT
    top_tb u_tb (
        .clk  (clk_wire),
        .rstn (rstn_wire)
    );

    dut u_dut (
        .clk   (clk_wire),
        .rstn  (rstn_wire),
        .count (count_wire)
    );
endmodule



