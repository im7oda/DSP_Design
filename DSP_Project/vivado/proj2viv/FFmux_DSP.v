module FFmux_DSP(clk,rst,enable,in,out);

parameter RSTTYPE= "SYNC";
parameter EN_REG = 1'b1; // Enable reg or not
parameter SIZE= 18; // In/Out size

input clk,rst,enable;
input [SIZE-1 : 0] in;
reg [SIZE-1 : 0] FF_out;
output [SIZE-1 : 0] out;
generate
    if(RSTTYPE== "SYNC") begin
        always @(posedge clk) begin
            if(rst)
                FF_out <= 0;
            else if(enable)
                FF_out <= in;
        end
    end
    else begin
        always @(posedge clk or posedge rst) begin
            if(rst)
                FF_out <= 0;
            else if(enable)
                FF_out <= in;
        end
    end
endgenerate
// Mux
assign out = (EN_REG== 1'b1) ? FF_out : in;
endmodule