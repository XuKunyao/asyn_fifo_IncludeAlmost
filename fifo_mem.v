`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/08 00:27:07
// Design Name: 
// Module Name: fifo_mem
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


module fifo_mem #(
    parameter DATA_WIDTH = 16,      //RAM存储器位宽
    parameter PTR_WIDTH  = 8       //指针地址位宽为8，地址位宽为9（定义9为进位），fifo深度则为2^8=256
    //parameter DATA_DEPTH = 256      //数据深度（数据个数）
)(
    input wr_clk,
    input wr_rst_n,
    input wr_en,
    input [PTR_WIDTH-1:0] wr_addr,  //写地址
    input [DATA_WIDTH-1:0] wr_data, //写数据
    input full,
    input rd_clk,
    input rd_rst_n,
    input rd_en,
    input [PTR_WIDTH-1:0] rd_addr,  //读地址
    input empty,

    output reg [DATA_WIDTH-1:0] rd_data //读数据
    );

    localparam DATA_DEPTH = 1 << PTR_WIDTH;//相当于将二进制数1在二进制中的表示向左移动PTR_WIDTH位，也就是将这个数乘以2的PTR_WIDTH次方
    
    //开辟存储空间
    reg [DATA_WIDTH-1:0] mem[DATA_DEPTH-1:0];

    integer i;
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            for(i=0;i<DATA_DEPTH;i=i+1) begin
                mem[i] <= 1'b0;
            end
        end
        else if(wr_en && !full) begin
            mem[wr_addr] <= wr_data;
        end
    end

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_data <= 'b0;
        end
        else if(rd_en && !empty) begin
            rd_data <= mem[rd_addr];
        end
    end

endmodule
