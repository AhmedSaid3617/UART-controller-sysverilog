interface sampler_if(input clk);
    logic rst, filtered, sig_in, sample_tick;

    modport sampler_mp (
        input clk, rst, sig_in, sample_tick,
        output filtered
    );

    modport tb_mp (
        input filtered,
        output rst, sig_in, sample_tick
    );
endinterface

module sampler (sampler_if.sampler_mp ifc);

    logic [7:0] high, low;

    always_ff @(posedge ifc.clk) begin
        if (ifc.rst) begin
            high <= 0;
            low <= 0;
        end
        else begin
            if (ifc.sig_in) high <= high+1;
            else low <= low+1;

            if (ifc.sample_tick) begin
               ifc.filtered <= (high > low)?1:0;
               high <= 0;
               low <= 0; 
            end
        end
    end

endmodule