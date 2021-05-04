`timescale 1ns / 1ns

//`define SYNTHESIS	// conditional compilation flag for synthesis
//`define FWDALL		// conditional compilation flag to forward cells

`define TxPorts 4  // set number of transmit ports
`define RxPorts 4  // set number of receive ports


module top;

  parameter int NumRx = `RxPorts;
  parameter int NumTx = `TxPorts;

  logic rst_n, clk;

  // System Clock and Reset
  initial begin
    rst_n = 1;
    #500 rst_n = 0;
    #500 rst_n = 1;
  end

  initial begin
    clk = 0;
    forever #5ns clk = ~clk;
  end


  Utopia rx[0:NumRx-1] (clk);  // NumRx x Level 1 Utopia Rx Interface
  Utopia tx[0:NumTx-1] (clk);  // NumTx x Level 1 Utopia Tx Interface
  cpu_ifc mif ();  // Intel-style Utopia parallel management interface

  squat squat (
      .clk  (clk),
      .rst_n(rst_n),

      .BusMode  (mif.BusMode),
      .Addr     (mif.Addr),
      .Sel      (mif.Sel),
      .DataIn   (mif.DataIn),
      .Rd_DS    (mif.Rd_DS),
      .Wr_RW    (mif.Wr_RW),
      .DataOut  (mif.DataOut),
      .Rdy_Dtack(mif.Rdy_Dtack),

`define TRANSFER_PORT_CONNECT(PORT, DIR)             \
      .``DIR````PORT``_soc (``DIR``[``PORT``].soc),  \
      .``DIR````PORT``_data(``DIR``[``PORT``].data), \
      .``DIR````PORT``_clav(``DIR``[``PORT``].clav), \
      .``DIR````PORT``_en  (``DIR``[``PORT``].en)



      `TRANSFER_PORT_CONNECT(0, rx),
      `TRANSFER_PORT_CONNECT(1, rx),
      `TRANSFER_PORT_CONNECT(2, rx),
      `TRANSFER_PORT_CONNECT(3, rx),

      `TRANSFER_PORT_CONNECT(0, tx),
      `TRANSFER_PORT_CONNECT(1, tx),
      `TRANSFER_PORT_CONNECT(2, tx),
      `TRANSFER_PORT_CONNECT(3, tx)
  );  // DUT

  test #(NumRx, NumTx) t1 (
      rx,
      tx,
      mif,
      clk,
      rst_n
  );  // Test


  initial begin
    $vcdpluson;
    $timeformat(-9, 1, "ns", 10);
    //$fsdbDumpvars;
  end

endmodule : top
