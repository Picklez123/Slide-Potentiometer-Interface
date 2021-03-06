module slide_intf(clk, cnv_cmplt, rst_n, chnnl, strt_cnv, POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME);

input clk, rst_n, cnv_cmplt;

output reg [2:0]chnnl;
output reg strt_cnv;
output reg [11:0]POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME;

reg [2:0]cnt, nxtchnnl;
reg state, nxtstate;

localparam IDLE = 1'b0;
localparam CNV = 1'b1;

//Instantiate A2D_intf
A2D_intf A2D(.clk(clk), .rst_n(rst_n), .chnnl(chnnl), .strt_cnv(strt_cnv), .MISO(MISO), .cnv_cmplt(cnv_cmplt), .res(res), .a2d_SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI));

//Next state logic
always_ff @(posedge clk, negedge rst_n)
 if(!rst_n)
  state <= IDLE;
 else
  state <= nxtstate;

//Implement cnt
always_ff @(posedge clk, negedge rst_n)
 if(!rst_n)
  cnt <= 3'b000;
 else if(&cnt)
  cnt <= 3'b000;			//resets cnt when cnt = 111
 else
  cnt <= nxtchnnl;			//nxtcnt assigned in state machine for next chnnl

//Potentiometer outputs
always @(posedge clk) begin
 case(cnt)
  000:   POT_LP <= res;
  001:   POT_B1 <= res;
  010:   POT_B2 <= res;
  011:   POT_B3 <= res;
  100:   POT_HP <= res;
  111:   VOLUME <= res;
 endcase
end
//Implement state machine
always @(*) begin
nxtchnnl = 1'b0;
chnnl = 3'b000;
nxtstate = IDLE;
case(state)
 IDLE:  begin
	strt_cnv = 1'b1;
	chnnl = cnt;
	nxtstate = CNV;
	end

 CNV:   if(!cnv_cmplt) begin
	nxtstate = CNV;
	end else begin
	nxtstate = IDLE;
	 if(cnt == 3'b101)
	 nxtchnnl = 3'b111;
	 else
	 nxtchnnl = nxtchnnl + 1;
	end
endcase
end
endmodule
