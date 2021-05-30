`ifndef __GENERATOR_STATS__SV__
`define __GENERATOR_STATS__SV__

// Need to be run indepenedently
class Generator_stats;
  semaphore sem_ = null;

  event event_triggerAll_;

  function new(event triggerAll, semaphore sem);
    this.sem_ = sem;
    this.event_triggerAll_ = triggerAll;
  endfunction : new

  virtual task run();
    forever begin
      sem_.get(8);
      $display("[INFO] generator trigger all!");
      ->event_triggerAll_;
      // sem_.put(1); // should not put back cuz only this thread will get it
    end
  endtask : run

endclass : Generator_stats



`endif
