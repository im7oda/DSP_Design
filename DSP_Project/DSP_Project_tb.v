module DSP_Project_tb();

reg [17:0] A,B,D;
reg [17:0] BCIN;
reg [47:0] C;
reg [47:0] PCIN;
reg CARRYIN ;
reg CLK;
reg [7:0] OPMODE;
reg CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP;
reg RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;

wire [35:0] M;
wire [47:0] P;
wire CARRYOUT, CARRYOUTF;
wire [17:0] BCOUT;
wire [47:0] PCOUT;

// Design module instantiation
DSP_Project dut (
    A,B,C,D,CARRYIN,BCIN,
    M,P,CARRYOUT,CARRYOUTF,
    CLK,OPMODE,
    CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP,
    RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP,
    BCOUT,PCIN,PCOUT
);
// CLK generation
initial begin
    CLK= 0;
    forever #1 CLK= ~CLK;
end

initial begin
    // initial RST'S with 1
    {RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP}= 8'b11111111;
    A = $random;
    B = $random;
    D = $random;
    BCIN = $random;
    C = $random;
    PCIN = $random;
    CARRYIN = $random;
    OPMODE = $random;
    CEA = $random;
    CEB = $random;
    CEC = $random;
    CECARRYIN = $random;
    CED = $random;
    CEM = $random;
    CEOPMODE = $random;
    CEP = $random;
    @(negedge CLK);
    // self-checking
    if ((P != 0)||(PCOUT != 0)||(BCOUT != 0)||(CARRYOUT != 0)||(CARRYOUTF != 0)||(M != 0)) begin
        $display("Error, Something wrong in reset!!!");
        $stop;
    end
    // Assert all enable clk signal
    // Deassert all reset's
    {CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP} = 8'b11111111;
    {RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP} = 8'b0;
    
    // Path 1
    OPMODE= 8'b11011101;
    A= 20; B= 10; C= 350; D= 25;
    BCIN= $random; PCIN= $random; CARRYIN= $random;
    repeat(4) @(negedge CLK);
    // self-check for O/P's
    if ((P != 'h32)||(PCOUT != 'h32)||(BCOUT != 'hf)||(CARRYOUT != 0)||(CARRYOUTF != 0)||(M != 'h12c)) begin
        $display("Error, Outputs are incorrect !!!");
        $stop;
    end

    // Path 2
    OPMODE= 8'b00010000;
    A= 20; B= 10; C= 350; D= 25;
    BCIN= $random; PCIN= $random; CARRYIN= $random;
    repeat(3) @(negedge CLK);
    // self-check for O/P's
    if ((P != 0)||(PCOUT != 0)||(BCOUT != 'h23)||(CARRYOUT != 0)||(CARRYOUTF != 0)||(M != 'h2bc)) begin
        $display("Error, Outputs are incorrect !!!");
        $stop;
    end

    // Path 3
    OPMODE= 8'b00001010;
    A= 20; B= 10; C= 350; D= 25;
    BCIN= $random; PCIN= $random; CARRYIN= $random;
    repeat(3) @(negedge CLK);
    // self-check for O/P's
    if ((P != 0)||(PCOUT != 0)||(BCOUT != 'ha)||(CARRYOUT != 0)||(CARRYOUTF != 0)||(M != 'hc8)) begin
        $display("Error, Outputs are incorrect !!!");
        $stop;
    end

    // Path 4
    OPMODE= 8'b10100111;
    A= 5; B= 6; C= 350; D= 25; PCIN = 3000;
    BCIN= $random; CARRYIN= $random;
    repeat(3) @(negedge CLK);
    // self-check for O/P's
    if ((P != 'hfe6fffec0bb1)||(PCOUT != 'hfe6fffec0bb1)||(BCOUT != 'h6)||(CARRYOUT != 1)||(CARRYOUTF != 1)||(M != 'h1e)) begin
        $display("Error, Outputs are incorrect !!!");
        $stop;
    end

    $stop;
end

endmodule