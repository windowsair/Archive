`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV

//`include "atm_cell.sv"
`include "color_helper.svh"

class Expect_cells;
  NNI_cell q[$];
  int iexpect, iactual, idrop;
endclass : Expect_cells


class Scoreboard;

  Config cfg;
  Expect_cells expect_cells[];
  NNI_cell cellq[$];
  int iexpect, iactual, idrop;

  int max_concurrent_;
  int port_concurrent_[];
  //   By "concurrency" we mean the number of packets for which data has been sent, but not yet received.
  //   In fact there may be various delays in the reception of packets. As an example, ARQ can be considered
  // as a case of delay

  extern function new(Config cfg);
  extern virtual function void wrap_up();
  extern function void save_expected(UNI_cell ucell);
  extern function void check_actual(input NNI_cell ncell, input int portn, bit isValid);
  extern function void display(string prefix = "");

endclass : Scoreboard


//---------------------------------------------------------------------------
function Scoreboard::new(Config cfg);
  this.cfg = cfg;
  expect_cells = new[cfg.numTx];
  foreach (expect_cells[i]) expect_cells[i] = new();

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

  $display("@%0t: Scb save: VPI=%0x, Forward=%b", $time, CellFwd.VPI, CellFwd.FWD);

  isValid = CellFwd.FWD != 8'b0000_0000;

  if (isValid == 0) begin
    u2ncell.setDrop();
    idrop++;
  end


  // Now we also save the packets with fwd == 0,
  // and later we will check whether they are discarded or not
  for (int i = 0; i < cfg.numTx; i++) begin
    if (CellFwd.FWD[i]) begin
      expect_cells[i].q.push_back(u2ncell);  // Save cell in this forward queue
      port_concurrent_[i]++;

      expect_cells[i].iexpect++;
      iexpect++;
      if (port_concurrent_[i] > max_concurrent_) max_concurrent_ = port_concurrent_[i];
    end else if (isValid == 0) begin
      expect_cells[i].q.push_back(u2ncell);  // Save cell in this forward queue
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

  //ncell.display($psprintf("@%0t: Scb check: ", $time));

  if (expect_cells[portn].q.size() == 0) begin
    $display("@%0t: ERROR: %m cell not found because scoreboard for TX%0d empty", $time, portn);
    ncell.display("Not Found: ");
    return;
  end

  if (isValid) begin
    expect_cells[portn].iactual++;
    iactual++;
  end


  foreach (expect_cells[portn].q[i]) begin
    if (expect_cells[portn].q[i].compare(ncell)) begin
      //$display("@%0t: Match found for cell", $time);
      //$display("@%0t: Packet %m Successfully Compare !!!!", $time,ncell);
      if (isValid) begin
        $display("@%0t: Packet Successfully Compare !!!!", $time);
        expect_cells[portn].q.delete(i);

        port_concurrent_[portn]--;
        return;
      end else begin
        $display("@%0t: [ERROR] Packets not dropped correctly!!!", $time);
        $finish;
      end
    end
  end

  //$display("@%0t: ERROR: %m cell not found", $time,ncell);
  //$display("@%0t: Packet %m Compare Fail !!!", $time,ncell);
  $display("@%0t:[ERROR] Packet Compare Fail !!!", $time);
  //$display("@%0t: Packet %d Cell is %m !!!", $time,iactual,ncell);
  ncell.display("Not Found: ");
  $finish;


endfunction : check_actual


//---------------------------------------------------------------------------
// Print end of simulation report
//---------------------------------------------------------------------------
function void Scoreboard::wrap_up();
  // Look for leftover cells
  foreach (expect_cells[i]) begin
    if (expect_cells[i].q.size()) begin
      $display("@%0t: %m cells remaining in Tx[%0d] scoreboard at end of test", $time, i);
      this.display("Unclaimed: ");
    end
  end

  `RED_START
  $display(
      "@%0t: %m %0d expected cells, %0d cells dropped, %0d actual cells received, Maximum number of concurrent connections: %d"
          , $time, iexpect, idrop, iactual, max_concurrent_);
  `RED_END


endfunction : wrap_up


//---------------------------------------------------------------------------
// Print the contents of the scoreboard, mainly for debugging
//---------------------------------------------------------------------------
function void Scoreboard::display(string prefix);
  $display("@%0t: %m so far %0d expected cells, %0d actual cells received", $time, iexpect,
           iactual);
  foreach (expect_cells[i]) begin
    $display("Tx[%0d]: exp=%0d, act=%0d", i, expect_cells[i].iexpect, expect_cells[i].iactual);
    foreach (expect_cells[i].q[j])
      expect_cells[i].q[j].display($psprintf("%sScoreboard: Tx%0d: ", prefix, i));
  end
endfunction : display

`endif
