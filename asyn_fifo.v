`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/07 15:33:36
// Design Name: 
// Module Name: asyn_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module asyn_fifo #(
    parameter DATA_WIDTH = 16,
    parameter PTR_WIDTH  = 8 ,
    parameter ALMOST_EMPTY_GAP = 3 ,
    parameter ALMOST_FULL_GAP  = 3
)(
    input  wr_clk,
    input  wr_rst_n,
    input  wr_en,
    input  [DATA_WIDTH-1:0] wr_data,
    input  rd_clk,
    input  rd_rst_n,
    input  rd_en,

    output [DATA_WIDTH-1:0] rd_data,
    output full,
    output almost_full,
    output wire empty,
    output wire almost_empty
    );

    wire [PTR_WIDTH:0] r2w_r_ptr_gray;
    wire [PTR_WIDTH:0] w2r_w_ptr_gray;

    wire [PTR_WIDTH:0] wr_ptr_gray;
    wire [PTR_WIDTH:0] rd_ptr_gray;

    wire [PTR_WIDTH-1:0] wr_addr;
    wire [PTR_WIDTH-1:0] rd_addr;
    

    wr_full #(
        .DATA_WIDTH(DATA_WIDTH),
        .PTR_WIDTH(PTR_WIDTH),
        .ALMOST_FULL_GAP(ALMOST_FULL_GAP)
    ) wr_full_inst(
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .r2w_r_ptr_gray(r2w_r_ptr_gray),
        .wr_addr(wr_addr),
        .wr_ptr_gray(wr_ptr_gray),
        .full(full),
        .almost_full(almost_full)
    );

    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) fifo_mem_inst(
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .full(full),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_addr(rd_addr),
        .empty(empty),

        .rd_data(rd_data)
    );

    rd_empty #(
        .DATA_WIDTH(DATA_WIDTH),
        .PTR_WIDTH(PTR_WIDTH),
        .ALMOST_EMPTY_GAP(ALMOST_EMPTY_GAP)
    ) rd_empty_inst(
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .w2r_w_ptr_gray(w2r_w_ptr_gray),
        .rd_addr(rd_addr),
        .rd_ptr_gray(rd_ptr_gray),
        .empty(empty),
        .almost_empty(almost_empty)
    );

    sync #(
        .DATA_WIDTH(DATA_WIDTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) sync_inst(
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .wr_ptr_gray(wr_ptr_gray),
        .rd_ptr_gray(rd_ptr_gray),

        .w2r_w_ptr_gray(w2r_w_ptr_gray),
        .r2w_r_ptr_gray(r2w_r_ptr_gray)
    );

endmodule
