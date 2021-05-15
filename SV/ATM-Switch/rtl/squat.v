
module squat (
                clk                 ,
			    rst_n               ,

                BusMode             ,
				Addr                ,
				Sel                 ,
				DataIn              ,
				Rd_DS               ,
				Wr_RW               ,
		        DataOut             ,
				Rdy_Dtack           ,

                rx0_soc             ,
				rx0_data            ,
				rx0_clav            ,
				rx0_en              ,

                rx1_soc             ,
				rx1_data            ,
				rx1_clav            ,
				rx1_en              ,

                rx2_soc             ,
				rx2_data            ,
				rx2_clav            ,
				rx2_en              ,

                rx3_soc             ,
				rx3_data            ,
				rx3_clav            ,
				rx3_en              ,

                rx4_soc             ,
				rx4_data            ,
				rx4_clav            ,
				rx4_en              ,

                rx5_soc             ,
				rx5_data            ,
				rx5_clav            ,
				rx5_en              ,

                rx6_soc             ,
				rx6_data            ,
				rx6_clav            ,
				rx6_en              ,

                rx7_soc             ,
				rx7_data            ,
				rx7_clav            ,
				rx7_en              ,

				tx0_soc             ,
				tx0_data            ,
				tx0_en              ,
				tx0_clav            ,

				tx1_soc             ,
				tx1_data            ,
				tx1_en              ,
				tx1_clav            ,

				tx2_soc             ,
				tx2_data            ,
				tx2_en              ,
				tx2_clav            ,

				tx3_soc             ,
				tx3_data            ,
				tx3_en              ,
				tx3_clav            ,

				tx4_soc             ,
				tx4_data            ,
				tx4_en              ,
				tx4_clav            ,

				tx5_soc             ,
				tx5_data            ,
				tx5_en              ,
				tx5_clav            ,

				tx6_soc             ,
				tx6_data            ,
				tx6_en              ,
				tx6_clav            ,

				tx7_soc             ,
				tx7_data            ,
				tx7_en              ,
				tx7_clav
             );

input                  clk                   ;
input                  rst_n                 ;


input                  BusMode               ;
input      [11:0]      Addr                  ;
input                  Sel                   ;
input      [19:0]      DataIn                ;
input                  Rd_DS                 ;
input                  Wr_RW                 ;
output     [19:0]      DataOut               ;
output                 Rdy_Dtack             ;


input                  rx0_soc               ;
input      [7:0]       rx0_data              ;
input                  rx0_clav              ;
output                 rx0_en                ;

input                  rx1_soc               ;
input      [7:0]       rx1_data              ;
input                  rx1_clav              ;
output                 rx1_en                ;

input                  rx2_soc               ;
input      [7:0]       rx2_data              ;
input                  rx2_clav              ;
output                 rx2_en                ;

input                  rx3_soc               ;
input      [7:0]       rx3_data              ;
input                  rx3_clav              ;
output                 rx3_en                ;

input                  rx4_soc               ;
input      [7:0]       rx4_data              ;
input                  rx4_clav              ;
output                 rx4_en                ;

input                  rx5_soc               ;
input      [7:0]       rx5_data              ;
input                  rx5_clav              ;
output                 rx5_en                ;

input                  rx6_soc               ;
input      [7:0]       rx6_data              ;
input                  rx6_clav              ;
output                 rx6_en                ;

input                  rx7_soc               ;
input      [7:0]       rx7_data              ;
input                  rx7_clav              ;
output                 rx7_en                ;

output                 tx0_soc               ;
output     [7:0]       tx0_data              ;
output                 tx0_en                ;
input                  tx0_clav              ;

output                 tx1_soc               ;
output     [7:0]       tx1_data              ;
output                 tx1_en                ;
input                  tx1_clav              ;

output                 tx2_soc               ;
output     [7:0]       tx2_data              ;
output                 tx2_en                ;
input                  tx2_clav              ;

output                 tx3_soc               ;
output     [7:0]       tx3_data              ;
output                 tx3_en                ;
input                  tx3_clav              ;


output                 tx4_soc               ;
output     [7:0]       tx4_data              ;
output                 tx4_en                ;
input                  tx4_clav              ;

output                 tx5_soc               ;
output     [7:0]       tx5_data              ;
output                 tx5_en                ;
input                  tx5_clav              ;

output                 tx6_soc               ;
output     [7:0]       tx6_data              ;
output                 tx6_en                ;
input                  tx6_clav              ;

output                 tx7_soc               ;
output     [7:0]       tx7_data              ;
output                 tx7_en                ;
input                  tx7_clav              ;

/////////////////////////////////////////////////////////////////////////

wire    		       rx0_rxreq          ;
wire    		       rx0_rxack          ;
wire    [3:0]	       rx0_uni_GFC        ;
wire    [7:0]	       rx0_uni_VPI        ;
wire    [15:0]	       rx0_uni_VCI        ;
wire    		       rx0_uni_CLP        ;
wire    [2:0]	       rx0_uni_PT         ;
wire    [7:0]	       rx0_uni_HEC        ;
wire    [8*48-1:0]	   rx0_uni_Payload    ;


utopia1_atm_rx atm_rx0(
                       .clk            ( clk                ),
					   .rst_n          ( rst_n              ),

                       .soc            ( rx0_soc            ),
					   .data           ( rx0_data           ),
					   .clav           ( rx0_clav           ),
					   .en             ( rx0_en             ),

					   .rxreq          ( rx0_rxreq          ),
					   .rxack          ( rx0_rxack          ),
					   .uni_GFC        ( rx0_uni_GFC        ),
					   .uni_VPI        ( rx0_uni_VPI        ),
					   .uni_VCI        ( rx0_uni_VCI        ),
					   .uni_CLP        ( rx0_uni_CLP        ),
					   .uni_PT         ( rx0_uni_PT         ),
					   .uni_HEC        ( rx0_uni_HEC        ),
					   .uni_Payload    ( rx0_uni_Payload    )

                      );


wire    		       rx1_rxreq          ;
wire    		       rx1_rxack          ;
wire    [3:0]	       rx1_uni_GFC        ;
wire    [7:0]	       rx1_uni_VPI        ;
wire    [15:0]	       rx1_uni_VCI        ;
wire    		       rx1_uni_CLP        ;
wire    [2:0]	       rx1_uni_PT         ;
wire    [7:0]	       rx1_uni_HEC        ;
wire    [8*48-1:0]	   rx1_uni_Payload    ;

utopia1_atm_rx atm_rx1(
                       .clk            ( clk                ),
					   .rst_n          ( rst_n              ),

                       .soc            ( rx1_soc            ),
					   .data           ( rx1_data           ),
					   .clav           ( rx1_clav           ),
					   .en             ( rx1_en             ),

					   .rxreq          ( rx1_rxreq          ),
					   .rxack          ( rx1_rxack          ),
					   .uni_GFC        ( rx1_uni_GFC        ),
					   .uni_VPI        ( rx1_uni_VPI        ),
					   .uni_VCI        ( rx1_uni_VCI        ),
					   .uni_CLP        ( rx1_uni_CLP        ),
					   .uni_PT         ( rx1_uni_PT         ),
					   .uni_HEC        ( rx1_uni_HEC        ),
					   .uni_Payload    ( rx1_uni_Payload    )

                      );

wire    		       rx2_rxreq          ;
wire    		       rx2_rxack          ;
wire    [3:0]	       rx2_uni_GFC        ;
wire    [7:0]	       rx2_uni_VPI        ;
wire    [15:0]	       rx2_uni_VCI        ;
wire    		       rx2_uni_CLP        ;
wire    [2:0]	       rx2_uni_PT         ;
wire    [7:0]	       rx2_uni_HEC        ;
wire    [8*48-1:0]	   rx2_uni_Payload    ;

utopia1_atm_rx atm_rx2(
                       .clk            ( clk                ),
					   .rst_n          ( rst_n              ),

                       .soc            ( rx2_soc            ),
					   .data           ( rx2_data           ),
					   .clav           ( rx2_clav           ),
					   .en             ( rx2_en             ),

					   .rxreq          ( rx2_rxreq          ),
					   .rxack          ( rx2_rxack          ),
					   .uni_GFC        ( rx2_uni_GFC        ),
					   .uni_VPI        ( rx2_uni_VPI        ),
					   .uni_VCI        ( rx2_uni_VCI        ),
					   .uni_CLP        ( rx2_uni_CLP        ),
					   .uni_PT         ( rx2_uni_PT         ),
					   .uni_HEC        ( rx2_uni_HEC        ),
					   .uni_Payload    ( rx2_uni_Payload    )

                      );


wire    		       rx3_rxreq          ;
wire    		       rx3_rxack          ;
wire    [3:0]	       rx3_uni_GFC        ;
wire    [7:0]	       rx3_uni_VPI        ;
wire    [15:0]	       rx3_uni_VCI        ;
wire    		       rx3_uni_CLP        ;
wire    [2:0]	       rx3_uni_PT         ;
wire    [7:0]	       rx3_uni_HEC        ;
wire    [8*48-1:0]	   rx3_uni_Payload    ;

utopia1_atm_rx atm_rx3(
                       .clk            ( clk                ),
					   .rst_n          ( rst_n              ),

                       .soc            ( rx3_soc            ),
					   .data           ( rx3_data           ),
					   .clav           ( rx3_clav           ),
					   .en             ( rx3_en             ),

					   .rxreq          ( rx3_rxreq          ),
					   .rxack          ( rx3_rxack          ),
					   .uni_GFC        ( rx3_uni_GFC        ),
					   .uni_VPI        ( rx3_uni_VPI        ),
					   .uni_VCI        ( rx3_uni_VCI        ),
					   .uni_CLP        ( rx3_uni_CLP        ),
					   .uni_PT         ( rx3_uni_PT         ),
					   .uni_HEC        ( rx3_uni_HEC        ),
					   .uni_Payload    ( rx3_uni_Payload    )

                      );
/////////////////////////////////////////////////////////////////////////
wire    		       rx4_rxreq          ;
wire    		       rx4_rxack          ;
wire    [3:0]	       rx4_uni_GFC        ;
wire    [7:0]	       rx4_uni_VPI        ;
wire    [15:0]	       rx4_uni_VCI        ;
wire    		       rx4_uni_CLP        ;
wire    [2:0]	       rx4_uni_PT         ;
wire    [7:0]	       rx4_uni_HEC        ;
wire    [8*48-1:0]	   rx4_uni_Payload    ;


utopia1_atm_rx atm_rx4(
                       .clk            ( clk                ),
					   .rst_n          ( rst_n              ),

                       .soc            ( rx4_soc            ),
					   .data           ( rx4_data           ),
					   .clav           ( rx4_clav           ),
					   .en             ( rx4_en             ),

					   .rxreq          ( rx4_rxreq          ),
					   .rxack          ( rx4_rxack          ),
					   .uni_GFC        ( rx4_uni_GFC        ),
					   .uni_VPI        ( rx4_uni_VPI        ),
					   .uni_VCI        ( rx4_uni_VCI        ),
					   .uni_CLP        ( rx4_uni_CLP        ),
					   .uni_PT         ( rx4_uni_PT         ),
					   .uni_HEC        ( rx4_uni_HEC        ),
					   .uni_Payload    ( rx4_uni_Payload    )

                      );


wire    		       rx5_rxreq          ;
wire    		       rx5_rxack          ;
wire    [3:0]	       rx5_uni_GFC        ;
wire    [7:0]	       rx5_uni_VPI        ;
wire    [15:0]	       rx5_uni_VCI        ;
wire    		       rx5_uni_CLP        ;
wire    [2:0]	       rx5_uni_PT         ;
wire    [7:0]	       rx5_uni_HEC        ;
wire    [8*48-1:0]	   rx5_uni_Payload    ;

utopia1_atm_rx atm_rx5(
                       .clk            ( clk                ),
					   .rst_n          ( rst_n              ),

                       .soc            ( rx5_soc            ),
					   .data           ( rx5_data           ),
					   .clav           ( rx5_clav           ),
					   .en             ( rx5_en             ),

					   .rxreq          ( rx5_rxreq          ),
					   .rxack          ( rx5_rxack          ),
					   .uni_GFC        ( rx5_uni_GFC        ),
					   .uni_VPI        ( rx5_uni_VPI        ),
					   .uni_VCI        ( rx5_uni_VCI        ),
					   .uni_CLP        ( rx5_uni_CLP        ),
					   .uni_PT         ( rx5_uni_PT         ),
					   .uni_HEC        ( rx5_uni_HEC        ),
					   .uni_Payload    ( rx5_uni_Payload    )

                      );

wire    		       rx6_rxreq          ;
wire    		       rx6_rxack          ;
wire    [3:0]	       rx6_uni_GFC        ;
wire    [7:0]	       rx6_uni_VPI        ;
wire    [15:0]	       rx6_uni_VCI        ;
wire    		       rx6_uni_CLP        ;
wire    [2:0]	       rx6_uni_PT         ;
wire    [7:0]	       rx6_uni_HEC        ;
wire    [8*48-1:0]	   rx6_uni_Payload    ;

utopia1_atm_rx atm_rx6(
                       .clk            ( clk                ),
					   .rst_n          ( rst_n              ),

                       .soc            ( rx6_soc            ),
					   .data           ( rx6_data           ),
					   .clav           ( rx6_clav           ),
					   .en             ( rx6_en             ),

					   .rxreq          ( rx6_rxreq          ),
					   .rxack          ( rx6_rxack          ),
					   .uni_GFC        ( rx6_uni_GFC        ),
					   .uni_VPI        ( rx6_uni_VPI        ),
					   .uni_VCI        ( rx6_uni_VCI        ),
					   .uni_CLP        ( rx6_uni_CLP        ),
					   .uni_PT         ( rx6_uni_PT         ),
					   .uni_HEC        ( rx6_uni_HEC        ),
					   .uni_Payload    ( rx6_uni_Payload    )

                      );


wire    		       rx7_rxreq          ;
wire    		       rx7_rxack          ;
wire    [3:0]	       rx7_uni_GFC        ;
wire    [7:0]	       rx7_uni_VPI        ;
wire    [15:0]	       rx7_uni_VCI        ;
wire    		       rx7_uni_CLP        ;
wire    [2:0]	       rx7_uni_PT         ;
wire    [7:0]	       rx7_uni_HEC        ;
wire    [8*48-1:0]	   rx7_uni_Payload    ;

utopia1_atm_rx atm_rx7(
                       .clk            ( clk                ),
					   .rst_n          ( rst_n              ),

                       .soc            ( rx7_soc            ),
					   .data           ( rx7_data           ),
					   .clav           ( rx7_clav           ),
					   .en             ( rx7_en             ),

					   .rxreq          ( rx7_rxreq          ),
					   .rxack          ( rx7_rxack          ),
					   .uni_GFC        ( rx7_uni_GFC        ),
					   .uni_VPI        ( rx7_uni_VPI        ),
					   .uni_VCI        ( rx7_uni_VCI        ),
					   .uni_CLP        ( rx7_uni_CLP        ),
					   .uni_PT         ( rx7_uni_PT         ),
					   .uni_HEC        ( rx7_uni_HEC        ),
					   .uni_Payload    ( rx7_uni_Payload    )

                      );
/////////////////////////////////////////////////////////////////////////


wire                   tx0_txreq              ;
wire                   tx0_txack              ;

wire       [11:0]      tx0_nni_VPI            ;
wire       [15:0]      tx0_nni_VCI            ;
wire                   tx0_nni_CLP            ;
wire       [2:0]       tx0_nni_PT             ;
wire       [7:0]       tx0_nni_HEC            ;
wire       [8*48-1:0]  tx0_nni_Payload        ;

utopia1_atm_tx atm_tx0(
                      .clk                ( clk                    ),
					  .rst_n              ( rst_n                  ),

					  .soc                ( tx0_soc                ),
					  .data               ( tx0_data               ),
					  .en                 ( tx0_en                 ),
					  .clav               ( tx0_clav               ),

					  .txreq              ( tx0_txreq              ),
					  .txack              ( tx0_txack              ),

                      .nni_VPI            ( tx0_nni_VPI            ),
                      .nni_VCI            ( tx0_nni_VCI            ),
                      .nni_CLP            ( tx0_nni_CLP            ),
                      .nni_PT             ( tx0_nni_PT             ),
                      .nni_HEC            ( tx0_nni_HEC            ),
                      .nni_Payload        ( tx0_nni_Payload        )

                      );


wire                   tx1_txreq              ;
wire                   tx1_txack              ;

wire       [11:0]      tx1_nni_VPI            ;
wire       [15:0]      tx1_nni_VCI            ;
wire                   tx1_nni_CLP            ;
wire       [2:0]       tx1_nni_PT             ;
wire       [7:0]       tx1_nni_HEC            ;
wire       [8*48-1:0]  tx1_nni_Payload        ;

utopia1_atm_tx atm_tx1(
                      .clk                ( clk                    ),
					  .rst_n              ( rst_n                  ),

					  .soc                ( tx1_soc                ),
					  .data               ( tx1_data               ),
					  .en                 ( tx1_en                 ),
					  .clav               ( tx1_clav               ),

					  .txreq              ( tx1_txreq              ),
					  .txack              ( tx1_txack              ),

                      .nni_VPI            ( tx1_nni_VPI            ),
                      .nni_VCI            ( tx1_nni_VCI            ),
                      .nni_CLP            ( tx1_nni_CLP            ),
                      .nni_PT             ( tx1_nni_PT             ),
                      .nni_HEC            ( tx1_nni_HEC            ),
                      .nni_Payload        ( tx1_nni_Payload        )

                      );


wire                   tx2_txreq              ;
wire                   tx2_txack              ;

wire       [11:0]      tx2_nni_VPI            ;
wire       [15:0]      tx2_nni_VCI            ;
wire                   tx2_nni_CLP            ;
wire       [2:0]       tx2_nni_PT             ;
wire       [7:0]       tx2_nni_HEC            ;
wire       [8*48-1:0]  tx2_nni_Payload        ;

utopia1_atm_tx atm_tx2(
                      .clk                ( clk                    ),
					  .rst_n              ( rst_n                  ),

					  .soc                ( tx2_soc                ),
					  .data               ( tx2_data               ),
					  .en                 ( tx2_en                 ),
					  .clav               ( tx2_clav               ),

					  .txreq              ( tx2_txreq              ),
					  .txack              ( tx2_txack              ),

                      .nni_VPI            ( tx2_nni_VPI            ),
                      .nni_VCI            ( tx2_nni_VCI            ),
                      .nni_CLP            ( tx2_nni_CLP            ),
                      .nni_PT             ( tx2_nni_PT             ),
                      .nni_HEC            ( tx2_nni_HEC            ),
                      .nni_Payload        ( tx2_nni_Payload        )

                      );


wire                   tx3_txreq              ;
wire                   tx3_txack              ;

wire       [11:0]      tx3_nni_VPI            ;
wire       [15:0]      tx3_nni_VCI            ;
wire                   tx3_nni_CLP            ;
wire       [2:0]       tx3_nni_PT             ;
wire       [7:0]       tx3_nni_HEC            ;
wire       [8*48-1:0]  tx3_nni_Payload        ;

utopia1_atm_tx atm_tx3(
                      .clk                ( clk                    ),
					  .rst_n              ( rst_n                  ),

					  .soc                ( tx3_soc                ),
					  .data               ( tx3_data               ),
					  .en                 ( tx3_en                 ),
					  .clav               ( tx3_clav               ),

					  .txreq              ( tx3_txreq              ),
					  .txack              ( tx3_txack              ),

                      .nni_VPI            ( tx3_nni_VPI            ),
                      .nni_VCI            ( tx3_nni_VCI            ),
                      .nni_CLP            ( tx3_nni_CLP            ),
                      .nni_PT             ( tx3_nni_PT             ),
                      .nni_HEC            ( tx3_nni_HEC            ),
                      .nni_Payload        ( tx3_nni_Payload        )

                      );
/////////////////////////////////////////////////////////////////////////
wire                   tx4_txreq              ;
wire                   tx4_txack              ;

wire       [11:0]      tx4_nni_VPI            ;
wire       [15:0]      tx4_nni_VCI            ;
wire                   tx4_nni_CLP            ;
wire       [2:0]       tx4_nni_PT             ;
wire       [7:0]       tx4_nni_HEC            ;
wire       [8*48-1:0]  tx4_nni_Payload        ;

utopia1_atm_tx atm_tx4(
                      .clk                ( clk                    ),
					  .rst_n              ( rst_n                  ),

					  .soc                ( tx4_soc                ),
					  .data               ( tx4_data               ),
					  .en                 ( tx4_en                 ),
					  .clav               ( tx4_clav               ),

					  .txreq              ( tx4_txreq              ),
					  .txack              ( tx4_txack              ),

                      .nni_VPI            ( tx4_nni_VPI            ),
                      .nni_VCI            ( tx4_nni_VCI            ),
                      .nni_CLP            ( tx4_nni_CLP            ),
                      .nni_PT             ( tx4_nni_PT             ),
                      .nni_HEC            ( tx4_nni_HEC            ),
                      .nni_Payload        ( tx4_nni_Payload        )

                      );


wire                   tx5_txreq              ;
wire                   tx5_txack              ;

wire       [11:0]      tx5_nni_VPI            ;
wire       [15:0]      tx5_nni_VCI            ;
wire                   tx5_nni_CLP            ;
wire       [2:0]       tx5_nni_PT             ;
wire       [7:0]       tx5_nni_HEC            ;
wire       [8*48-1:0]  tx5_nni_Payload        ;

utopia1_atm_tx atm_tx5(
                      .clk                ( clk                    ),
					  .rst_n              ( rst_n                  ),

					  .soc                ( tx5_soc                ),
					  .data               ( tx5_data               ),
					  .en                 ( tx5_en                 ),
					  .clav               ( tx5_clav               ),

					  .txreq              ( tx5_txreq              ),
					  .txack              ( tx5_txack              ),

                      .nni_VPI            ( tx5_nni_VPI            ),
                      .nni_VCI            ( tx5_nni_VCI            ),
                      .nni_CLP            ( tx5_nni_CLP            ),
                      .nni_PT             ( tx5_nni_PT             ),
                      .nni_HEC            ( tx5_nni_HEC            ),
                      .nni_Payload        ( tx5_nni_Payload        )

                      );


wire                   tx6_txreq              ;
wire                   tx6_txack              ;

wire       [11:0]      tx6_nni_VPI            ;
wire       [15:0]      tx6_nni_VCI            ;
wire                   tx6_nni_CLP            ;
wire       [2:0]       tx6_nni_PT             ;
wire       [7:0]       tx6_nni_HEC            ;
wire       [8*48-1:0]  tx6_nni_Payload        ;

utopia1_atm_tx atm_tx6(
                      .clk                ( clk                    ),
					  .rst_n              ( rst_n                  ),

					  .soc                ( tx6_soc                ),
					  .data               ( tx6_data               ),
					  .en                 ( tx6_en                 ),
					  .clav               ( tx6_clav               ),

					  .txreq              ( tx6_txreq              ),
					  .txack              ( tx6_txack              ),

                      .nni_VPI            ( tx6_nni_VPI            ),
                      .nni_VCI            ( tx6_nni_VCI            ),
                      .nni_CLP            ( tx6_nni_CLP            ),
                      .nni_PT             ( tx6_nni_PT             ),
                      .nni_HEC            ( tx6_nni_HEC            ),
                      .nni_Payload        ( tx6_nni_Payload        )

                      );


wire                   tx7_txreq              ;
wire                   tx7_txack              ;

wire       [11:0]      tx7_nni_VPI            ;
wire       [15:0]      tx7_nni_VCI            ;
wire                   tx7_nni_CLP            ;
wire       [2:0]       tx7_nni_PT             ;
wire       [7:0]       tx7_nni_HEC            ;
wire       [8*48-1:0]  tx7_nni_Payload        ;

utopia1_atm_tx atm_tx7(
                      .clk                ( clk                    ),
					  .rst_n              ( rst_n                  ),

					  .soc                ( tx7_soc                ),
					  .data               ( tx7_data               ),
					  .en                 ( tx7_en                 ),
					  .clav               ( tx7_clav               ),

					  .txreq              ( tx7_txreq              ),
					  .txack              ( tx7_txack              ),

                      .nni_VPI            ( tx7_nni_VPI            ),
                      .nni_VCI            ( tx7_nni_VCI            ),
                      .nni_CLP            ( tx7_nni_CLP            ),
                      .nni_PT             ( tx7_nni_PT             ),
                      .nni_HEC            ( tx7_nni_HEC            ),
                      .nni_Payload        ( tx7_nni_Payload        )

                      );
/////////////////////////////////////////////////////////////////////////
wire                  fwd_rden   ;
wire         [7:0]    fwd_addr   ;
wire         [19:0]   fwd_data   ;


FwdLkp     fwdtable  (
                      .clk                ( clk                    ),
				      .rst_n              ( rst_n                  ),

                      .BusMode            ( BusMode                ),
				      .Addr               ( Addr                   ),
				      .Sel                ( Sel                    ),
				      .DataIn             ( DataIn                 ),
				      .Rd_DS              ( Rd_DS                  ),
				      .Wr_RW              ( Wr_RW                  ),
		              .DataOut            ( DataOut                ),
				      .Rdy_Dtack          ( Rdy_Dtack              ),

				      .fwd_rden           ( fwd_rden               ),
				      .fwd_addr           ( fwd_addr               ),
				      .fwd_data           ( fwd_data               )

                      );



/////////////////////////////////////////////////////////////////////////

arbitor       arbit (
			          .clk                ( clk                    ),
			          .rst_n              ( rst_n                  ),

			          .fwd_rden           ( fwd_rden               ),
			          .fwd_addr           ( fwd_addr               ),
			          .fwd_data           ( fwd_data               ),

			          .rx0_rxreq          ( rx0_rxreq              ),
			          .rx0_rxack          ( rx0_rxack              ),
			          .rx0_uni_GFC        ( rx0_uni_GFC            ),
			          .rx0_uni_VPI        ( rx0_uni_VPI            ),
			          .rx0_uni_VCI        ( rx0_uni_VCI            ),
			          .rx0_uni_CLP        ( rx0_uni_CLP            ),
			          .rx0_uni_PT         ( rx0_uni_PT             ),
			          .rx0_uni_HEC        ( rx0_uni_HEC            ),
			          .rx0_uni_Payload    ( rx0_uni_Payload        ),

			          .rx1_rxreq          ( rx1_rxreq              ),
			          .rx1_rxack          ( rx1_rxack              ),
			          .rx1_uni_GFC        ( rx1_uni_GFC            ),
			          .rx1_uni_VPI        ( rx1_uni_VPI            ),
			          .rx1_uni_VCI        ( rx1_uni_VCI            ),
			          .rx1_uni_CLP        ( rx1_uni_CLP            ),
			          .rx1_uni_PT         ( rx1_uni_PT             ),
			          .rx1_uni_HEC        ( rx1_uni_HEC            ),
			          .rx1_uni_Payload    ( rx1_uni_Payload        ),

			          .rx2_rxreq          ( rx2_rxreq              ),
			          .rx2_rxack          ( rx2_rxack              ),
			          .rx2_uni_GFC        ( rx2_uni_GFC            ),
			          .rx2_uni_VPI        ( rx2_uni_VPI            ),
			          .rx2_uni_VCI        ( rx2_uni_VCI            ),
			          .rx2_uni_CLP        ( rx2_uni_CLP            ),
			          .rx2_uni_PT         ( rx2_uni_PT             ),
			          .rx2_uni_HEC        ( rx2_uni_HEC            ),
			          .rx2_uni_Payload    ( rx2_uni_Payload        ),

			          .rx3_rxreq          ( rx3_rxreq              ),
			          .rx3_rxack          ( rx3_rxack              ),
			          .rx3_uni_GFC        ( rx3_uni_GFC            ),
			          .rx3_uni_VPI        ( rx3_uni_VPI            ),
			          .rx3_uni_VCI        ( rx3_uni_VCI            ),
			          .rx3_uni_CLP        ( rx3_uni_CLP            ),
			          .rx3_uni_PT         ( rx3_uni_PT             ),
			          .rx3_uni_HEC        ( rx3_uni_HEC            ),
			          .rx3_uni_Payload    ( rx3_uni_Payload        ),

					  .rx4_rxreq          ( rx4_rxreq              ),
			          .rx4_rxack          ( rx4_rxack              ),
			          .rx4_uni_GFC        ( rx4_uni_GFC            ),
			          .rx4_uni_VPI        ( rx4_uni_VPI            ),
			          .rx4_uni_VCI        ( rx4_uni_VCI            ),
			          .rx4_uni_CLP        ( rx4_uni_CLP            ),
			          .rx4_uni_PT         ( rx4_uni_PT             ),
			          .rx4_uni_HEC        ( rx4_uni_HEC            ),
			          .rx4_uni_Payload    ( rx4_uni_Payload        ),

			          .rx5_rxreq          ( rx5_rxreq              ),
			          .rx5_rxack          ( rx5_rxack              ),
			          .rx5_uni_GFC        ( rx5_uni_GFC            ),
			          .rx5_uni_VPI        ( rx5_uni_VPI            ),
			          .rx5_uni_VCI        ( rx5_uni_VCI            ),
			          .rx5_uni_CLP        ( rx5_uni_CLP            ),
			          .rx5_uni_PT         ( rx5_uni_PT             ),
			          .rx5_uni_HEC        ( rx5_uni_HEC            ),
			          .rx5_uni_Payload    ( rx5_uni_Payload        ),

			          .rx6_rxreq          ( rx6_rxreq              ),
			          .rx6_rxack          ( rx6_rxack              ),
			          .rx6_uni_GFC        ( rx6_uni_GFC            ),
			          .rx6_uni_VPI        ( rx6_uni_VPI            ),
			          .rx6_uni_VCI        ( rx6_uni_VCI            ),
			          .rx6_uni_CLP        ( rx6_uni_CLP            ),
			          .rx6_uni_PT         ( rx6_uni_PT             ),
			          .rx6_uni_HEC        ( rx6_uni_HEC            ),
			          .rx6_uni_Payload    ( rx6_uni_Payload        ),

			          .rx7_rxreq          ( rx7_rxreq              ),
			          .rx7_rxack          ( rx7_rxack              ),
			          .rx7_uni_GFC        ( rx7_uni_GFC            ),
			          .rx7_uni_VPI        ( rx7_uni_VPI            ),
			          .rx7_uni_VCI        ( rx7_uni_VCI            ),
			          .rx7_uni_CLP        ( rx7_uni_CLP            ),
			          .rx7_uni_PT         ( rx7_uni_PT             ),
			          .rx7_uni_HEC        ( rx7_uni_HEC            ),
			          .rx7_uni_Payload    ( rx7_uni_Payload        ),

			          .tx0_txreq          ( tx0_txreq              ),
			          .tx0_txack          ( tx0_txack              ),
			          .tx0_nni_VPI        ( tx0_nni_VPI            ),
			          .tx0_nni_VCI        ( tx0_nni_VCI            ),
			          .tx0_nni_CLP        ( tx0_nni_CLP            ),
			          .tx0_nni_PT         ( tx0_nni_PT             ),
			          .tx0_nni_HEC        ( tx0_nni_HEC            ),
			          .tx0_nni_Payload    ( tx0_nni_Payload        ),


			          .tx1_txreq          ( tx1_txreq              ),
			          .tx1_txack          ( tx1_txack              ),
			          .tx1_nni_VPI        ( tx1_nni_VPI            ),
			          .tx1_nni_VCI        ( tx1_nni_VCI            ),
			          .tx1_nni_CLP        ( tx1_nni_CLP            ),
			          .tx1_nni_PT         ( tx1_nni_PT             ),
			          .tx1_nni_HEC        ( tx1_nni_HEC            ),
			          .tx1_nni_Payload    ( tx1_nni_Payload        ),

			          .tx2_txreq          ( tx2_txreq              ),
			          .tx2_txack          ( tx2_txack              ),
			          .tx2_nni_VPI        ( tx2_nni_VPI            ),
			          .tx2_nni_VCI        ( tx2_nni_VCI            ),
			          .tx2_nni_CLP        ( tx2_nni_CLP            ),
			          .tx2_nni_PT         ( tx2_nni_PT             ),
			          .tx2_nni_HEC        ( tx2_nni_HEC            ),
			          .tx2_nni_Payload    ( tx2_nni_Payload        ),

			          .tx3_txreq          ( tx3_txreq              ),
			          .tx3_txack          ( tx3_txack              ),
			          .tx3_nni_VPI        ( tx3_nni_VPI            ),
			          .tx3_nni_VCI        ( tx3_nni_VCI            ),
			          .tx3_nni_CLP        ( tx3_nni_CLP            ),
			          .tx3_nni_PT         ( tx3_nni_PT             ),
			          .tx3_nni_HEC        ( tx3_nni_HEC            ),
			          .tx3_nni_Payload    ( tx3_nni_Payload        ),

					  .tx4_txreq          ( tx4_txreq              ),
			          .tx4_txack          ( tx4_txack              ),
			          .tx4_nni_VPI        ( tx4_nni_VPI            ),
			          .tx4_nni_VCI        ( tx4_nni_VCI            ),
			          .tx4_nni_CLP        ( tx4_nni_CLP            ),
			          .tx4_nni_PT         ( tx4_nni_PT             ),
			          .tx4_nni_HEC        ( tx4_nni_HEC            ),
			          .tx4_nni_Payload    ( tx4_nni_Payload        ),


			          .tx5_txreq          ( tx5_txreq              ),
			          .tx5_txack          ( tx5_txack              ),
			          .tx5_nni_VPI        ( tx5_nni_VPI            ),
			          .tx5_nni_VCI        ( tx5_nni_VCI            ),
			          .tx5_nni_CLP        ( tx5_nni_CLP            ),
			          .tx5_nni_PT         ( tx5_nni_PT             ),
			          .tx5_nni_HEC        ( tx5_nni_HEC            ),
			          .tx5_nni_Payload    ( tx5_nni_Payload        ),

			          .tx6_txreq          ( tx6_txreq              ),
			          .tx6_txack          ( tx6_txack              ),
			          .tx6_nni_VPI        ( tx6_nni_VPI            ),
			          .tx6_nni_VCI        ( tx6_nni_VCI            ),
			          .tx6_nni_CLP        ( tx6_nni_CLP            ),
			          .tx6_nni_PT         ( tx6_nni_PT             ),
			          .tx6_nni_HEC        ( tx6_nni_HEC            ),
			          .tx6_nni_Payload    ( tx6_nni_Payload        ),

			          .tx7_txreq          ( tx7_txreq              ),
			          .tx7_txack          ( tx7_txack              ),
			          .tx7_nni_VPI        ( tx7_nni_VPI            ),
			          .tx7_nni_VCI        ( tx7_nni_VCI            ),
			          .tx7_nni_CLP        ( tx7_nni_CLP            ),
			          .tx7_nni_PT         ( tx7_nni_PT             ),
			          .tx7_nni_HEC        ( tx7_nni_HEC            ),
			          .tx7_nni_Payload    ( tx7_nni_Payload        )
              );


endmodule
