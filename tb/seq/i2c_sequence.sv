`ifndef I2C_BASE_SEQ_SV
`define I2C_BASE_SEQ_SV

class i2c_base_seq extends uvm_sequence #(i2c_item);
    `uvm_object_utils(i2c_base_seq)

    function new(string name = "i2c_base_seq");
        super.new(name);
    endfunction
    virtual task body();
        `uvm_info(get_name(), "Starting i2c_base_seq", UVM_LOW)

        //at least one read and write
        req =i2c_item::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { op == OP_WRITE_DATA; }) begin
            `uvm_error(get_name(), "Failed to randomize a write operation for the first transaction")
        end
        finish_item(req);


        req =i2c_item::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { op == OP_READ_DATA; }) begin
            `uvm_error(get_name(), "Failed to randomize a read operation for the second transaction")
        end
        finish_item(req);
        
        repeat(80) begin

            req = i2c_item::type_id::create("req");

            start_item(req);

            if (!req.randomize()) begin
                `uvm_error(get_name(), "Randomization failed for i2c_item")
            end

            finish_item(req);
            
            `uvm_info(get_name(), $sformatf("Transaction sent: %s", req.convert2string()), UVM_HIGH)
        end
        
        `uvm_info(get_name(), "Sequence completed", UVM_LOW)
    endtask

endclass

`endif