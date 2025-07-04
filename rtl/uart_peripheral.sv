import data_types_pkg::*;
import bus_if_types_pkg::*;

interface uart_mod_if(input clk);
    logic rst, interrupt, tx, rx;

    modport uart_mp (
        input clk, rst, rx,
        output interrupt, tx
    );

    modport tb_mp (
        input interrupt, tx,
        output rx
    );

endinterface

module uart_controller (slave_bus_if.slave bus, uart_mod_if.uart_mp uart_if);

    uart_tx_if tx_if(uart_if.clk);
    uart_tx transmitter(tx_if);

    uart_rx_if rx_if(uart_if.clk);
    uart_rx receiver(rx_if);

    ctrl_reg_t control_reg;
    logic [8:0] tx_buff;
    logic [8:0] rx_buff;
    logic tx_pending;

    logic tx_reset, rx_reset;

    assign control_reg.txf = ~tx_if.idle;
    
    // Connect TX IO.
    assign tx_if.tx_cfg = control_reg[11:0];
    assign tx_if.data = tx_buff;
    assign tx_if.rst = uart_if.rst || tx_reset;
    assign uart_if.tx = tx_if.tx_out;

    // Connect RX IO.
    assign rx_if.rx_cfg = control_reg[11:0];
    assign rx_if.rst = uart_if.rst || rx_reset;
    assign rx_if.rx_in = uart_if.rx;

    always_ff @(posedge uart_if.clk) begin
        if (uart_if.rst) begin
            tx_pending <= 0;
            tx_buff <= 0;
            control_reg.rxe <= 1;
            rx_buff <= 0;
        end
        else begin
            // Handle bus writes.
            if (bus.ss && bus.ttype == WRITE) begin
                case (bus.addr[7:0])
                    8'h00: begin 
                        if (control_reg.en) begin
                            tx_buff <= bus.wdata[8:0];
                            if (tx_if.idle) tx_if.enable <= 1;
                        end
                    end 
                    8'h04: begin
                        control_reg[10:0] <= bus.wdata[10:0];
                        tx_reset <= 1;
                        rx_reset <= 1;
                    end
                    default: ;
                endcase
            end
            else begin
                tx_reset <= 0;
                rx_reset <= 0;
            end

            // Handle bus read.
            if (bus.ss && bus.ttype == READ) begin
                case (bus.addr[7:0])
                    8'h00: begin 
                        bus.rdata <= rx_buff;
                        control_reg.rxe <= 1;
                    end 
                    8'h04: bus.rdata <= control_reg;
                    default: ; 
                endcase
            end

            // Release transmitter.
            if (tx_if.finish) tx_if.enable <= 0;

            // Save data from rx.
            if (rx_if.finish) begin
                rx_buff <= rx_if.data_out;
                control_reg.rxe <= 0;
            end
        end
    end

endmodule

