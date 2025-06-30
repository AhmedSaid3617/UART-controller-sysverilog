interface slave_bus_if(input bclk, input brst_n);
    logic [31:0] wdata, rdata;
    logic [31:0] addr;
    tsize_e tsize;
    ttype_e ttype;
    logic berror, bdone, bstart, ss;

    modport ic(
        output wdata, addr, bstart, tsize, ttype, ss,
        input rdata, berror, bdone
    );

    modport slave(
        input wdata, addr, bstart, tsize, ttype, ss, bclk,
        output rdata, berror, bdone
    );
endinterface
