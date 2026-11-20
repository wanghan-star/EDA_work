// Logic re-synthesized by rtl_agent (ABC syn2_dch); registers and ports unchanged.
// Default parameters use the optimized implementation; overrides retain original semantics.
module rtlopt_78ddd3f77dac_original
#(
    parameter DATA_WIDTH = 64,
    parameter STG_WIDTH = 16
)
(
    input clk,
    input rst_n,
    input i_en,
    input [DATA_WIDTH-1:0] adda,
    input [DATA_WIDTH-1:0] addb,
    output [DATA_WIDTH:0] result,
    output reg o_en
);

reg stage1;
reg stage2;
reg stage3;

wire [STG_WIDTH-1:0] a1;
wire [STG_WIDTH-1:0] b1;
wire [STG_WIDTH-1:0] a2;
wire [STG_WIDTH-1:0] b2;
wire [STG_WIDTH-1:0] a3;
wire [STG_WIDTH-1:0] b3;
wire [STG_WIDTH-1:0] a4;
wire [STG_WIDTH-1:0] b4;

reg [STG_WIDTH-1:0] a2_ff1;
reg [STG_WIDTH-1:0] b2_ff1;

reg [STG_WIDTH-1:0] a3_ff1;
reg [STG_WIDTH-1:0] b3_ff1;
reg [STG_WIDTH-1:0] a3_ff2;
reg [STG_WIDTH-1:0] b3_ff2;

reg [STG_WIDTH-1:0] a4_ff1;
reg [STG_WIDTH-1:0] b4_ff1;
reg [STG_WIDTH-1:0] a4_ff2;
reg [STG_WIDTH-1:0] b4_ff2;
reg [STG_WIDTH-1:0] a4_ff3;
reg [STG_WIDTH-1:0] b4_ff3;

reg c1;
reg c2;
reg c3;
reg c4;

reg [STG_WIDTH-1:0] s1;
reg [STG_WIDTH-1:0] s2;
reg [STG_WIDTH-1:0] s3;
reg [STG_WIDTH-1:0] s4;

reg [STG_WIDTH-1:0] s1_ff1;
reg [STG_WIDTH-1:0] s1_ff2;
reg [STG_WIDTH-1:0] s1_ff3;

reg [STG_WIDTH-1:0] s2_ff1;
reg [STG_WIDTH-1:0] s2_ff2;

reg [STG_WIDTH-1:0] s3_ff1;

assign a1 = adda[STG_WIDTH-1:0];
assign b1 = addb[STG_WIDTH-1:0];
assign a2 = adda[STG_WIDTH*2-1:16];
assign b2 = addb[STG_WIDTH*2-1:16];
assign a3 = adda[STG_WIDTH*3-1:32];
assign b3 = addb[STG_WIDTH*3-1:32];
assign a4 = adda[STG_WIDTH*4-1:48];
assign b4 = addb[STG_WIDTH*4-1:48];

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        stage1 <= 1'b0;
        stage2 <= 1'b0;
        stage3 <= 1'b0;
        o_en <= 1'b0;
    end
    else begin
        stage1 <= i_en;
        stage2 <= stage1;
        stage3 <= stage2;
        o_en <= stage3;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        a2_ff1 <= 'd0;
        b2_ff1 <= 'd0;
        a3_ff1 <= 'd0;
        b3_ff1 <= 'd0;
        a3_ff2 <= 'd0;
        b3_ff2 <= 'd0;
        a4_ff1 <= 'd0;
        b4_ff1 <= 'd0;
        a4_ff2 <= 'd0;
        b4_ff2 <= 'd0;
        a4_ff3 <= 'd0;
        b4_ff3 <= 'd0;
    end
    else begin
        a2_ff1 <= a2;
        b2_ff1 <= b2;
        a3_ff1 <= a3;
        b3_ff1 <= b3;
        a3_ff2 <= a3_ff1;
        b3_ff2 <= b3_ff1;
        a4_ff1 <= a4;
        b4_ff1 <= b4;
        a4_ff2 <= a4_ff1;
        b4_ff2<= b4_ff1;
        a4_ff3 <= a4_ff2;
        b4_ff3 <= b4_ff2;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        s1_ff1 <= 'd0;
        s1_ff2 <= 'd0;
        s1_ff3 <= 'd0;
        s2_ff1 <= 'd0;
        s2_ff2 <= 'd0;
        s3_ff1 <= 'd0;
    end
    else begin
        s1_ff1 <= s1;
        s1_ff2 <= s1_ff1;
        s1_ff3 <= s1_ff2;
        s2_ff1 <= s2;
        s2_ff2 <= s2_ff1;
        s3_ff1 <= s3;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        c1 <= 1'b0;
        s1 <= 'd0;
    end
    else if (i_en) begin
        {c1, s1} <= a1 + b1;
    end
    else begin
        c1 <= c1;
        s1 <= s1;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        c2 <= 1'b0;
        s2 <= 'd0;
    end
    else if (stage1) begin
        {c2, s2} <= a2_ff1 + b2_ff1 + c1;
    end
    else begin
        c2 <= c2;
        s2 <= s2;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        c3 <= 1'b0;
        s3 <= 'd0;
    end
    else if (stage2) begin
        {c3, s3} <= a3_ff2 + b3_ff2 + c2;
    end
    else begin
        c3 <= c3;
        s3 <= s3;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        c4 <= 1'b0;
        s4 <= 'd0;
    end
    else if (stage3) begin
        {c4, s4} <= a4_ff3 + b4_ff3 + c3;
    end
    else begin
        c4 <= c4;
        s4 <= s4;
    end
end

assign result = {c4, s4, s3_ff1, s2_ff2, s1_ff3};

endmodule
module verified_adder_64bit
#(
    parameter DATA_WIDTH = 64,
    parameter STG_WIDTH = 16
)
(
    input clk,
    input rst_n,
    input i_en,
    input [DATA_WIDTH-1:0] adda,
    input [DATA_WIDTH-1:0] addb,
    output [DATA_WIDTH:0] result,
    output wire o_en
);

generate
  if ((DATA_WIDTH === 32'b00000000000000000000000001000000) && (STG_WIDTH === 32'b00000000000000000000000000010000)) begin : rtlopt_default_config
wire [1-1:0] rtlopt_78ddd3f77dac_port_clk;
assign rtlopt_78ddd3f77dac_port_clk = clk;
wire [1-1:0] rtlopt_78ddd3f77dac_port_rst_n;
assign rtlopt_78ddd3f77dac_port_rst_n = rst_n;
wire [1-1:0] rtlopt_78ddd3f77dac_port_i_en;
assign rtlopt_78ddd3f77dac_port_i_en = i_en;
wire [64-1:0] rtlopt_78ddd3f77dac_port_adda;
assign rtlopt_78ddd3f77dac_port_adda = adda;
wire [64-1:0] rtlopt_78ddd3f77dac_port_addb;
assign rtlopt_78ddd3f77dac_port_addb = addb;
reg [65-1:0] rtlopt_78ddd3f77dac_port_result;
assign result = rtlopt_78ddd3f77dac_port_result;
reg [1-1:0] rtlopt_78ddd3f77dac_port_o_en;
assign o_en = rtlopt_78ddd3f77dac_port_o_en;

  reg _0000_;
  reg _0001_;
  reg _0002_;
  reg _0003_;
  reg [15:0] _0004_;
  reg [15:0] _0005_;
  reg [15:0] _0006_;
  reg [15:0] _0007_;
  reg _0008_;
  reg _0009_;
  reg _0010_;
  reg _0011_;
  reg _0012_;
  reg _0013_;
  reg _0014_;
  reg _0015_;
  reg _0016_;
  reg _0017_;
  reg _0018_;
  reg _0019_;
  reg _0020_;
  reg _0021_;
  reg _0022_;
  reg _0023_;
  reg _0024_;
  reg _0025_;
  reg _0026_;
  reg _0027_;
  reg _0028_;
  reg _0029_;
  reg _0030_;
  reg _0031_;
  reg _0032_;
  reg _0033_;
  reg _0034_;
  reg _0035_;
  reg _0036_;
  reg _0037_;
  reg _0038_;
  reg _0039_;
  reg _0040_;
  reg _0041_;
  reg _0042_;
  reg _0043_;
  reg _0044_;
  reg _0045_;
  reg _0046_;
  reg _0047_;
  reg _0048_;
  reg _0049_;
  reg _0050_;
  reg _0051_;
  reg _0052_;
  reg _0053_;
  reg _0054_;
  reg _0055_;
  reg _0056_;
  reg _0057_;
  reg _0058_;
  reg _0059_;
  reg _0060_;
  reg _0061_;
  reg _0062_;
  reg _0063_;
  reg _0064_;
  reg _0065_;
  reg _0066_;
  reg _0067_;
  reg _0068_;
  reg _0069_;
  reg _0070_;
  reg _0071_;
  reg _0072_;
  reg _0073_;
  reg _0074_;
  reg _0075_;
  reg _0076_;
  reg _0077_;
  reg _0078_;
  reg _0079_;
  reg _0080_;
  reg _0081_;
  reg _0082_;
  reg _0083_;
  reg _0084_;
  reg _0085_;
  reg _0086_;
  reg _0087_;
  reg _0088_;
  reg _0089_;
  reg _0090_;
  reg _0091_;
  reg _0092_;
  reg _0093_;
  reg _0094_;
  reg _0095_;
  reg _0096_;
  reg _0097_;
  reg _0098_;
  reg _0099_;
  reg _0100_;
  reg _0101_;
  reg _0102_;
  reg _0103_;
  reg _0104_;
  reg _0105_;
  reg _0106_;
  reg _0107_;
  reg _0108_;
  reg _0109_;
  reg _0110_;
  reg _0111_;
  reg _0112_;
  reg _0113_;
  reg _0114_;
  reg _0115_;
  reg _0116_;
  reg _0117_;
  reg _0118_;
  reg _0119_;
  reg _0120_;
  reg _0121_;
  reg _0122_;
  reg _0123_;
  reg _0124_;
  reg _0125_;
  reg _0126_;
  reg _0127_;
  reg _0128_;
  reg _0129_;
  reg _0130_;
  reg _0131_;
  reg _0132_;
  reg _0133_;
  reg _0134_;
  reg _0135_;
  reg _0136_;
  reg _0137_;
  reg _0138_;
  reg _0139_;
  reg _0140_;
  reg _0141_;
  reg _0142_;
  reg _0143_;
  reg _0144_;
  reg _0145_;
  reg _0146_;
  reg _0147_;
  reg _0148_;
  reg _0149_;
  reg _0150_;
  reg _0151_;
  reg _0152_;
  reg _0153_;
  reg _0154_;
  reg _0155_;
  reg _0156_;
  reg _0157_;
  reg _0158_;
  reg _0159_;
  reg _0160_;
  reg _0161_;
  reg _0162_;
  reg _0163_;
  reg _0164_;
  reg _0165_;
  reg _0166_;
  reg _0167_;
  reg _0168_;
  reg _0169_;
  reg _0170_;
  reg _0171_;
  reg _0172_;
  reg _0173_;
  reg _0174_;
  reg _0175_;
  reg _0176_;
  reg _0177_;
  reg _0178_;
  reg _0179_;
  reg _0180_;
  reg _0181_;
  reg _0182_;
  reg _0183_;
  reg _0184_;
  reg _0185_;
  reg _0186_;
  reg _0187_;
  reg _0188_;
  reg _0189_;
  reg _0190_;
  reg _0191_;
  reg _0192_;
  reg _0193_;
  reg _0194_;
  reg _0195_;
  reg _0196_;
  reg _0197_;
  reg _0198_;
  reg _0199_;
  reg _0200_;
  reg _0201_;
  reg _0202_;
  reg _0203_;
  reg _0204_;
  reg _0205_;
  reg _0206_;
  reg _0207_;
  reg _0208_;
  reg _0209_;
  reg _0210_;
  reg _0211_;
  reg _0212_;
  reg _0213_;
  reg _0214_;
  reg _0215_;
  reg _0216_;
  reg _0217_;
  reg _0218_;
  reg _0219_;
  reg _0220_;
  reg _0221_;
  reg _0222_;
  reg _0223_;
  reg _0224_;
  reg _0225_;
  reg _0226_;
  reg _0227_;
  reg _0228_;
  reg _0229_;
  reg _0230_;
  reg _0231_;
  reg _0232_;
  reg _0233_;
  reg _0234_;
  reg _0235_;
  reg _0236_;
  reg _0237_;
  reg _0238_;
  reg _0239_;
  reg _0240_;
  reg _0241_;
  reg _0242_;
  reg _0243_;
  reg _0244_;
  reg _0245_;
  reg _0246_;
  reg _0247_;
  reg _0248_;
  reg _0249_;
  reg _0250_;
  reg _0251_;
  reg _0252_;
  reg _0253_;
  reg _0254_;
  reg _0255_;
  reg _0256_;
  reg _0257_;
  reg _0258_;
  reg _0259_;
  reg _0260_;
  reg _0261_;
  reg _0262_;
  reg _0263_;
  reg _0264_;
  reg _0265_;
  reg _0266_;
  reg _0267_;
  reg _0268_;
  reg _0269_;
  reg _0270_;
  reg _0271_;
  reg _0272_;
  reg _0273_;
  reg _0274_;
  reg _0275_;
  reg _0276_;
  reg _0277_;
  reg _0278_;
  reg _0279_;
  reg _0280_;
  reg _0281_;
  reg _0282_;
  reg _0283_;
  reg _0284_;
  reg _0285_;
  reg _0286_;
  reg _0287_;
  reg _0288_;
  reg _0289_;
  reg _0290_;
  reg _0291_;
  reg _0292_;
  reg _0293_;
  reg _0294_;
  reg _0295_;
  reg _0296_;
  reg _0297_;
  reg _0298_;
  reg _0299_;
  reg _0300_;
  reg _0301_;
  reg _0302_;
  reg _0303_;
  reg _0304_;
  reg _0305_;
  reg _0306_;
  reg _0307_;
  reg _0308_;
  reg _0309_;
  reg _0310_;
  reg _0311_;
  reg _0312_;
  reg _0313_;
  reg _0314_;
  reg _0315_;
  reg _0316_;
  reg _0317_;
  reg _0318_;
  reg _0319_;
  reg _0320_;
  reg _0321_;
  reg _0322_;
  reg _0323_;
  reg _0324_;
  reg _0325_;
  reg _0326_;
  reg _0327_;
  reg _0328_;
  reg _0329_;
  reg _0330_;
  reg _0331_;
  reg _0332_;
  reg _0333_;
  reg _0334_;
  reg _0335_;
  reg _0336_;
  reg _0337_;
  reg _0338_;
  reg _0339_;
  reg _0340_;
  reg _0341_;
  reg _0342_;
  reg _0343_;
  reg _0344_;
  reg _0345_;
  reg _0346_;
  reg _0347_;
  reg _0348_;
  reg _0349_;
  reg _0350_;
  reg _0351_;
  reg _0352_;
  reg _0353_;
  reg _0354_;
  reg _0355_;
  reg _0356_;
  reg _0357_;
  reg _0358_;
  reg _0359_;
  reg _0360_;
  reg _0361_;
  reg _0362_;
  reg _0363_;
  reg _0364_;
  reg _0365_;
  reg _0366_;
  reg _0367_;
  reg _0368_;
  reg _0369_;
  reg _0370_;
  reg _0371_;
  reg _0372_;
  reg _0373_;
  reg _0374_;
  reg _0375_;
  reg _0376_;
  reg _0377_;
  reg _0378_;
  reg _0379_;
  reg _0380_;
  reg _0381_;
  reg _0382_;
  reg _0383_;
  reg _0384_;
  reg _0385_;
  reg _0386_;
  reg _0387_;
  reg _0388_;
  reg _0389_;
  reg _0390_;
  reg _0391_;
  reg _0392_;
  reg _0393_;
  reg _0394_;
  reg _0395_;
  reg _0396_;
  reg _0397_;
  reg _0398_;
  reg _0399_;
  reg _0400_;
  reg _0401_;
  reg _0402_;
  reg _0403_;
  reg _0404_;
  reg _0405_;
  reg _0406_;
  reg _0407_;
  reg _0408_;
  reg _0409_;
  reg _0410_;
  reg _0411_;
  reg _0412_;
  reg _0413_;
  reg _0414_;
  reg _0415_;
  reg _0416_;
  reg _0417_;
  reg _0418_;
  reg _0419_;
  reg _0420_;
  reg _0421_;
  reg _0422_;
  reg _0423_;
  reg _0424_;
  reg _0425_;
  reg _0426_;
  reg _0427_;
  reg _0428_;
  reg _0429_;
  reg _0430_;
  reg _0431_;
  reg _0432_;
  reg _0433_;
  reg _0434_;
  reg _0435_;
  reg _0436_;
  reg _0437_;
  reg _0438_;
  reg _0439_;
  reg _0440_;
  reg _0441_;
  reg _0442_;
  reg _0443_;
  reg _0444_;
  reg _0445_;
  reg _0446_;
  reg _0447_;
  reg _0448_;
  reg _0449_;
  reg _0450_;
  reg _0451_;
  reg _0452_;
  reg _0453_;
  reg _0454_;
  reg _0455_;
  reg _0456_;
  reg _0457_;
  reg _0458_;
  reg _0459_;
  reg _0460_;
  reg _0461_;
  reg _0462_;
  reg _0463_;
  reg _0464_;
  reg _0465_;
  reg _0466_;
  reg _0467_;
  reg _0468_;
  reg _0469_;
  reg _0470_;
  reg _0471_;
  reg _0472_;
  reg _0473_;
  reg _0474_;
  reg _0475_;
  reg _0476_;
  reg _0477_;
  reg _0478_;
  reg _0479_;
  reg _0480_;
  reg _0481_;
  reg _0482_;
  reg _0483_;
  reg _0484_;
  reg _0485_;
  reg _0486_;
  reg _0487_;
  reg _0488_;
  reg _0489_;
  reg _0490_;
  reg _0491_;
  reg _0492_;
  reg _0493_;
  reg _0494_;
  reg _0495_;
  reg _0496_;
  reg _0497_;
  reg _0498_;
  reg _0499_;
  reg _0500_;
  reg _0501_;
  reg _0502_;
  reg _0503_;
  reg _0504_;
  reg _0505_;
  reg _0506_;
  reg _0507_;
  reg _0508_;
  reg _0509_;
  reg _0510_;
  reg _0511_;
  reg _0512_;
  reg _0513_;
  reg _0514_;
  reg _0515_;
  reg _0516_;
  reg _0517_;
  reg _0518_;
  reg _0519_;
  reg _0520_;
  reg _0521_;
  reg _0522_;
  reg _0523_;
  reg _0524_;
  reg _0525_;
  reg _0526_;
  reg _0527_;
  reg _0528_;
  reg _0529_;
  reg _0530_;
  reg _0531_;
  reg _0532_;
  reg _0533_;
  reg _0534_;
  reg _0535_;
  reg _0536_;
  reg _0537_;
  reg _0538_;
  reg _0539_;
  reg _0540_;
  reg _0541_;
  reg _0542_;
  reg _0543_;
  reg _0544_;
  reg _0545_;
  reg _0546_;
  reg _0547_;
  reg _0548_;
  reg _0549_;
  reg _0550_;
  reg _0551_;
  reg _0552_;
  reg _0553_;
  reg _0554_;
  reg _0555_;
  reg _0556_;
  reg _0557_;
  reg _0558_;
  reg _0559_;
  reg _0560_;
  reg _0561_;
  reg _0562_;
  reg _0563_;
  reg _0564_;
  reg _0565_;
  reg _0566_;
  reg _0567_;
  reg _0568_;
  reg _0569_;
  reg _0570_;
  reg _0571_;
  reg _0572_;
  reg _0573_;
  reg _0574_;
  reg _0575_;
  reg _0576_;
  reg _0577_;
  reg _0578_;
  reg _0579_;
  reg _0580_;
  reg _0581_;
  reg _0582_;
  reg _0583_;
  reg _0584_;
  reg _0585_;
  reg _0586_;
  reg _0587_;
  reg _0588_;
  reg _0589_;
  reg _0590_;
  reg _0591_;
  reg _0592_;
  reg _0593_;
  reg _0594_;
  reg _0595_;
  reg _0596_;
  reg _0597_;
  reg _0598_;
  reg _0599_;
  reg _0600_;
  reg _0601_;
  reg _0602_;
  reg _0603_;
  reg _0604_;
  reg _0605_;
  reg _0606_;
  reg _0607_;
  reg _0608_;
  reg _0609_;
  reg _0610_;
  reg _0611_;
  reg _0612_;
  reg _0613_;
  reg _0614_;
  reg _0615_;
  reg _0616_;
  reg _0617_;
  reg _0618_;
  reg _0619_;
  reg _0620_;
  reg _0621_;
  reg _0622_;
  reg _0623_;
  reg _0624_;
  reg _0625_;
  reg _0626_;
  reg _0627_;
  reg _0628_;
  reg _0629_;
  reg _0630_;
  reg _0631_;
  reg _0632_;
  reg _0633_;
  reg _0634_;
  reg _0635_;
  reg _0636_;
  reg _0637_;
  reg _0638_;
  reg _0639_;
  reg _0640_;
  reg _0641_;
  reg _0642_;
  reg _0643_;
  reg _0644_;
  reg _0645_;
  reg _0646_;
  reg _0647_;
  reg _0648_;
  reg [15:0] a2_ff1;
  reg [15:0] a3_ff1;
  reg [15:0] a3_ff2;
  reg [15:0] a4_ff1;
  reg [15:0] a4_ff2;
  reg [15:0] a4_ff3;
  
  
  reg [15:0] b2_ff1;
  reg [15:0] b3_ff1;
  reg [15:0] b3_ff2;
  reg [15:0] b4_ff1;
  reg [15:0] b4_ff2;
  reg [15:0] b4_ff3;
  reg c1;
  reg c2;
  reg c3;
  reg c4;
  
  
  
  
  
  
  
  reg [15:0] s1;
  reg [15:0] s1_ff1;
  reg [15:0] s1_ff2;
  reg [15:0] s2;
  reg [15:0] s2_ff1;
  reg [15:0] s3;
  reg stage1;
  reg stage2;
  reg stage3;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      c4 <= 0;
    else
      c4 <= _0003_;
  reg \result_reg[48] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[48]  <= 0;
    else
      \result_reg[48]  <= _0007_[0];
  reg \result_reg[49] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[49]  <= 0;
    else
      \result_reg[49]  <= _0007_[1];
  reg \result_reg[50] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[50]  <= 0;
    else
      \result_reg[50]  <= _0007_[2];
  reg \result_reg[51] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[51]  <= 0;
    else
      \result_reg[51]  <= _0007_[3];
  reg \result_reg[52] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[52]  <= 0;
    else
      \result_reg[52]  <= _0007_[4];
  reg \result_reg[53] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[53]  <= 0;
    else
      \result_reg[53]  <= _0007_[5];
  reg \result_reg[54] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[54]  <= 0;
    else
      \result_reg[54]  <= _0007_[6];
  reg \result_reg[55] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[55]  <= 0;
    else
      \result_reg[55]  <= _0007_[7];
  reg \result_reg[56] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[56]  <= 0;
    else
      \result_reg[56]  <= _0007_[8];
  reg \result_reg[57] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[57]  <= 0;
    else
      \result_reg[57]  <= _0007_[9];
  reg \result_reg[58] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[58]  <= 0;
    else
      \result_reg[58]  <= _0007_[10];
  reg \result_reg[59] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[59]  <= 0;
    else
      \result_reg[59]  <= _0007_[11];
  reg \result_reg[60] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[60]  <= 0;
    else
      \result_reg[60]  <= _0007_[12];
  reg \result_reg[61] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[61]  <= 0;
    else
      \result_reg[61]  <= _0007_[13];
  reg \result_reg[62] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[62]  <= 0;
    else
      \result_reg[62]  <= _0007_[14];
  reg \result_reg[63] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[63]  <= 0;
    else
      \result_reg[63]  <= _0007_[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      c3 <= 0;
    else
      c3 <= _0002_;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[0] <= 0;
    else
      s3[0] <= _0006_[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[1] <= 0;
    else
      s3[1] <= _0006_[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[2] <= 0;
    else
      s3[2] <= _0006_[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[3] <= 0;
    else
      s3[3] <= _0006_[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[4] <= 0;
    else
      s3[4] <= _0006_[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[5] <= 0;
    else
      s3[5] <= _0006_[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[6] <= 0;
    else
      s3[6] <= _0006_[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[7] <= 0;
    else
      s3[7] <= _0006_[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[8] <= 0;
    else
      s3[8] <= _0006_[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[9] <= 0;
    else
      s3[9] <= _0006_[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[10] <= 0;
    else
      s3[10] <= _0006_[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[11] <= 0;
    else
      s3[11] <= _0006_[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[12] <= 0;
    else
      s3[12] <= _0006_[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[13] <= 0;
    else
      s3[13] <= _0006_[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[14] <= 0;
    else
      s3[14] <= _0006_[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s3[15] <= 0;
    else
      s3[15] <= _0006_[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      c2 <= 0;
    else
      c2 <= _0001_;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[0] <= 0;
    else
      s2[0] <= _0005_[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[1] <= 0;
    else
      s2[1] <= _0005_[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[2] <= 0;
    else
      s2[2] <= _0005_[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[3] <= 0;
    else
      s2[3] <= _0005_[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[4] <= 0;
    else
      s2[4] <= _0005_[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[5] <= 0;
    else
      s2[5] <= _0005_[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[6] <= 0;
    else
      s2[6] <= _0005_[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[7] <= 0;
    else
      s2[7] <= _0005_[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[8] <= 0;
    else
      s2[8] <= _0005_[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[9] <= 0;
    else
      s2[9] <= _0005_[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[10] <= 0;
    else
      s2[10] <= _0005_[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[11] <= 0;
    else
      s2[11] <= _0005_[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[12] <= 0;
    else
      s2[12] <= _0005_[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[13] <= 0;
    else
      s2[13] <= _0005_[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[14] <= 0;
    else
      s2[14] <= _0005_[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2[15] <= 0;
    else
      s2[15] <= _0005_[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      c1 <= 0;
    else
      c1 <= _0000_;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[0] <= 0;
    else
      s1[0] <= _0004_[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[1] <= 0;
    else
      s1[1] <= _0004_[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[2] <= 0;
    else
      s1[2] <= _0004_[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[3] <= 0;
    else
      s1[3] <= _0004_[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[4] <= 0;
    else
      s1[4] <= _0004_[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[5] <= 0;
    else
      s1[5] <= _0004_[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[6] <= 0;
    else
      s1[6] <= _0004_[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[7] <= 0;
    else
      s1[7] <= _0004_[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[8] <= 0;
    else
      s1[8] <= _0004_[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[9] <= 0;
    else
      s1[9] <= _0004_[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[10] <= 0;
    else
      s1[10] <= _0004_[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[11] <= 0;
    else
      s1[11] <= _0004_[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[12] <= 0;
    else
      s1[12] <= _0004_[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[13] <= 0;
    else
      s1[13] <= _0004_[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[14] <= 0;
    else
      s1[14] <= _0004_[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1[15] <= 0;
    else
      s1[15] <= _0004_[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[0] <= 0;
    else
      s1_ff1[0] <= s1[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[1] <= 0;
    else
      s1_ff1[1] <= s1[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[2] <= 0;
    else
      s1_ff1[2] <= s1[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[3] <= 0;
    else
      s1_ff1[3] <= s1[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[4] <= 0;
    else
      s1_ff1[4] <= s1[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[5] <= 0;
    else
      s1_ff1[5] <= s1[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[6] <= 0;
    else
      s1_ff1[6] <= s1[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[7] <= 0;
    else
      s1_ff1[7] <= s1[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[8] <= 0;
    else
      s1_ff1[8] <= s1[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[9] <= 0;
    else
      s1_ff1[9] <= s1[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[10] <= 0;
    else
      s1_ff1[10] <= s1[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[11] <= 0;
    else
      s1_ff1[11] <= s1[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[12] <= 0;
    else
      s1_ff1[12] <= s1[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[13] <= 0;
    else
      s1_ff1[13] <= s1[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[14] <= 0;
    else
      s1_ff1[14] <= s1[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff1[15] <= 0;
    else
      s1_ff1[15] <= s1[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[0] <= 0;
    else
      s1_ff2[0] <= s1_ff1[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[1] <= 0;
    else
      s1_ff2[1] <= s1_ff1[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[2] <= 0;
    else
      s1_ff2[2] <= s1_ff1[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[3] <= 0;
    else
      s1_ff2[3] <= s1_ff1[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[4] <= 0;
    else
      s1_ff2[4] <= s1_ff1[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[5] <= 0;
    else
      s1_ff2[5] <= s1_ff1[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[6] <= 0;
    else
      s1_ff2[6] <= s1_ff1[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[7] <= 0;
    else
      s1_ff2[7] <= s1_ff1[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[8] <= 0;
    else
      s1_ff2[8] <= s1_ff1[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[9] <= 0;
    else
      s1_ff2[9] <= s1_ff1[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[10] <= 0;
    else
      s1_ff2[10] <= s1_ff1[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[11] <= 0;
    else
      s1_ff2[11] <= s1_ff1[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[12] <= 0;
    else
      s1_ff2[12] <= s1_ff1[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[13] <= 0;
    else
      s1_ff2[13] <= s1_ff1[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[14] <= 0;
    else
      s1_ff2[14] <= s1_ff1[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s1_ff2[15] <= 0;
    else
      s1_ff2[15] <= s1_ff1[15];
  reg \result_reg[0] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[0]  <= 0;
    else
      \result_reg[0]  <= s1_ff2[0];
  reg \result_reg[1] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[1]  <= 0;
    else
      \result_reg[1]  <= s1_ff2[1];
  reg \result_reg[2] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[2]  <= 0;
    else
      \result_reg[2]  <= s1_ff2[2];
  reg \result_reg[3] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[3]  <= 0;
    else
      \result_reg[3]  <= s1_ff2[3];
  reg \result_reg[4] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[4]  <= 0;
    else
      \result_reg[4]  <= s1_ff2[4];
  reg \result_reg[5] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[5]  <= 0;
    else
      \result_reg[5]  <= s1_ff2[5];
  reg \result_reg[6] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[6]  <= 0;
    else
      \result_reg[6]  <= s1_ff2[6];
  reg \result_reg[7] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[7]  <= 0;
    else
      \result_reg[7]  <= s1_ff2[7];
  reg \result_reg[8] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[8]  <= 0;
    else
      \result_reg[8]  <= s1_ff2[8];
  reg \result_reg[9] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[9]  <= 0;
    else
      \result_reg[9]  <= s1_ff2[9];
  reg \result_reg[10] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[10]  <= 0;
    else
      \result_reg[10]  <= s1_ff2[10];
  reg \result_reg[11] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[11]  <= 0;
    else
      \result_reg[11]  <= s1_ff2[11];
  reg \result_reg[12] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[12]  <= 0;
    else
      \result_reg[12]  <= s1_ff2[12];
  reg \result_reg[13] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[13]  <= 0;
    else
      \result_reg[13]  <= s1_ff2[13];
  reg \result_reg[14] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[14]  <= 0;
    else
      \result_reg[14]  <= s1_ff2[14];
  reg \result_reg[15] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[15]  <= 0;
    else
      \result_reg[15]  <= s1_ff2[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[0] <= 0;
    else
      s2_ff1[0] <= s2[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[1] <= 0;
    else
      s2_ff1[1] <= s2[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[2] <= 0;
    else
      s2_ff1[2] <= s2[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[3] <= 0;
    else
      s2_ff1[3] <= s2[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[4] <= 0;
    else
      s2_ff1[4] <= s2[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[5] <= 0;
    else
      s2_ff1[5] <= s2[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[6] <= 0;
    else
      s2_ff1[6] <= s2[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[7] <= 0;
    else
      s2_ff1[7] <= s2[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[8] <= 0;
    else
      s2_ff1[8] <= s2[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[9] <= 0;
    else
      s2_ff1[9] <= s2[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[10] <= 0;
    else
      s2_ff1[10] <= s2[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[11] <= 0;
    else
      s2_ff1[11] <= s2[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[12] <= 0;
    else
      s2_ff1[12] <= s2[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[13] <= 0;
    else
      s2_ff1[13] <= s2[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[14] <= 0;
    else
      s2_ff1[14] <= s2[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      s2_ff1[15] <= 0;
    else
      s2_ff1[15] <= s2[15];
  reg \result_reg[16] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[16]  <= 0;
    else
      \result_reg[16]  <= s2_ff1[0];
  reg \result_reg[17] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[17]  <= 0;
    else
      \result_reg[17]  <= s2_ff1[1];
  reg \result_reg[18] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[18]  <= 0;
    else
      \result_reg[18]  <= s2_ff1[2];
  reg \result_reg[19] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[19]  <= 0;
    else
      \result_reg[19]  <= s2_ff1[3];
  reg \result_reg[20] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[20]  <= 0;
    else
      \result_reg[20]  <= s2_ff1[4];
  reg \result_reg[21] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[21]  <= 0;
    else
      \result_reg[21]  <= s2_ff1[5];
  reg \result_reg[22] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[22]  <= 0;
    else
      \result_reg[22]  <= s2_ff1[6];
  reg \result_reg[23] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[23]  <= 0;
    else
      \result_reg[23]  <= s2_ff1[7];
  reg \result_reg[24] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[24]  <= 0;
    else
      \result_reg[24]  <= s2_ff1[8];
  reg \result_reg[25] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[25]  <= 0;
    else
      \result_reg[25]  <= s2_ff1[9];
  reg \result_reg[26] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[26]  <= 0;
    else
      \result_reg[26]  <= s2_ff1[10];
  reg \result_reg[27] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[27]  <= 0;
    else
      \result_reg[27]  <= s2_ff1[11];
  reg \result_reg[28] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[28]  <= 0;
    else
      \result_reg[28]  <= s2_ff1[12];
  reg \result_reg[29] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[29]  <= 0;
    else
      \result_reg[29]  <= s2_ff1[13];
  reg \result_reg[30] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[30]  <= 0;
    else
      \result_reg[30]  <= s2_ff1[14];
  reg \result_reg[31] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[31]  <= 0;
    else
      \result_reg[31]  <= s2_ff1[15];
  reg \result_reg[32] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[32]  <= 0;
    else
      \result_reg[32]  <= s3[0];
  reg \result_reg[33] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[33]  <= 0;
    else
      \result_reg[33]  <= s3[1];
  reg \result_reg[34] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[34]  <= 0;
    else
      \result_reg[34]  <= s3[2];
  reg \result_reg[35] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[35]  <= 0;
    else
      \result_reg[35]  <= s3[3];
  reg \result_reg[36] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[36]  <= 0;
    else
      \result_reg[36]  <= s3[4];
  reg \result_reg[37] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[37]  <= 0;
    else
      \result_reg[37]  <= s3[5];
  reg \result_reg[38] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[38]  <= 0;
    else
      \result_reg[38]  <= s3[6];
  reg \result_reg[39] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[39]  <= 0;
    else
      \result_reg[39]  <= s3[7];
  reg \result_reg[40] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[40]  <= 0;
    else
      \result_reg[40]  <= s3[8];
  reg \result_reg[41] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[41]  <= 0;
    else
      \result_reg[41]  <= s3[9];
  reg \result_reg[42] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[42]  <= 0;
    else
      \result_reg[42]  <= s3[10];
  reg \result_reg[43] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[43]  <= 0;
    else
      \result_reg[43]  <= s3[11];
  reg \result_reg[44] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[44]  <= 0;
    else
      \result_reg[44]  <= s3[12];
  reg \result_reg[45] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[45]  <= 0;
    else
      \result_reg[45]  <= s3[13];
  reg \result_reg[46] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[46]  <= 0;
    else
      \result_reg[46]  <= s3[14];
  reg \result_reg[47] ;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      \result_reg[47]  <= 0;
    else
      \result_reg[47]  <= s3[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[0] <= 0;
    else
      a2_ff1[0] <= rtlopt_78ddd3f77dac_port_adda[16];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[1] <= 0;
    else
      a2_ff1[1] <= rtlopt_78ddd3f77dac_port_adda[17];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[2] <= 0;
    else
      a2_ff1[2] <= rtlopt_78ddd3f77dac_port_adda[18];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[3] <= 0;
    else
      a2_ff1[3] <= rtlopt_78ddd3f77dac_port_adda[19];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[4] <= 0;
    else
      a2_ff1[4] <= rtlopt_78ddd3f77dac_port_adda[20];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[5] <= 0;
    else
      a2_ff1[5] <= rtlopt_78ddd3f77dac_port_adda[21];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[6] <= 0;
    else
      a2_ff1[6] <= rtlopt_78ddd3f77dac_port_adda[22];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[7] <= 0;
    else
      a2_ff1[7] <= rtlopt_78ddd3f77dac_port_adda[23];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[8] <= 0;
    else
      a2_ff1[8] <= rtlopt_78ddd3f77dac_port_adda[24];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[9] <= 0;
    else
      a2_ff1[9] <= rtlopt_78ddd3f77dac_port_adda[25];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[10] <= 0;
    else
      a2_ff1[10] <= rtlopt_78ddd3f77dac_port_adda[26];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[11] <= 0;
    else
      a2_ff1[11] <= rtlopt_78ddd3f77dac_port_adda[27];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[12] <= 0;
    else
      a2_ff1[12] <= rtlopt_78ddd3f77dac_port_adda[28];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[13] <= 0;
    else
      a2_ff1[13] <= rtlopt_78ddd3f77dac_port_adda[29];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[14] <= 0;
    else
      a2_ff1[14] <= rtlopt_78ddd3f77dac_port_adda[30];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a2_ff1[15] <= 0;
    else
      a2_ff1[15] <= rtlopt_78ddd3f77dac_port_adda[31];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[0] <= 0;
    else
      b2_ff1[0] <= rtlopt_78ddd3f77dac_port_addb[16];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[1] <= 0;
    else
      b2_ff1[1] <= rtlopt_78ddd3f77dac_port_addb[17];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[2] <= 0;
    else
      b2_ff1[2] <= rtlopt_78ddd3f77dac_port_addb[18];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[3] <= 0;
    else
      b2_ff1[3] <= rtlopt_78ddd3f77dac_port_addb[19];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[4] <= 0;
    else
      b2_ff1[4] <= rtlopt_78ddd3f77dac_port_addb[20];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[5] <= 0;
    else
      b2_ff1[5] <= rtlopt_78ddd3f77dac_port_addb[21];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[6] <= 0;
    else
      b2_ff1[6] <= rtlopt_78ddd3f77dac_port_addb[22];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[7] <= 0;
    else
      b2_ff1[7] <= rtlopt_78ddd3f77dac_port_addb[23];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[8] <= 0;
    else
      b2_ff1[8] <= rtlopt_78ddd3f77dac_port_addb[24];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[9] <= 0;
    else
      b2_ff1[9] <= rtlopt_78ddd3f77dac_port_addb[25];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[10] <= 0;
    else
      b2_ff1[10] <= rtlopt_78ddd3f77dac_port_addb[26];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[11] <= 0;
    else
      b2_ff1[11] <= rtlopt_78ddd3f77dac_port_addb[27];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[12] <= 0;
    else
      b2_ff1[12] <= rtlopt_78ddd3f77dac_port_addb[28];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[13] <= 0;
    else
      b2_ff1[13] <= rtlopt_78ddd3f77dac_port_addb[29];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[14] <= 0;
    else
      b2_ff1[14] <= rtlopt_78ddd3f77dac_port_addb[30];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b2_ff1[15] <= 0;
    else
      b2_ff1[15] <= rtlopt_78ddd3f77dac_port_addb[31];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[0] <= 0;
    else
      a3_ff1[0] <= rtlopt_78ddd3f77dac_port_adda[32];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[1] <= 0;
    else
      a3_ff1[1] <= rtlopt_78ddd3f77dac_port_adda[33];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[2] <= 0;
    else
      a3_ff1[2] <= rtlopt_78ddd3f77dac_port_adda[34];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[3] <= 0;
    else
      a3_ff1[3] <= rtlopt_78ddd3f77dac_port_adda[35];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[4] <= 0;
    else
      a3_ff1[4] <= rtlopt_78ddd3f77dac_port_adda[36];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[5] <= 0;
    else
      a3_ff1[5] <= rtlopt_78ddd3f77dac_port_adda[37];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[6] <= 0;
    else
      a3_ff1[6] <= rtlopt_78ddd3f77dac_port_adda[38];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[7] <= 0;
    else
      a3_ff1[7] <= rtlopt_78ddd3f77dac_port_adda[39];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[8] <= 0;
    else
      a3_ff1[8] <= rtlopt_78ddd3f77dac_port_adda[40];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[9] <= 0;
    else
      a3_ff1[9] <= rtlopt_78ddd3f77dac_port_adda[41];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[10] <= 0;
    else
      a3_ff1[10] <= rtlopt_78ddd3f77dac_port_adda[42];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[11] <= 0;
    else
      a3_ff1[11] <= rtlopt_78ddd3f77dac_port_adda[43];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[12] <= 0;
    else
      a3_ff1[12] <= rtlopt_78ddd3f77dac_port_adda[44];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[13] <= 0;
    else
      a3_ff1[13] <= rtlopt_78ddd3f77dac_port_adda[45];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[14] <= 0;
    else
      a3_ff1[14] <= rtlopt_78ddd3f77dac_port_adda[46];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff1[15] <= 0;
    else
      a3_ff1[15] <= rtlopt_78ddd3f77dac_port_adda[47];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[0] <= 0;
    else
      b3_ff1[0] <= rtlopt_78ddd3f77dac_port_addb[32];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[1] <= 0;
    else
      b3_ff1[1] <= rtlopt_78ddd3f77dac_port_addb[33];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[2] <= 0;
    else
      b3_ff1[2] <= rtlopt_78ddd3f77dac_port_addb[34];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[3] <= 0;
    else
      b3_ff1[3] <= rtlopt_78ddd3f77dac_port_addb[35];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[4] <= 0;
    else
      b3_ff1[4] <= rtlopt_78ddd3f77dac_port_addb[36];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[5] <= 0;
    else
      b3_ff1[5] <= rtlopt_78ddd3f77dac_port_addb[37];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[6] <= 0;
    else
      b3_ff1[6] <= rtlopt_78ddd3f77dac_port_addb[38];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[7] <= 0;
    else
      b3_ff1[7] <= rtlopt_78ddd3f77dac_port_addb[39];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[8] <= 0;
    else
      b3_ff1[8] <= rtlopt_78ddd3f77dac_port_addb[40];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[9] <= 0;
    else
      b3_ff1[9] <= rtlopt_78ddd3f77dac_port_addb[41];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[10] <= 0;
    else
      b3_ff1[10] <= rtlopt_78ddd3f77dac_port_addb[42];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[11] <= 0;
    else
      b3_ff1[11] <= rtlopt_78ddd3f77dac_port_addb[43];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[12] <= 0;
    else
      b3_ff1[12] <= rtlopt_78ddd3f77dac_port_addb[44];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[13] <= 0;
    else
      b3_ff1[13] <= rtlopt_78ddd3f77dac_port_addb[45];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[14] <= 0;
    else
      b3_ff1[14] <= rtlopt_78ddd3f77dac_port_addb[46];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff1[15] <= 0;
    else
      b3_ff1[15] <= rtlopt_78ddd3f77dac_port_addb[47];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[0] <= 0;
    else
      a3_ff2[0] <= a3_ff1[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[1] <= 0;
    else
      a3_ff2[1] <= a3_ff1[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[2] <= 0;
    else
      a3_ff2[2] <= a3_ff1[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[3] <= 0;
    else
      a3_ff2[3] <= a3_ff1[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[4] <= 0;
    else
      a3_ff2[4] <= a3_ff1[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[5] <= 0;
    else
      a3_ff2[5] <= a3_ff1[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[6] <= 0;
    else
      a3_ff2[6] <= a3_ff1[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[7] <= 0;
    else
      a3_ff2[7] <= a3_ff1[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[8] <= 0;
    else
      a3_ff2[8] <= a3_ff1[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[9] <= 0;
    else
      a3_ff2[9] <= a3_ff1[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[10] <= 0;
    else
      a3_ff2[10] <= a3_ff1[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[11] <= 0;
    else
      a3_ff2[11] <= a3_ff1[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[12] <= 0;
    else
      a3_ff2[12] <= a3_ff1[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[13] <= 0;
    else
      a3_ff2[13] <= a3_ff1[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[14] <= 0;
    else
      a3_ff2[14] <= a3_ff1[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a3_ff2[15] <= 0;
    else
      a3_ff2[15] <= a3_ff1[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[0] <= 0;
    else
      b3_ff2[0] <= b3_ff1[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[1] <= 0;
    else
      b3_ff2[1] <= b3_ff1[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[2] <= 0;
    else
      b3_ff2[2] <= b3_ff1[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[3] <= 0;
    else
      b3_ff2[3] <= b3_ff1[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[4] <= 0;
    else
      b3_ff2[4] <= b3_ff1[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[5] <= 0;
    else
      b3_ff2[5] <= b3_ff1[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[6] <= 0;
    else
      b3_ff2[6] <= b3_ff1[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[7] <= 0;
    else
      b3_ff2[7] <= b3_ff1[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[8] <= 0;
    else
      b3_ff2[8] <= b3_ff1[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[9] <= 0;
    else
      b3_ff2[9] <= b3_ff1[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[10] <= 0;
    else
      b3_ff2[10] <= b3_ff1[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[11] <= 0;
    else
      b3_ff2[11] <= b3_ff1[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[12] <= 0;
    else
      b3_ff2[12] <= b3_ff1[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[13] <= 0;
    else
      b3_ff2[13] <= b3_ff1[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[14] <= 0;
    else
      b3_ff2[14] <= b3_ff1[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b3_ff2[15] <= 0;
    else
      b3_ff2[15] <= b3_ff1[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[0] <= 0;
    else
      a4_ff1[0] <= rtlopt_78ddd3f77dac_port_adda[48];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[1] <= 0;
    else
      a4_ff1[1] <= rtlopt_78ddd3f77dac_port_adda[49];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[2] <= 0;
    else
      a4_ff1[2] <= rtlopt_78ddd3f77dac_port_adda[50];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[3] <= 0;
    else
      a4_ff1[3] <= rtlopt_78ddd3f77dac_port_adda[51];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[4] <= 0;
    else
      a4_ff1[4] <= rtlopt_78ddd3f77dac_port_adda[52];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[5] <= 0;
    else
      a4_ff1[5] <= rtlopt_78ddd3f77dac_port_adda[53];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[6] <= 0;
    else
      a4_ff1[6] <= rtlopt_78ddd3f77dac_port_adda[54];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[7] <= 0;
    else
      a4_ff1[7] <= rtlopt_78ddd3f77dac_port_adda[55];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[8] <= 0;
    else
      a4_ff1[8] <= rtlopt_78ddd3f77dac_port_adda[56];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[9] <= 0;
    else
      a4_ff1[9] <= rtlopt_78ddd3f77dac_port_adda[57];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[10] <= 0;
    else
      a4_ff1[10] <= rtlopt_78ddd3f77dac_port_adda[58];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[11] <= 0;
    else
      a4_ff1[11] <= rtlopt_78ddd3f77dac_port_adda[59];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[12] <= 0;
    else
      a4_ff1[12] <= rtlopt_78ddd3f77dac_port_adda[60];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[13] <= 0;
    else
      a4_ff1[13] <= rtlopt_78ddd3f77dac_port_adda[61];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[14] <= 0;
    else
      a4_ff1[14] <= rtlopt_78ddd3f77dac_port_adda[62];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff1[15] <= 0;
    else
      a4_ff1[15] <= rtlopt_78ddd3f77dac_port_adda[63];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[0] <= 0;
    else
      b4_ff1[0] <= rtlopt_78ddd3f77dac_port_addb[48];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[1] <= 0;
    else
      b4_ff1[1] <= rtlopt_78ddd3f77dac_port_addb[49];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[2] <= 0;
    else
      b4_ff1[2] <= rtlopt_78ddd3f77dac_port_addb[50];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[3] <= 0;
    else
      b4_ff1[3] <= rtlopt_78ddd3f77dac_port_addb[51];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[4] <= 0;
    else
      b4_ff1[4] <= rtlopt_78ddd3f77dac_port_addb[52];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[5] <= 0;
    else
      b4_ff1[5] <= rtlopt_78ddd3f77dac_port_addb[53];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[6] <= 0;
    else
      b4_ff1[6] <= rtlopt_78ddd3f77dac_port_addb[54];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[7] <= 0;
    else
      b4_ff1[7] <= rtlopt_78ddd3f77dac_port_addb[55];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[8] <= 0;
    else
      b4_ff1[8] <= rtlopt_78ddd3f77dac_port_addb[56];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[9] <= 0;
    else
      b4_ff1[9] <= rtlopt_78ddd3f77dac_port_addb[57];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[10] <= 0;
    else
      b4_ff1[10] <= rtlopt_78ddd3f77dac_port_addb[58];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[11] <= 0;
    else
      b4_ff1[11] <= rtlopt_78ddd3f77dac_port_addb[59];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[12] <= 0;
    else
      b4_ff1[12] <= rtlopt_78ddd3f77dac_port_addb[60];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[13] <= 0;
    else
      b4_ff1[13] <= rtlopt_78ddd3f77dac_port_addb[61];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[14] <= 0;
    else
      b4_ff1[14] <= rtlopt_78ddd3f77dac_port_addb[62];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff1[15] <= 0;
    else
      b4_ff1[15] <= rtlopt_78ddd3f77dac_port_addb[63];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[0] <= 0;
    else
      a4_ff2[0] <= a4_ff1[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[1] <= 0;
    else
      a4_ff2[1] <= a4_ff1[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[2] <= 0;
    else
      a4_ff2[2] <= a4_ff1[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[3] <= 0;
    else
      a4_ff2[3] <= a4_ff1[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[4] <= 0;
    else
      a4_ff2[4] <= a4_ff1[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[5] <= 0;
    else
      a4_ff2[5] <= a4_ff1[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[6] <= 0;
    else
      a4_ff2[6] <= a4_ff1[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[7] <= 0;
    else
      a4_ff2[7] <= a4_ff1[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[8] <= 0;
    else
      a4_ff2[8] <= a4_ff1[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[9] <= 0;
    else
      a4_ff2[9] <= a4_ff1[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[10] <= 0;
    else
      a4_ff2[10] <= a4_ff1[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[11] <= 0;
    else
      a4_ff2[11] <= a4_ff1[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[12] <= 0;
    else
      a4_ff2[12] <= a4_ff1[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[13] <= 0;
    else
      a4_ff2[13] <= a4_ff1[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[14] <= 0;
    else
      a4_ff2[14] <= a4_ff1[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff2[15] <= 0;
    else
      a4_ff2[15] <= a4_ff1[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[0] <= 0;
    else
      b4_ff2[0] <= b4_ff1[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[1] <= 0;
    else
      b4_ff2[1] <= b4_ff1[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[2] <= 0;
    else
      b4_ff2[2] <= b4_ff1[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[3] <= 0;
    else
      b4_ff2[3] <= b4_ff1[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[4] <= 0;
    else
      b4_ff2[4] <= b4_ff1[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[5] <= 0;
    else
      b4_ff2[5] <= b4_ff1[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[6] <= 0;
    else
      b4_ff2[6] <= b4_ff1[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[7] <= 0;
    else
      b4_ff2[7] <= b4_ff1[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[8] <= 0;
    else
      b4_ff2[8] <= b4_ff1[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[9] <= 0;
    else
      b4_ff2[9] <= b4_ff1[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[10] <= 0;
    else
      b4_ff2[10] <= b4_ff1[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[11] <= 0;
    else
      b4_ff2[11] <= b4_ff1[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[12] <= 0;
    else
      b4_ff2[12] <= b4_ff1[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[13] <= 0;
    else
      b4_ff2[13] <= b4_ff1[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[14] <= 0;
    else
      b4_ff2[14] <= b4_ff1[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff2[15] <= 0;
    else
      b4_ff2[15] <= b4_ff1[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[0] <= 0;
    else
      a4_ff3[0] <= a4_ff2[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[1] <= 0;
    else
      a4_ff3[1] <= a4_ff2[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[2] <= 0;
    else
      a4_ff3[2] <= a4_ff2[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[3] <= 0;
    else
      a4_ff3[3] <= a4_ff2[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[4] <= 0;
    else
      a4_ff3[4] <= a4_ff2[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[5] <= 0;
    else
      a4_ff3[5] <= a4_ff2[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[6] <= 0;
    else
      a4_ff3[6] <= a4_ff2[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[7] <= 0;
    else
      a4_ff3[7] <= a4_ff2[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[8] <= 0;
    else
      a4_ff3[8] <= a4_ff2[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[9] <= 0;
    else
      a4_ff3[9] <= a4_ff2[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[10] <= 0;
    else
      a4_ff3[10] <= a4_ff2[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[11] <= 0;
    else
      a4_ff3[11] <= a4_ff2[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[12] <= 0;
    else
      a4_ff3[12] <= a4_ff2[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[13] <= 0;
    else
      a4_ff3[13] <= a4_ff2[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[14] <= 0;
    else
      a4_ff3[14] <= a4_ff2[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      a4_ff3[15] <= 0;
    else
      a4_ff3[15] <= a4_ff2[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[0] <= 0;
    else
      b4_ff3[0] <= b4_ff2[0];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[1] <= 0;
    else
      b4_ff3[1] <= b4_ff2[1];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[2] <= 0;
    else
      b4_ff3[2] <= b4_ff2[2];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[3] <= 0;
    else
      b4_ff3[3] <= b4_ff2[3];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[4] <= 0;
    else
      b4_ff3[4] <= b4_ff2[4];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[5] <= 0;
    else
      b4_ff3[5] <= b4_ff2[5];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[6] <= 0;
    else
      b4_ff3[6] <= b4_ff2[6];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[7] <= 0;
    else
      b4_ff3[7] <= b4_ff2[7];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[8] <= 0;
    else
      b4_ff3[8] <= b4_ff2[8];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[9] <= 0;
    else
      b4_ff3[9] <= b4_ff2[9];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[10] <= 0;
    else
      b4_ff3[10] <= b4_ff2[10];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[11] <= 0;
    else
      b4_ff3[11] <= b4_ff2[11];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[12] <= 0;
    else
      b4_ff3[12] <= b4_ff2[12];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[13] <= 0;
    else
      b4_ff3[13] <= b4_ff2[13];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[14] <= 0;
    else
      b4_ff3[14] <= b4_ff2[14];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      b4_ff3[15] <= 0;
    else
      b4_ff3[15] <= b4_ff2[15];
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      rtlopt_78ddd3f77dac_port_o_en <= 0;
    else
      rtlopt_78ddd3f77dac_port_o_en <= stage3;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      stage1 <= 0;
    else
      stage1 <= rtlopt_78ddd3f77dac_port_i_en;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      stage2 <= 0;
    else
      stage2 <= stage1;
  always @(posedge rtlopt_78ddd3f77dac_port_clk or negedge rtlopt_78ddd3f77dac_port_rst_n)
    if (!rtlopt_78ddd3f77dac_port_rst_n)
      stage3 <= 0;
    else
      stage3 <= stage2;
`ifndef SYNTHESIS
  reg rtlopt_t0_kick = 1'b0;
  initial #0 rtlopt_t0_kick = 1'b1;
`endif
  always @* begin
`ifndef SYNTHESIS
    if (rtlopt_t0_kick) begin end
`endif
    _0008_ = stage3 | c4;
    _0009_ = ~(b4_ff3[15] | a4_ff3[15]);
    _0010_ = ~(b4_ff3[14] | a4_ff3[14]);
    _0011_ = ~(b4_ff3[13] & a4_ff3[13]);
    _0012_ = b4_ff3[14] & a4_ff3[14];
    _0013_ = _0011_ & ~(_0012_);
    _0014_ = _0013_ | _0010_;
    _0015_ = _0014_ | _0009_;
    _0016_ = ~stage3;
    _0017_ = b4_ff3[15] & a4_ff3[15];
    _0018_ = _0017_ | _0016_;
    _0019_ = _0015_ & ~(_0018_);
    _0020_ = b4_ff3[13] ^ a4_ff3[13];
    _0021_ = ~(b4_ff3[14] ^ a4_ff3[14]);
    _0022_ = _0020_ & ~(_0021_);
    _0023_ = ~(b4_ff3[15] ^ a4_ff3[15]);
    _0024_ = _0022_ & ~(_0023_);
    _0025_ = ~(b4_ff3[12] ^ a4_ff3[12]);
    _0026_ = ~(b4_ff3[11] ^ a4_ff3[11]);
    _0027_ = ~(_0026_ | _0025_);
    _0028_ = ~(b4_ff3[10] ^ a4_ff3[10]);
    _0029_ = ~(b4_ff3[9] ^ a4_ff3[9]);
    _0030_ = _0029_ | _0028_;
    _0031_ = _0030_ | ~(_0027_);
    _0032_ = ~(b4_ff3[8] & a4_ff3[8]);
    _0033_ = b4_ff3[8] ^ a4_ff3[8];
    _0034_ = ~(b4_ff3[7] | a4_ff3[7]);
    _0035_ = ~(b4_ff3[7] & a4_ff3[7]);
    _0036_ = b4_ff3[6] | a4_ff3[6];
    _0037_ = ~(b4_ff3[6] & a4_ff3[6]);
    _0038_ = b4_ff3[5] & a4_ff3[5];
    _0039_ = _0037_ & ~(_0038_);
    _0040_ = _0036_ & ~(_0039_);
    _0041_ = b4_ff3[4] | a4_ff3[4];
    _0042_ = ~(b4_ff3[4] & a4_ff3[4]);
    _0043_ = b4_ff3[3] & a4_ff3[3];
    _0044_ = _0042_ & ~(_0043_);
    _0045_ = _0041_ & ~(_0044_);
    _0046_ = b4_ff3[4] ^ a4_ff3[4];
    _0047_ = ~(b4_ff3[3] ^ a4_ff3[3]);
    _0048_ = _0046_ & ~(_0047_);
    _0049_ = ~(b4_ff3[2] ^ a4_ff3[2]);
    _0050_ = ~(b4_ff3[1] ^ a4_ff3[1]);
    _0051_ = _0050_ | _0049_;
    _0052_ = ~(b4_ff3[0] & a4_ff3[0]);
    _0053_ = ~(b4_ff3[0] ^ a4_ff3[0]);
    _0054_ = c3 & ~(_0053_);
    _0055_ = _0052_ & ~(_0054_);
    _0056_ = _0055_ | _0051_;
    _0057_ = b4_ff3[2] | a4_ff3[2];
    _0058_ = ~(b4_ff3[2] & a4_ff3[2]);
    _0059_ = b4_ff3[1] & a4_ff3[1];
    _0060_ = _0058_ & ~(_0059_);
    _0061_ = _0057_ & ~(_0060_);
    _0062_ = _0056_ & ~(_0061_);
    _0063_ = _0048_ & ~(_0062_);
    _0064_ = _0063_ | _0045_;
    _0065_ = ~(b4_ff3[6] ^ a4_ff3[6]);
    _0066_ = ~(b4_ff3[5] ^ a4_ff3[5]);
    _0067_ = _0066_ | _0065_;
    _0068_ = _0064_ & ~(_0067_);
    _0069_ = _0068_ | _0040_;
    _0070_ = _0035_ & ~(_0069_);
    _0071_ = _0070_ | _0034_;
    _0072_ = _0033_ & ~(_0071_);
    _0073_ = _0032_ & ~(_0072_);
    _0074_ = _0073_ | _0031_;
    _0075_ = ~(b4_ff3[9] & a4_ff3[9]);
    _0076_ = _0075_ | _0028_;
    _0077_ = _0027_ & ~(_0076_);
    _0078_ = b4_ff3[10] & a4_ff3[10];
    _0079_ = _0078_ & _0027_;
    _0080_ = b4_ff3[12] | a4_ff3[12];
    _0081_ = ~(b4_ff3[12] & a4_ff3[12]);
    _0082_ = b4_ff3[11] & a4_ff3[11];
    _0083_ = _0081_ & ~(_0082_);
    _0084_ = _0080_ & ~(_0083_);
    _0085_ = _0084_ | _0079_;
    _0086_ = _0085_ | _0077_;
    _0087_ = _0074_ & ~(_0086_);
    _0088_ = _0024_ & ~(_0087_);
    _0089_ = _0019_ & ~(_0088_);
    _0003_ = _0008_ & ~(_0089_);
    _0090_ = ~(_0053_ ^ c3);
    _0091_ = _0055_ ^ _0050_;
    _0093_ = b4_ff3[1] | a4_ff3[1];
    _0094_ = _0093_ & ~(_0055_);
    _0095_ = ~(_0094_ | _0059_);
    _0096_ = _0095_ | _0049_;
    _0097_ = _0095_ & _0049_;
    _0098_ = _0097_ | _0016_;
    _0099_ = _0096_ & ~(_0098_);
    _0100_ = _0062_ ^ _0047_;
    _0102_ = b4_ff3[3] | a4_ff3[3];
    _0103_ = _0102_ & ~(_0062_);
    _0104_ = ~(_0103_ | _0043_);
    _0105_ = _0046_ & ~(_0104_);
    _0106_ = _0104_ & ~(_0046_);
    _0107_ = stage3 & ~(_0106_);
    _0108_ = _0107_ & ~(_0105_);
    _0109_ = ~(_0066_ ^ _0064_);
    _0111_ = ~(b4_ff3[5] | a4_ff3[5]);
    _0112_ = ~(_0064_ | _0038_);
    _0113_ = ~(_0112_ | _0111_);
    _0114_ = _0065_ & ~(_0113_);
    _0115_ = _0113_ & ~(_0065_);
    _0116_ = stage3 & ~(_0115_);
    _0117_ = _0116_ & ~(_0114_);
    _0119_ = ~(b4_ff3[7] ^ a4_ff3[7]);
    _0120_ = _0119_ | _0069_;
    _0121_ = _0119_ & _0069_;
    _0122_ = _0121_ | _0016_;
    _0123_ = _0120_ & ~(_0122_);
    _0124_ = ~(_0071_ ^ _0033_);
    _0126_ = _0029_ | ~(_0073_);
    _0127_ = _0029_ & ~(_0073_);
    _0128_ = _0127_ | _0016_;
    _0129_ = _0126_ & ~(_0128_);
    _0130_ = ~(b4_ff3[9] | a4_ff3[9]);
    _0131_ = ~(_0130_ | _0073_);
    _0132_ = _0075_ & ~(_0131_);
    _0133_ = _0132_ ^ _0028_;
    _0134_ = _0030_ | ~(_0072_);
    _0135_ = b4_ff3[10] | a4_ff3[10];
    _0136_ = _0075_ & ~(_0078_);
    _0137_ = _0135_ & ~(_0136_);
    _0138_ = _0130_ | _0032_;
    _0139_ = _0135_ & ~(_0138_);
    _0140_ = _0139_ | _0137_;
    _0141_ = _0134_ & ~(_0140_);
    _0142_ = _0141_ ^ _0026_;
    _0143_ = ~(b4_ff3[11] | a4_ff3[11]);
    _0144_ = ~(_0137_ | _0082_);
    _0145_ = _0144_ | _0143_;
    _0146_ = ~(_0030_ | _0026_);
    _0147_ = _0146_ & ~(_0073_);
    _0148_ = _0145_ & ~(_0147_);
    _0149_ = _0148_ ^ _0025_;
    _0151_ = _0087_ | _0020_;
    _0152_ = _0087_ & _0020_;
    _0153_ = _0152_ | _0016_;
    _0154_ = _0151_ & ~(_0153_);
    _0156_ = ~(b4_ff3[13] | a4_ff3[13]);
    _0157_ = _0087_ & _0011_;
    _0158_ = ~(_0157_ | _0156_);
    _0159_ = _0021_ | ~(_0158_);
    _0160_ = _0021_ & ~(_0158_);
    _0161_ = _0160_ | _0016_;
    _0162_ = _0159_ & ~(_0161_);
    _0163_ = _0022_ & ~(_0087_);
    _0164_ = _0014_ & ~(_0163_);
    _0165_ = _0164_ ^ _0023_;
    _0166_ = stage2 | c3;
    _0167_ = ~(b3_ff2[15] | a3_ff2[15]);
    _0168_ = ~(b3_ff2[14] | a3_ff2[14]);
    _0169_ = ~(b3_ff2[13] & a3_ff2[13]);
    _0170_ = b3_ff2[14] & a3_ff2[14];
    _0171_ = _0169_ & ~(_0170_);
    _0172_ = _0171_ | _0168_;
    _0173_ = _0172_ | _0167_;
    _0174_ = ~stage2;
    _0175_ = b3_ff2[15] & a3_ff2[15];
    _0176_ = _0175_ | _0174_;
    _0177_ = _0173_ & ~(_0176_);
    _0178_ = ~(b3_ff2[13] ^ a3_ff2[13]);
    _0179_ = ~(b3_ff2[14] ^ a3_ff2[14]);
    _0180_ = ~(_0179_ | _0178_);
    _0181_ = ~(b3_ff2[15] ^ a3_ff2[15]);
    _0182_ = _0180_ & ~(_0181_);
    _0183_ = ~(b3_ff2[12] ^ a3_ff2[12]);
    _0184_ = ~(b3_ff2[11] ^ a3_ff2[11]);
    _0185_ = ~(_0184_ | _0183_);
    _0186_ = ~(b3_ff2[10] ^ a3_ff2[10]);
    _0187_ = ~(b3_ff2[9] ^ a3_ff2[9]);
    _0188_ = _0187_ | _0186_;
    _0189_ = _0188_ | ~(_0185_);
    _0190_ = ~(b3_ff2[8] & a3_ff2[8]);
    _0191_ = b3_ff2[8] ^ a3_ff2[8];
    _0192_ = ~(b3_ff2[7] | a3_ff2[7]);
    _0193_ = ~(b3_ff2[7] & a3_ff2[7]);
    _0194_ = b3_ff2[6] | a3_ff2[6];
    _0195_ = ~(b3_ff2[6] & a3_ff2[6]);
    _0196_ = b3_ff2[5] & a3_ff2[5];
    _0197_ = _0195_ & ~(_0196_);
    _0198_ = _0194_ & ~(_0197_);
    _0199_ = b3_ff2[4] | a3_ff2[4];
    _0200_ = ~(b3_ff2[4] & a3_ff2[4]);
    _0201_ = b3_ff2[3] & a3_ff2[3];
    _0202_ = _0200_ & ~(_0201_);
    _0203_ = _0199_ & ~(_0202_);
    _0204_ = b3_ff2[4] ^ a3_ff2[4];
    _0205_ = ~(b3_ff2[3] ^ a3_ff2[3]);
    _0206_ = _0204_ & ~(_0205_);
    _0207_ = ~(b3_ff2[2] ^ a3_ff2[2]);
    _0208_ = ~(b3_ff2[1] ^ a3_ff2[1]);
    _0209_ = _0208_ | _0207_;
    _0210_ = ~(b3_ff2[0] & a3_ff2[0]);
    _0211_ = ~(b3_ff2[0] ^ a3_ff2[0]);
    _0212_ = c2 & ~(_0211_);
    _0213_ = _0210_ & ~(_0212_);
    _0214_ = _0213_ | _0209_;
    _0215_ = b3_ff2[2] | a3_ff2[2];
    _0216_ = ~(b3_ff2[2] & a3_ff2[2]);
    _0217_ = b3_ff2[1] & a3_ff2[1];
    _0218_ = _0216_ & ~(_0217_);
    _0219_ = _0215_ & ~(_0218_);
    _0220_ = _0214_ & ~(_0219_);
    _0221_ = _0206_ & ~(_0220_);
    _0222_ = _0221_ | _0203_;
    _0223_ = ~(b3_ff2[6] ^ a3_ff2[6]);
    _0224_ = ~(b3_ff2[5] ^ a3_ff2[5]);
    _0225_ = _0224_ | _0223_;
    _0226_ = _0222_ & ~(_0225_);
    _0227_ = _0226_ | _0198_;
    _0228_ = _0193_ & ~(_0227_);
    _0229_ = _0228_ | _0192_;
    _0230_ = _0191_ & ~(_0229_);
    _0231_ = _0190_ & ~(_0230_);
    _0232_ = _0231_ | _0189_;
    _0233_ = b3_ff2[12] | a3_ff2[12];
    _0234_ = ~(b3_ff2[12] & a3_ff2[12]);
    _0235_ = b3_ff2[11] & a3_ff2[11];
    _0236_ = _0234_ & ~(_0235_);
    _0237_ = _0233_ & ~(_0236_);
    _0238_ = b3_ff2[10] & a3_ff2[10];
    _0239_ = ~(b3_ff2[9] & a3_ff2[9]);
    _0240_ = ~(_0239_ | _0186_);
    _0241_ = _0240_ | _0238_;
    _0242_ = _0241_ & _0185_;
    _0243_ = _0242_ | _0237_;
    _0244_ = _0232_ & ~(_0243_);
    _0245_ = _0182_ & ~(_0244_);
    _0246_ = _0177_ & ~(_0245_);
    _0002_ = _0166_ & ~(_0246_);
    _0247_ = ~(_0211_ ^ c2);
    _0006_[0] = _0174_ ? s3[0] : _0247_;
    _0248_ = _0213_ ^ _0208_;
    _0006_[1] = _0174_ ? s3[1] : _0248_;
    _0249_ = s3[2] & ~(stage2);
    _0250_ = b3_ff2[1] | a3_ff2[1];
    _0251_ = _0250_ & ~(_0213_);
    _0252_ = ~(_0251_ | _0217_);
    _0253_ = _0252_ | _0207_;
    _0254_ = _0252_ & _0207_;
    _0255_ = _0254_ | _0174_;
    _0256_ = _0253_ & ~(_0255_);
    _0006_[2] = _0256_ | _0249_;
    _0257_ = _0220_ ^ _0205_;
    _0006_[3] = _0174_ ? s3[3] : _0257_;
    _0258_ = s3[4] & ~(stage2);
    _0259_ = b3_ff2[3] | a3_ff2[3];
    _0260_ = _0259_ & ~(_0220_);
    _0261_ = ~(_0260_ | _0201_);
    _0262_ = _0204_ & ~(_0261_);
    _0263_ = _0261_ & ~(_0204_);
    _0264_ = stage2 & ~(_0263_);
    _0265_ = _0264_ & ~(_0262_);
    _0006_[4] = _0265_ | _0258_;
    _0266_ = ~(_0224_ ^ _0222_);
    _0006_[5] = _0174_ ? s3[5] : _0266_;
    _0267_ = s3[6] & ~(stage2);
    _0268_ = ~(b3_ff2[5] | a3_ff2[5]);
    _0269_ = ~(_0222_ | _0196_);
    _0270_ = ~(_0269_ | _0268_);
    _0271_ = _0223_ & ~(_0270_);
    _0272_ = _0270_ & ~(_0223_);
    _0273_ = stage2 & ~(_0272_);
    _0274_ = _0273_ & ~(_0271_);
    _0006_[6] = _0274_ | _0267_;
    _0275_ = s3[7] | stage2;
    _0276_ = ~(b3_ff2[7] ^ a3_ff2[7]);
    _0277_ = _0276_ | _0227_;
    _0278_ = _0276_ & _0227_;
    _0279_ = _0278_ | _0174_;
    _0280_ = _0277_ & ~(_0279_);
    _0006_[7] = _0275_ & ~(_0280_);
    _0281_ = ~(_0229_ ^ _0191_);
    _0006_[8] = _0174_ ? s3[8] : _0281_;
    _0282_ = s3[9] & ~(stage2);
    _0283_ = _0231_ | _0187_;
    _0284_ = _0231_ & _0187_;
    _0285_ = _0284_ | _0174_;
    _0286_ = _0283_ & ~(_0285_);
    _0006_[9] = _0286_ | _0282_;
    _0287_ = ~(b3_ff2[9] | a3_ff2[9]);
    _0288_ = ~(_0287_ | _0231_);
    _0289_ = _0239_ & ~(_0288_);
    _0290_ = _0289_ ^ _0186_;
    _0006_[10] = _0174_ ? s3[10] : _0290_;
    _0291_ = _0188_ | ~(_0230_);
    _0292_ = b3_ff2[10] | a3_ff2[10];
    _0293_ = _0287_ | _0190_;
    _0294_ = _0292_ & ~(_0293_);
    _0295_ = _0294_ | _0241_;
    _0296_ = _0291_ & ~(_0295_);
    _0297_ = _0296_ ^ _0184_;
    _0006_[11] = _0174_ ? s3[11] : _0297_;
    _0298_ = ~(b3_ff2[11] | a3_ff2[11]);
    _0299_ = ~(_0241_ | _0235_);
    _0300_ = _0299_ | _0298_;
    _0301_ = ~(_0188_ | _0184_);
    _0302_ = _0301_ & ~(_0231_);
    _0303_ = _0300_ & ~(_0302_);
    _0304_ = _0303_ ^ _0183_;
    _0006_[12] = _0174_ ? s3[12] : _0304_;
    _0305_ = s3[13] | stage2;
    _0306_ = _0178_ | ~(_0244_);
    _0307_ = _0178_ & ~(_0244_);
    _0308_ = _0307_ | _0174_;
    _0309_ = _0306_ & ~(_0308_);
    _0006_[13] = _0305_ & ~(_0309_);
    _0310_ = s3[14] & ~(stage2);
    _0311_ = ~(b3_ff2[13] | a3_ff2[13]);
    _0312_ = _0244_ & _0169_;
    _0313_ = ~(_0312_ | _0311_);
    _0314_ = _0179_ | ~(_0313_);
    _0315_ = _0179_ & ~(_0313_);
    _0316_ = _0315_ | _0174_;
    _0317_ = _0314_ & ~(_0316_);
    _0006_[14] = _0317_ | _0310_;
    _0318_ = _0180_ & ~(_0244_);
    _0319_ = _0172_ & ~(_0318_);
    _0320_ = _0319_ ^ _0181_;
    _0006_[15] = _0174_ ? s3[15] : _0320_;
    _0321_ = stage1 | c2;
    _0322_ = ~(b2_ff1[15] ^ a2_ff1[15]);
    _0323_ = ~(b2_ff1[13] ^ a2_ff1[13]);
    _0324_ = ~(b2_ff1[14] ^ a2_ff1[14]);
    _0325_ = _0324_ | _0323_;
    _0326_ = ~(b2_ff1[12] ^ a2_ff1[12]);
    _0327_ = ~(b2_ff1[11] ^ a2_ff1[11]);
    _0328_ = ~(_0327_ | _0326_);
    _0329_ = ~(b2_ff1[10] ^ a2_ff1[10]);
    _0330_ = ~(b2_ff1[9] ^ a2_ff1[9]);
    _0331_ = _0330_ | _0329_;
    _0332_ = _0331_ | ~(_0328_);
    _0333_ = ~(b2_ff1[8] & a2_ff1[8]);
    _0334_ = b2_ff1[8] ^ a2_ff1[8];
    _0335_ = ~(b2_ff1[7] | a2_ff1[7]);
    _0336_ = ~(b2_ff1[7] & a2_ff1[7]);
    _0337_ = b2_ff1[6] | a2_ff1[6];
    _0338_ = ~(b2_ff1[6] & a2_ff1[6]);
    _0339_ = b2_ff1[5] & a2_ff1[5];
    _0340_ = _0338_ & ~(_0339_);
    _0341_ = _0337_ & ~(_0340_);
    _0342_ = b2_ff1[4] | a2_ff1[4];
    _0343_ = ~(b2_ff1[4] & a2_ff1[4]);
    _0344_ = b2_ff1[3] & a2_ff1[3];
    _0345_ = _0343_ & ~(_0344_);
    _0346_ = _0342_ & ~(_0345_);
    _0347_ = b2_ff1[4] ^ a2_ff1[4];
    _0348_ = ~(b2_ff1[3] ^ a2_ff1[3]);
    _0349_ = _0347_ & ~(_0348_);
    _0350_ = ~(b2_ff1[2] ^ a2_ff1[2]);
    _0351_ = ~(b2_ff1[1] ^ a2_ff1[1]);
    _0352_ = _0351_ | _0350_;
    _0353_ = ~(b2_ff1[0] & a2_ff1[0]);
    _0354_ = ~(b2_ff1[0] ^ a2_ff1[0]);
    _0355_ = c1 & ~(_0354_);
    _0356_ = _0353_ & ~(_0355_);
    _0357_ = _0356_ | _0352_;
    _0358_ = b2_ff1[2] | a2_ff1[2];
    _0359_ = ~(b2_ff1[2] & a2_ff1[2]);
    _0360_ = b2_ff1[1] & a2_ff1[1];
    _0361_ = _0359_ & ~(_0360_);
    _0362_ = _0358_ & ~(_0361_);
    _0363_ = _0357_ & ~(_0362_);
    _0364_ = _0349_ & ~(_0363_);
    _0365_ = _0364_ | _0346_;
    _0366_ = ~(b2_ff1[6] ^ a2_ff1[6]);
    _0367_ = ~(b2_ff1[5] ^ a2_ff1[5]);
    _0368_ = _0367_ | _0366_;
    _0369_ = _0365_ & ~(_0368_);
    _0370_ = _0369_ | _0341_;
    _0371_ = _0336_ & ~(_0370_);
    _0372_ = _0371_ | _0335_;
    _0373_ = _0334_ & ~(_0372_);
    _0374_ = _0333_ & ~(_0373_);
    _0375_ = _0374_ | _0332_;
    _0376_ = b2_ff1[12] | a2_ff1[12];
    _0377_ = ~(b2_ff1[12] & a2_ff1[12]);
    _0378_ = b2_ff1[11] & a2_ff1[11];
    _0379_ = _0377_ & ~(_0378_);
    _0380_ = _0376_ & ~(_0379_);
    _0381_ = b2_ff1[10] & a2_ff1[10];
    _0382_ = ~(b2_ff1[9] & a2_ff1[9]);
    _0383_ = ~(_0382_ | _0329_);
    _0384_ = _0383_ | _0381_;
    _0385_ = _0384_ & _0328_;
    _0386_ = _0385_ | _0380_;
    _0387_ = _0375_ & ~(_0386_);
    _0388_ = _0387_ | _0325_;
    _0389_ = _0388_ | _0322_;
    _0390_ = ~(b2_ff1[15] | a2_ff1[15]);
    _0391_ = ~(b2_ff1[14] | a2_ff1[14]);
    _0392_ = b2_ff1[13] & a2_ff1[13];
    _0393_ = ~(b2_ff1[14] & a2_ff1[14]);
    _0394_ = _0393_ & ~(_0392_);
    _0395_ = ~(_0394_ | _0391_);
    _0396_ = _0395_ & ~(_0390_);
    _0397_ = ~stage1;
    _0398_ = b2_ff1[15] & a2_ff1[15];
    _0399_ = _0398_ | _0397_;
    _0400_ = _0399_ | _0396_;
    _0401_ = _0389_ & ~(_0400_);
    _0001_ = _0321_ & ~(_0401_);
    _0402_ = ~(_0354_ ^ c1);
    _0005_[0] = _0397_ ? s2[0] : _0402_;
    _0403_ = _0356_ ^ _0351_;
    _0005_[1] = _0397_ ? s2[1] : _0403_;
    _0404_ = s2[2] & ~(stage1);
    _0405_ = b2_ff1[1] | a2_ff1[1];
    _0406_ = _0405_ & ~(_0356_);
    _0407_ = ~(_0406_ | _0360_);
    _0408_ = _0407_ | _0350_;
    _0409_ = _0407_ & _0350_;
    _0410_ = _0409_ | _0397_;
    _0411_ = _0408_ & ~(_0410_);
    _0005_[2] = _0411_ | _0404_;
    _0412_ = _0363_ ^ _0348_;
    _0005_[3] = _0397_ ? s2[3] : _0412_;
    _0413_ = s2[4] & ~(stage1);
    _0414_ = b2_ff1[3] | a2_ff1[3];
    _0415_ = _0414_ & ~(_0363_);
    _0416_ = ~(_0415_ | _0344_);
    _0417_ = _0347_ & ~(_0416_);
    _0418_ = _0416_ & ~(_0347_);
    _0419_ = stage1 & ~(_0418_);
    _0420_ = _0419_ & ~(_0417_);
    _0005_[4] = _0420_ | _0413_;
    _0421_ = ~(_0367_ ^ _0365_);
    _0005_[5] = _0397_ ? s2[5] : _0421_;
    _0422_ = s2[6] & ~(stage1);
    _0423_ = ~(b2_ff1[5] | a2_ff1[5]);
    _0424_ = ~(_0365_ | _0339_);
    _0425_ = ~(_0424_ | _0423_);
    _0426_ = _0366_ | ~(_0425_);
    _0427_ = _0366_ & ~(_0425_);
    _0428_ = _0427_ | _0397_;
    _0429_ = _0426_ & ~(_0428_);
    _0005_[6] = _0429_ | _0422_;
    _0430_ = s2[7] | stage1;
    _0431_ = ~(b2_ff1[7] ^ a2_ff1[7]);
    _0432_ = _0431_ | _0370_;
    _0433_ = _0431_ & _0370_;
    _0434_ = _0433_ | _0397_;
    _0435_ = _0432_ & ~(_0434_);
    _0005_[7] = _0430_ & ~(_0435_);
    _0436_ = ~(_0372_ ^ _0334_);
    _0005_[8] = _0397_ ? s2[8] : _0436_;
    _0437_ = s2[9] & ~(stage1);
    _0438_ = _0374_ | _0330_;
    _0439_ = _0374_ & _0330_;
    _0440_ = _0439_ | _0397_;
    _0441_ = _0438_ & ~(_0440_);
    _0005_[9] = _0441_ | _0437_;
    _0442_ = ~(b2_ff1[9] | a2_ff1[9]);
    _0443_ = ~(_0442_ | _0374_);
    _0444_ = _0382_ & ~(_0443_);
    _0445_ = _0444_ ^ _0329_;
    _0005_[10] = _0397_ ? s2[10] : _0445_;
    _0446_ = _0331_ | ~(_0373_);
    _0447_ = b2_ff1[10] | a2_ff1[10];
    _0448_ = _0442_ | _0333_;
    _0449_ = _0447_ & ~(_0448_);
    _0450_ = _0449_ | _0384_;
    _0451_ = _0446_ & ~(_0450_);
    _0452_ = _0451_ ^ _0327_;
    _0005_[11] = _0397_ ? s2[11] : _0452_;
    _0453_ = ~(b2_ff1[11] | a2_ff1[11]);
    _0454_ = ~(_0384_ | _0378_);
    _0455_ = _0454_ | _0453_;
    _0456_ = ~(_0331_ | _0327_);
    _0457_ = _0456_ & ~(_0374_);
    _0458_ = _0455_ & ~(_0457_);
    _0459_ = _0458_ ^ _0326_;
    _0005_[12] = _0397_ ? s2[12] : _0459_;
    _0460_ = s2[13] | stage1;
    _0461_ = _0323_ | ~(_0387_);
    _0462_ = _0323_ & ~(_0387_);
    _0463_ = _0462_ | _0397_;
    _0464_ = _0461_ & ~(_0463_);
    _0005_[13] = _0460_ & ~(_0464_);
    _0465_ = s2[14] & ~(stage1);
    _0466_ = ~(b2_ff1[13] | a2_ff1[13]);
    _0467_ = _0387_ & ~(_0392_);
    _0468_ = ~(_0467_ | _0466_);
    _0469_ = _0324_ | ~(_0468_);
    _0470_ = _0324_ & ~(_0468_);
    _0471_ = _0470_ | _0397_;
    _0472_ = _0469_ & ~(_0471_);
    _0005_[14] = _0472_ | _0465_;
    _0473_ = _0388_ & ~(_0395_);
    _0474_ = _0473_ ^ _0322_;
    _0005_[15] = _0397_ ? s2[15] : _0474_;
    _0475_ = rtlopt_78ddd3f77dac_port_i_en | c1;
    _0476_ = ~(rtlopt_78ddd3f77dac_port_addb[3] | rtlopt_78ddd3f77dac_port_adda[3]);
    _0477_ = ~(rtlopt_78ddd3f77dac_port_addb[3] & rtlopt_78ddd3f77dac_port_adda[3]);
    _0478_ = rtlopt_78ddd3f77dac_port_addb[2] | rtlopt_78ddd3f77dac_port_adda[2];
    _0479_ = rtlopt_78ddd3f77dac_port_addb[1] | rtlopt_78ddd3f77dac_port_adda[1];
    _0480_ = ~(rtlopt_78ddd3f77dac_port_addb[1] & rtlopt_78ddd3f77dac_port_adda[1]);
    _0481_ = rtlopt_78ddd3f77dac_port_addb[0] & rtlopt_78ddd3f77dac_port_adda[0];
    _0482_ = _0480_ & ~(_0481_);
    _0483_ = _0479_ & ~(_0482_);
    _0484_ = rtlopt_78ddd3f77dac_port_addb[2] & rtlopt_78ddd3f77dac_port_adda[2];
    _0485_ = ~(_0484_ | _0483_);
    _0486_ = _0478_ & ~(_0485_);
    _0487_ = _0477_ & ~(_0486_);
    _0488_ = _0487_ | _0476_;
    _0489_ = ~(rtlopt_78ddd3f77dac_port_addb[4] ^ rtlopt_78ddd3f77dac_port_adda[4]);
    _0490_ = _0489_ | _0488_;
    _0491_ = ~(rtlopt_78ddd3f77dac_port_addb[5] ^ rtlopt_78ddd3f77dac_port_adda[5]);
    _0492_ = ~(rtlopt_78ddd3f77dac_port_addb[6] ^ rtlopt_78ddd3f77dac_port_adda[6]);
    _0493_ = _0492_ | _0491_;
    _0494_ = ~(rtlopt_78ddd3f77dac_port_addb[7] ^ rtlopt_78ddd3f77dac_port_adda[7]);
    _0495_ = _0494_ | _0493_;
    _0496_ = ~(_0495_ | _0490_);
    _0497_ = rtlopt_78ddd3f77dac_port_addb[7] | rtlopt_78ddd3f77dac_port_adda[7];
    _0498_ = ~(rtlopt_78ddd3f77dac_port_addb[4] & rtlopt_78ddd3f77dac_port_adda[4]);
    _0499_ = rtlopt_78ddd3f77dac_port_addb[5] & rtlopt_78ddd3f77dac_port_adda[5];
    _0500_ = _0498_ & ~(_0499_);
    _0501_ = ~(rtlopt_78ddd3f77dac_port_addb[5] | rtlopt_78ddd3f77dac_port_adda[5]);
    _0502_ = ~(rtlopt_78ddd3f77dac_port_addb[6] | rtlopt_78ddd3f77dac_port_adda[6]);
    _0503_ = _0502_ | _0501_;
    _0504_ = _0503_ | _0500_;
    _0505_ = rtlopt_78ddd3f77dac_port_addb[6] & rtlopt_78ddd3f77dac_port_adda[6];
    _0506_ = rtlopt_78ddd3f77dac_port_addb[7] & rtlopt_78ddd3f77dac_port_adda[7];
    _0507_ = _0506_ | _0505_;
    _0508_ = _0504_ & ~(_0507_);
    _0509_ = _0497_ & ~(_0508_);
    _0510_ = _0509_ | _0496_;
    _0511_ = ~(rtlopt_78ddd3f77dac_port_addb[9] ^ rtlopt_78ddd3f77dac_port_adda[9]);
    _0512_ = ~(rtlopt_78ddd3f77dac_port_addb[8] ^ rtlopt_78ddd3f77dac_port_adda[8]);
    _0513_ = _0512_ | _0511_;
    _0514_ = _0513_ | ~(_0510_);
    _0515_ = ~(rtlopt_78ddd3f77dac_port_addb[11] ^ rtlopt_78ddd3f77dac_port_adda[11]);
    _0516_ = ~(rtlopt_78ddd3f77dac_port_addb[10] ^ rtlopt_78ddd3f77dac_port_adda[10]);
    _0517_ = _0516_ | _0515_;
    _0518_ = ~(_0517_ | _0514_);
    _0519_ = rtlopt_78ddd3f77dac_port_addb[11] | rtlopt_78ddd3f77dac_port_adda[11];
    _0520_ = ~(rtlopt_78ddd3f77dac_port_addb[11] & rtlopt_78ddd3f77dac_port_adda[11]);
    _0521_ = rtlopt_78ddd3f77dac_port_addb[10] | rtlopt_78ddd3f77dac_port_adda[10];
    _0522_ = rtlopt_78ddd3f77dac_port_addb[10] & rtlopt_78ddd3f77dac_port_adda[10];
    _0523_ = rtlopt_78ddd3f77dac_port_addb[9] | rtlopt_78ddd3f77dac_port_adda[9];
    _0524_ = ~(rtlopt_78ddd3f77dac_port_addb[9] & rtlopt_78ddd3f77dac_port_adda[9]);
    _0525_ = rtlopt_78ddd3f77dac_port_addb[8] & rtlopt_78ddd3f77dac_port_adda[8];
    _0526_ = _0524_ & ~(_0525_);
    _0527_ = _0523_ & ~(_0526_);
    _0528_ = ~(_0527_ | _0522_);
    _0529_ = _0521_ & ~(_0528_);
    _0530_ = _0520_ & ~(_0529_);
    _0531_ = _0519_ & ~(_0530_);
    _0532_ = _0531_ | _0518_;
    _0533_ = ~(rtlopt_78ddd3f77dac_port_addb[15] ^ rtlopt_78ddd3f77dac_port_adda[15]);
    _0534_ = ~(rtlopt_78ddd3f77dac_port_addb[14] ^ rtlopt_78ddd3f77dac_port_adda[14]);
    _0535_ = _0534_ | _0533_;
    _0536_ = ~(rtlopt_78ddd3f77dac_port_addb[12] ^ rtlopt_78ddd3f77dac_port_adda[12]);
    _0537_ = ~(rtlopt_78ddd3f77dac_port_addb[13] ^ rtlopt_78ddd3f77dac_port_adda[13]);
    _0538_ = _0537_ | _0536_;
    _0539_ = _0538_ | _0535_;
    _0540_ = _0539_ | ~(_0532_);
    _0541_ = ~rtlopt_78ddd3f77dac_port_i_en;
    _0542_ = rtlopt_78ddd3f77dac_port_addb[15] | rtlopt_78ddd3f77dac_port_adda[15];
    _0543_ = ~(rtlopt_78ddd3f77dac_port_addb[12] & rtlopt_78ddd3f77dac_port_adda[12]);
    _0544_ = rtlopt_78ddd3f77dac_port_addb[13] & rtlopt_78ddd3f77dac_port_adda[13];
    _0545_ = _0543_ & ~(_0544_);
    _0546_ = ~(rtlopt_78ddd3f77dac_port_addb[13] | rtlopt_78ddd3f77dac_port_adda[13]);
    _0547_ = ~(rtlopt_78ddd3f77dac_port_addb[14] | rtlopt_78ddd3f77dac_port_adda[14]);
    _0548_ = _0547_ | _0546_;
    _0549_ = _0548_ | _0545_;
    _0550_ = rtlopt_78ddd3f77dac_port_addb[15] & rtlopt_78ddd3f77dac_port_adda[15];
    _0551_ = rtlopt_78ddd3f77dac_port_addb[14] & rtlopt_78ddd3f77dac_port_adda[14];
    _0552_ = _0551_ | _0550_;
    _0553_ = _0549_ & ~(_0552_);
    _0554_ = _0542_ & ~(_0553_);
    _0555_ = _0554_ | _0541_;
    _0556_ = _0540_ & ~(_0555_);
    _0000_ = _0475_ & ~(_0556_);
    _0557_ = ~(rtlopt_78ddd3f77dac_port_addb[0] | rtlopt_78ddd3f77dac_port_adda[0]);
    _0558_ = rtlopt_78ddd3f77dac_port_i_en & ~(_0557_);
    _0559_ = _0558_ & ~(_0481_);
    _0560_ = s1[0] & ~(rtlopt_78ddd3f77dac_port_i_en);
    _0004_[0] = _0560_ | _0559_;
    _0561_ = rtlopt_78ddd3f77dac_port_addb[1] ^ rtlopt_78ddd3f77dac_port_adda[1];
    _0562_ = _0561_ ^ _0481_;
    _0004_[1] = _0541_ ? s1[1] : _0562_;
    _0563_ = s1[2] | rtlopt_78ddd3f77dac_port_i_en;
    _0564_ = ~(rtlopt_78ddd3f77dac_port_addb[2] ^ rtlopt_78ddd3f77dac_port_adda[2]);
    _0565_ = _0564_ | _0483_;
    _0566_ = _0564_ & _0483_;
    _0567_ = _0566_ | _0541_;
    _0568_ = _0565_ & ~(_0567_);
    _0004_[2] = _0563_ & ~(_0568_);
    _0569_ = s1[3] | rtlopt_78ddd3f77dac_port_i_en;
    _0570_ = ~(rtlopt_78ddd3f77dac_port_addb[3] ^ rtlopt_78ddd3f77dac_port_adda[3]);
    _0571_ = _0570_ | _0486_;
    _0572_ = _0570_ & _0486_;
    _0573_ = _0572_ | _0541_;
    _0574_ = _0571_ & ~(_0573_);
    _0004_[3] = _0569_ & ~(_0574_);
    _0575_ = s1[4] & ~(rtlopt_78ddd3f77dac_port_i_en);
    _0576_ = _0489_ & _0488_;
    _0577_ = _0576_ | _0541_;
    _0578_ = _0490_ & ~(_0577_);
    _0004_[4] = _0578_ | _0575_;
    _0579_ = s1[5] | rtlopt_78ddd3f77dac_port_i_en;
    _0580_ = ~_0491_;
    _0581_ = rtlopt_78ddd3f77dac_port_addb[4] | rtlopt_78ddd3f77dac_port_adda[4];
    _0582_ = _0498_ & _0488_;
    _0583_ = _0581_ & ~(_0582_);
    _0584_ = _0580_ | ~(_0583_);
    _0585_ = _0580_ & ~(_0583_);
    _0586_ = _0585_ | _0541_;
    _0587_ = _0584_ & ~(_0586_);
    _0004_[5] = _0579_ & ~(_0587_);
    _0588_ = s1[6] | rtlopt_78ddd3f77dac_port_i_en;
    _0589_ = ~_0492_;
    _0590_ = ~(_0583_ | _0499_);
    _0591_ = ~(_0590_ | _0501_);
    _0592_ = _0589_ | ~(_0591_);
    _0593_ = _0589_ & ~(_0591_);
    _0594_ = _0593_ | _0541_;
    _0595_ = _0592_ & ~(_0594_);
    _0004_[6] = _0588_ & ~(_0595_);
    _0596_ = s1[7] | rtlopt_78ddd3f77dac_port_i_en;
    _0597_ = ~(_0591_ | _0505_);
    _0598_ = ~(_0597_ | _0502_);
    _0599_ = _0598_ | _0494_;
    _0600_ = _0598_ & _0494_;
    _0601_ = _0600_ | _0541_;
    _0602_ = _0599_ & ~(_0601_);
    _0004_[7] = _0596_ & ~(_0602_);
    _0603_ = s1[8] | rtlopt_78ddd3f77dac_port_i_en;
    _0604_ = _0512_ | _0510_;
    _0605_ = _0512_ & _0510_;
    _0606_ = _0605_ | _0541_;
    _0607_ = _0604_ & ~(_0606_);
    _0004_[8] = _0603_ & ~(_0607_);
    _0608_ = s1[9] | rtlopt_78ddd3f77dac_port_i_en;
    _0609_ = ~(rtlopt_78ddd3f77dac_port_addb[8] | rtlopt_78ddd3f77dac_port_adda[8]);
    _0610_ = ~(_0525_ | _0510_);
    _0611_ = ~(_0610_ | _0609_);
    _0612_ = _0611_ | _0511_;
    _0613_ = _0611_ & _0511_;
    _0614_ = _0613_ | _0541_;
    _0615_ = _0612_ & ~(_0614_);
    _0004_[9] = _0608_ & ~(_0615_);
    _0616_ = _0514_ & ~(_0527_);
    _0617_ = _0616_ ^ _0516_;
    _0004_[10] = _0541_ ? s1[10] : _0617_;
    _0618_ = _0528_ & _0514_;
    _0619_ = _0618_ | ~(_0521_);
    _0620_ = _0619_ ^ _0515_;
    _0004_[11] = _0541_ ? s1[11] : _0620_;
    _0621_ = s1[12] | rtlopt_78ddd3f77dac_port_i_en;
    _0622_ = _0536_ | _0532_;
    _0623_ = _0536_ & _0532_;
    _0624_ = _0623_ | _0541_;
    _0625_ = _0622_ & ~(_0624_);
    _0004_[12] = _0621_ & ~(_0625_);
    _0626_ = s1[13] | rtlopt_78ddd3f77dac_port_i_en;
    _0627_ = ~(rtlopt_78ddd3f77dac_port_addb[12] | rtlopt_78ddd3f77dac_port_adda[12]);
    _0628_ = _0532_ & ~(_0627_);
    _0629_ = _0543_ & ~(_0628_);
    _0630_ = _0537_ | ~(_0629_);
    _0631_ = _0537_ & ~(_0629_);
    _0632_ = _0631_ | _0541_;
    _0633_ = _0630_ & ~(_0632_);
    _0004_[13] = _0626_ & ~(_0633_);
    _0634_ = s1[14] | rtlopt_78ddd3f77dac_port_i_en;
    _0635_ = ~_0534_;
    _0636_ = _0545_ & ~(_0628_);
    _0637_ = _0636_ | _0546_;
    _0638_ = _0637_ | _0635_;
    _0639_ = _0637_ & _0635_;
    _0640_ = _0639_ | _0541_;
    _0641_ = _0638_ & ~(_0640_);
    _0004_[14] = _0634_ & ~(_0641_);
    _0642_ = s1[15] | rtlopt_78ddd3f77dac_port_i_en;
    _0643_ = ~(_0637_ | _0547_);
    _0644_ = _0643_ | _0551_;
    _0645_ = ~(_0644_ & _0533_);
    _0646_ = ~(_0644_ | _0533_);
    _0647_ = _0646_ | _0541_;
    _0648_ = _0645_ & ~(_0647_);
    _0004_[15] = _0642_ & ~(_0648_);
    rtlopt_78ddd3f77dac_port_result[48] = \result_reg[48] ;
    _0007_[0] = _0016_ ? rtlopt_78ddd3f77dac_port_result[48] : _0090_;
    rtlopt_78ddd3f77dac_port_result[49] = \result_reg[49] ;
    _0007_[1] = _0016_ ? rtlopt_78ddd3f77dac_port_result[49] : _0091_;
    rtlopt_78ddd3f77dac_port_result[50] = \result_reg[50] ;
    _0092_ = rtlopt_78ddd3f77dac_port_result[50] & ~(stage3);
    _0007_[2] = _0099_ | _0092_;
    rtlopt_78ddd3f77dac_port_result[51] = \result_reg[51] ;
    _0007_[3] = _0016_ ? rtlopt_78ddd3f77dac_port_result[51] : _0100_;
    rtlopt_78ddd3f77dac_port_result[52] = \result_reg[52] ;
    _0101_ = rtlopt_78ddd3f77dac_port_result[52] & ~(stage3);
    _0007_[4] = _0108_ | _0101_;
    rtlopt_78ddd3f77dac_port_result[53] = \result_reg[53] ;
    _0007_[5] = _0016_ ? rtlopt_78ddd3f77dac_port_result[53] : _0109_;
    rtlopt_78ddd3f77dac_port_result[54] = \result_reg[54] ;
    _0110_ = rtlopt_78ddd3f77dac_port_result[54] & ~(stage3);
    _0007_[6] = _0117_ | _0110_;
    rtlopt_78ddd3f77dac_port_result[55] = \result_reg[55] ;
    _0118_ = rtlopt_78ddd3f77dac_port_result[55] | stage3;
    _0007_[7] = _0118_ & ~(_0123_);
    rtlopt_78ddd3f77dac_port_result[56] = \result_reg[56] ;
    _0007_[8] = _0016_ ? rtlopt_78ddd3f77dac_port_result[56] : _0124_;
    rtlopt_78ddd3f77dac_port_result[57] = \result_reg[57] ;
    _0125_ = rtlopt_78ddd3f77dac_port_result[57] | stage3;
    _0007_[9] = _0125_ & ~(_0129_);
    rtlopt_78ddd3f77dac_port_result[58] = \result_reg[58] ;
    _0007_[10] = _0016_ ? rtlopt_78ddd3f77dac_port_result[58] : _0133_;
    rtlopt_78ddd3f77dac_port_result[59] = \result_reg[59] ;
    _0007_[11] = _0016_ ? rtlopt_78ddd3f77dac_port_result[59] : _0142_;
    rtlopt_78ddd3f77dac_port_result[60] = \result_reg[60] ;
    _0007_[12] = _0016_ ? rtlopt_78ddd3f77dac_port_result[60] : _0149_;
    rtlopt_78ddd3f77dac_port_result[61] = \result_reg[61] ;
    _0150_ = rtlopt_78ddd3f77dac_port_result[61] | stage3;
    _0007_[13] = _0150_ & ~(_0154_);
    rtlopt_78ddd3f77dac_port_result[62] = \result_reg[62] ;
    _0155_ = rtlopt_78ddd3f77dac_port_result[62] & ~(stage3);
    _0007_[14] = _0162_ | _0155_;
    rtlopt_78ddd3f77dac_port_result[63] = \result_reg[63] ;
    _0007_[15] = _0016_ ? rtlopt_78ddd3f77dac_port_result[63] : _0165_;
    rtlopt_78ddd3f77dac_port_result[0] = \result_reg[0] ;
    rtlopt_78ddd3f77dac_port_result[1] = \result_reg[1] ;
    rtlopt_78ddd3f77dac_port_result[2] = \result_reg[2] ;
    rtlopt_78ddd3f77dac_port_result[3] = \result_reg[3] ;
    rtlopt_78ddd3f77dac_port_result[4] = \result_reg[4] ;
    rtlopt_78ddd3f77dac_port_result[5] = \result_reg[5] ;
    rtlopt_78ddd3f77dac_port_result[6] = \result_reg[6] ;
    rtlopt_78ddd3f77dac_port_result[7] = \result_reg[7] ;
    rtlopt_78ddd3f77dac_port_result[8] = \result_reg[8] ;
    rtlopt_78ddd3f77dac_port_result[9] = \result_reg[9] ;
    rtlopt_78ddd3f77dac_port_result[10] = \result_reg[10] ;
    rtlopt_78ddd3f77dac_port_result[11] = \result_reg[11] ;
    rtlopt_78ddd3f77dac_port_result[12] = \result_reg[12] ;
    rtlopt_78ddd3f77dac_port_result[13] = \result_reg[13] ;
    rtlopt_78ddd3f77dac_port_result[14] = \result_reg[14] ;
    rtlopt_78ddd3f77dac_port_result[15] = \result_reg[15] ;
    rtlopt_78ddd3f77dac_port_result[16] = \result_reg[16] ;
    rtlopt_78ddd3f77dac_port_result[17] = \result_reg[17] ;
    rtlopt_78ddd3f77dac_port_result[18] = \result_reg[18] ;
    rtlopt_78ddd3f77dac_port_result[19] = \result_reg[19] ;
    rtlopt_78ddd3f77dac_port_result[20] = \result_reg[20] ;
    rtlopt_78ddd3f77dac_port_result[21] = \result_reg[21] ;
    rtlopt_78ddd3f77dac_port_result[22] = \result_reg[22] ;
    rtlopt_78ddd3f77dac_port_result[23] = \result_reg[23] ;
    rtlopt_78ddd3f77dac_port_result[24] = \result_reg[24] ;
    rtlopt_78ddd3f77dac_port_result[25] = \result_reg[25] ;
    rtlopt_78ddd3f77dac_port_result[26] = \result_reg[26] ;
    rtlopt_78ddd3f77dac_port_result[27] = \result_reg[27] ;
    rtlopt_78ddd3f77dac_port_result[28] = \result_reg[28] ;
    rtlopt_78ddd3f77dac_port_result[29] = \result_reg[29] ;
    rtlopt_78ddd3f77dac_port_result[30] = \result_reg[30] ;
    rtlopt_78ddd3f77dac_port_result[31] = \result_reg[31] ;
    rtlopt_78ddd3f77dac_port_result[32] = \result_reg[32] ;
    rtlopt_78ddd3f77dac_port_result[33] = \result_reg[33] ;
    rtlopt_78ddd3f77dac_port_result[34] = \result_reg[34] ;
    rtlopt_78ddd3f77dac_port_result[35] = \result_reg[35] ;
    rtlopt_78ddd3f77dac_port_result[36] = \result_reg[36] ;
    rtlopt_78ddd3f77dac_port_result[37] = \result_reg[37] ;
    rtlopt_78ddd3f77dac_port_result[38] = \result_reg[38] ;
    rtlopt_78ddd3f77dac_port_result[39] = \result_reg[39] ;
    rtlopt_78ddd3f77dac_port_result[40] = \result_reg[40] ;
    rtlopt_78ddd3f77dac_port_result[41] = \result_reg[41] ;
    rtlopt_78ddd3f77dac_port_result[42] = \result_reg[42] ;
    rtlopt_78ddd3f77dac_port_result[43] = \result_reg[43] ;
    rtlopt_78ddd3f77dac_port_result[44] = \result_reg[44] ;
    rtlopt_78ddd3f77dac_port_result[45] = \result_reg[45] ;
    rtlopt_78ddd3f77dac_port_result[46] = \result_reg[46] ;
    rtlopt_78ddd3f77dac_port_result[47] = \result_reg[47] ;
    rtlopt_78ddd3f77dac_port_result[64] = c4;
  end

  end else begin : rtlopt_original_config
    rtlopt_78ddd3f77dac_original #(.DATA_WIDTH(DATA_WIDTH), .STG_WIDTH(STG_WIDTH)) impl (.clk(clk), .rst_n(rst_n), .i_en(i_en), .adda(adda), .addb(addb), .result(result), .o_en(o_en));
  end
endgenerate
endmodule
