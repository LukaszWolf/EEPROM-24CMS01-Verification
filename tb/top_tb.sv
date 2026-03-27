module top_tb (
    output logic clk,
    output logic rstn
);
  //Zegar
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("[%0t] TB: Start symulacji - Aktywuje reset (rstn=0)", $time);
        rstn = 0;       // Reset aktywny
        
        #25;          
        
        rstn = 1;       // Zwolnienie resetu
        $display("[%0t] TB: Reset zwolniony (rstn=1) - DUT powinien zaczac prace", $time);
        
        #100;          
        $display("[%0t] TB: Koniec symulacji", $time);
        $finish;
    end

    always @(posedge rstn) begin
        $display("[%0t] TB DEBUG: Wykryto zbocze narastajace na linii resetu!", $time);
    end

endmodule
