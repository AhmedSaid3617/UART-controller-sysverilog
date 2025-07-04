import bus_if_types_pkg::*;
import data_types_pkg::*;

module uart_periph_tb_2;
    logic clk, bnrst;
    slave_bus_if bus(clk, bnrst);
    uart_mod_if uart_if(clk);

    uart_controller uart_dut(bus.slave, uart_if.uart_mp);

    ctrl_reg_t control_reg_in;

    assign uart_if.rx = uart_if.tx;

    initial begin
        clk = 0;
        for (int i = 0; i < 4000; i++) begin
            #542.535 clk = ~clk;
        end
    end

    initial begin
        bnrst = 0;
        uart_if.rst = 1;
        #1000
        uart_if.rst = 0;
        bnrst = 1;
        bus.ss = 1;
        bus.ttype = WRITE;
        bus.tsize = WORD;

        bus.addr = 8'h04;
        control_reg_in.br_div = 8;
        control_reg_in.word = 0;
        control_reg_in.stop = 0;
        control_reg_in.en = 1;
        bus.wdata = control_reg_in;
        bus.bstart = 1;
        #10000

        bus.addr = 8'h00;
        bus.wdata = 8'h8e;
        #5000
        bus.wdata = 8'hff;
        #1000
        bus.ss = 1;
        bus.ttype = READ;
        bus.addr = 8'h04;

        #100000
        bus.ttype = WRITE;
        bus.addr = 8'h00;
        bus.wdata = 8'hf0;
        #2000
        bus.ss = 0;

    end


endmodule