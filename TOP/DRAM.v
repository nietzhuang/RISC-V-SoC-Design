`timescale 1ns/10ps
module DRAM(
    Q,
    RST,
    CSn,
    WEn,
    RASn,
    CASn,
    A,
    D
);

    parameter word_size = 32;                                        //Word Size
    parameter row_size = 11;                                         //Row Size
    parameter col_size = 10;                                         //Column Size
    parameter addr_size = (row_size > col_size)? row_size: col_size; //Address Size
    parameter addr_size_total = (row_size + col_size);               //Total Address Size
    parameter mem_size = (1 << addr_size_total);                     //Memory Size
    parameter Hi_Z_pattern = {word_size{1'bz}};
    parameter dont_care = {word_size{1'bx}};


    parameter read_delay = 40;                                       //Read Delay(ns)
    parameter write_delay = 20;                                      //Write Delay(ns)

    output reg [word_size-1:0] Q;                                    //Data Output
    input RST;
    input CSn;                                                       //Chip Select
    input WEn;                                                       //Write Enable
    input RASn;                                                      //Row Address Select
    input CASn;                                                      //Column Address Select
    input [addr_size-1:0] A;                                         //Address
    input [word_size-1:0] D;                                         //Data Input
    integer i;

    reg [row_size-1:0] row_l;
    reg [col_size-1:0] col_l;
    reg [word_size-1:0] mem_data [0:mem_size-1];

    wire [addr_size_total-1:0]addr;
    assign addr = {row_l,col_l};
    wire [word_size-1:0]WinData;
    assign WinData=mem_data[addr];
    reg delayed_CASn;

    always@(posedge RST or negedge RASn)begin
        if (RST) begin
            row_l <= 0;
        end
        else if (~CSn) begin
            if (~RASn) row_l <= A[row_size-1:0];
            else row_l <= row_l;
        end
        else begin
            row_l <= row_l;
        end
    end

    always@(posedge RST or negedge CASn)begin
        if (RST) begin
            col_l <= 0;
        end
        else if (~CSn) begin
            if (~CASn) col_l <= A[col_size-1:0];
            else col_l <= col_l;
        end
        else begin
            col_l <= col_l;
        end
    end

    always@(posedge RST or negedge CASn)begin
        if(RST)begin
            for (i=0;i<mem_size;i=i+1) begin
                mem_data [i] <=0;
            end
        end
        else if (~CSn && ~CASn && ~WEn) begin
            #(write_delay) mem_data[addr] = D;
        end
    end

    always@(posedge RST or CASn or RASn) begin
        if (RST) begin
          Q <= Hi_Z_pattern;
        end
        else if (~CSn && ~CASn) begin
            if (~RASn && WEn) begin
                Q <= #(read_delay) mem_data[addr];
            end
            else begin
                Q <= #(read_delay) dont_care;
            end
        end
        else begin
            Q <= #(read_delay) Hi_Z_pattern;
        end
    end

endmodule
