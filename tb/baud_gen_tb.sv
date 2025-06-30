`timescale 1ns/1ps

module baud_gen_tb;
    bit clk, rst;
    logic [7:0] div;
    logic tick;

    baud_gen baud_gen_dut(.*);

    initial begin 
        clk = 0;
        for (int i = 0; i < 1000; i++) begin
            #542.535 clk = ~clk;
        end
    end

    initial begin
        rst = 1;
        #2000
        div = 8;
        rst = 0;
    end

endmodule