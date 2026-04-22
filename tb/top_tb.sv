`timescale 1ns / 10ps

import i2c_operations_pkg::*;

module tb_top (
    output logic       clk,
    output logic       rst_n,
    output operation_t   op_sel,    
    output logic       start,
    output logic [7:0] write_data_in,
    input  logic [23:0] read_data,
    input  logic       busy,
    input  logic       done
);
    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst_n = 0;
        op_sel = OP_READ_DATA;
        start = 0;
        #100;
        rst_n = 1;

        #1100us; 

        // --- 01:Manufacturer ID ---
        $display("[%t] TB: Rozpoczynam odczyt MAN_ID...", $time);
        @(posedge clk);
        op_sel = OP_READ_ID; 
        start = 1;
        @(posedge clk);
        start = 0;

        wait(done);
        $display("[%t] TB: Otrzymano MAN_ID: %h", $time, read_data);
        if (read_data === 24'h00D0D0) $display(">>> TEST 1 PASS");
        else                          $error(">>> TEST 1 FAIL!");

        #50us;

        // --- 10: Status Register ---
        $display("[%t] TB: Rozpoczynam odczyt STATUS...", $time);
        @(posedge clk);
        op_sel = OP_READ_STATUS;
        start = 1;
        @(posedge clk);
        start = 0;

        wait(done);
        $display("[%t] TB: Otrzymano STATUS: %h", $time, read_data[15:0]);
        if (read_data[7] == 0) $display(">>> TEST 2 PASS (ECC OK)");
        else                   $error(">>> TEST 2 FAIL (ECC Error!)");

        #100us;

        // --- 11: Write data---
        $display("\n[%t] === TEST 3: Zapis 0x55 pod adres 0x0005 ===", $time);
        write_data_in = 8'h55;
        op_sel = OP_WRITE_DATA;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        wait(busy);    
        wait(done);    
        $display("[%t] TB: Zakończono sekwencję zapisu.", $time);

        #6ms; 
        // --- 00: Read data ---
        $display("\n[%t] === TEST 4: Odczyt danych z adresu 0x0005 ===", $time);
        op_sel = OP_READ_DATA;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        wait(busy); 
        wait(done);
        $display("[%t] TB: Odczytano: %h", $time, read_data[7:0]);

        $finish;
    end
endmodule