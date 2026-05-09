`ifndef I2C_DRIVER_SV
`define I2C_DRIVER_SV

class i2c_driver extends uvm_driver #(i2c_item);
    `uvm_component_utils(i2c_driver)

    virtual i2c_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_full_name(), "Cannot get virtual interface 'vif'!") 
        end
    endfunction

    virtual task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "Reset DUT...", UVM_LOW)
        
        vif.rst_n <= 1'b0;
        vif.start <= 1'b0;
        #100ns;
        vif.rst_n <= 1'b1;
        
        phase.drop_objection(this);
    endtask

    virtual task main_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            
            `uvm_info(get_type_name(), $sformatf("Driving: %s", req.convert2string()), UVM_MEDIUM)

            @(posedge vif.clk);
            vif.addr_in       <= req.addr;
            vif.write_data_in <= req.wdata;
            vif.datacount     <= req.count;
            vif.op_sel        <= req.op;
            vif.start         <= 1'b1;
            
            do begin
                @(posedge vif.clk);
            end while (vif.busy !== 1'b1);
            
            vif.start <= 1'b0;

            do begin
                @(posedge vif.clk);
            end while (vif.done !== 1'b1);
            
            req.rdata = vif.read_data;
            seq_item_port.item_done();
        end
    endtask

endclass

`endif