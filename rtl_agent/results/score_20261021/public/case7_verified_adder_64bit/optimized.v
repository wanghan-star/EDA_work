// Logic re-synthesized by rtl_agent (ABC syn2_dch); registers and ports unchanged.
// Default parameters use the optimized implementation; overrides retain original semantics.
module rtlopt_46d9489de218_original
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
wire [1-1:0] rtlopt_46d9489de218_port_clk;
assign rtlopt_46d9489de218_port_clk = clk;
wire [1-1:0] rtlopt_46d9489de218_port_rst_n;
assign rtlopt_46d9489de218_port_rst_n = rst_n;
wire [1-1:0] rtlopt_46d9489de218_port_i_en;
assign rtlopt_46d9489de218_port_i_en = i_en;
wire [64-1:0] rtlopt_46d9489de218_port_adda;
assign rtlopt_46d9489de218_port_adda = adda;
wire [64-1:0] rtlopt_46d9489de218_port_addb;
assign rtlopt_46d9489de218_port_addb = addb;
reg [65-1:0] rtlopt_46d9489de218_port_result;
assign result = rtlopt_46d9489de218_port_result;
reg [1-1:0] rtlopt_46d9489de218_port_o_en;
assign o_en = rtlopt_46d9489de218_port_o_en;

  reg _0000_;
  reg _0001_;
  reg _0002_;
  reg _0003_;
  reg _0004_;
  reg _0005_;
  reg _0006_;
  reg _0007_;
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
  reg [16:0] _0644_;
  reg [16:0] _0645_;
  reg [16:0] _0646_;
  reg [17:0] _0647_;
  reg [17:0] _0648_;
  reg [17:0] _0649_;
  reg [17:0] _0650_;
  reg [17:0] _0651_;
  reg [17:0] _0652_;
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
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[0] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[0] <= _0645_[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[1] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[1] <= _0646_[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[2] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[2] <= _0646_[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[3] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[3] <= _0646_[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[4] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[4] <= _0646_[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[5] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[5] <= _0646_[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[6] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[6] <= _0646_[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[7] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[7] <= _0646_[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[8] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[8] <= _0646_[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[9] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[9] <= _0646_[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[10] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[10] <= _0646_[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[11] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[11] <= _0646_[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[12] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[12] <= _0646_[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[13] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[13] <= _0646_[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[14] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[14] <= _0646_[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1[15] <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) s1[15] <= _0646_[15];
  reg \result_reg[48] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[48]  <= 1'h0;
    else if (stage3) \result_reg[48]  <= _0652_[1];
  reg \result_reg[49] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[49]  <= 1'h0;
    else if (stage3) \result_reg[49]  <= _0652_[2];
  reg \result_reg[50] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[50]  <= 1'h0;
    else if (stage3) \result_reg[50]  <= _0652_[3];
  reg \result_reg[51] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[51]  <= 1'h0;
    else if (stage3) \result_reg[51]  <= _0652_[4];
  reg \result_reg[52] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[52]  <= 1'h0;
    else if (stage3) \result_reg[52]  <= _0652_[5];
  reg \result_reg[53] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[53]  <= 1'h0;
    else if (stage3) \result_reg[53]  <= _0652_[6];
  reg \result_reg[54] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[54]  <= 1'h0;
    else if (stage3) \result_reg[54]  <= _0652_[7];
  reg \result_reg[55] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[55]  <= 1'h0;
    else if (stage3) \result_reg[55]  <= _0652_[8];
  reg \result_reg[56] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[56]  <= 1'h0;
    else if (stage3) \result_reg[56]  <= _0652_[9];
  reg \result_reg[57] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[57]  <= 1'h0;
    else if (stage3) \result_reg[57]  <= _0652_[10];
  reg \result_reg[58] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[58]  <= 1'h0;
    else if (stage3) \result_reg[58]  <= _0652_[11];
  reg \result_reg[59] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[59]  <= 1'h0;
    else if (stage3) \result_reg[59]  <= _0652_[12];
  reg \result_reg[60] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[60]  <= 1'h0;
    else if (stage3) \result_reg[60]  <= _0652_[13];
  reg \result_reg[61] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[61]  <= 1'h0;
    else if (stage3) \result_reg[61]  <= _0652_[14];
  reg \result_reg[62] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[62]  <= 1'h0;
    else if (stage3) \result_reg[62]  <= _0652_[15];
  reg \result_reg[63] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[63]  <= 1'h0;
    else if (stage3) \result_reg[63]  <= _0652_[16];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) c3 <= 1'h0;
    else if (stage2) c3 <= _0649_[16];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[0] <= 1'h0;
    else if (stage2) s3[0] <= _0650_[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[1] <= 1'h0;
    else if (stage2) s3[1] <= _0650_[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[2] <= 1'h0;
    else if (stage2) s3[2] <= _0650_[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[3] <= 1'h0;
    else if (stage2) s3[3] <= _0650_[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[4] <= 1'h0;
    else if (stage2) s3[4] <= _0650_[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[5] <= 1'h0;
    else if (stage2) s3[5] <= _0650_[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[6] <= 1'h0;
    else if (stage2) s3[6] <= _0650_[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[7] <= 1'h0;
    else if (stage2) s3[7] <= _0650_[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[8] <= 1'h0;
    else if (stage2) s3[8] <= _0650_[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[9] <= 1'h0;
    else if (stage2) s3[9] <= _0650_[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[10] <= 1'h0;
    else if (stage2) s3[10] <= _0650_[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[11] <= 1'h0;
    else if (stage2) s3[11] <= _0650_[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[12] <= 1'h0;
    else if (stage2) s3[12] <= _0650_[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[13] <= 1'h0;
    else if (stage2) s3[13] <= _0650_[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[14] <= 1'h0;
    else if (stage2) s3[14] <= _0650_[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s3[15] <= 1'h0;
    else if (stage2) s3[15] <= _0650_[16];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) c2 <= 1'h0;
    else if (stage1) c2 <= _0647_[16];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[0] <= 1'h0;
    else if (stage1) s2[0] <= _0648_[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[1] <= 1'h0;
    else if (stage1) s2[1] <= _0648_[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[2] <= 1'h0;
    else if (stage1) s2[2] <= _0648_[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[3] <= 1'h0;
    else if (stage1) s2[3] <= _0648_[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[4] <= 1'h0;
    else if (stage1) s2[4] <= _0648_[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[5] <= 1'h0;
    else if (stage1) s2[5] <= _0648_[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[6] <= 1'h0;
    else if (stage1) s2[6] <= _0648_[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[7] <= 1'h0;
    else if (stage1) s2[7] <= _0648_[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[8] <= 1'h0;
    else if (stage1) s2[8] <= _0648_[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[9] <= 1'h0;
    else if (stage1) s2[9] <= _0648_[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[10] <= 1'h0;
    else if (stage1) s2[10] <= _0648_[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[11] <= 1'h0;
    else if (stage1) s2[11] <= _0648_[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[12] <= 1'h0;
    else if (stage1) s2[12] <= _0648_[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[13] <= 1'h0;
    else if (stage1) s2[13] <= _0648_[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[14] <= 1'h0;
    else if (stage1) s2[14] <= _0648_[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2[15] <= 1'h0;
    else if (stage1) s2[15] <= _0648_[16];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) c1 <= 1'h0;
    else if (rtlopt_46d9489de218_port_i_en) c1 <= _0644_[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) c4 <= 1'h0;
    else if (stage3) c4 <= _0651_[16];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[0] <= 1'h0;
    else s1_ff1[0] <= s1[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[1] <= 1'h0;
    else s1_ff1[1] <= s1[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[2] <= 1'h0;
    else s1_ff1[2] <= s1[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[3] <= 1'h0;
    else s1_ff1[3] <= s1[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[4] <= 1'h0;
    else s1_ff1[4] <= s1[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[5] <= 1'h0;
    else s1_ff1[5] <= s1[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[6] <= 1'h0;
    else s1_ff1[6] <= s1[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[7] <= 1'h0;
    else s1_ff1[7] <= s1[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[8] <= 1'h0;
    else s1_ff1[8] <= s1[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[9] <= 1'h0;
    else s1_ff1[9] <= s1[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[10] <= 1'h0;
    else s1_ff1[10] <= s1[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[11] <= 1'h0;
    else s1_ff1[11] <= s1[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[12] <= 1'h0;
    else s1_ff1[12] <= s1[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[13] <= 1'h0;
    else s1_ff1[13] <= s1[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[14] <= 1'h0;
    else s1_ff1[14] <= s1[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff1[15] <= 1'h0;
    else s1_ff1[15] <= s1[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[0] <= 1'h0;
    else s1_ff2[0] <= s1_ff1[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[1] <= 1'h0;
    else s1_ff2[1] <= s1_ff1[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[2] <= 1'h0;
    else s1_ff2[2] <= s1_ff1[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[3] <= 1'h0;
    else s1_ff2[3] <= s1_ff1[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[4] <= 1'h0;
    else s1_ff2[4] <= s1_ff1[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[5] <= 1'h0;
    else s1_ff2[5] <= s1_ff1[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[6] <= 1'h0;
    else s1_ff2[6] <= s1_ff1[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[7] <= 1'h0;
    else s1_ff2[7] <= s1_ff1[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[8] <= 1'h0;
    else s1_ff2[8] <= s1_ff1[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[9] <= 1'h0;
    else s1_ff2[9] <= s1_ff1[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[10] <= 1'h0;
    else s1_ff2[10] <= s1_ff1[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[11] <= 1'h0;
    else s1_ff2[11] <= s1_ff1[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[12] <= 1'h0;
    else s1_ff2[12] <= s1_ff1[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[13] <= 1'h0;
    else s1_ff2[13] <= s1_ff1[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[14] <= 1'h0;
    else s1_ff2[14] <= s1_ff1[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s1_ff2[15] <= 1'h0;
    else s1_ff2[15] <= s1_ff1[15];
  reg \result_reg[0] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[0]  <= 1'h0;
    else \result_reg[0]  <= s1_ff2[0];
  reg \result_reg[1] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[1]  <= 1'h0;
    else \result_reg[1]  <= s1_ff2[1];
  reg \result_reg[2] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[2]  <= 1'h0;
    else \result_reg[2]  <= s1_ff2[2];
  reg \result_reg[3] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[3]  <= 1'h0;
    else \result_reg[3]  <= s1_ff2[3];
  reg \result_reg[4] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[4]  <= 1'h0;
    else \result_reg[4]  <= s1_ff2[4];
  reg \result_reg[5] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[5]  <= 1'h0;
    else \result_reg[5]  <= s1_ff2[5];
  reg \result_reg[6] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[6]  <= 1'h0;
    else \result_reg[6]  <= s1_ff2[6];
  reg \result_reg[7] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[7]  <= 1'h0;
    else \result_reg[7]  <= s1_ff2[7];
  reg \result_reg[8] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[8]  <= 1'h0;
    else \result_reg[8]  <= s1_ff2[8];
  reg \result_reg[9] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[9]  <= 1'h0;
    else \result_reg[9]  <= s1_ff2[9];
  reg \result_reg[10] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[10]  <= 1'h0;
    else \result_reg[10]  <= s1_ff2[10];
  reg \result_reg[11] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[11]  <= 1'h0;
    else \result_reg[11]  <= s1_ff2[11];
  reg \result_reg[12] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[12]  <= 1'h0;
    else \result_reg[12]  <= s1_ff2[12];
  reg \result_reg[13] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[13]  <= 1'h0;
    else \result_reg[13]  <= s1_ff2[13];
  reg \result_reg[14] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[14]  <= 1'h0;
    else \result_reg[14]  <= s1_ff2[14];
  reg \result_reg[15] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[15]  <= 1'h0;
    else \result_reg[15]  <= s1_ff2[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[0] <= 1'h0;
    else s2_ff1[0] <= s2[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[1] <= 1'h0;
    else s2_ff1[1] <= s2[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[2] <= 1'h0;
    else s2_ff1[2] <= s2[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[3] <= 1'h0;
    else s2_ff1[3] <= s2[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[4] <= 1'h0;
    else s2_ff1[4] <= s2[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[5] <= 1'h0;
    else s2_ff1[5] <= s2[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[6] <= 1'h0;
    else s2_ff1[6] <= s2[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[7] <= 1'h0;
    else s2_ff1[7] <= s2[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[8] <= 1'h0;
    else s2_ff1[8] <= s2[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[9] <= 1'h0;
    else s2_ff1[9] <= s2[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[10] <= 1'h0;
    else s2_ff1[10] <= s2[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[11] <= 1'h0;
    else s2_ff1[11] <= s2[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[12] <= 1'h0;
    else s2_ff1[12] <= s2[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[13] <= 1'h0;
    else s2_ff1[13] <= s2[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[14] <= 1'h0;
    else s2_ff1[14] <= s2[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) s2_ff1[15] <= 1'h0;
    else s2_ff1[15] <= s2[15];
  reg \result_reg[16] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[16]  <= 1'h0;
    else \result_reg[16]  <= s2_ff1[0];
  reg \result_reg[17] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[17]  <= 1'h0;
    else \result_reg[17]  <= s2_ff1[1];
  reg \result_reg[18] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[18]  <= 1'h0;
    else \result_reg[18]  <= s2_ff1[2];
  reg \result_reg[19] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[19]  <= 1'h0;
    else \result_reg[19]  <= s2_ff1[3];
  reg \result_reg[20] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[20]  <= 1'h0;
    else \result_reg[20]  <= s2_ff1[4];
  reg \result_reg[21] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[21]  <= 1'h0;
    else \result_reg[21]  <= s2_ff1[5];
  reg \result_reg[22] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[22]  <= 1'h0;
    else \result_reg[22]  <= s2_ff1[6];
  reg \result_reg[23] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[23]  <= 1'h0;
    else \result_reg[23]  <= s2_ff1[7];
  reg \result_reg[24] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[24]  <= 1'h0;
    else \result_reg[24]  <= s2_ff1[8];
  reg \result_reg[25] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[25]  <= 1'h0;
    else \result_reg[25]  <= s2_ff1[9];
  reg \result_reg[26] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[26]  <= 1'h0;
    else \result_reg[26]  <= s2_ff1[10];
  reg \result_reg[27] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[27]  <= 1'h0;
    else \result_reg[27]  <= s2_ff1[11];
  reg \result_reg[28] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[28]  <= 1'h0;
    else \result_reg[28]  <= s2_ff1[12];
  reg \result_reg[29] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[29]  <= 1'h0;
    else \result_reg[29]  <= s2_ff1[13];
  reg \result_reg[30] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[30]  <= 1'h0;
    else \result_reg[30]  <= s2_ff1[14];
  reg \result_reg[31] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[31]  <= 1'h0;
    else \result_reg[31]  <= s2_ff1[15];
  reg \result_reg[32] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[32]  <= 1'h0;
    else \result_reg[32]  <= s3[0];
  reg \result_reg[33] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[33]  <= 1'h0;
    else \result_reg[33]  <= s3[1];
  reg \result_reg[34] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[34]  <= 1'h0;
    else \result_reg[34]  <= s3[2];
  reg \result_reg[35] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[35]  <= 1'h0;
    else \result_reg[35]  <= s3[3];
  reg \result_reg[36] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[36]  <= 1'h0;
    else \result_reg[36]  <= s3[4];
  reg \result_reg[37] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[37]  <= 1'h0;
    else \result_reg[37]  <= s3[5];
  reg \result_reg[38] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[38]  <= 1'h0;
    else \result_reg[38]  <= s3[6];
  reg \result_reg[39] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[39]  <= 1'h0;
    else \result_reg[39]  <= s3[7];
  reg \result_reg[40] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[40]  <= 1'h0;
    else \result_reg[40]  <= s3[8];
  reg \result_reg[41] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[41]  <= 1'h0;
    else \result_reg[41]  <= s3[9];
  reg \result_reg[42] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[42]  <= 1'h0;
    else \result_reg[42]  <= s3[10];
  reg \result_reg[43] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[43]  <= 1'h0;
    else \result_reg[43]  <= s3[11];
  reg \result_reg[44] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[44]  <= 1'h0;
    else \result_reg[44]  <= s3[12];
  reg \result_reg[45] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[45]  <= 1'h0;
    else \result_reg[45]  <= s3[13];
  reg \result_reg[46] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[46]  <= 1'h0;
    else \result_reg[46]  <= s3[14];
  reg \result_reg[47] ;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) \result_reg[47]  <= 1'h0;
    else \result_reg[47]  <= s3[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[0] <= 1'h0;
    else a2_ff1[0] <= rtlopt_46d9489de218_port_adda[16];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[1] <= 1'h0;
    else a2_ff1[1] <= rtlopt_46d9489de218_port_adda[17];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[2] <= 1'h0;
    else a2_ff1[2] <= rtlopt_46d9489de218_port_adda[18];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[3] <= 1'h0;
    else a2_ff1[3] <= rtlopt_46d9489de218_port_adda[19];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[4] <= 1'h0;
    else a2_ff1[4] <= rtlopt_46d9489de218_port_adda[20];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[5] <= 1'h0;
    else a2_ff1[5] <= rtlopt_46d9489de218_port_adda[21];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[6] <= 1'h0;
    else a2_ff1[6] <= rtlopt_46d9489de218_port_adda[22];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[7] <= 1'h0;
    else a2_ff1[7] <= rtlopt_46d9489de218_port_adda[23];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[8] <= 1'h0;
    else a2_ff1[8] <= rtlopt_46d9489de218_port_adda[24];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[9] <= 1'h0;
    else a2_ff1[9] <= rtlopt_46d9489de218_port_adda[25];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[10] <= 1'h0;
    else a2_ff1[10] <= rtlopt_46d9489de218_port_adda[26];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[11] <= 1'h0;
    else a2_ff1[11] <= rtlopt_46d9489de218_port_adda[27];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[12] <= 1'h0;
    else a2_ff1[12] <= rtlopt_46d9489de218_port_adda[28];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[13] <= 1'h0;
    else a2_ff1[13] <= rtlopt_46d9489de218_port_adda[29];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[14] <= 1'h0;
    else a2_ff1[14] <= rtlopt_46d9489de218_port_adda[30];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a2_ff1[15] <= 1'h0;
    else a2_ff1[15] <= rtlopt_46d9489de218_port_adda[31];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[0] <= 1'h0;
    else b2_ff1[0] <= rtlopt_46d9489de218_port_addb[16];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[1] <= 1'h0;
    else b2_ff1[1] <= rtlopt_46d9489de218_port_addb[17];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[2] <= 1'h0;
    else b2_ff1[2] <= rtlopt_46d9489de218_port_addb[18];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[3] <= 1'h0;
    else b2_ff1[3] <= rtlopt_46d9489de218_port_addb[19];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[4] <= 1'h0;
    else b2_ff1[4] <= rtlopt_46d9489de218_port_addb[20];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[5] <= 1'h0;
    else b2_ff1[5] <= rtlopt_46d9489de218_port_addb[21];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[6] <= 1'h0;
    else b2_ff1[6] <= rtlopt_46d9489de218_port_addb[22];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[7] <= 1'h0;
    else b2_ff1[7] <= rtlopt_46d9489de218_port_addb[23];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[8] <= 1'h0;
    else b2_ff1[8] <= rtlopt_46d9489de218_port_addb[24];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[9] <= 1'h0;
    else b2_ff1[9] <= rtlopt_46d9489de218_port_addb[25];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[10] <= 1'h0;
    else b2_ff1[10] <= rtlopt_46d9489de218_port_addb[26];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[11] <= 1'h0;
    else b2_ff1[11] <= rtlopt_46d9489de218_port_addb[27];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[12] <= 1'h0;
    else b2_ff1[12] <= rtlopt_46d9489de218_port_addb[28];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[13] <= 1'h0;
    else b2_ff1[13] <= rtlopt_46d9489de218_port_addb[29];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[14] <= 1'h0;
    else b2_ff1[14] <= rtlopt_46d9489de218_port_addb[30];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b2_ff1[15] <= 1'h0;
    else b2_ff1[15] <= rtlopt_46d9489de218_port_addb[31];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[0] <= 1'h0;
    else a3_ff1[0] <= rtlopt_46d9489de218_port_adda[32];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[1] <= 1'h0;
    else a3_ff1[1] <= rtlopt_46d9489de218_port_adda[33];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[2] <= 1'h0;
    else a3_ff1[2] <= rtlopt_46d9489de218_port_adda[34];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[3] <= 1'h0;
    else a3_ff1[3] <= rtlopt_46d9489de218_port_adda[35];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[4] <= 1'h0;
    else a3_ff1[4] <= rtlopt_46d9489de218_port_adda[36];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[5] <= 1'h0;
    else a3_ff1[5] <= rtlopt_46d9489de218_port_adda[37];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[6] <= 1'h0;
    else a3_ff1[6] <= rtlopt_46d9489de218_port_adda[38];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[7] <= 1'h0;
    else a3_ff1[7] <= rtlopt_46d9489de218_port_adda[39];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[8] <= 1'h0;
    else a3_ff1[8] <= rtlopt_46d9489de218_port_adda[40];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[9] <= 1'h0;
    else a3_ff1[9] <= rtlopt_46d9489de218_port_adda[41];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[10] <= 1'h0;
    else a3_ff1[10] <= rtlopt_46d9489de218_port_adda[42];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[11] <= 1'h0;
    else a3_ff1[11] <= rtlopt_46d9489de218_port_adda[43];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[12] <= 1'h0;
    else a3_ff1[12] <= rtlopt_46d9489de218_port_adda[44];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[13] <= 1'h0;
    else a3_ff1[13] <= rtlopt_46d9489de218_port_adda[45];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[14] <= 1'h0;
    else a3_ff1[14] <= rtlopt_46d9489de218_port_adda[46];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff1[15] <= 1'h0;
    else a3_ff1[15] <= rtlopt_46d9489de218_port_adda[47];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[0] <= 1'h0;
    else b3_ff1[0] <= rtlopt_46d9489de218_port_addb[32];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[1] <= 1'h0;
    else b3_ff1[1] <= rtlopt_46d9489de218_port_addb[33];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[2] <= 1'h0;
    else b3_ff1[2] <= rtlopt_46d9489de218_port_addb[34];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[3] <= 1'h0;
    else b3_ff1[3] <= rtlopt_46d9489de218_port_addb[35];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[4] <= 1'h0;
    else b3_ff1[4] <= rtlopt_46d9489de218_port_addb[36];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[5] <= 1'h0;
    else b3_ff1[5] <= rtlopt_46d9489de218_port_addb[37];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[6] <= 1'h0;
    else b3_ff1[6] <= rtlopt_46d9489de218_port_addb[38];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[7] <= 1'h0;
    else b3_ff1[7] <= rtlopt_46d9489de218_port_addb[39];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[8] <= 1'h0;
    else b3_ff1[8] <= rtlopt_46d9489de218_port_addb[40];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[9] <= 1'h0;
    else b3_ff1[9] <= rtlopt_46d9489de218_port_addb[41];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[10] <= 1'h0;
    else b3_ff1[10] <= rtlopt_46d9489de218_port_addb[42];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[11] <= 1'h0;
    else b3_ff1[11] <= rtlopt_46d9489de218_port_addb[43];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[12] <= 1'h0;
    else b3_ff1[12] <= rtlopt_46d9489de218_port_addb[44];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[13] <= 1'h0;
    else b3_ff1[13] <= rtlopt_46d9489de218_port_addb[45];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[14] <= 1'h0;
    else b3_ff1[14] <= rtlopt_46d9489de218_port_addb[46];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff1[15] <= 1'h0;
    else b3_ff1[15] <= rtlopt_46d9489de218_port_addb[47];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[0] <= 1'h0;
    else a3_ff2[0] <= a3_ff1[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[1] <= 1'h0;
    else a3_ff2[1] <= a3_ff1[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[2] <= 1'h0;
    else a3_ff2[2] <= a3_ff1[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[3] <= 1'h0;
    else a3_ff2[3] <= a3_ff1[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[4] <= 1'h0;
    else a3_ff2[4] <= a3_ff1[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[5] <= 1'h0;
    else a3_ff2[5] <= a3_ff1[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[6] <= 1'h0;
    else a3_ff2[6] <= a3_ff1[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[7] <= 1'h0;
    else a3_ff2[7] <= a3_ff1[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[8] <= 1'h0;
    else a3_ff2[8] <= a3_ff1[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[9] <= 1'h0;
    else a3_ff2[9] <= a3_ff1[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[10] <= 1'h0;
    else a3_ff2[10] <= a3_ff1[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[11] <= 1'h0;
    else a3_ff2[11] <= a3_ff1[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[12] <= 1'h0;
    else a3_ff2[12] <= a3_ff1[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[13] <= 1'h0;
    else a3_ff2[13] <= a3_ff1[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[14] <= 1'h0;
    else a3_ff2[14] <= a3_ff1[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a3_ff2[15] <= 1'h0;
    else a3_ff2[15] <= a3_ff1[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[0] <= 1'h0;
    else b3_ff2[0] <= b3_ff1[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[1] <= 1'h0;
    else b3_ff2[1] <= b3_ff1[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[2] <= 1'h0;
    else b3_ff2[2] <= b3_ff1[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[3] <= 1'h0;
    else b3_ff2[3] <= b3_ff1[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[4] <= 1'h0;
    else b3_ff2[4] <= b3_ff1[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[5] <= 1'h0;
    else b3_ff2[5] <= b3_ff1[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[6] <= 1'h0;
    else b3_ff2[6] <= b3_ff1[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[7] <= 1'h0;
    else b3_ff2[7] <= b3_ff1[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[8] <= 1'h0;
    else b3_ff2[8] <= b3_ff1[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[9] <= 1'h0;
    else b3_ff2[9] <= b3_ff1[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[10] <= 1'h0;
    else b3_ff2[10] <= b3_ff1[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[11] <= 1'h0;
    else b3_ff2[11] <= b3_ff1[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[12] <= 1'h0;
    else b3_ff2[12] <= b3_ff1[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[13] <= 1'h0;
    else b3_ff2[13] <= b3_ff1[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[14] <= 1'h0;
    else b3_ff2[14] <= b3_ff1[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b3_ff2[15] <= 1'h0;
    else b3_ff2[15] <= b3_ff1[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[0] <= 1'h0;
    else a4_ff1[0] <= rtlopt_46d9489de218_port_adda[48];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[1] <= 1'h0;
    else a4_ff1[1] <= rtlopt_46d9489de218_port_adda[49];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[2] <= 1'h0;
    else a4_ff1[2] <= rtlopt_46d9489de218_port_adda[50];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[3] <= 1'h0;
    else a4_ff1[3] <= rtlopt_46d9489de218_port_adda[51];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[4] <= 1'h0;
    else a4_ff1[4] <= rtlopt_46d9489de218_port_adda[52];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[5] <= 1'h0;
    else a4_ff1[5] <= rtlopt_46d9489de218_port_adda[53];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[6] <= 1'h0;
    else a4_ff1[6] <= rtlopt_46d9489de218_port_adda[54];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[7] <= 1'h0;
    else a4_ff1[7] <= rtlopt_46d9489de218_port_adda[55];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[8] <= 1'h0;
    else a4_ff1[8] <= rtlopt_46d9489de218_port_adda[56];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[9] <= 1'h0;
    else a4_ff1[9] <= rtlopt_46d9489de218_port_adda[57];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[10] <= 1'h0;
    else a4_ff1[10] <= rtlopt_46d9489de218_port_adda[58];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[11] <= 1'h0;
    else a4_ff1[11] <= rtlopt_46d9489de218_port_adda[59];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[12] <= 1'h0;
    else a4_ff1[12] <= rtlopt_46d9489de218_port_adda[60];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[13] <= 1'h0;
    else a4_ff1[13] <= rtlopt_46d9489de218_port_adda[61];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[14] <= 1'h0;
    else a4_ff1[14] <= rtlopt_46d9489de218_port_adda[62];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff1[15] <= 1'h0;
    else a4_ff1[15] <= rtlopt_46d9489de218_port_adda[63];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[0] <= 1'h0;
    else b4_ff1[0] <= rtlopt_46d9489de218_port_addb[48];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[1] <= 1'h0;
    else b4_ff1[1] <= rtlopt_46d9489de218_port_addb[49];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[2] <= 1'h0;
    else b4_ff1[2] <= rtlopt_46d9489de218_port_addb[50];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[3] <= 1'h0;
    else b4_ff1[3] <= rtlopt_46d9489de218_port_addb[51];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[4] <= 1'h0;
    else b4_ff1[4] <= rtlopt_46d9489de218_port_addb[52];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[5] <= 1'h0;
    else b4_ff1[5] <= rtlopt_46d9489de218_port_addb[53];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[6] <= 1'h0;
    else b4_ff1[6] <= rtlopt_46d9489de218_port_addb[54];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[7] <= 1'h0;
    else b4_ff1[7] <= rtlopt_46d9489de218_port_addb[55];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[8] <= 1'h0;
    else b4_ff1[8] <= rtlopt_46d9489de218_port_addb[56];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[9] <= 1'h0;
    else b4_ff1[9] <= rtlopt_46d9489de218_port_addb[57];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[10] <= 1'h0;
    else b4_ff1[10] <= rtlopt_46d9489de218_port_addb[58];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[11] <= 1'h0;
    else b4_ff1[11] <= rtlopt_46d9489de218_port_addb[59];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[12] <= 1'h0;
    else b4_ff1[12] <= rtlopt_46d9489de218_port_addb[60];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[13] <= 1'h0;
    else b4_ff1[13] <= rtlopt_46d9489de218_port_addb[61];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[14] <= 1'h0;
    else b4_ff1[14] <= rtlopt_46d9489de218_port_addb[62];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff1[15] <= 1'h0;
    else b4_ff1[15] <= rtlopt_46d9489de218_port_addb[63];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[0] <= 1'h0;
    else a4_ff2[0] <= a4_ff1[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[1] <= 1'h0;
    else a4_ff2[1] <= a4_ff1[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[2] <= 1'h0;
    else a4_ff2[2] <= a4_ff1[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[3] <= 1'h0;
    else a4_ff2[3] <= a4_ff1[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[4] <= 1'h0;
    else a4_ff2[4] <= a4_ff1[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[5] <= 1'h0;
    else a4_ff2[5] <= a4_ff1[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[6] <= 1'h0;
    else a4_ff2[6] <= a4_ff1[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[7] <= 1'h0;
    else a4_ff2[7] <= a4_ff1[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[8] <= 1'h0;
    else a4_ff2[8] <= a4_ff1[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[9] <= 1'h0;
    else a4_ff2[9] <= a4_ff1[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[10] <= 1'h0;
    else a4_ff2[10] <= a4_ff1[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[11] <= 1'h0;
    else a4_ff2[11] <= a4_ff1[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[12] <= 1'h0;
    else a4_ff2[12] <= a4_ff1[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[13] <= 1'h0;
    else a4_ff2[13] <= a4_ff1[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[14] <= 1'h0;
    else a4_ff2[14] <= a4_ff1[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff2[15] <= 1'h0;
    else a4_ff2[15] <= a4_ff1[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[0] <= 1'h0;
    else b4_ff2[0] <= b4_ff1[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[1] <= 1'h0;
    else b4_ff2[1] <= b4_ff1[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[2] <= 1'h0;
    else b4_ff2[2] <= b4_ff1[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[3] <= 1'h0;
    else b4_ff2[3] <= b4_ff1[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[4] <= 1'h0;
    else b4_ff2[4] <= b4_ff1[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[5] <= 1'h0;
    else b4_ff2[5] <= b4_ff1[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[6] <= 1'h0;
    else b4_ff2[6] <= b4_ff1[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[7] <= 1'h0;
    else b4_ff2[7] <= b4_ff1[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[8] <= 1'h0;
    else b4_ff2[8] <= b4_ff1[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[9] <= 1'h0;
    else b4_ff2[9] <= b4_ff1[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[10] <= 1'h0;
    else b4_ff2[10] <= b4_ff1[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[11] <= 1'h0;
    else b4_ff2[11] <= b4_ff1[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[12] <= 1'h0;
    else b4_ff2[12] <= b4_ff1[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[13] <= 1'h0;
    else b4_ff2[13] <= b4_ff1[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[14] <= 1'h0;
    else b4_ff2[14] <= b4_ff1[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff2[15] <= 1'h0;
    else b4_ff2[15] <= b4_ff1[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[0] <= 1'h0;
    else a4_ff3[0] <= a4_ff2[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[1] <= 1'h0;
    else a4_ff3[1] <= a4_ff2[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[2] <= 1'h0;
    else a4_ff3[2] <= a4_ff2[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[3] <= 1'h0;
    else a4_ff3[3] <= a4_ff2[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[4] <= 1'h0;
    else a4_ff3[4] <= a4_ff2[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[5] <= 1'h0;
    else a4_ff3[5] <= a4_ff2[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[6] <= 1'h0;
    else a4_ff3[6] <= a4_ff2[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[7] <= 1'h0;
    else a4_ff3[7] <= a4_ff2[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[8] <= 1'h0;
    else a4_ff3[8] <= a4_ff2[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[9] <= 1'h0;
    else a4_ff3[9] <= a4_ff2[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[10] <= 1'h0;
    else a4_ff3[10] <= a4_ff2[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[11] <= 1'h0;
    else a4_ff3[11] <= a4_ff2[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[12] <= 1'h0;
    else a4_ff3[12] <= a4_ff2[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[13] <= 1'h0;
    else a4_ff3[13] <= a4_ff2[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[14] <= 1'h0;
    else a4_ff3[14] <= a4_ff2[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) a4_ff3[15] <= 1'h0;
    else a4_ff3[15] <= a4_ff2[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[0] <= 1'h0;
    else b4_ff3[0] <= b4_ff2[0];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[1] <= 1'h0;
    else b4_ff3[1] <= b4_ff2[1];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[2] <= 1'h0;
    else b4_ff3[2] <= b4_ff2[2];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[3] <= 1'h0;
    else b4_ff3[3] <= b4_ff2[3];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[4] <= 1'h0;
    else b4_ff3[4] <= b4_ff2[4];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[5] <= 1'h0;
    else b4_ff3[5] <= b4_ff2[5];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[6] <= 1'h0;
    else b4_ff3[6] <= b4_ff2[6];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[7] <= 1'h0;
    else b4_ff3[7] <= b4_ff2[7];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[8] <= 1'h0;
    else b4_ff3[8] <= b4_ff2[8];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[9] <= 1'h0;
    else b4_ff3[9] <= b4_ff2[9];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[10] <= 1'h0;
    else b4_ff3[10] <= b4_ff2[10];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[11] <= 1'h0;
    else b4_ff3[11] <= b4_ff2[11];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[12] <= 1'h0;
    else b4_ff3[12] <= b4_ff2[12];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[13] <= 1'h0;
    else b4_ff3[13] <= b4_ff2[13];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[14] <= 1'h0;
    else b4_ff3[14] <= b4_ff2[14];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) b4_ff3[15] <= 1'h0;
    else b4_ff3[15] <= b4_ff2[15];
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) rtlopt_46d9489de218_port_o_en <= 1'h0;
    else rtlopt_46d9489de218_port_o_en <= stage3;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) stage1 <= 1'h0;
    else stage1 <= rtlopt_46d9489de218_port_i_en;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) stage2 <= 1'h0;
    else stage2 <= stage1;
  always @(posedge rtlopt_46d9489de218_port_clk, negedge rtlopt_46d9489de218_port_rst_n)
    if (!rtlopt_46d9489de218_port_rst_n) stage3 <= 1'h0;
    else stage3 <= stage2;
  always @* begin
    _0000_ = 4'h8 >> { b3_ff2[0], a3_ff2[0] };
    _0001_ = 4'h1 >> { b3_ff2[0], a3_ff2[0] };
    _0002_ = 4'h2 >> { _0001_, c2 };
    _0003_ = 4'h1 >> { _0002_, _0000_ };
    _0004_ = 4'h1 >> { _0003_, _0000_ };
    _0005_ = 4'h2 >> { _0004_, c2 };
    _0006_ = 4'h4 >> { _0003_, _0001_ };
    _0650_[1] = 4'he >> { _0006_, _0005_ };
    _0007_ = 4'h4 >> { b3_ff2[1], a3_ff2[1] };
    _0008_ = 4'h2 >> { b3_ff2[1], a3_ff2[1] };
    _0009_ = 4'h1 >> { _0008_, _0007_ };
    _0010_ = 4'h4 >> { _0009_, _0003_ };
    _0011_ = 4'h2 >> { _0009_, _0003_ };
    _0650_[2] = 4'he >> { _0011_, _0010_ };
    _0012_ = 4'h8 >> { b3_ff2[1], a3_ff2[1] };
    _0013_ = 4'h1 >> { _0009_, _0003_ };
    _0014_ = 4'h1 >> { _0013_, _0012_ };
    _0015_ = 4'h4 >> { b3_ff2[2], a3_ff2[2] };
    _0016_ = 4'h2 >> { b3_ff2[2], a3_ff2[2] };
    _0017_ = 4'h1 >> { _0016_, _0015_ };
    _0018_ = 4'h4 >> { _0017_, _0014_ };
    _0019_ = 4'h2 >> { _0017_, _0014_ };
    _0650_[3] = 4'he >> { _0019_, _0018_ };
    _0020_ = 4'h1 >> { b3_ff2[2], a3_ff2[2] };
    _0021_ = 4'h8 >> { b3_ff2[2], a3_ff2[2] };
    _0022_ = 4'h1 >> { _0021_, _0012_ };
    _0023_ = 4'h4 >> { _0022_, _0013_ };
    _0024_ = 4'h1 >> { _0023_, _0020_ };
    _0025_ = 4'h4 >> { b3_ff2[3], a3_ff2[3] };
    _0026_ = 4'h2 >> { b3_ff2[3], a3_ff2[3] };
    _0027_ = 4'h1 >> { _0026_, _0025_ };
    _0028_ = 4'h4 >> { _0027_, _0024_ };
    _0029_ = 4'h2 >> { _0027_, _0024_ };
    _0650_[4] = 4'h1 >> { _0029_, _0028_ };
    _0030_ = 4'h8 >> { b3_ff2[3], a3_ff2[3] };
    _0031_ = 4'h1 >> { _0030_, _0029_ };
    _0032_ = 4'h4 >> { b3_ff2[4], a3_ff2[4] };
    _0033_ = 4'h2 >> { b3_ff2[4], a3_ff2[4] };
    _0034_ = 4'h1 >> { _0033_, _0032_ };
    _0035_ = 4'h4 >> { _0034_, _0031_ };
    _0036_ = 4'h2 >> { _0034_, _0031_ };
    _0650_[5] = 4'he >> { _0036_, _0035_ };
    _0037_ = 4'h2 >> { _0034_, _0029_ };
    _0038_ = 4'h1 >> { b3_ff2[4], a3_ff2[4] };
    _0039_ = 4'h8 >> { b3_ff2[4], a3_ff2[4] };
    _0040_ = 4'h1 >> { _0039_, _0030_ };
    _0041_ = 4'h1 >> { _0040_, _0038_ };
    _0042_ = 4'h1 >> { _0041_, _0037_ };
    _0043_ = 4'h4 >> { b3_ff2[5], a3_ff2[5] };
    _0044_ = 4'h2 >> { b3_ff2[5], a3_ff2[5] };
    _0045_ = 4'h1 >> { _0044_, _0043_ };
    _0046_ = 4'h4 >> { _0045_, _0042_ };
    _0047_ = 4'h2 >> { _0045_, _0042_ };
    _0650_[6] = 4'he >> { _0047_, _0046_ };
    _0048_ = 4'h4 >> { b3_ff2[6], a3_ff2[6] };
    _0049_ = 4'h2 >> { b3_ff2[6], a3_ff2[6] };
    _0050_ = 4'h1 >> { _0049_, _0048_ };
    _0051_ = 4'h1 >> { b3_ff2[5], a3_ff2[5] };
    _0052_ = 4'h8 >> { b3_ff2[5], a3_ff2[5] };
    _0053_ = 4'h2 >> { _0052_, _0042_ };
    _0054_ = 4'h1 >> { _0053_, _0051_ };
    _0055_ = 4'h4 >> { _0054_, _0050_ };
    _0056_ = 4'h2 >> { _0054_, _0050_ };
    _0650_[7] = 4'h1 >> { _0056_, _0055_ };
    _0057_ = 4'h1 >> { _0050_, _0045_ };
    _0058_ = 4'h8 >> { _0057_, _0037_ };
    _0059_ = 4'h1 >> { b3_ff2[6], a3_ff2[6] };
    _0060_ = 4'h2 >> { _0051_, _0041_ };
    _0061_ = 4'h8 >> { b3_ff2[6], a3_ff2[6] };
    _0062_ = 4'h1 >> { _0061_, _0052_ };
    _0063_ = 4'h4 >> { _0062_, _0060_ };
    _0064_ = 4'h1 >> { _0063_, _0059_ };
    _0065_ = 4'h1 >> { _0064_, _0058_ };
    _0066_ = 4'h4 >> { b3_ff2[7], a3_ff2[7] };
    _0067_ = 4'h2 >> { b3_ff2[7], a3_ff2[7] };
    _0068_ = 4'h1 >> { _0067_, _0066_ };
    _0069_ = 4'h4 >> { _0068_, _0065_ };
    _0070_ = 4'h2 >> { _0068_, _0065_ };
    _0650_[8] = 4'he >> { _0070_, _0069_ };
    _0071_ = 4'h4 >> { b3_ff2[8], a3_ff2[8] };
    _0072_ = 4'h2 >> { b3_ff2[8], a3_ff2[8] };
    _0073_ = 4'h1 >> { _0072_, _0071_ };
    _0074_ = 4'h8 >> { b3_ff2[7], a3_ff2[7] };
    _0075_ = 4'h1 >> { b3_ff2[7], a3_ff2[7] };
    _0076_ = 4'h1 >> { _0075_, _0065_ };
    _0077_ = 4'h1 >> { _0076_, _0074_ };
    _0078_ = 4'h4 >> { _0077_, _0073_ };
    _0079_ = 4'h2 >> { _0077_, _0073_ };
    _0650_[9] = 4'he >> { _0079_, _0078_ };
    _0080_ = 4'h1 >> { _0073_, _0068_ };
    _0081_ = 4'h4 >> { _0080_, _0065_ };
    _0082_ = 4'h1 >> { b3_ff2[8], a3_ff2[8] };
    _0083_ = 4'h8 >> { b3_ff2[8], a3_ff2[8] };
    _0084_ = 4'h1 >> { _0083_, _0074_ };
    _0085_ = 4'h1 >> { _0084_, _0082_ };
    _0086_ = 4'h1 >> { _0085_, _0081_ };
    _0087_ = 4'h4 >> { b3_ff2[9], a3_ff2[9] };
    _0088_ = 4'h2 >> { b3_ff2[9], a3_ff2[9] };
    _0089_ = 4'h1 >> { _0088_, _0087_ };
    _0090_ = 4'h4 >> { _0089_, _0086_ };
    _0091_ = 4'h2 >> { _0089_, _0086_ };
    _0650_[10] = 4'he >> { _0091_, _0090_ };
    _0092_ = 4'h4 >> { b3_ff2[10], a3_ff2[10] };
    _0093_ = 4'h2 >> { b3_ff2[10], a3_ff2[10] };
    _0094_ = 4'h1 >> { _0093_, _0092_ };
    _0095_ = 4'h1 >> { b3_ff2[9], a3_ff2[9] };
    _0096_ = 4'h8 >> { b3_ff2[9], a3_ff2[9] };
    _0097_ = 4'h2 >> { _0096_, _0086_ };
    _0098_ = 4'h1 >> { _0097_, _0095_ };
    _0099_ = 4'h4 >> { _0098_, _0094_ };
    _0100_ = 4'h2 >> { _0098_, _0094_ };
    _0650_[11] = 4'h1 >> { _0100_, _0099_ };
    _0101_ = 4'h1 >> { b3_ff2[10], a3_ff2[10] };
    _0102_ = 4'h2 >> { _0095_, _0085_ };
    _0103_ = 4'h8 >> { b3_ff2[10], a3_ff2[10] };
    _0104_ = 4'h1 >> { _0103_, _0096_ };
    _0105_ = 4'h4 >> { _0104_, _0102_ };
    _0106_ = 4'h1 >> { _0105_, _0101_ };
    _0107_ = 4'h1 >> { _0094_, _0089_ };
    _0108_ = 4'h8 >> { _0107_, _0081_ };
    _0109_ = 4'h1 >> { _0108_, _0106_ };
    _0110_ = 4'h4 >> { b3_ff2[11], a3_ff2[11] };
    _0111_ = 4'h2 >> { b3_ff2[11], a3_ff2[11] };
    _0112_ = 4'h1 >> { _0111_, _0110_ };
    _0113_ = 4'h4 >> { _0112_, _0109_ };
    _0114_ = 4'h2 >> { _0112_, _0109_ };
    _0650_[12] = 4'he >> { _0114_, _0113_ };
    _0115_ = 4'h4 >> { b3_ff2[12], a3_ff2[12] };
    _0116_ = 4'h2 >> { b3_ff2[12], a3_ff2[12] };
    _0117_ = 4'h1 >> { _0116_, _0115_ };
    _0118_ = 4'h8 >> { b3_ff2[11], a3_ff2[11] };
    _0119_ = 4'h1 >> { b3_ff2[11], a3_ff2[11] };
    _0120_ = 4'h1 >> { _0119_, _0109_ };
    _0121_ = 4'h1 >> { _0120_, _0118_ };
    _0122_ = 4'h4 >> { _0121_, _0117_ };
    _0123_ = 4'h2 >> { _0121_, _0117_ };
    _0650_[13] = 4'he >> { _0123_, _0122_ };
    _0124_ = 4'h1 >> { _0117_, _0112_ };
    _0125_ = 4'h4 >> { _0124_, _0109_ };
    _0126_ = 4'h1 >> { b3_ff2[12], a3_ff2[12] };
    _0127_ = 4'h8 >> { b3_ff2[12], a3_ff2[12] };
    _0128_ = 4'h1 >> { _0127_, _0118_ };
    _0129_ = 4'h1 >> { _0128_, _0126_ };
    _0130_ = 4'h1 >> { _0129_, _0125_ };
    _0131_ = 4'h4 >> { b3_ff2[13], a3_ff2[13] };
    _0132_ = 4'h2 >> { b3_ff2[13], a3_ff2[13] };
    _0133_ = 4'h1 >> { _0132_, _0131_ };
    _0134_ = 4'h4 >> { _0133_, _0130_ };
    _0135_ = 4'h2 >> { _0133_, _0130_ };
    _0650_[14] = 4'he >> { _0135_, _0134_ };
    _0136_ = 4'h4 >> { b3_ff2[14], a3_ff2[14] };
    _0137_ = 4'h2 >> { b3_ff2[14], a3_ff2[14] };
    _0138_ = 4'h1 >> { _0137_, _0136_ };
    _0139_ = 4'h1 >> { b3_ff2[13], a3_ff2[13] };
    _0140_ = 4'h8 >> { b3_ff2[13], a3_ff2[13] };
    _0141_ = 4'h2 >> { _0140_, _0130_ };
    _0142_ = 4'h1 >> { _0141_, _0139_ };
    _0143_ = 4'h4 >> { _0142_, _0138_ };
    _0144_ = 4'h2 >> { _0142_, _0138_ };
    _0650_[15] = 4'h1 >> { _0144_, _0143_ };
    _0145_ = 4'h8 >> { b3_ff2[14], a3_ff2[14] };
    _0146_ = 4'h1 >> { _0140_, _0129_ };
    _0147_ = 4'h1 >> { b3_ff2[14], a3_ff2[14] };
    _0148_ = 4'h1 >> { _0147_, _0139_ };
    _0149_ = 4'h4 >> { _0148_, _0146_ };
    _0150_ = 4'h1 >> { _0149_, _0145_ };
    _0151_ = 4'h1 >> { _0138_, _0133_ };
    _0152_ = 4'h8 >> { _0151_, _0125_ };
    _0153_ = 4'h2 >> { _0152_, _0150_ };
    _0154_ = 4'h4 >> { b3_ff2[15], a3_ff2[15] };
    _0155_ = 4'h2 >> { b3_ff2[15], a3_ff2[15] };
    _0156_ = 4'h1 >> { _0155_, _0154_ };
    _0157_ = 4'h4 >> { _0156_, _0153_ };
    _0158_ = 4'h2 >> { _0156_, _0153_ };
    _0650_[16] = 4'he >> { _0158_, _0157_ };
    _0159_ = 4'h8 >> { b4_ff3[0], a4_ff3[0] };
    _0160_ = 4'h1 >> { b4_ff3[0], a4_ff3[0] };
    _0161_ = 4'h2 >> { _0160_, c3 };
    _0162_ = 4'h1 >> { _0161_, _0159_ };
    _0163_ = 4'h1 >> { _0162_, _0159_ };
    _0164_ = 4'h2 >> { _0163_, c3 };
    _0165_ = 4'h4 >> { _0162_, _0160_ };
    _0652_[1] = 4'he >> { _0165_, _0164_ };
    _0166_ = 4'h4 >> { b4_ff3[1], a4_ff3[1] };
    _0167_ = 4'h2 >> { b4_ff3[1], a4_ff3[1] };
    _0168_ = 4'h1 >> { _0167_, _0166_ };
    _0169_ = 4'h4 >> { _0168_, _0162_ };
    _0170_ = 4'h2 >> { _0168_, _0162_ };
    _0652_[2] = 4'he >> { _0170_, _0169_ };
    _0171_ = 4'h8 >> { b4_ff3[1], a4_ff3[1] };
    _0172_ = 4'h1 >> { _0168_, _0162_ };
    _0173_ = 4'h1 >> { _0172_, _0171_ };
    _0174_ = 4'h4 >> { b4_ff3[2], a4_ff3[2] };
    _0175_ = 4'h2 >> { b4_ff3[2], a4_ff3[2] };
    _0176_ = 4'h1 >> { _0175_, _0174_ };
    _0177_ = 4'h4 >> { _0176_, _0173_ };
    _0178_ = 4'h2 >> { _0176_, _0173_ };
    _0652_[3] = 4'he >> { _0178_, _0177_ };
    _0179_ = 4'h1 >> { b4_ff3[2], a4_ff3[2] };
    _0180_ = 4'h8 >> { b4_ff3[2], a4_ff3[2] };
    _0181_ = 4'h1 >> { _0180_, _0171_ };
    _0182_ = 4'h4 >> { _0181_, _0172_ };
    _0183_ = 4'h1 >> { _0182_, _0179_ };
    _0184_ = 4'h4 >> { b4_ff3[3], a4_ff3[3] };
    _0185_ = 4'h2 >> { b4_ff3[3], a4_ff3[3] };
    _0186_ = 4'h1 >> { _0185_, _0184_ };
    _0187_ = 4'h4 >> { _0186_, _0183_ };
    _0188_ = 4'h2 >> { _0186_, _0183_ };
    _0652_[4] = 4'h1 >> { _0188_, _0187_ };
    _0189_ = 4'h8 >> { b4_ff3[3], a4_ff3[3] };
    _0190_ = 4'h1 >> { _0189_, _0188_ };
    _0191_ = 4'h4 >> { b4_ff3[4], a4_ff3[4] };
    _0192_ = 4'h2 >> { b4_ff3[4], a4_ff3[4] };
    _0193_ = 4'h1 >> { _0192_, _0191_ };
    _0194_ = 4'h4 >> { _0193_, _0190_ };
    _0195_ = 4'h2 >> { _0193_, _0190_ };
    _0652_[5] = 4'he >> { _0195_, _0194_ };
    _0196_ = 4'h2 >> { _0193_, _0188_ };
    _0197_ = 4'h1 >> { b4_ff3[4], a4_ff3[4] };
    _0198_ = 4'h8 >> { b4_ff3[4], a4_ff3[4] };
    _0199_ = 4'h1 >> { _0198_, _0189_ };
    _0200_ = 4'h1 >> { _0199_, _0197_ };
    _0201_ = 4'h1 >> { _0200_, _0196_ };
    _0202_ = 4'h4 >> { b4_ff3[5], a4_ff3[5] };
    _0203_ = 4'h2 >> { b4_ff3[5], a4_ff3[5] };
    _0204_ = 4'h1 >> { _0203_, _0202_ };
    _0205_ = 4'h4 >> { _0204_, _0201_ };
    _0206_ = 4'h2 >> { _0204_, _0201_ };
    _0652_[6] = 4'he >> { _0206_, _0205_ };
    _0207_ = 4'h4 >> { b4_ff3[6], a4_ff3[6] };
    _0208_ = 4'h2 >> { b4_ff3[6], a4_ff3[6] };
    _0209_ = 4'h1 >> { _0208_, _0207_ };
    _0210_ = 4'h1 >> { b4_ff3[5], a4_ff3[5] };
    _0211_ = 4'h8 >> { b4_ff3[5], a4_ff3[5] };
    _0212_ = 4'h2 >> { _0211_, _0201_ };
    _0213_ = 4'h1 >> { _0212_, _0210_ };
    _0214_ = 4'h4 >> { _0213_, _0209_ };
    _0215_ = 4'h2 >> { _0213_, _0209_ };
    _0652_[7] = 4'h1 >> { _0215_, _0214_ };
    _0216_ = 4'h1 >> { _0209_, _0204_ };
    _0217_ = 4'h8 >> { _0216_, _0196_ };
    _0218_ = 4'h1 >> { b4_ff3[6], a4_ff3[6] };
    _0219_ = 4'h2 >> { _0210_, _0200_ };
    _0220_ = 4'h8 >> { b4_ff3[6], a4_ff3[6] };
    _0221_ = 4'h1 >> { _0220_, _0211_ };
    _0222_ = 4'h4 >> { _0221_, _0219_ };
    _0223_ = 4'h1 >> { _0222_, _0218_ };
    _0224_ = 4'h1 >> { _0223_, _0217_ };
    _0225_ = 4'h4 >> { b4_ff3[7], a4_ff3[7] };
    _0226_ = 4'h2 >> { b4_ff3[7], a4_ff3[7] };
    _0227_ = 4'h1 >> { _0226_, _0225_ };
    _0228_ = 4'h4 >> { _0227_, _0224_ };
    _0229_ = 4'h2 >> { _0227_, _0224_ };
    _0652_[8] = 4'he >> { _0229_, _0228_ };
    _0230_ = 4'h4 >> { b4_ff3[8], a4_ff3[8] };
    _0231_ = 4'h2 >> { b4_ff3[8], a4_ff3[8] };
    _0232_ = 4'h1 >> { _0231_, _0230_ };
    _0233_ = 4'h8 >> { b4_ff3[7], a4_ff3[7] };
    _0234_ = 4'h1 >> { b4_ff3[7], a4_ff3[7] };
    _0235_ = 4'h1 >> { _0234_, _0224_ };
    _0236_ = 4'h1 >> { _0235_, _0233_ };
    _0237_ = 4'h4 >> { _0236_, _0232_ };
    _0238_ = 4'h2 >> { _0236_, _0232_ };
    _0652_[9] = 4'he >> { _0238_, _0237_ };
    _0239_ = 4'h1 >> { _0232_, _0227_ };
    _0240_ = 4'h4 >> { _0239_, _0224_ };
    _0241_ = 4'h1 >> { b4_ff3[8], a4_ff3[8] };
    _0242_ = 4'h8 >> { b4_ff3[8], a4_ff3[8] };
    _0243_ = 4'h1 >> { _0242_, _0233_ };
    _0244_ = 4'h1 >> { _0243_, _0241_ };
    _0245_ = 4'h1 >> { _0244_, _0240_ };
    _0246_ = 4'h4 >> { b4_ff3[9], a4_ff3[9] };
    _0247_ = 4'h2 >> { b4_ff3[9], a4_ff3[9] };
    _0248_ = 4'h1 >> { _0247_, _0246_ };
    _0249_ = 4'h4 >> { _0248_, _0245_ };
    _0250_ = 4'h2 >> { _0248_, _0245_ };
    _0652_[10] = 4'he >> { _0250_, _0249_ };
    _0251_ = 4'h4 >> { b4_ff3[10], a4_ff3[10] };
    _0252_ = 4'h2 >> { b4_ff3[10], a4_ff3[10] };
    _0253_ = 4'h1 >> { _0252_, _0251_ };
    _0254_ = 4'h1 >> { b4_ff3[9], a4_ff3[9] };
    _0255_ = 4'h8 >> { b4_ff3[9], a4_ff3[9] };
    _0256_ = 4'h2 >> { _0255_, _0245_ };
    _0257_ = 4'h1 >> { _0256_, _0254_ };
    _0258_ = 4'h4 >> { _0257_, _0253_ };
    _0259_ = 4'h2 >> { _0257_, _0253_ };
    _0652_[11] = 4'h1 >> { _0259_, _0258_ };
    _0260_ = 4'h1 >> { _0253_, _0248_ };
    _0261_ = 4'h8 >> { _0260_, _0240_ };
    _0262_ = 4'h8 >> { b4_ff3[10], a4_ff3[10] };
    _0263_ = 4'h1 >> { _0255_, _0244_ };
    _0264_ = 4'h1 >> { b4_ff3[10], a4_ff3[10] };
    _0265_ = 4'h1 >> { _0264_, _0254_ };
    _0266_ = 4'h4 >> { _0265_, _0263_ };
    _0267_ = 4'h1 >> { _0266_, _0262_ };
    _0268_ = 4'h4 >> { _0267_, _0261_ };
    _0269_ = 4'h4 >> { b4_ff3[11], a4_ff3[11] };
    _0270_ = 4'h2 >> { b4_ff3[11], a4_ff3[11] };
    _0271_ = 4'h1 >> { _0270_, _0269_ };
    _0272_ = 4'h4 >> { _0271_, _0268_ };
    _0273_ = 4'h2 >> { _0271_, _0268_ };
    _0652_[12] = 4'he >> { _0273_, _0272_ };
    _0274_ = 4'h4 >> { b4_ff3[12], a4_ff3[12] };
    _0275_ = 4'h2 >> { b4_ff3[12], a4_ff3[12] };
    _0276_ = 4'h1 >> { _0275_, _0274_ };
    _0277_ = 4'h8 >> { b4_ff3[11], a4_ff3[11] };
    _0278_ = 4'h1 >> { b4_ff3[11], a4_ff3[11] };
    _0279_ = 4'h1 >> { _0278_, _0268_ };
    _0280_ = 4'h1 >> { _0279_, _0277_ };
    _0281_ = 4'h4 >> { _0280_, _0276_ };
    _0282_ = 4'h2 >> { _0280_, _0276_ };
    _0652_[13] = 4'he >> { _0282_, _0281_ };
    _0283_ = 4'h1 >> { _0276_, _0271_ };
    _0284_ = 4'h4 >> { _0283_, _0268_ };
    _0285_ = 4'h1 >> { b4_ff3[12], a4_ff3[12] };
    _0286_ = 4'h8 >> { b4_ff3[12], a4_ff3[12] };
    _0287_ = 4'h1 >> { _0286_, _0277_ };
    _0288_ = 4'h1 >> { _0287_, _0285_ };
    _0289_ = 4'h1 >> { _0288_, _0284_ };
    _0290_ = 4'h4 >> { b4_ff3[13], a4_ff3[13] };
    _0291_ = 4'h2 >> { b4_ff3[13], a4_ff3[13] };
    _0292_ = 4'h1 >> { _0291_, _0290_ };
    _0293_ = 4'h4 >> { _0292_, _0289_ };
    _0294_ = 4'h2 >> { _0292_, _0289_ };
    _0652_[14] = 4'he >> { _0294_, _0293_ };
    _0295_ = 4'h4 >> { b4_ff3[14], a4_ff3[14] };
    _0296_ = 4'h2 >> { b4_ff3[14], a4_ff3[14] };
    _0297_ = 4'h1 >> { _0296_, _0295_ };
    _0298_ = 4'h1 >> { b4_ff3[13], a4_ff3[13] };
    _0299_ = 4'h8 >> { b4_ff3[13], a4_ff3[13] };
    _0300_ = 4'h2 >> { _0299_, _0289_ };
    _0301_ = 4'h1 >> { _0300_, _0298_ };
    _0302_ = 4'h4 >> { _0301_, _0297_ };
    _0303_ = 4'h2 >> { _0301_, _0297_ };
    _0652_[15] = 4'h1 >> { _0303_, _0302_ };
    _0304_ = 4'h1 >> { b4_ff3[14], a4_ff3[14] };
    _0305_ = 4'h2 >> { _0298_, _0288_ };
    _0306_ = 4'h8 >> { b4_ff3[14], a4_ff3[14] };
    _0307_ = 4'h1 >> { _0306_, _0299_ };
    _0308_ = 4'h4 >> { _0307_, _0305_ };
    _0309_ = 4'h1 >> { _0308_, _0304_ };
    _0310_ = 4'h1 >> { _0297_, _0292_ };
    _0311_ = 4'h8 >> { _0310_, _0284_ };
    _0312_ = 4'h1 >> { _0311_, _0309_ };
    _0313_ = 4'h4 >> { b4_ff3[15], a4_ff3[15] };
    _0314_ = 4'h2 >> { b4_ff3[15], a4_ff3[15] };
    _0315_ = 4'h1 >> { _0314_, _0313_ };
    _0316_ = 4'h4 >> { _0315_, _0312_ };
    _0317_ = 4'h2 >> { _0315_, _0312_ };
    _0652_[16] = 4'he >> { _0317_, _0316_ };
    _0318_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[14], rtlopt_46d9489de218_port_adda[14] };
    _0319_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[14], rtlopt_46d9489de218_port_adda[14] };
    _0320_ = 4'h1 >> { _0319_, _0318_ };
    _0321_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[15], rtlopt_46d9489de218_port_adda[15] };
    _0322_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[15], rtlopt_46d9489de218_port_adda[15] };
    _0323_ = 4'h1 >> { _0322_, _0321_ };
    _0324_ = 4'h1 >> { _0323_, _0320_ };
    _0325_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[4], rtlopt_46d9489de218_port_adda[4] };
    _0326_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[4], rtlopt_46d9489de218_port_adda[4] };
    _0327_ = 4'h1 >> { _0326_, _0325_ };
    _0328_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[3], rtlopt_46d9489de218_port_adda[3] };
    _0329_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[3], rtlopt_46d9489de218_port_adda[3] };
    _0330_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[2], rtlopt_46d9489de218_port_adda[2] };
    _0331_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[2], rtlopt_46d9489de218_port_adda[2] };
    _0332_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[2], rtlopt_46d9489de218_port_adda[2] };
    _0333_ = 4'h1 >> { _0332_, _0331_ };
    _0334_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[1], rtlopt_46d9489de218_port_adda[1] };
    _0335_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[1], rtlopt_46d9489de218_port_adda[1] };
    _0336_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[0], rtlopt_46d9489de218_port_adda[0] };
    _0337_ = 4'h4 >> { _0336_, _0335_ };
    _0338_ = 4'h1 >> { _0337_, _0334_ };
    _0339_ = 4'h1 >> { _0338_, _0333_ };
    _0340_ = 4'h1 >> { _0339_, _0330_ };
    _0341_ = 4'h1 >> { _0340_, _0329_ };
    _0342_ = 4'h1 >> { _0341_, _0328_ };
    _0343_ = 4'h1 >> { _0342_, _0327_ };
    _0344_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[5], rtlopt_46d9489de218_port_adda[5] };
    _0345_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[5], rtlopt_46d9489de218_port_adda[5] };
    _0346_ = 4'h1 >> { _0345_, _0344_ };
    _0347_ = 4'h2 >> { _0346_, _0343_ };
    _0348_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[6], rtlopt_46d9489de218_port_adda[6] };
    _0349_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[6], rtlopt_46d9489de218_port_adda[6] };
    _0350_ = 4'h1 >> { _0349_, _0348_ };
    _0351_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[7], rtlopt_46d9489de218_port_adda[7] };
    _0352_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[7], rtlopt_46d9489de218_port_adda[7] };
    _0353_ = 4'h1 >> { _0352_, _0351_ };
    _0354_ = 4'h1 >> { _0353_, _0350_ };
    _0355_ = 4'h8 >> { _0354_, _0347_ };
    _0356_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[7], rtlopt_46d9489de218_port_adda[7] };
    _0357_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[7], rtlopt_46d9489de218_port_adda[7] };
    _0358_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[6], rtlopt_46d9489de218_port_adda[6] };
    _0359_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[6], rtlopt_46d9489de218_port_adda[6] };
    _0360_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[5], rtlopt_46d9489de218_port_adda[5] };
    _0361_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[4], rtlopt_46d9489de218_port_adda[4] };
    _0362_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[5], rtlopt_46d9489de218_port_adda[5] };
    _0363_ = 4'h1 >> { _0362_, _0361_ };
    _0364_ = 4'h1 >> { _0363_, _0360_ };
    _0365_ = 4'h1 >> { _0364_, _0359_ };
    _0366_ = 4'h1 >> { _0365_, _0358_ };
    _0367_ = 4'h4 >> { _0366_, _0357_ };
    _0368_ = 4'h1 >> { _0367_, _0356_ };
    _0369_ = 4'h4 >> { _0368_, _0355_ };
    _0370_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[9], rtlopt_46d9489de218_port_adda[9] };
    _0371_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[9], rtlopt_46d9489de218_port_adda[9] };
    _0372_ = 4'h1 >> { _0371_, _0370_ };
    _0373_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[8], rtlopt_46d9489de218_port_adda[8] };
    _0374_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[8], rtlopt_46d9489de218_port_adda[8] };
    _0375_ = 4'h1 >> { _0374_, _0373_ };
    _0376_ = 4'h1 >> { _0375_, _0372_ };
    _0377_ = 4'h4 >> { _0376_, _0369_ };
    _0378_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[11], rtlopt_46d9489de218_port_adda[11] };
    _0379_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[11], rtlopt_46d9489de218_port_adda[11] };
    _0380_ = 4'h1 >> { _0379_, _0378_ };
    _0381_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[10], rtlopt_46d9489de218_port_adda[10] };
    _0382_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[10], rtlopt_46d9489de218_port_adda[10] };
    _0383_ = 4'h1 >> { _0382_, _0381_ };
    _0384_ = 4'h1 >> { _0383_, _0380_ };
    _0385_ = 4'h8 >> { _0384_, _0377_ };
    _0386_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[11], rtlopt_46d9489de218_port_adda[11] };
    _0387_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[11], rtlopt_46d9489de218_port_adda[11] };
    _0388_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[10], rtlopt_46d9489de218_port_adda[10] };
    _0389_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[10], rtlopt_46d9489de218_port_adda[10] };
    _0390_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[9], rtlopt_46d9489de218_port_adda[9] };
    _0391_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[9], rtlopt_46d9489de218_port_adda[9] };
    _0392_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[8], rtlopt_46d9489de218_port_adda[8] };
    _0393_ = 4'h1 >> { _0392_, _0391_ };
    _0394_ = 4'h1 >> { _0393_, _0390_ };
    _0395_ = 4'h1 >> { _0394_, _0389_ };
    _0396_ = 4'h1 >> { _0395_, _0388_ };
    _0397_ = 4'h4 >> { _0396_, _0387_ };
    _0398_ = 4'h1 >> { _0397_, _0386_ };
    _0399_ = 4'h4 >> { _0398_, _0385_ };
    _0400_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[13], rtlopt_46d9489de218_port_adda[13] };
    _0401_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[13], rtlopt_46d9489de218_port_adda[13] };
    _0402_ = 4'h1 >> { _0401_, _0400_ };
    _0403_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[12], rtlopt_46d9489de218_port_adda[12] };
    _0404_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[12], rtlopt_46d9489de218_port_adda[12] };
    _0405_ = 4'h1 >> { _0404_, _0403_ };
    _0406_ = 4'h1 >> { _0405_, _0402_ };
    _0407_ = 4'h4 >> { _0406_, _0399_ };
    _0408_ = 4'h8 >> { _0407_, _0324_ };
    _0409_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[15], rtlopt_46d9489de218_port_adda[15] };
    _0410_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[15], rtlopt_46d9489de218_port_adda[15] };
    _0411_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[14], rtlopt_46d9489de218_port_adda[14] };
    _0412_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[14], rtlopt_46d9489de218_port_adda[14] };
    _0413_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[13], rtlopt_46d9489de218_port_adda[13] };
    _0414_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[13], rtlopt_46d9489de218_port_adda[13] };
    _0415_ = 4'h8 >> { rtlopt_46d9489de218_port_addb[12], rtlopt_46d9489de218_port_adda[12] };
    _0416_ = 4'h1 >> { _0415_, _0414_ };
    _0417_ = 4'h1 >> { _0416_, _0413_ };
    _0418_ = 4'h1 >> { _0417_, _0412_ };
    _0419_ = 4'h1 >> { _0418_, _0411_ };
    _0420_ = 4'h4 >> { _0419_, _0410_ };
    _0421_ = 4'h1 >> { _0420_, _0409_ };
    _0644_[15] = 4'hb >> { _0421_, _0408_ };
    _0422_ = 4'h8 >> { b2_ff1[14], a2_ff1[14] };
    _0423_ = 4'h1 >> { b2_ff1[14], a2_ff1[14] };
    _0424_ = 4'h1 >> { b2_ff1[13], a2_ff1[13] };
    _0425_ = 4'h8 >> { b2_ff1[13], a2_ff1[13] };
    _0426_ = 4'h1 >> { b2_ff1[12], a2_ff1[12] };
    _0427_ = 4'h8 >> { b2_ff1[12], a2_ff1[12] };
    _0428_ = 4'h8 >> { b2_ff1[11], a2_ff1[11] };
    _0429_ = 4'h1 >> { _0428_, _0427_ };
    _0430_ = 4'h1 >> { _0429_, _0426_ };
    _0431_ = 4'h1 >> { _0430_, _0425_ };
    _0432_ = 4'h1 >> { _0431_, _0424_ };
    _0433_ = 4'h4 >> { _0432_, _0423_ };
    _0434_ = 4'h1 >> { _0433_, _0422_ };
    _0435_ = 4'h4 >> { b2_ff1[14], a2_ff1[14] };
    _0436_ = 4'h2 >> { b2_ff1[14], a2_ff1[14] };
    _0437_ = 4'h1 >> { _0436_, _0435_ };
    _0438_ = 4'h4 >> { b2_ff1[13], a2_ff1[13] };
    _0439_ = 4'h2 >> { b2_ff1[13], a2_ff1[13] };
    _0440_ = 4'h1 >> { _0439_, _0438_ };
    _0441_ = 4'h1 >> { _0440_, _0437_ };
    _0442_ = 4'h4 >> { b2_ff1[12], a2_ff1[12] };
    _0443_ = 4'h2 >> { b2_ff1[12], a2_ff1[12] };
    _0444_ = 4'h1 >> { _0443_, _0442_ };
    _0445_ = 4'h4 >> { b2_ff1[11], a2_ff1[11] };
    _0446_ = 4'h2 >> { b2_ff1[11], a2_ff1[11] };
    _0447_ = 4'h1 >> { _0446_, _0445_ };
    _0448_ = 4'h1 >> { _0447_, _0444_ };
    _0449_ = 4'h8 >> { b2_ff1[10], a2_ff1[10] };
    _0450_ = 4'h1 >> { b2_ff1[10], a2_ff1[10] };
    _0451_ = 4'h1 >> { b2_ff1[9], a2_ff1[9] };
    _0452_ = 4'h8 >> { b2_ff1[9], a2_ff1[9] };
    _0453_ = 4'h1 >> { b2_ff1[8], a2_ff1[8] };
    _0454_ = 4'h8 >> { b2_ff1[8], a2_ff1[8] };
    _0455_ = 4'h8 >> { b2_ff1[7], a2_ff1[7] };
    _0456_ = 4'h1 >> { _0455_, _0454_ };
    _0457_ = 4'h1 >> { _0456_, _0453_ };
    _0458_ = 4'h1 >> { _0457_, _0452_ };
    _0459_ = 4'h1 >> { _0458_, _0451_ };
    _0460_ = 4'h4 >> { _0459_, _0450_ };
    _0461_ = 4'h1 >> { _0460_, _0449_ };
    _0462_ = 4'h1 >> { b2_ff1[2], a2_ff1[2] };
    _0463_ = 4'h8 >> { b2_ff1[1], a2_ff1[1] };
    _0464_ = 4'h8 >> { b2_ff1[2], a2_ff1[2] };
    _0465_ = 4'h1 >> { _0464_, _0463_ };
    _0466_ = 4'h4 >> { b2_ff1[1], a2_ff1[1] };
    _0467_ = 4'h2 >> { b2_ff1[1], a2_ff1[1] };
    _0468_ = 4'h1 >> { _0467_, _0466_ };
    _0469_ = 4'h8 >> { b2_ff1[0], a2_ff1[0] };
    _0470_ = 4'h1 >> { b2_ff1[0], a2_ff1[0] };
    _0471_ = 4'h2 >> { _0470_, c1 };
    _0472_ = 4'h1 >> { _0471_, _0469_ };
    _0473_ = 4'h1 >> { _0472_, _0468_ };
    _0474_ = 4'h2 >> { _0473_, _0465_ };
    _0475_ = 4'h1 >> { _0474_, _0462_ };
    _0476_ = 4'h4 >> { b2_ff1[3], a2_ff1[3] };
    _0477_ = 4'h2 >> { b2_ff1[3], a2_ff1[3] };
    _0478_ = 4'h1 >> { _0477_, _0476_ };
    _0479_ = 4'h2 >> { _0478_, _0475_ };
    _0480_ = 4'h4 >> { b2_ff1[4], a2_ff1[4] };
    _0481_ = 4'h2 >> { b2_ff1[4], a2_ff1[4] };
    _0482_ = 4'h1 >> { _0481_, _0480_ };
    _0483_ = 4'h2 >> { _0482_, _0479_ };
    _0484_ = 4'h4 >> { b2_ff1[6], a2_ff1[6] };
    _0485_ = 4'h2 >> { b2_ff1[6], a2_ff1[6] };
    _0486_ = 4'h1 >> { _0485_, _0484_ };
    _0487_ = 4'h4 >> { b2_ff1[5], a2_ff1[5] };
    _0488_ = 4'h2 >> { b2_ff1[5], a2_ff1[5] };
    _0489_ = 4'h1 >> { _0488_, _0487_ };
    _0490_ = 4'h1 >> { _0489_, _0486_ };
    _0491_ = 4'h8 >> { _0490_, _0483_ };
    _0492_ = 4'h8 >> { b2_ff1[6], a2_ff1[6] };
    _0493_ = 4'h1 >> { b2_ff1[6], a2_ff1[6] };
    _0494_ = 4'h1 >> { b2_ff1[5], a2_ff1[5] };
    _0495_ = 4'h8 >> { b2_ff1[5], a2_ff1[5] };
    _0496_ = 4'h1 >> { b2_ff1[4], a2_ff1[4] };
    _0497_ = 4'h8 >> { b2_ff1[3], a2_ff1[3] };
    _0498_ = 4'h8 >> { b2_ff1[4], a2_ff1[4] };
    _0499_ = 4'h1 >> { _0498_, _0497_ };
    _0500_ = 4'h1 >> { _0499_, _0496_ };
    _0501_ = 4'h1 >> { _0500_, _0495_ };
    _0502_ = 4'h1 >> { _0501_, _0494_ };
    _0503_ = 4'h4 >> { _0502_, _0493_ };
    _0504_ = 4'h1 >> { _0503_, _0492_ };
    _0505_ = 4'h4 >> { _0504_, _0491_ };
    _0506_ = 4'h4 >> { b2_ff1[8], a2_ff1[8] };
    _0507_ = 4'h2 >> { b2_ff1[8], a2_ff1[8] };
    _0508_ = 4'h1 >> { _0507_, _0506_ };
    _0509_ = 4'h4 >> { b2_ff1[7], a2_ff1[7] };
    _0510_ = 4'h2 >> { b2_ff1[7], a2_ff1[7] };
    _0511_ = 4'h1 >> { _0510_, _0509_ };
    _0512_ = 4'h1 >> { _0511_, _0508_ };
    _0513_ = 4'h4 >> { _0512_, _0505_ };
    _0514_ = 4'h4 >> { b2_ff1[10], a2_ff1[10] };
    _0515_ = 4'h2 >> { b2_ff1[10], a2_ff1[10] };
    _0516_ = 4'h1 >> { _0515_, _0514_ };
    _0517_ = 4'h4 >> { b2_ff1[9], a2_ff1[9] };
    _0518_ = 4'h2 >> { b2_ff1[9], a2_ff1[9] };
    _0519_ = 4'h1 >> { _0518_, _0517_ };
    _0520_ = 4'h1 >> { _0519_, _0516_ };
    _0521_ = 4'h8 >> { _0520_, _0513_ };
    _0522_ = 4'h2 >> { _0521_, _0461_ };
    _0523_ = 4'h2 >> { _0522_, _0448_ };
    _0524_ = 4'h8 >> { _0523_, _0441_ };
    _0525_ = 4'h2 >> { _0524_, _0434_ };
    _0526_ = 4'h4 >> { _0525_, b2_ff1[15] };
    _0527_ = 4'h2 >> { _0525_, b2_ff1[15] };
    _0528_ = 4'h1 >> { _0527_, a2_ff1[15] };
    _0647_[16] = 4'h1 >> { _0528_, _0526_ };
    _0529_ = 4'h4 >> { _0153_, b3_ff2[15] };
    _0530_ = 4'h2 >> { _0153_, b3_ff2[15] };
    _0531_ = 4'h1 >> { _0530_, a3_ff2[15] };
    _0649_[16] = 4'h1 >> { _0531_, _0529_ };
    _0532_ = 4'h4 >> { _0312_, b4_ff3[15] };
    _0533_ = 4'h2 >> { _0312_, b4_ff3[15] };
    _0534_ = 4'h1 >> { _0533_, a4_ff3[15] };
    _0651_[16] = 4'h1 >> { _0534_, _0532_ };
    _0535_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[1], rtlopt_46d9489de218_port_adda[1] };
    _0536_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[1], rtlopt_46d9489de218_port_adda[1] };
    _0537_ = 4'h1 >> { _0536_, _0535_ };
    _0538_ = 4'h4 >> { _0537_, _0336_ };
    _0539_ = 4'h2 >> { _0537_, _0336_ };
    _0646_[1] = 4'h1 >> { _0539_, _0538_ };
    _0540_ = 4'h4 >> { _0338_, _0333_ };
    _0541_ = 4'h2 >> { _0338_, _0333_ };
    _0646_[2] = 4'he >> { _0541_, _0540_ };
    _0542_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[3], rtlopt_46d9489de218_port_adda[3] };
    _0543_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[3], rtlopt_46d9489de218_port_adda[3] };
    _0544_ = 4'h1 >> { _0543_, _0542_ };
    _0545_ = 4'h4 >> { _0544_, _0340_ };
    _0546_ = 4'h2 >> { _0544_, _0340_ };
    _0646_[3] = 4'he >> { _0546_, _0545_ };
    _0547_ = 4'h4 >> { _0342_, _0327_ };
    _0548_ = 4'h2 >> { _0342_, _0327_ };
    _0646_[4] = 4'he >> { _0548_, _0547_ };
    _0549_ = 4'h1 >> { _0361_, _0343_ };
    _0550_ = 4'h4 >> { _0549_, _0346_ };
    _0551_ = 4'h2 >> { _0549_, _0346_ };
    _0646_[5] = 4'he >> { _0551_, _0550_ };
    _0552_ = 4'h1 >> { _0364_, _0347_ };
    _0553_ = 4'h4 >> { _0552_, _0350_ };
    _0554_ = 4'h2 >> { _0552_, _0350_ };
    _0646_[6] = 4'he >> { _0554_, _0553_ };
    _0555_ = 4'h2 >> { _0358_, _0347_ };
    _0556_ = 4'h1 >> { _0555_, _0366_ };
    _0557_ = 4'h4 >> { _0556_, _0353_ };
    _0558_ = 4'h2 >> { _0556_, _0353_ };
    _0646_[7] = 4'he >> { _0558_, _0557_ };
    _0559_ = 4'h4 >> { _0375_, _0369_ };
    _0560_ = 4'h2 >> { _0375_, _0369_ };
    _0646_[8] = 4'he >> { _0560_, _0559_ };
    _0561_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[8], rtlopt_46d9489de218_port_adda[8] };
    _0562_ = 4'h1 >> { _0561_, _0369_ };
    _0563_ = 4'h1 >> { _0562_, _0392_ };
    _0564_ = 4'h4 >> { _0563_, _0372_ };
    _0565_ = 4'h2 >> { _0563_, _0372_ };
    _0646_[9] = 4'he >> { _0565_, _0564_ };
    _0566_ = 4'h1 >> { _0394_, _0377_ };
    _0567_ = 4'h4 >> { _0566_, _0383_ };
    _0568_ = 4'h2 >> { _0566_, _0383_ };
    _0646_[10] = 4'he >> { _0568_, _0567_ };
    _0569_ = 4'h2 >> { _0388_, _0377_ };
    _0570_ = 4'h1 >> { _0569_, _0396_ };
    _0571_ = 4'h4 >> { _0570_, _0380_ };
    _0572_ = 4'h2 >> { _0570_, _0380_ };
    _0646_[11] = 4'he >> { _0572_, _0571_ };
    _0573_ = 4'h4 >> { _0405_, _0399_ };
    _0574_ = 4'h2 >> { _0405_, _0399_ };
    _0646_[12] = 4'he >> { _0574_, _0573_ };
    _0575_ = 4'h1 >> { rtlopt_46d9489de218_port_addb[12], rtlopt_46d9489de218_port_adda[12] };
    _0576_ = 4'h1 >> { _0575_, _0399_ };
    _0577_ = 4'h1 >> { _0576_, _0415_ };
    _0578_ = 4'h4 >> { _0577_, _0402_ };
    _0579_ = 4'h2 >> { _0577_, _0402_ };
    _0646_[13] = 4'he >> { _0579_, _0578_ };
    _0580_ = 4'h1 >> { _0417_, _0407_ };
    _0581_ = 4'h4 >> { _0580_, _0320_ };
    _0582_ = 4'h2 >> { _0580_, _0320_ };
    _0646_[14] = 4'he >> { _0582_, _0581_ };
    _0583_ = 4'h2 >> { _0411_, _0407_ };
    _0584_ = 4'h1 >> { _0583_, _0419_ };
    _0585_ = 4'h4 >> { _0584_, _0323_ };
    _0586_ = 4'h2 >> { _0584_, _0323_ };
    _0646_[15] = 4'he >> { _0586_, _0585_ };
    _0587_ = 4'h4 >> { rtlopt_46d9489de218_port_addb[0], rtlopt_46d9489de218_port_adda[0] };
    _0588_ = 4'h2 >> { rtlopt_46d9489de218_port_addb[0], rtlopt_46d9489de218_port_adda[0] };
    _0645_[0] = 4'he >> { _0588_, _0587_ };
    _0589_ = 4'h4 >> { _0472_, _0470_ };
    _0590_ = 4'h1 >> { _0589_, c1 };
    _0591_ = 4'h1 >> { _0472_, _0469_ };
    _0648_[1] = 4'h1 >> { _0591_, _0590_ };
    _0592_ = 4'h4 >> { _0472_, _0468_ };
    _0593_ = 4'h2 >> { _0472_, _0468_ };
    _0648_[2] = 4'he >> { _0593_, _0592_ };
    _0594_ = 4'h4 >> { b2_ff1[2], a2_ff1[2] };
    _0595_ = 4'h2 >> { b2_ff1[2], a2_ff1[2] };
    _0596_ = 4'h1 >> { _0595_, _0594_ };
    _0597_ = 4'h1 >> { _0473_, _0463_ };
    _0598_ = 4'h4 >> { _0597_, _0596_ };
    _0599_ = 4'h2 >> { _0597_, _0596_ };
    _0648_[3] = 4'he >> { _0599_, _0598_ };
    _0600_ = 4'h4 >> { _0478_, _0475_ };
    _0648_[4] = 4'h1 >> { _0600_, _0479_ };
    _0601_ = 4'h1 >> { _0497_, _0479_ };
    _0602_ = 4'h4 >> { _0601_, _0482_ };
    _0603_ = 4'h2 >> { _0601_, _0482_ };
    _0648_[5] = 4'he >> { _0603_, _0602_ };
    _0604_ = 4'h1 >> { _0500_, _0483_ };
    _0605_ = 4'h4 >> { _0604_, _0489_ };
    _0606_ = 4'h2 >> { _0604_, _0489_ };
    _0648_[6] = 4'he >> { _0606_, _0605_ };
    _0607_ = 4'h2 >> { _0494_, _0483_ };
    _0608_ = 4'h1 >> { _0607_, _0502_ };
    _0609_ = 4'h4 >> { _0608_, _0486_ };
    _0610_ = 4'h2 >> { _0608_, _0486_ };
    _0648_[7] = 4'he >> { _0610_, _0609_ };
    _0611_ = 4'h4 >> { _0511_, _0505_ };
    _0612_ = 4'h2 >> { _0511_, _0505_ };
    _0648_[8] = 4'he >> { _0612_, _0611_ };
    _0613_ = 4'h1 >> { b2_ff1[7], a2_ff1[7] };
    _0614_ = 4'h1 >> { _0613_, _0505_ };
    _0615_ = 4'h1 >> { _0614_, _0455_ };
    _0616_ = 4'h4 >> { _0615_, _0508_ };
    _0617_ = 4'h2 >> { _0615_, _0508_ };
    _0648_[9] = 4'he >> { _0617_, _0616_ };
    _0618_ = 4'h1 >> { _0513_, _0457_ };
    _0619_ = 4'h4 >> { _0618_, _0519_ };
    _0620_ = 4'h2 >> { _0618_, _0519_ };
    _0648_[10] = 4'he >> { _0620_, _0619_ };
    _0621_ = 4'h4 >> { _0513_, _0451_ };
    _0622_ = 4'h1 >> { _0621_, _0459_ };
    _0623_ = 4'h4 >> { _0622_, _0516_ };
    _0624_ = 4'h2 >> { _0622_, _0516_ };
    _0648_[11] = 4'he >> { _0624_, _0623_ };
    _0625_ = 4'h4 >> { _0522_, _0447_ };
    _0626_ = 4'h2 >> { _0522_, _0447_ };
    _0648_[12] = 4'he >> { _0626_, _0625_ };
    _0627_ = 4'h1 >> { b2_ff1[11], a2_ff1[11] };
    _0628_ = 4'h1 >> { _0627_, _0522_ };
    _0629_ = 4'h1 >> { _0628_, _0428_ };
    _0630_ = 4'h4 >> { _0629_, _0444_ };
    _0631_ = 4'h2 >> { _0629_, _0444_ };
    _0648_[13] = 4'he >> { _0631_, _0630_ };
    _0632_ = 4'h1 >> { _0523_, _0430_ };
    _0633_ = 4'h4 >> { _0632_, _0440_ };
    _0634_ = 4'h2 >> { _0632_, _0440_ };
    _0648_[14] = 4'he >> { _0634_, _0633_ };
    _0635_ = 4'h4 >> { _0523_, _0424_ };
    _0636_ = 4'h1 >> { _0635_, _0432_ };
    _0637_ = 4'h4 >> { _0636_, _0437_ };
    _0638_ = 4'h2 >> { _0636_, _0437_ };
    _0648_[15] = 4'he >> { _0638_, _0637_ };
    _0639_ = 4'h4 >> { b2_ff1[15], a2_ff1[15] };
    _0640_ = 4'h2 >> { b2_ff1[15], a2_ff1[15] };
    _0641_ = 4'h1 >> { _0640_, _0639_ };
    _0642_ = 4'h4 >> { _0641_, _0525_ };
    _0643_ = 4'h2 >> { _0641_, _0525_ };
    _0648_[16] = 4'he >> { _0643_, _0642_ };
    rtlopt_46d9489de218_port_result[48] = \result_reg[48] ;
    rtlopt_46d9489de218_port_result[49] = \result_reg[49] ;
    rtlopt_46d9489de218_port_result[50] = \result_reg[50] ;
    rtlopt_46d9489de218_port_result[51] = \result_reg[51] ;
    rtlopt_46d9489de218_port_result[52] = \result_reg[52] ;
    rtlopt_46d9489de218_port_result[53] = \result_reg[53] ;
    rtlopt_46d9489de218_port_result[54] = \result_reg[54] ;
    rtlopt_46d9489de218_port_result[55] = \result_reg[55] ;
    rtlopt_46d9489de218_port_result[56] = \result_reg[56] ;
    rtlopt_46d9489de218_port_result[57] = \result_reg[57] ;
    rtlopt_46d9489de218_port_result[58] = \result_reg[58] ;
    rtlopt_46d9489de218_port_result[59] = \result_reg[59] ;
    rtlopt_46d9489de218_port_result[60] = \result_reg[60] ;
    rtlopt_46d9489de218_port_result[61] = \result_reg[61] ;
    rtlopt_46d9489de218_port_result[62] = \result_reg[62] ;
    rtlopt_46d9489de218_port_result[63] = \result_reg[63] ;
    rtlopt_46d9489de218_port_result[0] = \result_reg[0] ;
    rtlopt_46d9489de218_port_result[1] = \result_reg[1] ;
    rtlopt_46d9489de218_port_result[2] = \result_reg[2] ;
    rtlopt_46d9489de218_port_result[3] = \result_reg[3] ;
    rtlopt_46d9489de218_port_result[4] = \result_reg[4] ;
    rtlopt_46d9489de218_port_result[5] = \result_reg[5] ;
    rtlopt_46d9489de218_port_result[6] = \result_reg[6] ;
    rtlopt_46d9489de218_port_result[7] = \result_reg[7] ;
    rtlopt_46d9489de218_port_result[8] = \result_reg[8] ;
    rtlopt_46d9489de218_port_result[9] = \result_reg[9] ;
    rtlopt_46d9489de218_port_result[10] = \result_reg[10] ;
    rtlopt_46d9489de218_port_result[11] = \result_reg[11] ;
    rtlopt_46d9489de218_port_result[12] = \result_reg[12] ;
    rtlopt_46d9489de218_port_result[13] = \result_reg[13] ;
    rtlopt_46d9489de218_port_result[14] = \result_reg[14] ;
    rtlopt_46d9489de218_port_result[15] = \result_reg[15] ;
    rtlopt_46d9489de218_port_result[16] = \result_reg[16] ;
    rtlopt_46d9489de218_port_result[17] = \result_reg[17] ;
    rtlopt_46d9489de218_port_result[18] = \result_reg[18] ;
    rtlopt_46d9489de218_port_result[19] = \result_reg[19] ;
    rtlopt_46d9489de218_port_result[20] = \result_reg[20] ;
    rtlopt_46d9489de218_port_result[21] = \result_reg[21] ;
    rtlopt_46d9489de218_port_result[22] = \result_reg[22] ;
    rtlopt_46d9489de218_port_result[23] = \result_reg[23] ;
    rtlopt_46d9489de218_port_result[24] = \result_reg[24] ;
    rtlopt_46d9489de218_port_result[25] = \result_reg[25] ;
    rtlopt_46d9489de218_port_result[26] = \result_reg[26] ;
    rtlopt_46d9489de218_port_result[27] = \result_reg[27] ;
    rtlopt_46d9489de218_port_result[28] = \result_reg[28] ;
    rtlopt_46d9489de218_port_result[29] = \result_reg[29] ;
    rtlopt_46d9489de218_port_result[30] = \result_reg[30] ;
    rtlopt_46d9489de218_port_result[31] = \result_reg[31] ;
    rtlopt_46d9489de218_port_result[32] = \result_reg[32] ;
    rtlopt_46d9489de218_port_result[33] = \result_reg[33] ;
    rtlopt_46d9489de218_port_result[34] = \result_reg[34] ;
    rtlopt_46d9489de218_port_result[35] = \result_reg[35] ;
    rtlopt_46d9489de218_port_result[36] = \result_reg[36] ;
    rtlopt_46d9489de218_port_result[37] = \result_reg[37] ;
    rtlopt_46d9489de218_port_result[38] = \result_reg[38] ;
    rtlopt_46d9489de218_port_result[39] = \result_reg[39] ;
    rtlopt_46d9489de218_port_result[40] = \result_reg[40] ;
    rtlopt_46d9489de218_port_result[41] = \result_reg[41] ;
    rtlopt_46d9489de218_port_result[42] = \result_reg[42] ;
    rtlopt_46d9489de218_port_result[43] = \result_reg[43] ;
    rtlopt_46d9489de218_port_result[44] = \result_reg[44] ;
    rtlopt_46d9489de218_port_result[45] = \result_reg[45] ;
    rtlopt_46d9489de218_port_result[46] = \result_reg[46] ;
    rtlopt_46d9489de218_port_result[47] = \result_reg[47] ;
    _0644_[16] = 1'h0;
    _0645_[16] = 1'h0;
    { _0646_[16], _0646_[0] } = { _0644_[15], _0645_[0] };
    { _0647_[17], _0647_[0] } = { 1'h0, c1 };
    _0648_[17] = _0647_[16];
    { _0649_[17], _0649_[0] } = { 1'h0, c2 };
    _0650_[17] = _0649_[16];
    { _0651_[17], _0651_[0] } = { 1'h0, c3 };
    _0652_[17] = _0651_[16];
    rtlopt_46d9489de218_port_result[64] = c4;
  end

  end else begin : rtlopt_original_config
    rtlopt_46d9489de218_original #(.DATA_WIDTH(DATA_WIDTH), .STG_WIDTH(STG_WIDTH)) impl (.clk(clk), .rst_n(rst_n), .i_en(i_en), .adda(adda), .addb(addb), .result(result), .o_en(o_en));
  end
endgenerate
endmodule
