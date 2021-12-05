module CP0ByPassProc(
    input wire[4:0] EXE_waddr, // Src: ID_EXE_reg.exe_GPR_waddr
    input wire[31:0] EXE_wdata,
    input wire EXE_we,

    input wire[4:0] mfc0_addr,
    input wire[31:0] mfc0_ori_data,

    output wire[31:0] mfc0_valid_data
);

    assign mfc0_valid_data = (EXE_we & (mfc0_addr == EXE_waddr)) ? EXE_wdata : mfc0_data;
endmodule