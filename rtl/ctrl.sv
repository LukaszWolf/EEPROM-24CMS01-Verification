`timescale 1ns / 10ps

import i2c_operations_pkg::*;

module controller (
    input  logic        clk,
    input  logic        rst_n,
    input  operation_t  op_sel,
    input  logic        start,
    input  logic [7:0]  write_data_in,
    output logic [23:0] read_data, 
    output logic        busy,
    output logic        done,
    output logic        scl,
    inout  wire         sda
);
    logic [9:0] cnt; 
    always_ff @(posedge clk) begin //frequency divider
        if (!rst_n) cnt <= 0;
        else if (cnt == 999) cnt <= 0;
        else cnt <= cnt + 1;
    end

    typedef enum {PWR_UP, IDLE, SETUP, START_BIT, SEND_BYTE, GET_ACK, 
                  REP_START, READ_BYTE, SEND_ACK, SEND_NACK, STOP, FINISH} state_t; 
    state_t state; //state machine

    logic is_write; // 1 = write, 0 = read
    logic [7:0]  ctrl_w, ctrl_r;
    logic [7:0]  addr_h, addr_l;
    logic [1:0]  addr_len;    
    logic [1:0]  data_len;    
    logic [2:0]  step_cnt;    
    logic        is_reading;   

    logic [11:0] pwr_cnt; 
    logic [7:0]  tx_data;
    logic [3:0]  bit_idx;
    logic [1:0]  byte_idx;
    logic [7:0]  rx_temp;
    logic sda_out, sda_oe;

    assign sda = (sda_oe && !sda_out) ? 1'b0 : 1'bz;
    logic bit_end;
    assign bit_end = (cnt == 999);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= PWR_UP; scl <= 1; sda_out <= 1; sda_oe <= 1;
            done <= 0; busy <= 0; read_data <= 0; pwr_cnt <= 0;
        end else begin
            case (state)
                PWR_UP: begin
                    if (bit_end) begin
                        if (pwr_cnt == 100) state <= IDLE; 
                        else pwr_cnt <= pwr_cnt + 1;
                    end
                end

                IDLE: begin
                    scl <= 1; sda_out <= 1; sda_oe <= 1;
                    busy <= 0; done <= 0;
                    if (start) begin 
                        state <= SETUP; 
                        busy <= 1;
                        read_data <= 0;
                    end
                end

                SETUP: begin
                    is_reading <= 0; 
                    is_write   <= 0;
                    step_cnt <= 0;
                    case (op_sel)
                        OP_READ_ID: begin
                            ctrl_w   <= 8'hF8; 
                            ctrl_r   <= 8'hF9;
                            addr_l   <= 8'hA0; 
                            addr_len <= 1;
                            data_len <= 3;
                        end
                        OP_READ_STATUS: begin
                            ctrl_w   <= 8'hB0; // Device Address (Write)
                            ctrl_r   <= 8'hB1; // Device Address (Read)
                            addr_h   <= 8'h88; // Word Address Byte 0
                            addr_l   <= 8'h00; // Word Address Byte 1
                            addr_len <= 2;     
                            data_len <= 2;
                        end
                        OP_READ_DATA: begin
                            ctrl_w   <= 8'hA0; // Control Code dla EEPROM (Write)
                            ctrl_r   <= 8'hA1; // Control Code dla EEPROM (Read)
                            addr_h   <= 8'h00; // Word Address High
                            addr_l   <= 8'h05; // Word Address Low (0x0005)
                            addr_len <= 2;     
                            data_len <= 1;
                        end
                        OP_WRITE_DATA: begin
                            ctrl_w   <= 8'hA0; 
                            addr_h   <= 8'h00; // Adres zapisu H
                            addr_l   <= 8'h05; // Adres zapisu L
                            addr_len <= 2;
                            is_write <= 1;
                        end
                    endcase
                    state <= START_BIT;
                end

                START_BIT: begin
                    if (cnt == 100) sda_out <= 0;
                    if (cnt == 600) scl <= 0;
                    if (bit_end) begin 
                        state <= SEND_BYTE;
                        tx_data <= ctrl_w;
                        bit_idx <= 7;
                    end
                end

                SEND_BYTE: begin
                    if (cnt == 0)   sda_out <= tx_data[bit_idx];
                    if (cnt == 250) scl <= 1;
                    if (cnt == 750) scl <= 0;
                    if (bit_end) begin
                        if (bit_idx == 0) state <= GET_ACK;
                        else bit_idx <= bit_idx - 1;
                    end
                end

                GET_ACK: begin
                    if (cnt == 0)   sda_oe <= 0;
                    if (cnt == 250) scl <= 1;
                    if (cnt == 750) scl <= 0;
                    if (bit_end) begin
                        sda_oe <= 1;
                        if (!is_reading) begin 
                            if (step_cnt < addr_len) begin
                                tx_data <= (addr_len == 2 && step_cnt == 0) ? addr_h : addr_l;
                                step_cnt <= step_cnt + 1;
                                state <= SEND_BYTE;
                                bit_idx <= 7;
                            end else if (is_write) begin
                               
                                tx_data <= write_data_in;
                                
                                state <= SEND_BYTE;
                                bit_idx <= 7;
                                is_write <= 0; 
                                step_cnt <= 4; 
                            end else if (step_cnt == 4) begin
                                state <= STOP;
                            end else begin
                                state <= REP_START;
                            end
                        end else begin 
                            state <= READ_BYTE;
                            bit_idx <= 7;
                            byte_idx <= 0;
                        end
                    end
                end

                REP_START: begin
                    if (cnt == 0)   begin sda_out <= 1; scl <= 0; end
                    if (cnt == 250) scl <= 1;
                    if (cnt == 600) sda_out <= 0; 
                    if (cnt == 850) scl <= 0;
                    if (bit_end) begin 
                        state <= SEND_BYTE; 
                        tx_data <= ctrl_r; 
                        bit_idx <= 7;
                        is_reading <= 1; 
                    end
                end

                READ_BYTE: begin
                    if (cnt == 0)   sda_oe <= 0;
                    if (cnt == 250) scl <= 1;
                    if (cnt == 500) rx_temp[bit_idx] <= sda;
                    if (cnt == 750) scl <= 0;
                    if (bit_end) begin
                        if (bit_idx == 0) begin
                            read_data <= {read_data[15:0], rx_temp};
                            state <= (byte_idx < data_len - 1) ? SEND_ACK : SEND_NACK;
                        end else bit_idx <= bit_idx - 1;
                    end
                end

                SEND_ACK: begin
                    if (cnt == 0)   begin sda_oe <= 1; sda_out <= 0; end
                    if (cnt == 250) scl <= 1;
                    if (cnt == 750) scl <= 0;
                    if (bit_end) begin 
                        byte_idx <= byte_idx + 1; 
                        state <= READ_BYTE; 
                        bit_idx <= 7; 
                    end
                end

                SEND_NACK: begin
                    if (cnt == 0)   begin 
                        sda_oe <= 1; 
                        sda_out <= 1; 
                        end
                    if (cnt == 250) scl <= 1;
                    if (cnt == 750) scl <= 0;
                    if (bit_end) state <= STOP;
                end

                STOP: begin
                    if (cnt == 0)   begin 
                        sda_oe <= 1; 
                        sda_out <= 0; 
                        end
                    if (cnt == 250) scl <= 1;
                    if (cnt == 600) sda_out <= 1;
                    if (bit_end) state <= FINISH;
                end

                FINISH: begin
                    done <= 1;
                    busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule