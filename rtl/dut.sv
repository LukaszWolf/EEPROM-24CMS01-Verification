module dut (
    input  logic clk,
    input  logic rstn,
    output logic [3:0] count
);
    
    always @(posedge rstn) begin
        $display("[%0t] DUT: Reset zwolniony, liczenie rozpoczete", $time);
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count <= 4'b0000;
        end else begin
            count <= count + 1;
        end
    end
endmodule

