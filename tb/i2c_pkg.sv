package i2c_pkg;
    import uvm_pkg::*;
    import i2c_operations_pkg::*;
    `include "uvm_macros.svh"
    `include "seq/i2c_sequence_item.sv"
    `include "i2c_sequencer.sv"
    `include "i2c_driver.sv"
    `include "i2c_env.sv"
    `include "seq/i2c_sequence.sv"
    `include "tests/i2c_base_test.sv"
endpackage