`ifndef I2C_ITEM_SV
`define I2C_ITEM_SV

class i2c_item extends uvm_sequence_item;
    `uvm_object_utils(i2c_item)

    typedef enum {SINGLE,SHORT,MEDIUM,LONG,MAX} data_length_t;
    
    rand logic [15:0]  addr;
    rand logic [7:0]   wdata;
    rand logic [2:0]   count;
    rand operation_t   op;        
    rand data_length_t length;
    logic [23:0]       rdata;
    
    
    
    function new(string name = "i2c_item");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return $sformatf("op=%s, addr=0x%0h, count=%0d, wdata=0x%0h, rdata=0x%0h", 
                         op.name(), addr, count, wdata, rdata);
    endfunction


    //even both read and write operations
    constraint c_op_dist {
        op dist { OP_READ_ID := 0, OP_READ_STATUS := 0, OP_WRITE_DATA := 1, OP_READ_DATA := 1 };
    }
    constraint c_len_dist{
        length dist {SINGLE := 1, SHORT := 5, MEDIUM := 3, LONG := 3, MAX := 1};
    }

endclass

`endif