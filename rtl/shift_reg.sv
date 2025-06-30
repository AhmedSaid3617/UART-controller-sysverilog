interface shift_if(input logic clk);
    logic rst;
    logic shift_en;
    logic load_en;
    logic serial_in;
    logic [8:0] parallel_in;
    logic [8:0] q;
endinterface

module shift_register(shift_if sif);

    always_ff @(posedge sif.clk or posedge sif.rst) begin
        if (sif.rst)
            sif.q <= 8'b0;
        else if (sif.load_en)
            sif.q <= sif.parallel_in;              // Parallel load
        else if (sif.shift_en)
            sif.q <= {sif.serial_in, sif.q[7:1]};  // Right shift
    end

endmodule
