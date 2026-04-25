`timescale 1ns / 10ps

import i2c_operations_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module tb_top (
    output logic [2:0] datacount,
    output logic [15:0] addr_in,
    output logic       clk,
    output logic       rst_n,
    output operation_t   op_sel,    
    output logic       start,
    output logic [7:0] write_data_in,
    input  logic [23:0] read_data,
    input  logic       busy,
    input  logic       done
);
    logic [15:0] local_rand_addr;
    logic [7:0]  expected_data;
    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        `uvm_info("TB", "Hello, World!", UVM_MEDIUM);
        `uvm_info("TB", "Starting testbench...", UVM_LOW);
        rst_n = 0;
        op_sel = OP_READ_DATA;
        start = 0;
        addr_in = 0;
        #100;
        rst_n = 1;

        #1100us; 

        // --- 01:Manufacturer ID ---
        `uvm_info("TB", "Starting Manufacturer ID read...", UVM_LOW);
        @(posedge clk);
        op_sel = OP_READ_ID; 
        start = 1;
        @(posedge clk);
        start = 0;

        wait(done);
        `uvm_info("MAN_ID", $sformatf("Otrzymano MAN_ID: %h", read_data), UVM_LOW);
        if (read_data === 24'h00D0D0) begin
            `uvm_info("TB", "TEST 1 PASS", UVM_LOW);
        end
        else begin
            `uvm_error("TB", "TEST 1 FAIL!");
        end

        #50us;

        // --- 10: Status Register ---
        `uvm_info("STATUS", "Starting Status Register read...", UVM_LOW);
        @(posedge clk);
        op_sel = OP_READ_STATUS;
        start = 1;
        @(posedge clk);
        start = 0;

        wait(done);
        `uvm_info("STATUS", $sformatf("Otrzymano STATUS: %h", read_data[15:0]), UVM_LOW);
        if (read_data[7] == 0) begin
            `uvm_info("STATUS", "TEST 2 PASS (ECC OK)", UVM_LOW);
        end
        else begin
            `uvm_error("STATUS", "TEST 2 FAIL (ECC Error!)");
        end

        #100us;

        repeat (40) begin

            if (!std::randomize(local_rand_addr)) begin 
                `uvm_error("STATUS", "Błąd randomizacji adresu");
            end
            if (!std::randomize(write_data_in)) begin
                `uvm_error("STATUS", "Błąd randomizacji danych");
            end
            if (!std::randomize(datacount)) begin
                `uvm_error("STATUS", "Błąd randomizacji licznika danych");
            end
            addr_in       = local_rand_addr;
            expected_data = write_data_in;
            // --- 11: Write data---
            `uvm_info("WRITE", $sformatf("Zapis 0x%h pod adres 0x%h", expected_data, addr_in), UVM_LOW);
            @(posedge clk);
            op_sel = OP_WRITE_DATA;
            start = 1;
            @(posedge clk);
            start = 0;
            wait(busy);    
            wait(done);    

            #6ms; 
            // --- 00: Read data ---
            `uvm_info("READ", $sformatf("Odczyt z adresu 0x%h...", addr_in), UVM_LOW);
            @(posedge clk);
            op_sel = OP_READ_DATA;
            start = 1;
            @(posedge clk);
            start = 0;
            wait(busy); 
            wait(done);

            // --- Verification---
            if (read_data[7:0] === expected_data) begin
                `uvm_info("VERIFY_RD_WR", $sformatf("TEST PASS: Adres 0x%h, Dane 0x%h OK", addr_in, read_data[7:0]), UVM_LOW);
            end
            else begin
                `uvm_error("VERIFY_RD_WR", $sformatf("TEST FAIL: Adres 0x%h, Oczekiwano: 0x%h, Otrzymano: 0x%h", 
                            addr_in, expected_data, read_data[7:0]));
            end

            #100us;
        end
        `uvm_info("TB", $sformatf("\n[%t] === KONIEC TESTÓW ===", $time), UVM_LOW);
 
        $finish;
    end
endmodule