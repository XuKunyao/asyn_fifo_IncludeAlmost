`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/08 00:58:01
// Design Name: 
// Module Name: wr_full
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


module wr_full #(
    parameter   DATA_WIDTH = 16,
    parameter   PTR_WIDTH  = 8,
    parameter   ALMOST_FULL_GAP = 3
)
(
    input wr_clk,
    input wr_rst_n,
    input wr_en,
    input [PTR_WIDTH:0] r2w_r_ptr_gray,

    output full,
    output [PTR_WIDTH-1:0] wr_addr,
    output [PTR_WIDTH:0] wr_ptr_gray,
    output wire almost_full
);
    localparam DATA_DEPTH = 1 << PTR_WIDTH;//相当于将二进制数1在二进制中的表示向左移动PTR_WIDTH位，也就是将这个数乘以2的PTR_WIDTH次方
    reg [PTR_WIDTH:0] wr_ptr;
    wire [PTR_WIDTH:0] wr_almost_ptr;
    wire [PTR_WIDTH:0] wr_almost_val;
    
    //fifo_mem的地址
    assign wr_addr = wr_ptr[PTR_WIDTH-1:0];
    //读指针格雷码转换
    assign wr_ptr_gray = wr_ptr ^ (wr_ptr >> 1);
    //产生full, 最高位和此高位不同而其他位均相同则判断为full
    assign full = ({~wr_ptr_gray[PTR_WIDTH:PTR_WIDTH-1],wr_ptr_gray[PTR_WIDTH-2:0]} == 
                       {r2w_r_ptr_gray[PTR_WIDTH:PTR_WIDTH-1],r2w_r_ptr_gray[PTR_WIDTH-2:0]}) ? 1'b1:1'b0;
    //格雷码转二进制
    assign wr_almost_ptr[PTR_WIDTH] = r2w_r_ptr_gray[PTR_WIDTH];
    genvar i;
    generate
        for (i=PTR_WIDTH-1;i>=0;i=i-1) begin:wrgray2bin  // <-- example block name
            assign wr_almost_ptr[i] = wr_almost_ptr[i+1] ^ r2w_r_ptr_gray[i];
        end
    endgenerate
    
    //若最高位不相同则直接相减，最高位相同则需在此基础上加一个数据深度DATA_DEPTH
    assign wr_almost_val = (wr_almost_ptr[PTR_WIDTH] ^ wr_ptr[PTR_WIDTH]) ? wr_almost_ptr[PTR_WIDTH-1:0] - wr_ptr[PTR_WIDTH-1:0] : DATA_DEPTH + wr_almost_ptr - wr_ptr;
    
    //产生将满信号
    assign almost_full = (wr_almost_val <= ALMOST_FULL_GAP) ? 1'b1 : 1'b0;
    //产生写指针
    always@(posedge wr_clk or negedge wr_rst_n)
        if (!wr_rst_n)begin
            wr_ptr <= 'b0;
            end
        else if (~full && wr_en)begin
            wr_ptr <= wr_ptr + 1'b1;
            end
            
    endmodule