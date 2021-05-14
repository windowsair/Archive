`ifndef GENERATOR__SV
`define GENERATOR__SV

//`include "atm_cell.sv"


class VPI_generator;
  rand bit [7:0] VPI_;
  static int count_ = `TxPorts;

  extern function new();
  extern function bit [7:0] getVPI();
endclass : VPI_generator


function VPI_generator::new();
  assert(this.randomize());
endfunction : new

function bit [7:0] VPI_generator::getVPI();
  count_--;
  if (count_ == 0) begin
    this.randomize();
    count_ = `TxPorts;
  end
endfunction : getVPI

class UNI_generator;
  UNI_cell blueprint;  // Blueprint for generator
  VPI_generator VPIFactory_;
  bit useSyncVPI_;

  // TODO: add semaphore, should we use ref?


  mailbox gen2drv;  // Mailbox to driver for cells
  event drv2gen;  // Event from driver when done with cell
  int nCells;  // Number of cells for this generator to create
  int PortID;  // Which Rx port are we generating?
  event gen_done;

  function new(input mailbox gen2drv, input event drv2gen, input int nCells, input int PortID,
  ref event event_gen_done, input bit useSyncVPI=0);
    this.gen2drv = gen2drv;
    this.drv2gen = drv2gen;
    this.nCells = nCells;
    this.PortID = PortID;
    this.gen_done = event_gen_done;
    this.useSyncVPI_ = useSyncVPI;
    blueprint = new();
    VPIFactory_ = new();


  endfunction : new


  virtual function UNI_cell generate_uni();
    UNI_cell ucell;

    assert(blueprint.randomize());
    if (useSyncVPI_) begin
      blueprint.setVPI(VPIFactory_.getVPI());
    end

    blueprint.extraData_.TxPort_ = PortID;

    $cast(ucell, blueprint.copy());
    ucell.display($psprintf("@%0t: Gen%0d: ", $time, PortID));

    return ucell;

  endfunction : generate_uni

  virtual task run();
    UNI_cell ucell;

    repeat (nCells) begin
      ucell = generate_uni();
      gen2drv.put(ucell);
      @drv2gen;  // Wait for driver to finish with it
    end
    ->gen_done;

  endtask : run

endclass : UNI_generator

`endif  // GENERATOR__SV
