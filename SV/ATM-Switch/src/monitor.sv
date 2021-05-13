`ifndef MONITOR__SV
`define MONITOR__SV

//`include "atm_cell.sv"
`include "decorate_callback.svh"

typedef class Monitor;


class Monitor;

  vUtopiaTx Tx;  // Virtual interface with output of DUT
  local Decorate_callback #(Monitor, NNI_cell) cbsq_[$];  // Queue of callback objects
  int PortID;
  bit delay_;

  extern function new(input vUtopiaTx Tx, input int PortID, input bit isDelay=1);
  extern function addDecorate(Decorate_callback#(Monitor, NNI_cell) cb);

  extern task run();
  extern task receive(output NNI_cell ncell);
endclass : Monitor


//---------------------------------------------------------------------------
// new(): construct an object
//---------------------------------------------------------------------------
function Monitor::new(input vUtopiaTx Tx, input int PortID, input bit isDelay=1);
  this.Tx = Tx;
  this.PortID = PortID;
  this.delay_ = isDelay;
endfunction : new


function Monitor::addDecorate(Decorate_callback#(Monitor, NNI_cell) cb);
  this.cbsq_.push_back(cb);
endfunction : addDecorate


//---------------------------------------------------------------------------
// run(): Run the monitor
//---------------------------------------------------------------------------
task Monitor::run();
  NNI_cell ncell;
  int delayClk;
  forever begin
    delayClk = $urandom_range(100, 1000);
    $display("DELAY: %d", delayClk);
    //if (delay_)
      //#(delayClk);
    receive(ncell);
    foreach (cbsq_[i]) cbsq_[i].post_task(this, ncell);  // Post-receive callback
  end
endtask : run


//---------------------------------------------------------------------------
// receive(): Read a cell from the DUT output, pack it into a NNI cell
//---------------------------------------------------------------------------
task Monitor::receive(output NNI_cell ncell);

  ATMCellType pkt_cmp;

  int j = 0;
  Tx.cbt.clav <= 1;

  wait(Tx.cbt.en);
  wait(Tx.cbt.soc);
  while (j <= 52) begin
    if (Tx.cbt.en == 1'b1) begin
      pkt_cmp.Mem[j] = Tx.cbt.data;
      @(Tx.cbt);
      j = j + 1;
    end else begin
      @(Tx.cbt);
    end
  end
  j = 0;

  ncell = new();
  ncell.unpack(pkt_cmp);

endtask : receive

`endif  // MONITOR__SV
