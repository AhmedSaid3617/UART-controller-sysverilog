`timescale 1ns/1ps
import data_types_pkg::*;

module uart_tx_tb;
    // Testbench signals for uart_tx
    bit clk;

    uart_tx_if txif(clk);
    uart_tx uart_tx_dut(txif);

    config_t cfg_reg;
    assign txif.tx_cfg = cfg_reg;
    

    initial begin
        clk = 0;
        for (int i = 0; i < 4000; i++) begin
            #542.535 clk = ~clk;
        end
    end

    initial begin
        txif.rst = 1;
        cfg_reg.br_div = 8;
        cfg_reg.word = 0;
        cfg_reg.stop = 0;
        cfg_reg.en = 1;
        #2000
        txif.rst = 0;
        txif.data = 'h8e;
        txif.enable = 1;
        #5000
        txif.enable = 0;
        wait(txif.idle)
        #400
        txif.data = 'h81;
        txif.enable = 1;
        #3000
        txif.enable = 0;
        wait (txif.idle)
        #2000
        txif.enable = 1;
        cfg_reg.word = 1;
        txif.data = 'h1fe;
        #2000;
        txif.enable = 0;
        wait(txif.idle)
        #1000
        txif.enable = 1;
        cfg_reg.stop = 1;

    end

endmodule