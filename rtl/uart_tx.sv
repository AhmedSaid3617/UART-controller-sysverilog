import data_types_pkg::*;

module uart_tx (
    input rst, clk,
    input [8:0] data,
    input [11:0] control,
    input start,
    output idle,
    output logic tx_out
);

    state_t state, next_state;
    logic [8:0] tx_buff;
    ctrl_reg_t control_buff;
    assign control_buff = control;

    logic [3:0] d_count;
    logic s_count;
    logic br_tick, br_rst;

    assign idle = (state == IDLE);
    assign br_rst = (next_state == IDLE || state==IDLE && next_state==IDLE);

    /* shift_if data_if(clk);
    
    assign data_if.rst = rst;
    assign data_if.shift_en = shift;
    assign data_if.load_en = load_data;
    assign data_if.parallel_in = data;
    assign shift_out = data_if.q[0];
   
    shift_register data_buffer(data_if); */

    // Baud rate generator, to divide the main clock signal and get the required baud rate for data transmission.
    baud_gen br_gen(.clk(clk), .rst(br_rst), .div(control_buff.br_div), .tick(br_tick));

    always_ff @( posedge clk ) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            case (state)
                IDLE: if (next_state == START) begin
                    tx_buff <= data;
                    d_count <= control_buff.word?8:7;
                    s_count <= control_buff.stop;
                end
                DATA: if (next_state == DATA && br_tick) d_count <= d_count - 1;
                STOP: begin 
                    if (next_state == STOP && br_tick) s_count <= 0;
                    if (next_state == START) begin
                        tx_buff <= data;
                        d_count <= control_buff.word?8:7;
                        s_count <= control_buff.stop;
                    end
                end
            endcase
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            IDLE: begin
                tx_out = 1;
                if (start) next_state = START;
            end
            START: begin
                tx_out = 0;
                if (br_tick) next_state = DATA;
            end
            DATA: begin
                tx_out = tx_buff[d_count];
                if (!d_count & br_tick) next_state = STOP;
            end
            STOP: begin
                tx_out = 1;
                if (!s_count & start & br_tick) next_state = START;
                else if (!s_count & br_tick) next_state = IDLE;
            end
        endcase
    end

    
endmodule