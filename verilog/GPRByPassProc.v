/*
File Name : GPRByPassProc.v
Create time : 2021.07.14 1:05
Author : Morning Han
Function : 
    ByPass data Process on GPR read.

*/

module GPRByPassProc(
    input wire[4:0] EXE_waddr, // Src: ID_EXE_reg.exe_GPR_waddr
    input wire[31:0] EXE_wdata,
    input wire EXE_we,

    input wire[4:0] rs_addr,
    input wire[31:0] rs_data,

    input wire[4:0] rt_addr,
    input wire[31:0] rt_data,

    output wire[31:0] rs_valid_data,
    output wire[31:0] rt_valid_data
);

    assign rs_valid_data = (EXE_we & (rs_addr != 0) & (rs_addr == EXE_waddr)) ? EXE_wdata : rs_data;
    assign rt_valid_data = (EXE_we & (rt_addr != 0) & (rt_addr == EXE_waddr)) ? EXE_wdata : rt_data;
endmodule