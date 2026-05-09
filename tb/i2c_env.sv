`ifndef I2C_ENV_SV
`define I2C_ENV_SV

class i2c_env extends uvm_env;
    `uvm_component_utils(i2c_env)

    i2c_sequencer m_seqr;
    i2c_driver    m_drv;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        m_seqr = i2c_sequencer::type_id::create("m_seqr", this);
        m_drv  = i2c_driver::type_id::create("m_drv", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_drv.seq_item_port.connect(m_seqr.seq_item_export);
        
        `uvm_info(get_name(), "Connected driver to sequencer", UVM_LOW)
    endfunction

endclass

`endif