`ifndef I2C_SEQUENCE_ITEM_SV
`define I2C_SEQUENCE_ITEM_SV

class i2c_item extends uvm_sequence_item;
    `uvm_object_utils(i2c_item)

    rand logic [15:0]  addr;
    rand logic [7:0]   wdata;
    rand logic [2:0]   count;
    rand operation_t   op;        

    logic [23:0]       rdata;

    function new(string name = "i2c_item");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return $sformatf("op=%s, addr=0x%0h, count=%0d, wdata=0x%0h, rdata=0x%0h", 
                         op.name(), addr, count, wdata, rdata);
    endfunction

    // Edge case constraints for better coverage
    constraint c_toggle_power {
        wdata dist { 8'hAA := 5, 8'h55 := 5, [0:255] := 1 };
        
        addr dist { 16'h0000 := 10, 16'hFFFF := 10, [1:16'hFFFE] := 1 };

        op dist { OP_READ_ID := 10, OP_READ_STATUS := 10, OP_WRITE_DATA := 20, OP_READ_DATA := 20 };
    }
    constraint c_toggle_burst {
    wdata inside {8'h00, 8'hFF, 8'hAA, 8'h55};
    addr  inside {16'h0000, 16'hFFFF, 16'hAAAA, 16'h5555};
}

endclass

`endif