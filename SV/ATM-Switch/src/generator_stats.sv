`ifndef __GENERATOR_STATS__SV__
`define __GENERATOR_STATS__SV__

class Generator_stats;
  semaphore sem_ = null;

  event event_triggerAll_;

  function new(input semaphore sem, input event triggerAll);
    this.sem_ = sem;
    this.event_triggerAll_ = triggerAll;
  endfunction : new

  task run();
    forever begin
      sem_.get(8);
      ->event_triggerAll_;
      // sem_.put(1); // should not put back cuz only this thread will get it
    end
  endtask : run

endclass : Generator_stats



`endif
