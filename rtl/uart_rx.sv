import data_types_pkg::*;

interface uart_rx_if (input clk);
    logic rst, finish, rx_in;
    config_t rx_cfg;
    logic [8:0] data_out;
endinterface

module uart_rx (uart_rx_if rx_if);

    sampler_if rx_filter_if(rx_if.clk);
    sampler rx_filter(rx_filter_if);

    assign rx_filter_if.rst = rx_if.rst;
    //assign rx_filter_if.

    
endmodule