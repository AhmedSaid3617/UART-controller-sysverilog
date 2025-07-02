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

    uart_tx_if txif(uart_if.clk);
    uart_tx transmitter(txif);

    ctrl_reg_t control_reg;
    logic [8:0] tx_buff;
    logic tx_pending;

    assign control_reg.txf = ~txif.idle;
    // TODO: implement.
    assign control_reg.rxe = 0;

    // Connect TX IO.
    assign txif.tx_cfg = control_reg[11:0];
    assign txif.data = tx_buff;
    assign txif.rst = uart_if.rst;
    assign uart_if.tx = txif.tx_out;

    always_ff @(posedge uart_if.clk) begin
        if (uart_if.rst) begin
            tx_pending <= 0;
            tx_buff <= 0;
        end
        else begin
            // Handle bus writes.
            if (bus.ss && bus.ttype == WRITE) begin
                case (bus.addr[7:0])
                    8'h00: begin 
                        if (control_reg.en) begin
                            tx_buff <= bus.wdata[8:0];
                            if (txif.idle) txif.enable <= 1;
                        end
                    end 
                    8'h04: control_reg[10:0] <= bus.wdata[10:0];
                    default: ;
                endcase
            end

            // Handle bus read.
            // TODO: Implement rx.
            else if (bus.ss && bus.ttype == READ) begin
                case (bus.addr[7:0])
                    8'h00: begin 
                        // TODO
                    end 
                    8'h04: bus.rdata <= control_reg;
                    default: ; 
                endcase
            end
            // Release transmitter.
            if (txif.finish) txif.enable <= 0;
        end
    end

endmodule

