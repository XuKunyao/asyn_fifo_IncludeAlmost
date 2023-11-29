`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/08 14:22:16
// Design Name: 
// Module Name: sync
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


module sync #(
    parameter DATA_WIDTH = 16,
    parameter PTR_WIDTH  = 8 
)(
    input  wr_clk,
    input  wr_rst_n,
    input  rd_clk,
    input  rd_rst_n,
    input  [PTR_WIDTH:0] wr_ptr_gray,
    input  [PTR_WIDTH:0] rd_ptr_gray,

    output wire [PTR_WIDTH:0] w2r_w_ptr_gray,
    output wire [PTR_WIDTH:0] r2w_r_ptr_gray
    );

    reg [PTR_WIDTH:0] wr_ptr_gray_r[1:0];
    reg [PTR_WIDTH:0] rd_ptr_gray_r[1:0];

    assign w2r_w_ptr_gray = wr_ptr_gray_r[1];
    assign r2w_r_ptr_gray = rd_ptr_gray_r[1];

    //写指针同步到读时钟域
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_gray_r[0] <= 'b0;
            wr_ptr_gray_r[1] <= 'b0;
        end
        else begin
            wr_ptr_gray_r[0] <= wr_ptr_gray;
            wr_ptr_gray_r[1] <= wr_ptr_gray_r[0];
        end
    end

    //读指针同步到写时钟域
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_gray_r[0] <= 'b0;
            rd_ptr_gray_r[1] <= 'b0;
        end
        else begin
            rd_ptr_gray_r[0] <= rd_ptr_gray;
            rd_ptr_gray_r[1] <= rd_ptr_gray_r[0];
        end
    end

endmodule
