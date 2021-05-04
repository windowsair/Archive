
`include "definitions.svh"
`include "atm_cell.sv"

program automatic test #(
    parameter int NumRx = 4,
    parameter int NumTx = 4
) (
          Utopia.TB_Rx Rx [0:NumRx-1],
          Utopia.TB_Tx Tx [0:NumTx-1],
          cpu_ifc.Test mif,
    input logic        clk,
    rst_n
);

  ///////////////////////////////////////////////////////////////////////////////////////////////////

  `include "environment.sv"

  /////////////////////////////////////////////////////////////////////////////////////////////
  Environment env;
  /////////////////////////////////////////////////////////////////////////////////////////////

  initial begin
    env = new(Rx, Tx, NumRx, NumTx, mif);

    $display("###################################################################");
    $display("##################  Program Start !!!!!! ##########################");
    $display("###################################################################");

    env.gen_cfg();
    env.build();
    env.reset();
    env.run();
    env.wrap_up();

    $display("###################################################################");
    $display("##################  Program End  !!!!!!! ##########################");
    $display("###################################################################");
  end

endprogram
