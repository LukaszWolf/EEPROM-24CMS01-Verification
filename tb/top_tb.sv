`timescale 1ns / 10ps

import i2c_operations_pkg::*;

module tb_top (
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
        rst_n = 0;
        op_sel = OP_READ_DATA;
        start = 0;
        addr_in = 0;
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

        repeat (40) begin

            if (!std::randomize(local_rand_addr)) $error("Błąd randomizacji adresu");
            if (!std::randomize(write_data_in))    $error("Błąd randomizacji danych");
            
            addr_in       = local_rand_addr;
            expected_data = write_data_in;
            // --- 11: Write data---
            $display("[%t] TB: Zapis 0x%h pod adres 0x%h", $time, expected_data, addr_in);
            @(posedge clk);
            op_sel = OP_WRITE_DATA;
            start = 1;
            @(posedge clk);
            start = 0;
            wait(busy);    
            wait(done);    

            #6ms; 
            // --- 00: Read data ---
            $display("[%t] TB: Odczyt z adresu 0x%h...", $time, addr_in);            
            @(posedge clk);
            op_sel = OP_READ_DATA;
            start = 1;
            @(posedge clk);
            start = 0;
            wait(busy); 
            wait(done);

            // --- Verification---
            if (read_data[7:0] === expected_data) begin
                $display(">>> TEST PASS: Adres 0x%h, Dane 0x%h OK", addr_in, read_data[7:0]);
            end else begin
                $error(">>> TEST FAIL: Adres 0x%h, Oczekiwano: 0x%h, Otrzymano: 0x%h", 
                        addr_in, expected_data, read_data[7:0]);
            end
            
            #100us;
        end
        $display("\n[%t] === KONIEC TESTÓW ===", $time);
 
        $finish;
    end
endmodule