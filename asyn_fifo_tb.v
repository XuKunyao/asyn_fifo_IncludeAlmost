`timescale 1ns/1ns
module asyn_fifo_tb;
    localparam DATA_WIDTH = 16; 
     
    reg wr_clk;
    reg wr_rst_n;
    reg wr_en;
    reg [DATA_WIDTH-1:0] wr_data;
    reg rd_clk;
    reg rd_rst_n;
    reg rd_en;
    
    wire [DATA_WIDTH-1:0] rd_data;
    wire full;
    wire almost_full;
    wire empty;
    wire almost_empty;
    
asyn_fifo #(
    .DATA_WIDTH(16),
    .PTR_WIDTH(8) 
)
asyn_fifo_inst
(
    .wr_clk(wr_clk),
    .wr_rst_n(wr_rst_n),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .rd_clk(rd_clk),
    .rd_rst_n(rd_rst_n),
    .rd_en(rd_en),

    .rd_data(rd_data),
    .full(full),
    .almost_full(almost_full),
    .empty(empty),
    .almost_empty(almost_empty)
    );
    
initial wr_clk = 0;
always #10 wr_clk = ~wr_clk;

initial rd_clk = 0;
always #30 rd_clk = ~rd_clk;

//写数据
always @(posedge wr_clk or negedge wr_rst_n)
    begin
    if (!wr_rst_n)
        begin
        wr_data <= 1'b0;
        end
    else if(wr_en)
        begin
        wr_data <= wr_data + 1'b1;
        end
    else 
        begin
        wr_data <= wr_data;
        end
    end
    
initial begin
    wr_rst_n = 0;
    rd_rst_n = 0;
    wr_en    = 0;
    rd_en    = 0;
    #200;
    wr_rst_n = 1;
    rd_rst_n = 1;
    wr_en    = 1;
    #200
    rd_en    = 1;
    #8000;
    wr_en    = 0;
    #20000
    rd_en    = 0;
    #2000
    wr_en    = 1;
    #3000
    $stop;
    end
    
endmodule