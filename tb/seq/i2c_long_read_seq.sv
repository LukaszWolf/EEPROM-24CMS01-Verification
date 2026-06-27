`ifndef I2C_LONG_READ_SEQ_SV
`define I2C_LONG_READ_SEQ_SV

// Directed sequence: inject a known data block into the EEPROM, then read it
// back in one long (multi-byte) burst and self-check the returned data.
class i2c_long_read_seq extends uvm_sequence #(i2c_item);
    `uvm_object_utils(i2c_long_read_seq)

    bit [15:0] base_addr = 16'h0040;  // start address of the injected block
    bit [7:0]  inj_data  = 8'hA5;     // value written to every byte
    bit [2:0]  burst     = 3'd7;      // count -> (burst + 1) bytes = 8 (MAX)

    function new(string name = "i2c_long_read_seq");
        super.new(name);
    endfunction

    // Drive one fully-specified transaction (directed: fields set explicitly).
    task drive(operation_t op, bit [15:0] addr, bit [7:0] data = '0, bit [2:0] cnt = '0);
        req = i2c_item::type_id::create("req");
        start_item(req);
        req.op = op; req.addr = addr; req.wdata = data; req.count = cnt;
        finish_item(req);
    endtask

    virtual task body();
        `uvm_info(get_name(), $sformatf("INJECT: %0d byte(s) of 0x%0h at 0x%0h",
                  burst + 1, inj_data, base_addr), UVM_LOW)

        // 1) Inject: one long write loads (burst + 1) bytes with inj_data.
        drive(OP_WRITE_DATA, base_addr, inj_data, burst);

        // 2) Wait out the EEPROM internal write cycle (tWC = 5 ms) so it commits.
        #6ms;

    
        drive(OP_READ_DATA, base_addr, .cnt(burst));

        
        if (req.rdata[23:0] !== {inj_data, inj_data, inj_data}) begin
            `uvm_error(get_name(), $sformatf("LONG READ MISMATCH: expected 0x%0h, got 0x%0h",
                       {inj_data, inj_data, inj_data}, req.rdata[23:0]))
        end else begin
            `uvm_info(get_name(), $sformatf("LONG READ OK: read_data = 0x%0h", req.rdata[23:0]), UVM_LOW)
        end
    endtask
endclass

`endif
