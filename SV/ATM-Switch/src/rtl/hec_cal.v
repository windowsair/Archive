module hec_cal(
               hec_in ,
			   hec_out
               );

input   [31:0] hec_in  ;
output  [7:0]  hec_out ;

   //////////////////////////////////////////////////////////
   /////////// Generate the CRC-8 syndrom table /////////////
   //////////////////////////////////////////////////////////
   //产生一个CRC的报表
   //其原理是对于一个8位宽的数据，只有当高位为1时，才需要异或影响因子
   //使用initial初始化并不会综合出一个具体电路，它会使得4个ROM进行初始化
   reg  [7:0] syndrom[0:255];
   reg  [7:0] sndrm;

   integer    i ;
   initial begin

     for (i=0; i<256; i++) begin
	   sndrm = i;
	   repeat (8) begin
	     if (sndrm[7] == 1'b1)
              sndrm = (sndrm << 1) ^ 8'h07;
	     else
              sndrm = sndrm << 1;
	   end
	   syndrom[i] = sndrm;
     end
   end
  /* .................... CRC ................ */
  wire [31:0] hdr = hec_in;
  wire [7:0]  RtnCode0 = syndrom[hdr[31:24]];
  wire [7:0]  RtnCode1 = syndrom[RtnCode0 ^ hdr[23:16]];
  wire [7:0]  RtnCode2 = syndrom[RtnCode1 ^ hdr[15:8]];
  wire [7:0]  RtnCode3 = syndrom[RtnCode2 ^ hdr[7:0]];
  wire [7:0]  RtnCode = RtnCode3 ^ 8'h55;

  assign   hec_out = RtnCode ;


endmodule
