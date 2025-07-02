import data_types_pkg::*;

interface uart_tx_if(input clk);
    logic rst;
    logic [8:0] data;
    tx_config_t tx_cfg;
    logic enable;
    logic idle;
    logic finish;
    logic tx_out;
endinterface

module uart_tx (
    uart_tx_if txif
);

    state_t state, next_state;
    logic [8:0] tx_buff;
    /* ctrl_reg_t control_buff;
    assign control_buff = txif.control; */

    logic [3:0] d_count;
    logic s_count;
    logic br_tick, br_rst;

    assign txif.idle = (state == IDLE);

    // Reset the baudrate generator in idle state.
    assign br_rst = (next_state == IDLE || state==IDLE && next_state==IDLE);

    // Baud rate generator
    baud_gen br_gen(.clk(txif.clk), .rst(br_rst), .div(txif.tx_cfg.br_div), .tick(br_tick));

    always_ff @(posedge txif.clk) begin
        if (txif.rst) begin
            state <= IDLE;
        end
        else begin
            case (state)
                IDLE: if (next_state == START) begin
                    tx_buff <= txif.data;
                    d_count <= txif.tx_cfg.word ? 8 : 7;
                    s_count <= txif.tx_cfg.stop;
                end
                DATA: if (next_state == DATA && br_tick) d_count <= d_count - 1;
                STOP: begin 
                    if (next_state == STOP && br_tick) s_count <= 0;
                    if (next_state == START) begin
                        tx_buff <= txif.data;
                        d_count <= txif.tx_cfg.word ? 8 : 7;
                        s_count <= txif.tx_cfg.stop;
                    end
                end
            endcase
            state <= next_state;
        end
    end

    always_comb begin
        txif.finish = 0;
        case (state)
            IDLE: begin
                txif.tx_out = 1;
                if (txif.enable) next_state = START;
            end
            START: begin
                txif.tx_out = 0;
                if (br_tick) next_state = DATA;
            end
            DATA: begin
                txif.tx_out = tx_buff[d_count];
                if (!d_count & br_tick) next_state = STOP;
            end
            STOP: begin
                txif.tx_out = 1;
                txif.finish = 1;
                if (!s_count & txif.enable & br_tick) next_state = START;
                else if (!s_count & br_tick) next_state = IDLE;
            end
        endcase
    end

endmodule