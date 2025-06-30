`timescale 1ns/1ps
import data_types_pkg::*;

module uart_tx_tb;
    // Testbench signals for uart_tx
    bit clk;

    uart_tx_if txif(clk);
    uart_tx uart_tx_dut(txif);

    ctrl_reg_t ctrl_reg;
    assign txif.control = ctrl_reg;
    

    initial begin
        clk = 0;
        for (int i = 0; i < 4000; i++) begin
            #542.535 clk = ~clk;
        end
    end

    initial begin
        txif.rst = 1;
        ctrl_reg.br_div = 8;
        ctrl_reg.word = 0;
        ctrl_reg.stop = 0;
        ctrl_reg.en = 1;
        #2000
        txif.rst = 0;
        txif.data = 'h8e;
        txif.start = 1;
        #5000
        txif.start = 0;
        wait(txif.idle)
        #400
        txif.data = 'h81;
        txif.start = 1;
        #3000
        txif.start = 0;
        wait (txif.idle)
        #2000
        txif.start = 1;
        ctrl_reg.word = 1;
        txif.data = 'h1fe;
        #2000;
        txif.start = 0;
        wait(txif.idle)
        #1000
        txif.start = 1;
        ctrl_reg.stop = 1;

    end

endmodule