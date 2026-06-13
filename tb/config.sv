`ifndef I2C_CONFIG_SV
`define I2C_CONFIG_SV

class i2c_config extends uvm_object;

    bit scoreboard_enable = 1'b0;
    bit coverage_enable   = 1'b0;

    `uvm_object_utils_begin(i2c_config)
        `uvm_field_int(scoreboard_enable, UVM_ALL_ON)
        `uvm_field_int(coverage_enable,   UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "i2c_config");
        super.new(name);
    endfunction

endclass

`endif