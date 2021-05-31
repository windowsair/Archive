`ifndef ENVIRONMENT__SV
`define ENVIRONMENT__SV


`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "config.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "cpu_driver.sv"
`include "decorate.sv"
`include "generator_stats.sv"


class Environment_arbitor;

  UNI_generator gen[];
  mailbox gen2drv[];
  event drv2gen[];
  event event_genAllDone[];

  event arbitorEvent;
  semaphore arbitorSem;
  Generator_stats genStats;

  Driver drv[];
  Monitor mon[];

  Config cfg;
  Scoreboard scb;
  Coverage cov;
  virtual Utopia.TB_Rx Rx[];
  virtual Utopia.TB_Tx Tx[];
  int numRx, numTx;
  vCPU_T mif;
  CPU_driver cpu;

  extern function new(input vUtopiaRx Rx[], input vUtopiaTx Tx[], input int numRx, numTx,
                      input vCPU_T mif);
  extern virtual function void gen_cfg();
  extern virtual function void build();
  extern virtual task run();
  extern virtual function void wrap_up();
  extern virtual task reset();
  extern virtual task wait_for_end();

endclass : Environment_arbitor


//---------------------------------------------------------------------------
// Construct an environment instance
//---------------------------------------------------------------------------
function Environment_arbitor::new(input vUtopiaRx Rx[], input vUtopiaTx Tx[], input int numRx, numTx,
                          input vCPU_T mif);
  this.Rx = new[Rx.size()];
  foreach (Rx[i]) this.Rx[i] = Rx[i];
  this.Tx = new[Tx.size()];
  foreach (Tx[i]) this.Tx[i] = Tx[i];
  this.numRx = numRx;
  this.numTx = numTx;
  this.mif = mif;

  cfg = new(numRx, numTx);

  if ($test$plusargs("ntb_random_seed")) begin
    int seed;
    $value$plusargs("ntb_random_seed=%d", seed);
    $display("Simulation run with random seed=%0d", seed);
  end else $display("Simulation run with default random seed");

endfunction : new


//---------------------------------------------------------------------------
// Randomize the configuration descriptor
//---------------------------------------------------------------------------
function void Environment_arbitor::gen_cfg();
  assert (cfg.randomize());
  cfg.display();
endfunction : gen_cfg


//---------------------------------------------------------------------------
// Build the environment objects for this test
// Note that objects are built for every channel, even if they are not in use
// This prevents the bug when you use a null handle
//---------------------------------------------------------------------------
function void Environment_arbitor::build();
  //cpu = new(mif, cfg);
  cpu = new(mif, 0); // do not generate FWD = 0

  gen = new[numRx];
  drv = new[numRx];
  gen2drv = new[numRx];
  drv2gen = new[numRx];
  event_genAllDone = new[numRx];


  arbitorSem = new(0);

  genStats = new(arbitorEvent, arbitorSem);

  scb = new(cfg, Arbitor_check::getInstance()); // new (cfg, new Normal_check())   // fail....
  cov = new();

  foreach (gen[i]) begin
    gen2drv[i] = new();
    gen[i] = new(gen2drv[i], drv2gen[i], 1, i, event_genAllDone[i]);
    drv[i] = new(gen2drv[i], drv2gen[i], Rx[i], i);
  end

  mon = new[numTx];
  foreach (mon[i]) mon[i] = new(Tx[i], i);

  // Connect the scoreboard with callbacks
  begin
    Scb_Driver_cbs sdc = new(scb);
    Arbitor_Driver_cbs adc = new(arbitorEvent, arbitorSem);

    Scb_Monitor_cbs smc = new(scb);

    foreach (drv[i]) drv[i].addDecorate(sdc);  // Add scb to every driver
    foreach (drv[i]) drv[i].addDecorate(adc);  // should be add after sdc

    foreach (mon[i]) mon[i].addDecorate(smc);  // Add scb to every monitor
  end

  // Connect coverage with callbacks
  begin
    Cov_Monitor_cbs smc = new(cov);
    foreach (mon[i]) mon[i].addDecorate(smc);  // Add cov to every monitor
  end

endfunction : build


//---------------------------------------------------------------------------
// Start the transactors (generators, drivers, monitors) in the environment
// Channels that are not in use don't get started
//---------------------------------------------------------------------------
task Environment_arbitor::run();
  int num_gen_running;

  // Let the CPU interface do its initialization before anyone else starts
  cpu.run();

  num_gen_running = numRx;

  fork
    genStats.run();
  join_none

  // For each input RX channel, start generator and driver
  foreach (gen[i]) begin
    int j = i;  // Automatic variable to hold index in spawned threads
    fork
      begin
        gen[j].run();  // Wait for generator to finish
      end
      drv[j].run();
    join_none
  end

  // For each output TX channel, start monitor
  foreach (mon[i]) begin
    int j = i;  // Automatic variable to hold index in spawned threads
    fork
      mon[j].run();
    join_none
  end

  wait_for_end();

endtask : run


//---------------------------------------------------------------------------
// Any post-run cleanup / reporting
//---------------------------------------------------------------------------
function void Environment_arbitor::wrap_up();
  $display("@%0t: End of simulation, %0d error%s, %0d warning%s", $time, cfg.nErrors,
           cfg.nErrors == 1 ? "" : "s", cfg.nWarnings, cfg.nWarnings == 1 ? "" : "s");
  scb.wrap_up;

endfunction : wrap_up


//---------------------------------------------------------------------------
// reset
//---------------------------------------------------------------------------

task Environment_arbitor::reset();

  mif.BusMode <= 1'b0;
  mif.Addr <= '0;
  mif.Sel <= '1;
  mif.DataIn <= '0;
  mif.Rd_DS <= '1;
  mif.Wr_RW <= '1;

  foreach (Rx[i]) begin
    Rx[i].cbr.data <= 0;
    Rx[i].cbr.soc <= 0;
    Rx[i].cbr.clav <= 0;
  end

  foreach (Tx[i]) begin
    Tx[i].cbt.clav <= 0;
  end

  @(posedge rst_n);

  repeat (15) @(posedge clk);

  mif.BusMode <= 1'b1;

  foreach (Rx[i]) begin
    Rx[i].cbr.clav <= 1;
  end

  foreach (Tx[i]) begin
    Tx[i].cbt.clav <= 1;
  end

endtask : reset


//---------------------------------------------------------------------------
// wait_for_end
//---------------------------------------------------------------------------
`define WAIT_FOR_PORT_TRIGGERED(port)                                          \
   begin                                                                       \
      wait((cfg.cells_per_chan[port] == 0) || (event_genAllDone[port].triggered)); \
      $display("###### Port Number %d is triggered ###############", port);    \
   end



task Environment_arbitor::wait_for_end();

  fork : timeout_block

    `WAIT_FOR_PORT_TRIGGERED(0)
    `WAIT_FOR_PORT_TRIGGERED(1)
    `WAIT_FOR_PORT_TRIGGERED(2)
    `WAIT_FOR_PORT_TRIGGERED(3)
    `WAIT_FOR_PORT_TRIGGERED(4)
    `WAIT_FOR_PORT_TRIGGERED(5)
    `WAIT_FOR_PORT_TRIGGERED(6)
    `WAIT_FOR_PORT_TRIGGERED(7)

    // TODO: Longer waiting time
    // begin
    //   repeat (1_000_000) @(Rx[0].cbr);
    //   $display("@%0t: %m ERROR: Timeout while waiting for generators to finish", $time);
    // end
  join
  disable timeout_block;

  repeat (5000) @(clk);

endtask : wait_for_end


`endif  // ENVIRONMENT_ARBITOR_SV
