module fifo #(
    parameter WIDTH = 32,
    parameter DEPTH = 8,
    parameter ADDR_WL = $clog2(DEPTH)
) (
    // input
    input clk,
    input rst_n,
    input i_wr_rqst,
    input i_rd_rqst,
    input [WIDTH-1:0] i_data,
    // output
    output reg o_empty,
    output reg o_full,
    output reg o_new_output,
    output reg [WIDTH-1:0] o_data
);

// internal registers
reg [ADDR_WL-1:0] addr_rd;
reg [ADDR_WL-1:0] addr_wr;
reg [WIDTH-1:0] fifo_mem [0:DEPTH-1];

// next step addresses (if the op happens)
wire [ADDR_WL-1:0] next_addr_rd = (addr_rd == ADDR_WL'(DEPTH - 1)) ? '0 : (addr_rd + 1);
wire [ADDR_WL-1:0] next_addr_wr = (addr_wr == ADDR_WL'(DEPTH - 1)) ? '0 : (addr_wr + 1);

// rin_*: register input
// read
wire op_rd = i_rd_rqst & !o_empty;
wire [ADDR_WL-1:0] rin_addr_rd = op_rd ? next_addr_rd : addr_rd;
// write
wire op_wr = i_wr_rqst & (i_rd_rqst || !o_full);
wire [ADDR_WL-1:0] rin_addr_wr = op_wr ? next_addr_wr : addr_wr;

// empty/full
wire rin_empty = op_rd & (rin_addr_rd == rin_addr_wr) & !i_wr_rqst;
wire rin_full = op_wr & (rin_addr_wr == rin_addr_rd) & !rin_empty;

// RD update
always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // read
        o_empty <= 1;
        o_data <= '0;
        addr_rd <= '0;
        // write
        o_full <= 0;
        addr_wr <= '0;
        o_new_output <= 0;
    end else begin
        // read
        o_empty <= rin_empty;
        o_data <= op_rd ? fifo_mem[addr_rd] : o_data;
        addr_rd <= rin_addr_rd;
        o_new_output <= op_rd;
        // write
        o_full <= rin_full;
        addr_wr <= rin_addr_wr;
        fifo_mem[addr_wr] <= op_wr ? i_data : fifo_mem[addr_wr];
    end
end

endmodule
