/* A register array to be used for tag arrays, LRU array, etc. */

module l2_array #(
    parameter s_index = 4,
    parameter width = 1
)
(
    clk,
    rst,
    read,
    load,
    rindex,
    windex,
    iindex,
    dindex,
    datain,
    dataout,
    dataout_imm,
    iout,
    dout
);

localparam num_sets = 2**s_index;

input clk;
input rst;
input read;
input load;
input [s_index-1:0] rindex;
input [s_index-1:0] windex;
input [s_index-1:0] iindex;
input [s_index-1:0] dindex;
input [width-1:0] datain;
output logic [width-1:0] dataout;
output logic [width-1:0] dataout_imm;
output logic iout;
output logic dout;

logic [width-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
logic [width-1:0] _dataout;
assign dataout = _dataout;
assign dataout_imm = data[rindex]; // immediate read

assign iout = data[iindex];
assign dout = data[dindex];


always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            data[i] <= '0;
    end
    else begin
        if (read)
            _dataout <= (load  & (rindex == windex)) ? datain : data[rindex];

        if(load)
            data[windex] <= datain;
    end
end

endmodule : l2_array
