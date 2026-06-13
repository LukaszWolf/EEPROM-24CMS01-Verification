class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)

    virtual i2c_if vif;
    uvm_analysis_port #(i2c_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("MONITOR", "Nie znaleziono wirtualnego interfejsu w config_db!")
        end
    endfunction

virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            if (vif.done === 1'b1) begin
                i2c_item item = i2c_item::type_id::create("item");

                item.op    = vif.op_sel;
                item.addr  = vif.addr_in; 
                item.wdata = vif.write_data_in; 
                item.count = vif.datacount;
                item.rdata = vif.read_data;

                `uvm_info("MONITOR", $sformatf("Zaobserwowano: %s", item.convert2string()), UVM_LOW)
                ap.write(item);
            end
        end
    endtask
endclass