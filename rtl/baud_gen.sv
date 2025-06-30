module baud_gen (
    input clk, rst, 
    input [7:0] div,
    output tick
);
    logic [7:0] counter;
    bit tick_reg;

    assign tick = tick_reg;

    always_ff @(posedge clk) begin
        if (rst) begin 
            counter <= 0;
            tick_reg <= 0;
        end
        else begin
            if (counter < div-1) begin
                counter <= counter + 1;
                tick_reg <= 0;
            end
            else begin
                counter <= 0;
                tick_reg <= 1;
            end
        end
    end
endmodule