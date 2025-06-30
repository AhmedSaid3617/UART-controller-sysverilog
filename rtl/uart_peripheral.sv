import data_types_pkg::*;
import bus_if_types_pkg::*;

module uart_controller (slave_bus_if.slave bus, input bit uart_clk, uart_rst, output interrupt);

    uart_tx_if txif(uart_clk);
    uart_tx transmitter(txif);

    ctrl_reg_t control_reg;

    always_ff @(posedge uart_clk) begin
        if (uart_rst) begin
            
        end
        else begin
            if (bus.ss && bus.ttype == WRITE) begin
                /* case (bus.addr[7:0])
                    8'h00: 
                    8'h04: 
                    default: 
                endcase */
            end
        end
    end

endmodule

