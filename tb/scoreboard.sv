`ifndef I2C_SCOREBOARD_SV
`define I2C_SCOREBOARD_SV

`uvm_analysis_imp_decl(_mon)

class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)

    uvm_analysis_imp_mon #(i2c_item, i2c_scoreboard) mon_export;

    bit [7:0] memory_model [bit [15:0]];

    bit [23:0] last_status;

    int match_count = 0;
    int error_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mon_export = new("mon_export", this);
    endfunction

    virtual function void write_mon(i2c_item item);
        `uvm_info("SCOREBOARD", $sformatf("Acquired transaction: %s", item.convert2string()), UVM_HIGH)

        case(item.op)
            OP_WRITE_DATA:   process_write(item);
            OP_READ_DATA:    process_read(item);
            OP_READ_STATUS:  process_status(item);
            OP_READ_ID:      process_id(item);
        endcase
    endfunction

    virtual function void process_write(i2c_item item);
        memory_model[item.addr] = item.wdata;
        `uvm_info("SCB_WRITE", $sformatf("write to model: Address=0x%0h, Data=0x%0h", item.addr, item.wdata), UVM_MEDIUM)
    endfunction

    virtual function void process_read(i2c_item item);
        bit [7:0] expected_data;

        if (!memory_model.exists(item.addr)) begin
            expected_data = 8'hFF;
        end else begin
            expected_data = memory_model[item.addr];
        end

        if (item.rdata[7:0] !== expected_data) begin
            `uvm_error("SCB_READ_ERR", $sformatf("READ ERROR! Address=0x%0h, Expected=0x%0h, Received=0x%0h", 
                                                 item.addr, expected_data, item.rdata[7:0]))
            error_count++;
        end else begin
            `uvm_info("SCB_READ_OK", $sformatf("Read successful! Address=0x%0h, Data=0x%0h", item.addr, item.rdata[7:0]), UVM_MEDIUM)
            match_count++;
        end
    endfunction

    virtual function void process_status(i2c_item item);
        last_status = item.rdata;
        `uvm_info("SCB_STATUS", $sformatf("Updated status register: 0x%0h", last_status), UVM_MEDIUM)
    endfunction

    virtual function void process_id(i2c_item item);
        bit [15:0] expected_id = 16'hD0D0;

        if (item.rdata[15:0] !== expected_id) begin
            `uvm_error("SCB_ID_ERR", $sformatf("WRONG CHIP ID! expected=0x%0h, received=0x%0h", expected_id, item.rdata[15:0]))
            error_count++;
        end else begin
            `uvm_info("SCB_ID_OK", $sformatf("correct chip ID: 0x%0h", item.rdata[15:0]), UVM_MEDIUM)
            match_count++;
        end
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        `uvm_info("SCOREBOARD", "=========================================================", UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf(" Scoreboard summary: Errors: %0d, Correct: %0d", error_count, match_count), UVM_LOW)
        `uvm_info("SCOREBOARD", "=========================================================", UVM_LOW)
        
        if (error_count > 0) begin
            `uvm_error("SCOREBOARD", "Errors occurred!")
        end
    endfunction

endclass

`endif // I2C_SCOREBOARD_SV