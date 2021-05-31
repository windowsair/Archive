`ifndef __DECORATE_SV__
`define __DECORATE_SV__

`include "decorate_callback.svh"



// Call scoreboard from Driver using callbacks
class Scb_Driver_cbs extends Decorate_callback #(Driver, UNI_cell);
  Scoreboard scb;

  function new(Scoreboard scb);
    this.scb = scb;
  endfunction : new

  // Send received cell to scoreboard
  virtual task pre_task(input Driver drv, input UNI_cell ucell);
    scb.save_expected(ucell);
  endtask : pre_task
endclass : Scb_Driver_cbs


// Verfiy Arbitor, should be add after Scb_Driver_cbs
class Arbitor_Driver_cbs extends Decorate_callback #(Driver, UNI_cell);
  local event wait_event_;
  local semaphore produce_done_sem_;

  function new(event wait_event, semaphore sem);
    this.wait_event_ = wait_event;
    this.produce_done_sem_ = sem;
  endfunction : new

  // Wait for all packages to be ready
  virtual task pre_task(input Driver drv, input UNI_cell ucell);
    produce_done_sem_.put(1);
    $display("wait start");
    @wait_event_;
    $display("wait done");
  endtask : pre_task
endclass : Arbitor_Driver_cbs



// Call scoreboard from Monitor using callbacks
class Scb_Monitor_cbs extends Decorate_callback #(Monitor, NNI_cell);
  Scoreboard scb;

  function new(Scoreboard scb);
    this.scb = scb;
  endfunction : new

  // Send received cell to scoreboard
  virtual task post_task(input Monitor mon, input NNI_cell ncell);
    CellCfgType CellCfg = top.squat.fwdtable.lut.Mem[ncell.getVPI()];
    bit isValid;
    isValid = CellCfg.FWD != 8'b0000_0000;
    scb.check_actual(ncell, mon.PortID, isValid);
  endtask : post_task
endclass : Scb_Monitor_cbs



// Call coverage from Monitor using callbacks
class Cov_Monitor_cbs extends Decorate_callback #(Monitor, NNI_cell);
  Coverage cov;

  function new(Coverage cov);
    this.cov = cov;
  endfunction : new

  // Send received cell to coverage
  virtual task post_task(input Monitor mon, input NNI_cell ncell);
    CellCfgType CellCfg = top.squat.fwdtable.lut.Mem[ncell.getVPI()];
    cov.sample(mon.PortID, CellCfg.FWD);
  endtask : post_task
endclass : Cov_Monitor_cbs



`endif