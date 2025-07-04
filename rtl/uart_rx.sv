import data_types_pkg::*;

interface uart_rx_if (input clk);
    logic rst, finish, rx_in;
    config_t rx_cfg;
    logic [8:0] data_out;
endinterface

module uart_rx (uart_rx_if rx_if);

    sampler_if rx_filter_if(rx_if.clk);
    sampler rx_filter(rx_filter_if);

    logic br_rst;
    logic br_tick;

    baud_gen br_gen(rx_if.clk, br_rst, rx_if.rx_cfg.br_div, br_tick);

    //assign rx_filter_if.rst = rx_if.rst;
    assign rx_filter_if.sample_tick = br_tick;
    assign rx_filter_if.sig_in = rx_if.rx_in;

    state_t state, next_state;
    logic [3:0] d_count, w_size;
    logic s_count;
    logic [8:0] rx_buff;

    always_ff @(posedge rx_if.clk) begin
        if (rx_if.rst) begin
            state <=  IDLE;
            d_count <= 0;
            w_size <= rx_if.rx_cfg.word?8:7;
            s_count <= rx_if.rx_cfg.stop;
            //rx_if.data_out <= 0;
        end
        else begin
            case (state)
                START: if (br_tick)begin
                    rx_buff[d_count] <= rx_if.rx_in;
                    d_count <= d_count + 1;
                end
                DATA: begin
                    if (br_tick) begin
                        rx_buff[d_count] <= rx_if.rx_in;
                        d_count <= d_count + 1;
                    end
                end
                STOP: begin
                    if (br_tick) begin
                        rx_if.data_out <= rx_buff;
                        rx_buff <= 0;
                        d_count <= 0;
                        if (next_state == STOP) s_count <= 0;
                    end
                    
                end
                /* SAVE: begin
                    rx_if.data_out <= rx_buff;
                    rx_buff <= 0;
                    d_count <= 0;
                end */
            endcase
            state <= next_state;
        end
    end

    always_comb begin
        br_rst = 0;
        rx_filter_if.rst = 0;
        case (state)
            IDLE: if(!rx_if.rx_in)begin
               next_state = START;
               br_rst = 1;
               rx_filter_if.rst = 1;
            end

            START: if(br_tick) begin
                next_state = DATA;
            end

            DATA: if (d_count == w_size && br_tick) next_state = STOP;

            STOP: if (!s_count && br_tick) next_state = IDLE;
            
            //SAVE: next_state = IDLE;

            ERROR: next_state = IDLE;
        endcase
    end

    
endmodule