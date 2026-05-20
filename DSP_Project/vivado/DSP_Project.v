module DSP_Project(
    A,B,C,D,CARRYIN,BCIN,
    M,P,CARRYOUT,CARRYOUTF,
    CLK,OPMODE,
    CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP,
    RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP,
    BCOUT,PCIN,PCOUT
);
parameter A0REG = 1'b0;
parameter A1REG = 1'b1;
parameter B0REG = 1'b0;
parameter B1REG = 1'b1;
parameter CREG = 1'b1;
parameter DREG = 1'b1;
parameter MREG = 1'b1;
parameter PREG = 1'b1;
parameter CARRYINREG = 1'b1;
parameter CARRYOUTREG = 1'b1;
parameter OPMODEREG = 1'b1;
parameter CARRYINSEL = "OPMODE5";
parameter B_INPUT = "DIRECT";
parameter RSTTYPE = "SYNC";

input [17:0] A,B,D;
input [17:0] BCIN;
input [47:0] C;
input [47:0] PCIN;
input CARRYIN ;
input CLK;
input [7:0] OPMODE;
input CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP;
input RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
// FFmux-module outputs
wire [17:0] A0_reg,A1_reg,B0_reg,B1_reg,D_reg;
wire [47:0] C_reg;
wire [35:0] M_reg;
wire CARRYIN_reg;
wire CARRYOUT_reg;
wire [47:0] P_reg;
wire [7:0] OPMODE_reg;

wire CARRYIN_Mux_out;
wire [17:0] B_Mux_out;
wire [17:0] Pre_B_Mux_out; // o/p of mux select between B,Pre-adder
wire [17:0] Pre_AddSub;
wire [47:0] Post_AddSub;
wire [35:0] multip; // Multiplication(X)

reg [47:0] X_Mux_out;
reg [47:0] Z_Mux_out;

output [35:0] M;
output [47:0] P;
output CARRYOUT, CARRYOUTF;
output [17:0] BCOUT;
output [47:0] PCOUT;

// Module instantiation
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(A0REG), .SIZE(18)) a0_reg (CLK,RSTA,CEA,A,A0_reg);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(B0REG), .SIZE(18)) b0_reg (CLK,RSTB,CEB,B_Mux_out,B0_reg);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(CREG), .SIZE(48)) c_reg (CLK,RSTC,CEC,C,C_reg);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(DREG), .SIZE(18)) d_reg (CLK,RSTD,CED,D,D_reg);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(A1REG), .SIZE(18)) a1_reg (CLK,RSTA,CEA,A0_reg,A1_reg);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(B1REG), .SIZE(18)) b1_reg (CLK,RSTB,CEB,Pre_B_Mux_out,B1_reg);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(MREG), .SIZE(36)) m_reg (CLK,RSTM,CEM,multip,M_reg);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(CARRYINREG), .SIZE(1)) cyi_reg (CLK,RSTCARRYIN,CECARRYIN,CARRYIN_Mux_out,CARRYIN_reg);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(CARRYOUTREG), .SIZE(1)) cyo_reg (CLK,RSTCARRYIN,CECARRYIN,Post_AddSub[47],CARRYOUT);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(PREG), .SIZE(48)) p_reg (CLK,RSTP,CEP,Post_AddSub,P);
FFmux_DSP #(.RSTTYPE(RSTTYPE), .EN_REG(PREG), .SIZE(8)) opmode_reg (CLK,RSTOPMODE,CEOPMODE,OPMODE,OPMODE_reg);


// assign (Mux's)
assign B_Mux_out =  (B_INPUT== "DIRECT")? B :
                    (B_INPUT== "CASCADE")? BCIN : 0;
assign Pre_B_Mux_out = (OPMODE_reg[4])? Pre_AddSub : B0_reg;
assign CARRYIN_Mux_out =  (CARRYINSEL== "OPMODE5")? OPMODE[5] :
                          (CARRYINSEL== "CARRYIN")? CARRYIN : 0;
// Operations
assign Pre_AddSub = (OPMODE[6])? D_reg - B0_reg : D_reg + B0_reg;
assign multip = B1_reg * A1_reg;
assign Post_AddSub = (OPMODE[7])? Z_Mux_out-(X_Mux_out+CARRYIN_reg) : Z_Mux_out+(X_Mux_out+CARRYIN_reg);

// assign
assign BCOUT = B1_reg;
assign CARRYOUTF = CARRYOUT;
assign M = M_reg;
assign PCOUT = P;
// X,Z Mux's
always @(*) begin
    case (OPMODE[1:0])
        2'd0 : X_Mux_out = 0;
        2'd1 : X_Mux_out = {12'b0, M_reg};
        2'd2 : X_Mux_out = P;
        2'd3 : X_Mux_out = {D_reg[11:0] , A1_reg , B1_reg};
    endcase

    case (OPMODE[3:2])
        2'd0 : Z_Mux_out = 0;
        2'd1 : Z_Mux_out = PCIN;
        2'd2 : Z_Mux_out = P;
        2'd3 : Z_Mux_out = C_reg;
    endcase
end
endmodule