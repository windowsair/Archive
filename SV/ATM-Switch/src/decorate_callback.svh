`ifndef __DECORATE_CALLBACK_SVH__
`define __DECORATE_CALLBACK_SVH__

class Decorate_callback #(
    type Tclass,
    type Thandle
);
  virtual task pre_task(input Tclass decorateCls, input Thandle handle);
  endtask : pre_task

  virtual task post_task(input Tclass decorateCls, input Thandle handle);
  endtask : post_task
endclass : Decorate_callback


`endif
