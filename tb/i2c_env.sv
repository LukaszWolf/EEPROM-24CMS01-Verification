`ifndef I2C_ENV_SV
`define I2C_ENV_SV

class i2c_env extends uvm_env;
    `uvm_component_utils(i2c_env)

    i2c_sequencer m_seqr;
    i2c_driver    m_drv;
    i2c_monitor   m_monitor;
    i2c_scoreboard m_scb;
    i2c_config     m_cfg;
    i2c_coverage   m_cov;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        m_seqr = i2c_sequencer::type_id::create("m_seqr", this);
        m_drv  = i2c_driver::type_id::create("m_drv", this);
        m_monitor = i2c_monitor::type_id::create("m_monitor", this);
        m_scb     = i2c_scoreboard::type_id::create("m_scb", this);
        m_cov     = i2c_coverage::type_id::create("m_cov", this);
        if (!uvm_config_db#(i2c_config)::get(this, "", "m_cfg", m_cfg)) begin
            `uvm_warning("ENV_BUILD", "config i2c_config not found in config_db, using default settings.")
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_drv.seq_item_port.connect(m_seqr.seq_item_export);
        
        if (m_cfg == null || m_cfg.scoreboard_enable == 1'b1) begin
            `uvm_info("ENV_CONNECT", "Connecting monitor analysis port to scoreboard.", UVM_LOW)
            m_monitor.ap.connect(m_scb.mon_export);
        end else begin
            `uvm_info("ENV_CONNECT", "Scoreboard disabled in configuration.", UVM_LOW)
        end

        if (m_cfg == null || m_cfg.coverage_enable == 1'b1) begin
            `uvm_info("ENV_CONNECT", "Connecting monitor analysis port to coverage.", UVM_LOW)
            m_monitor.ap.connect(m_cov.analysis_export); 
        end
    endfunction

endclass

`endif