`ifndef I2C_LONG_READ_TEST_SV
`define I2C_LONG_READ_TEST_SV

class i2c_long_read_test extends i2c_base_test;
    `uvm_component_utils(i2c_long_read_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task main_phase(uvm_phase phase);
        i2c_long_read_seq seq = i2c_long_read_seq::type_id::create("seq");
        phase.get_objection().set_drain_time(this, 50us);
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "Directed test: long read of injected data", UVM_LOW)
        seq.start(m_env.m_seqr);
        phase.drop_objection(this);
    endtask
endclass

`endif
