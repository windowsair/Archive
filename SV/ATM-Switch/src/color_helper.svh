`ifndef __COLOR_HELPER_SVH__
`define __COLOR_HELPER_SVH__

`define RED_START \
  $display("%c[1;31m",27);

`define RED_END   \
  $display("%c[0m",27);


`define GREEN_START \
  $display("%c[5;34m",27);

`define GREEN_END   \
  $display("%c[0m",27);


`define BLUE_START \
  $display("");("%c[1;34m",27);

`define BLUE_END   \
  $display("%c[0m",27);


`endif
