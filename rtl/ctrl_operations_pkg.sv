`timescale 1ns / 10ps
package i2c_operations_pkg; // Enumeration for I2C control operations
    typedef enum logic [1:0] {
        OP_READ_DATA   = 2'b00,
        OP_READ_ID     = 2'b01,
        OP_READ_STATUS = 2'b10,
        OP_WRITE_DATA  = 2'b11
    } operation_t;
endpackage