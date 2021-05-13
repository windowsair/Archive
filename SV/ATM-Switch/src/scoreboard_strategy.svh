`ifndef __SCOREBOARD_STRATEGY_SV__
`define __SCOREBOARD_STRATEGY_SV__


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


`endif
