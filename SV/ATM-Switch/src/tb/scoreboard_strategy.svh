`ifndef __SCOREBOARD_STRATEGY_SV__
`define __SCOREBOARD_STRATEGY_SV__

`include "color_helper.svh"

typedef class Scoreboard;

virtual class Scoreboard_strategy;
  pure virtual function void check(Scoreboard handle, input NNI_cell ncell, input int portn,
                                   bit isValid);
endclass : Scoreboard_strategy


class Normal_check extends Scoreboard_strategy;
  static function Scoreboard_strategy getInstance();
    Normal_check instance = new();
    return instance;
  endfunction : getInstance

  virtual function void check(Scoreboard handle, input NNI_cell ncell, input int portn,
                              bit isValid);
    //ncell.display($psprintf("@%0t: Scb check: ", $time));

    if (handle.expect_cells_[portn].q.size() == 0) begin
      $display("@%0t: ERROR: %m cell not found because scoreboard for TX%0d empty", $time, portn);
      ncell.display("Not Found: ");
      return;
    end

    if (isValid) begin
      handle.expect_cells_[portn].iactual++;
      handle.iactual_++;
    end


    foreach (handle.expect_cells_[portn].q[i]) begin
      if (handle.expect_cells_[portn].q[i].compare(ncell)) begin
        //$display("@%0t: Match found for cell", $time);
        //$display("@%0t: Packet %m Successfully Compare !!!!", $time,ncell);
        if (isValid) begin
          $display("@%0t: Packet Successfully Compare !!!!", $time);
          handle.expect_cells_[portn].q.delete(i);

          handle.port_concurrent_[portn]--;
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
    $display("[ERROR] Maybe this packet is on a port it shouldn't be on..");
    //$display("@%0t: Packet %d Cell is %m !!!", $time,iactual,ncell);
    ncell.display("Not Found: ");
    $finish;
  endfunction : check
endclass : Normal_check


class Arbitor_check extends Scoreboard_strategy;
  static function Scoreboard_strategy getInstance();
    Arbitor_check instance = new();
    return instance;
  endfunction : getInstance

  function void check(Scoreboard handle, input NNI_cell ncell, input int portn,
                      bit isValid);

    Scoreboard_strategy remain_check = Normal_check::getInstance();

    // int portAcutal = ncell.extraData_.TxPort_; // opps, we can not get any info from received cell

    int portExpect = 8;
    int roundMin = 2147483647; // INT32_MAX

    NNI_cell tmpCell;
    NNI_cell expectCell = null;

    // find expect port.
    if (handle.expect_cells_[portn].q.size() == 0) begin
      $display("@%0t: ERROR: %m cell not found because scoreboard for TX%0d empty", $time, portn);
      ncell.display("Not Found: ");
      return;
    end

    foreach (handle.expect_cells_[portn].q[i]) begin
      tmpCell = handle.expect_cells_[portn].q[i];
      $display("[DEBUG] port : %d round: %d", tmpCell.extraData_.TxPort_,
      tmpCell.extraData_.round_);

      if(tmpCell.extraData_.TxPort_ < portExpect) begin
        roundMin = tmpCell.extraData_.round_;
        portExpect = tmpCell.extraData_.TxPort_;
        expectCell = tmpCell;
      end
      else if (tmpCell.extraData_.TxPort_ == portExpect && tmpCell.extraData_.round_ < roundMin) begin
        roundMin = tmpCell.extraData_.round_;
        expectCell = tmpCell;
      end
    end


    $display("find port %d, round %d", portExpect, roundMin);

    if (expectCell == null || !expectCell.compare(ncell)) begin
      `RED_START
      $display("[ERROR] Arbitor check failed.");

      expectCell.display("expect necll:");
      ncell.display("raw ncell:");
      `RED_END
      $finish;
    end

    $display("Arbitor check success.");

    // delete it from queue
    remain_check.check(handle, ncell, portn, isValid);

  endfunction : check
endclass : Arbitor_check


`endif
