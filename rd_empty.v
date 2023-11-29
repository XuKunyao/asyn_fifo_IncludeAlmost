`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/08 00:58:15
// Design Name: 
// Module Name: rd_empty
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


module rd_empty #(
    parameter DATA_WIDTH = 16,
    parameter PTR_WIDTH  = 8,
    parameter ALMOST_EMPTY_GAP = 3  //将空信号间隔阈值为3
)
(
    input  rd_clk,
    input  rd_rst_n,
    input  rd_en,
    input  [PTR_WIDTH:0] w2r_w_ptr_gray,    //写时钟域同步到写时钟域的读指针的格雷码
    output [PTR_WIDTH-1:0] rd_addr,         //fifo_mem的地址
    output [PTR_WIDTH:0] rd_ptr_gray,       //格雷码形式的读指针
    output wire empty,
    output wire almost_empty
);
    reg [PTR_WIDTH:0] rd_ptr; //比rd_addr多出来一位作为空满判断位   
    wire [PTR_WIDTH:0] rd_almost_ptr; //用来判断将空信号的读指针   
 
    
    //直接作为存储实体的地址，比如连接到RAM存储实体的读地址端
    assign rd_addr = rd_ptr[PTR_WIDTH-1:0];

    //读指针格雷码转换
    assign rd_ptr_gray = rd_ptr ^ (rd_ptr>>1);

    //产生读空信号empty
    assign empty = (rd_ptr_gray == w2r_w_ptr_gray) ? 1'b1:1'b0;

    //格雷码转二进制
    assign rd_almost_ptr[PTR_WIDTH] = w2r_w_ptr_gray[PTR_WIDTH];
    genvar i;
    generate
        for(i=PTR_WIDTH-1;i>=0;i=i-1)begin:rdgray2bin  // <-- example block name
            assign rd_almost_ptr[i] = rd_almost_ptr[i+1] ^ w2r_w_ptr_gray[i];
        end
    endgenerate
    
    //产生将空信号 fifo_almost_empty
    assign almost_empty = ((rd_almost_ptr - rd_ptr) <= ALMOST_EMPTY_GAP) ? 1'b1 : 1'b0;
    
    //读指针产生
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr <= 'b0;
        end
        else if(rd_en && !empty) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    endmodule
