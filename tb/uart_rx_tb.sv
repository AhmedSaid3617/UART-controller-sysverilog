import data_types_pkg::*;

module uart_rx_tb;
    bit clk;

    uart_rx_if rx_if(clk);
    uart_rx rx_dut(rx_if);
    
    uart_tx_if tx_if(clk);
    uart_tx tx_dut(tx_if);

    config_t cfg_reg;
    assign tx_if.tx_cfg = cfg_reg;
    assign rx_if.rx_cfg = cfg_reg;

    assign rx_if.rx_in = tx_if.tx_out;

    initial begin
        tx_if.rst = 1;
        rx_if.rst = 1;
        cfg_reg.br_div = 8;
        cfg_reg.word = 0;
        cfg_reg.stop = 0;
        cfg_reg.en = 1;
        #2000
        tx_if.rst = 0;
        rx_if.rst = 0;
        tx_if.data = 'h8e;
        tx_if.enable = 1;
        #5000
        tx_if.enable = 0;
        wait(tx_if.idle);
        /* rx_if.rst = 1;
        #2000
        rx_if.rst = 0; */
        #5000
        tx_if.data = 'h81;
        tx_if.enable = 1;
        #3000
        tx_if.enable = 0;
        wait (tx_if.idle)
        #2000
        cfg_reg.word = 1;
        tx_if.data = 'h1fe;
        rx_if.rst = 1;
        #2000
        rx_if.rst = 0;
        #1000
        tx_if.enable = 1;
        tx_if.enable = 0;
        wait(tx_if.idle)
        #1000
        tx_if.enable = 1;
        cfg_reg.stop = 1;

    end

    initial begin
        clk = 0;
        for (int i = 0; i < 4000; i++) begin
            #542.535 clk = ~clk;
        end
    end

endmodule