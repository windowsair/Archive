`timescale 1ns/1ns
`define clk_period 20
module sync_fifo_tb;
    reg clk;
    reg rst_n;
    reg [7:0]fifo_din;
    reg read;
    reg write;

    wire empty;
    wire full;
    wire [7:0]fifo_dout;

    sync_fifo sync_fifo_inst(
    .clk(clk),
    .rst_n(rst_n),
    .fifo_din(fifo_din),
    .read(read),
    .write(write),

    .empty(empty),
    .full(full),
    .fifo_dout(fifo_dout)
    );

    initial begin
        clk=1;
        write = 0;
        read = 0;
        rst_n=0;
    #45;
        rst_n=1;
    #320;
        write = 1;
        read = 0;
    #100;
        read = 1;
    #20;
        read = 0;
    #200;
        write = 0;
        read = 1;
    #200;
        write = 1;
        read = 1;
    #100;
    /*write = 1;
    read = 0;
    #200;
    write = 0;
    read = 1;
    #300;*/
    #300;
    $stop;
    end

    //clk
    always #(`clk_period/2) clk=~clk;

    //fifo_din
    always@(posedge clk) begin
    fifo_din <= $random($time);
    end

    //always #(`clk_period * 60) write = ~write;
    //always #(`clk_period *20) read = ~read;


endmodule