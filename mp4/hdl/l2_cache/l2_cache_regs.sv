module tag_array #(
    parameter s_offset = 5,
    parameter s_index  = 4
)
(
    clk,
    reset,
    load,
    addr,
    tag_in,
    hit,
    rtag,
    iindex,
    dindex,
    iout,
    dout
);

localparam s_tag    = 32 - s_offset - s_index;
localparam s_mask   = 2**s_offset;
localparam s_line   = 8*s_mask;
localparam num_sets = 2**s_index;

input clk;
input reset;
input load;
input [s_index-1:0] addr;
input [s_tag-1:0] tag_in;
output logic hit;
output logic [s_tag-1:0] rtag;

// prefetching
input logic [s_index-1:0] iindex;
input logic [s_index-1:0] dindex;
output logic [s_tag-1:0] iout;
output logic [s_tag-1:0] dout;

logic [s_tag-1:0] data [num_sets-1:0];

assign iout = data[iindex];
assign dout = data[dindex];

always_ff @(posedge clk)
begin
    if (reset)
    begin
        for (int i=0; i<num_sets; i++)
            data[i] <= 24'h0;
    end
    else if (load)
        data[addr] <= tag_in;
end

assign hit = (data[addr] == tag_in);
assign rtag = data[addr];

endmodule : tag_array

// module for selecting data to cache regs to write on a miss.
// if it is a read, we just pass the data straight through, if not, assign appropriate data
//
module write_mux(
    input logic select, // read or write from CPU?
    input logic [255:0] from_mem, // data read from memory
    input logic [255:0] from_adapter, // write data from CPU
    input logic [31:0] mem_byte_enable, // 32 bit mem_b_enable
    output logic [255:0] data_to_reg
);

always_comb
begin
    if(!select)
        data_to_reg = from_mem;
    else
    begin
        for(int i = 0; i< 32; i++)
        begin
            if(mem_byte_enable[i])
                data_to_reg[8*i +: 8] = from_adapter[8*i +: 8];
            else
                data_to_reg[8*i +: 8] = from_mem[8*i +: 8];
        end
    end
end


endmodule : write_mux

// module cache_regs(
//     input logic select, // read or write from CPU?
//     input logic [255:0] from_mem, // data read from memory
//     input logic [255:0] from_adaptor, // write data from CPU
//     input logic [31:0] mem_byte_enable, // 32 bit mem_b_enable
//     output logic [255:0] data_to_reg
// );

// write_mux wm(.*);

// endmodule : cache_regs