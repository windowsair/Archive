//fifo的深深度
`define FIFO_DEPTH 106
//fifo数据的宽度
`define DATA_WIDTH 8
module sync_fifo(
  input clk,
  input rst_n,
  input [`DATA_WIDTH - 1:0]fifo_din,
  input read,
  input write,

  output  empty,
  output  full,
  output reg [`DATA_WIDTH - 1:0]fifo_dout
 );

//fifo地址的位数
 parameter FIFO_WIDH = 6;

 reg [FIFO_WIDH - 1:0] rp_reg;//0-64
 reg [FIFO_WIDH - 1:0] wp_reg;
 reg [FIFO_WIDH - 1:0]   cnt_reg;//FIFO_DEPTH = 53
 reg [`DATA_WIDTH - 1:0] men[`FIFO_DEPTH - 1:0];

 //从fifo读取地址，初始化指向地址0
 //每次读取逐渐+1
 //不为空持续加1
 always@(posedge clk or negedge rst_n) begin
  if(rst_n == 0)
   rp_reg <= 8'd0;
  else if(!empty && read == 1'b1)
   rp_reg <= rp_reg + 1'b1;
  else rp_reg <= rp_reg;

 end

 //fifo写入地址，初始化指向地址0
 //每次写入逐渐+1
 //不为满持续写入
 always@(posedge clk or negedge rst_n) begin
  if(rst_n == 0)
   wp_reg <= 8'd0;
  else if(!full && write == 1'b1)
   wp_reg <= wp_reg + 1'b1;
  else wp_reg <= wp_reg;

 end

 //fifo长度计数
 //用于产生empty和full
 always@(posedge clk or negedge rst_n) begin
  if(rst_n == 0)
   cnt_reg <= 8'd0;
  else if(!full && write == 1'b1 && !empty && read == 1'b1)
   cnt_reg <= cnt_reg;
  else if(!full && write == 1'b1)
   cnt_reg <= cnt_reg + 1'b1;
  else if(!empty && read == 1'b1)
   cnt_reg <= cnt_reg - 1'b1;
  else
   cnt_reg <= cnt_reg;
 end

 //men
//用于产生empty和full
 always@(posedge clk) begin
  if(!full && write == 1'b1)
   men[wp_reg] <= fifo_din;
  if(!empty && read == 1'b1)
   fifo_dout <= men[rp_reg];
 end

 assign empty = (cnt_reg == 8'd0) ? 1'b1 : 1'b0;
 assign full = (cnt_reg == 8'd106) ? 1'b1 : 1'b0;//FIFO DEPTH 53

endmodule
