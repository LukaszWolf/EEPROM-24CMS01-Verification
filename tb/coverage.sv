`ifndef I2C_COVERAGE_SV
`define I2C_COVERAGE_SV

class i2c_coverage extends uvm_subscriber #(i2c_item);
    `uvm_component_utils(i2c_coverage)

    operation_t op_sampled;
    bit [15:0]  addr_sampled;

    covergroup i2c_cg;
        cp_op: coverpoint op_sampled {
            bins b_write = { OP_WRITE_DATA };
            bins b_read  = { OP_READ_DATA };
        }
        cp_addr: coverpoint addr_sampled {
            bins b_low_boundary  = { 16'h0000 };
            bins b_high_boundary = { 16'hFFFF };
            bins b_others        = { [16'h0001 : 16'hFFFE] };
        }
        cc_op_cross_addr: cross cp_op, cp_addr; 
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        i2c_cg = new();
    endfunction

    virtual function void write(i2c_item t);
        `uvm_info("COVERAGE", $sformatf("data acquired : %s", t.convert2string()), UVM_HIGH)
        op_sampled   = t.op;
        addr_sampled = t.addr;
        i2c_cg.sample();
    endfunction
endclass

`endif