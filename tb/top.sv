`timescale 1ns / 10ps

module top();
    import uvm_pkg::*;
    import i2c_pkg::*;

    logic clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    i2c_if vif(clk);

    dut i_dut (
        .clk            (clk),
        .rst_n          (vif.rst_n),
        .datacount      (vif.datacount),
        .addr_in        (vif.addr_in),
        .op_sel         (vif.op_sel),
        .start          (vif.start),
        .write_data_in  (vif.write_data_in),
        .read_data      (vif.read_data),
        .busy           (vif.busy),
        .done           (vif.done)
    );
 
    initial begin
        uvm_config_db#(virtual i2c_if)::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
        if ($test$plusargs("DUMP_WAVES")) begin
            $dumpfile("dump.vcd");
            $dumpvars(0, top);
        end
    end
endmodule