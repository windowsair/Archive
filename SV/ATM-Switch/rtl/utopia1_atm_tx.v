
module utopia1_atm_tx(
                      clk                ,
					  rst_n              ,

					  soc                ,
					  data               ,
					  en                 ,
					  clav               ,

					  txreq              ,
					  txack              ,

                      nni_VPI            ,
                      nni_VCI            ,
                      nni_CLP            ,
                      nni_PT             ,
                      nni_HEC            ,
                      nni_Payload

                      );
///////////////////////////////////////////////////
input                  clk               ;
input                  rst_n             ;

output                 soc               ;
output     [7:0]       data              ;
output                 en                ;
input                  clav              ;

///////////////////////////////////////////////////

input                  txreq              ;
output                 txack              ;

input      [11:0]      nni_VPI            ;
input      [15:0]      nni_VCI            ;
input                  nni_CLP            ;
input      [2:0]       nni_PT             ;
input      [7:0]       nni_HEC            ;
input      [8*48-1:0]  nni_Payload        ;

///////////////////////////////////////////////////

///////////////////////////////////////////////////
reg        [5:0]      PayloadIndex  ;
reg        [5:0]      fifo_PayloadIndex;
reg        [2:0]      nop_cnt;
reg        [31:0]     level_ctrl;
reg        [1:0]      level_line;
parameter             reset      = 4'h0 ,
                      ready      = 4'h1 ,
					            soc_frm    = 4'h2 ,
					            vpi_vci    = 4'h3 ,
                      vci        = 4'h4 ,
                      vci_clp_pt = 4'h5 ,
                      hec        = 4'h6 ,
                      payload	   = 4'h7 ,
                      ack        = 4'h8 ,
                      done       = 4'h9 ,
                      nop			   = 4'h10;

parameter             fifo_reset      = 4'h0 ,
                      fifo_ready      = 4'h1 ,
					            fifo_soc_frm    = 4'h2 ,
					            fifo_vpi_vci    = 4'h3 ,
                      fifo_vci        = 4'h4 ,
                      fifo_vci_clp_pt = 4'h5 ,
                      fifo_hec        = 4'h6 ,
                      fifo_payload	  = 4'h7 ,
                      fifo_ack        = 4'h8 ,
                      fifo_done       = 4'h9 ;


reg        [3:0]      UtopiaStatus      ;
reg        [3:0]      fifoStatus        ;
/////////////////////////////////////////////////////
reg [7:0]fifo_din;
reg read;
reg write;
wire empty;
wire full;
wire [7:0]fifo_dout;
wire fifo_unreset = fifoStatus == fifo_reset;
wire fifo_issocfrm = fifoStatus == fifo_ready;
wire tx_unreset = UtopiaStatus == reset;
    sync_fifo sync_fifo_inst(
    .clk(clk),
    .rst_n(rst_n),
    .fifo_din(fifo_din),
    .read(read),
    .write(write),

    .empty(empty),
    .full(full),
    .fifo_dout(fifo_dout)
    );
//写入信号控制
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    write <= 0;
  else if (!full && !fifo_unreset)
    write <= 1;
  else
    write <= 0;
end
//读取信号控制
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    read <= 0;
  else if(!empty)
    read <= 1;
  else
    read <= 0;
end
// always @(posedge clk or negedge rst_n) begin
//   if(!rst_n)
//     fifo_din <= 0;
//   else begin
//     fifo_din <= data;
//   end
// end
reg[7:0] read_tmp;
//读取数据
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    read_tmp <= 0;
  else
    read_tmp <= fifo_dout;
end
wire     [7:0] read_data;
assign   read_data = read_tmp;
/////////////////////////////////////////////////////////
always @(posedge clk, negedge rst_n)
    if (~rst_n)
      fifoStatus <= reset;
  	else begin
      unique case (fifoStatus)
	      fifo_reset     : if(txreq)
		               fifoStatus <= ready          ;
        fifo_ready     : if(clav &&write)
                       fifoStatus <= fifo_soc_frm    ;
	    	fifo_soc_frm       : if(clav &&write)
                       fifoStatus <= fifo_vpi_vci    ;
        fifo_vpi_vci   : if (clav &&write)
                       fifoStatus <= fifo_vci        ;
        fifo_vci       : if (clav &&write)
                       fifoStatus <= fifo_vci_clp_pt ;
        fifo_vci_clp_pt: if (clav &&write)
                       fifoStatus <= fifo_hec        ;
        fifo_hec       : if (clav &&write)
                       fifoStatus <= fifo_payload    ;
        fifo_payload   : if (clav) begin
                       if (fifo_PayloadIndex==47)
		                 fifoStatus <= fifo_ack          ;
                    end
        fifo_ack       : fifoStatus <= fifo_done          ;
        fifo_done      : fifoStatus <= fifo_reset         ;
		default   : fifoStatus <= fifo_reset             ;
      endcase
end

  reg [48*8-1:0] fifo_nni_Payload_reg ;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
        fifo_nni_Payload_reg <= 'h0;
    else if((fifoStatus == fifo_ready))
        fifo_nni_Payload_reg <= nni_Payload;

  always @(posedge clk or negedge rst_n)
    if (~rst_n)
        fifo_din <= 8'h00;
    else begin
      unique case (fifoStatus)
        fifo_soc_frm        : if (clav &&write)
                        fifo_din <= nni_VPI[11:4];
	      fifo_vpi_vci    : if (clav)
                        fifo_din <= {nni_VPI[3:0],
                                 nni_VCI[15:12]
						        };
        fifo_vci        :  if (clav &&write)
                        fifo_din <= nni_VCI[11:4];
        fifo_vci_clp_pt :  if (clav &&write)
                        fifo_din <= {nni_VCI[3:0],
                                 nni_CLP, nni_PT};
        fifo_hec        :  if (clav &&write)
                        fifo_din <= nni_HEC;
        fifo_payload    :  if (clav &&write) begin
                        fifo_din <= fifo_nni_Payload_reg[7:0];
                        fifo_nni_Payload_reg[48*8-1:0] <={8'h00,fifo_nni_Payload_reg[48*8-1:8]} ;
		          end
		default    :	fifo_din <= 8'h00 ;
      endcase
	end
    always_ff @(posedge clk, negedge rst_n)
    if (~rst_n)
        fifo_PayloadIndex <= 0;
    else if(fifoStatus == fifo_payload) begin
	   if(clav)
         fifo_PayloadIndex <= fifo_PayloadIndex + 1 ;
	  end
	  else
        fifo_PayloadIndex <= 0;
/////////////////////////////////////////////////////////
always @(posedge clk, negedge rst_n)
    if (~rst_n)
      UtopiaStatus <= reset;
  	else begin
      unique case (UtopiaStatus)
	      reset     : if(txreq) begin
                     if(clav && read)
		                 UtopiaStatus <= ready        ;
        end

        ready     : if(clav && read)begin
                      if(nop_cnt == 2)
                       UtopiaStatus <= soc_frm    ;
                    end
	    	soc_frm       : if(clav && read)
                       UtopiaStatus <= vpi_vci    ;
        vpi_vci   : if (clav && read)
                       UtopiaStatus <= vci        ;
        vci       : if (clav && read)
                       UtopiaStatus <= vci_clp_pt ;
        vci_clp_pt: if (clav && read)
                       UtopiaStatus <= hec        ;
        hec       : if (clav && read)
                       UtopiaStatus <= payload    ;
        payload   : if (clav && read) begin
                       if (PayloadIndex==47)
		                 UtopiaStatus <= ack   ;
                    end
        ack       : UtopiaStatus <= done          ;
        done      : UtopiaStatus <= reset         ;
		default   : UtopiaStatus <= reset         ;
      endcase
end

  wire     s_state_ready = (UtopiaStatus == ready)  ;
  //assign   txack = (UtopiaStatus == ack)      ;
    assign   txack = (fifoStatus == fifo_ack)      ;

  reg soc ;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
        soc <= 0  ;
    else
        soc <= clav & (UtopiaStatus == soc_frm)      ;

  reg en ;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
        en <= 0;
    else if( (UtopiaStatus == reset) || (UtopiaStatus == ack) || (UtopiaStatus == done) ||(UtopiaStatus == ready && nop_cnt != 2))
        en <= 0;
    else
        en <= clav      ;


  reg [7:0] data ;
  reg [48*8-1:0] nni_Payload_reg ;
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
        nni_Payload_reg <= 'h0;
    else if(s_state_ready)
        nni_Payload_reg <= nni_Payload;

//在NNI和UNI中采用的时MSB的编码格式
//在发送数据中以vpi为例，第一字节位于[11:4]位
  // always @(posedge clk or negedge rst_n)
  //   if (~rst_n)
  //       data <= 8'h00;
  //   else begin
  //     unique case (UtopiaStatus)
  //       soc_frm        : if (clav)
  //                       data <= nni_VPI[11:4];
	//       vpi_vci    : if (clav && read)
  //                       data <= {nni_VPI[3:0],
  //                                nni_VCI[15:12]
	// 					        };
  //       vci        :  if (clav && read)
  //                       data <= nni_VCI[11:4];
  //       vci_clp_pt :  if (clav && read)
  //                       data <= {nni_VCI[3:0],
  //                                nni_CLP, nni_PT};
  //       hec        :  if (clav && read)
  //                       data <= nni_HEC;
  //       payload    :  if (clav && read) begin
  //                       data <= nni_Payload_reg[7:0];
  //                       nni_Payload_reg[48*8-1:0] <={8'h00,nni_Payload_reg[48*8-1:8]} ;
	// 	          end
	// 	default    :	data <= 8'h00 ;
  //     endcase
	// end
    always @(posedge clk or negedge rst_n)
    if (~rst_n)
        data <= 8'h00;
    else begin
      unique case (UtopiaStatus)
        soc_frm        : if (clav && read)
                        data <= read_data;
	      vpi_vci    : if (clav && read)
                        data <= read_data;
        vci        :  if (clav && read)
                        data <= read_data;
        vci_clp_pt :  if (clav && read)
                        data <= read_data;
        hec        :  if (clav && read)
                        data <= read_data;
        payload    :  if (clav && read) begin
                        data <= read_data;

		          end
		default    :	data <= 8'h00 ;
      endcase
	end
	//递进发送报文数据，报文一共0-47字节，在发送47字节时，进行判断等待仲裁
  always_ff @(posedge clk, negedge rst_n)
    if (~rst_n)
        PayloadIndex <= 0;
    else if(UtopiaStatus == payload) begin
	   if(clav)
         PayloadIndex <= PayloadIndex + 1 ;
	end
	else
        PayloadIndex <= 0;
  always_ff @(posedge clk, negedge rst_n)
    if (~rst_n)
        nop_cnt <= 0;
    else if(UtopiaStatus == ready) begin
	   if(clav)
         nop_cnt <= nop_cnt + 1 ;
	end
	else
        nop_cnt <= 0;
  always_ff @(posedge clk, negedge rst_n)
    if (~rst_n)
        level_ctrl <= 0;
    else if(UtopiaStatus == ack) begin
	   if(clav)
         level_ctrl <= level_ctrl + 1 ;
	end
  always_ff @(posedge clk, negedge rst_n)
    if (~rst_n)
        level_line <= 2;
    else if(level_ctrl > 1) begin
         level_line <=  1 ;
	end

endmodule

