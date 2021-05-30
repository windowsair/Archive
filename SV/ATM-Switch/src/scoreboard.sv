`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV

//`include "atm_cell.sv"
`include "color_helper.svh"

`include "scoreboard_strategy.svh"




class Expect_cells;
  NNI_cell q[$];
  int iexpect, iactual, idrop;
endclass : Expect_cells


class Scoreboard;

  Config cfg;
  Expect_cells expect_cells_[];
  NNI_cell cellq[$];  // no use ?
  int iexpect_, iactual_, idrop_;

  int max_concurrent_;
  int port_concurrent_[];
  // By "concurrency" we mean the number of packets for which data has been sent, but not yet received.
  // In fact there may be various delays in the reception of packets. As an example, ARQ can be considered
  // as a case of delay

  Scoreboard_strategy check_method_;

  extern function new(Config cfg, Scoreboard_strategy check_method);
  extern virtual function void wrap_up();
  extern function void save_expected(UNI_cell ucell);
  extern function void check_actual(input NNI_cell ncell, input int portn, bit isValid);
  extern function void display(string prefix = "");

endclass : Scoreboard


//---------------------------------------------------------------------------
function Scoreboard::new(Config cfg, Scoreboard_strategy check_method);
  this.check_method_ = check_method;

  this.cfg = cfg;
  expect_cells_ = new[cfg.numTx];
  foreach (expect_cells_[i]) expect_cells_[i] = new();

  this.max_concurrent_ = 0;
  this.port_concurrent_ = new[cfg.numTx];
endfunction  // Scoreboard


//---------------------------------------------------------------------------
function void Scoreboard::save_expected(UNI_cell ucell);

  CellCfgType CellFwd = env.cpu.lookup[ucell.getVPI()];
  NNI_cell u2ncell;
  bit isValid;
  u2ncell = new();
  u2ncell = ucell.to_NNI(CellFwd.VPI);

  $display("@%0t: Scb save: VPI=%0x, Forward=%b, round=%d, Txport=%d", $time, CellFwd.VPI,
           CellFwd.FWD, u2ncell.extraData_.TxPort_, u2ncell.extraData_.round_);
  u2ncell.display("NNI save:");

  isValid = CellFwd.FWD != 8'b0000_0000;

  if (isValid == 0) begin
    u2ncell.setDrop();
    idrop_++;
  end


  // Now we also save the packets with fwd == 0,
  // and later we will check whether they are discarded or not
  for (int i = 0; i < cfg.numTx; i++) begin
    if (CellFwd.FWD[i]) begin
      expect_cells_[i].q.push_back(u2ncell);  // Save cell in this forward queue
      port_concurrent_[i]++;

      expect_cells_[i].iexpect++;
      iexpect_++;
      if (port_concurrent_[i] > max_concurrent_) max_concurrent_ = port_concurrent_[i];
    end else if (isValid == 0) begin
      expect_cells_[i].q.push_back(u2ncell);  // Save cell in this forward queue
    end
  end

endfunction : save_expected


//-----------------------------------------------------------------------------
/**
 * @brief Check if the current package is properly handled
 *
 * @param ncell
 * @param portn
 * @param isValid 0: this packet should be drop
 *                1: this packet should be receive
 */
function void Scoreboard::check_actual(input NNI_cell ncell, input int portn, bit isValid);
  this.check_method_.check(this, ncell, portn, isValid);
endfunction : check_actual


//---------------------------------------------------------------------------
// Print end of simulation report
//---------------------------------------------------------------------------
function void Scoreboard::wrap_up();
  // Look for leftover cells
  int sz;
  CellCfgType CellCfg;

  foreach (expect_cells_[i]) begin
    sz = expect_cells_[i].q.size();
    foreach (expect_cells_[i].q[j]) begin
      CellCfg = top.squat.fwdtable.lut.Mem[expect_cells_[i].q[j].getVPI()];
      if (CellCfg.FWD == 8'b0000_0000) begin
        sz--;
      end
    end

    if (sz) begin
      $display("@%0t: %m cells remaining in Tx[%0d] scoreboard at end of test", $time, i);
      this.display("Unclaimed: ");
    end
  end

  `BLUE_START
  $display(
      "@%0t: %m %0d expected cells, %0d cells dropped, %0d actual cells received, Maximum number of concurrent connections: %d"
          , $time, iexpect_, idrop_, iactual_, max_concurrent_);
  `BLUE_END


endfunction : wrap_up


//---------------------------------------------------------------------------
// Print the contents of the scoreboard, mainly for debugging
//---------------------------------------------------------------------------
function void Scoreboard::display(string prefix);
  $display("@%0t: %m so far %0d expected cells, %0d actual cells received", $time, iexpect_,
           iactual_);
  foreach (expect_cells_[i]) begin
    $display("Tx[%0d]: exp=%0d, act=%0d", i, expect_cells_[i].iexpect, expect_cells_[i].iactual);
    foreach (expect_cells_[i].q[j])
      expect_cells_[i].q[j].display($psprintf("%sScoreboard: Tx%0d: ", prefix, i));
  end
endfunction : display

`endif
