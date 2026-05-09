`ifndef I2C_BASE_TEST_SV
`define I2C_BASE_TEST_SV

class i2c_base_test extends uvm_test;
    `uvm_component_utils(i2c_base_test)

    i2c_env m_env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_env = i2c_env::type_id::create("m_env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("TOPOLOGY", "\n--- UVM TOPOLOGY ---", UVM_LOW)
        uvm_top.print_topology();
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_top.set_timeout(500ms, 0); 
    endfunction

    virtual task main_phase(uvm_phase phase);
        i2c_aggressive_seq m_seq = i2c_aggressive_seq::type_id::create("m_seq");
        
        phase.get_objection().set_drain_time(this, 50us); 
        phase.raise_objection(this);

        `uvm_info(get_name(), "Coverage tests started", UVM_LOW)
        m_seq.start(m_env.m_seqr);

        phase.drop_objection(this);
    endtask

endclass

`endif