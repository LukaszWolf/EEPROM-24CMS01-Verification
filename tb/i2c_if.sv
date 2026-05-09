interface i2c_if (input logic clk);
    import i2c_operations_pkg::*;
    
    logic [2:0]  datacount;
    logic        rst_n;
    logic        start;
    operation_t  op_sel;
    logic [15:0] addr_in;
    logic [7:0]  write_data_in;
    logic [23:0] read_data;
    logic        busy;          
    logic        done;
endinterface