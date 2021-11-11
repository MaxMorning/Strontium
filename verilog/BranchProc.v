module BranchProc (
    input wire[31:0] instr, // Src: Instr(ID)
    input wire[31:0] GPR_rs_data, // Src: RegFile.rdata1(ID)
    input wire[31:0] GPR_rt_data, // Src: RegFile.rdata2(ID)
    input wire[31:0] delay_slot_pc, // Src: PC.pc_out(IF)

    (* max_fanout = "8" *) output wire is_branch,
    output wire[31:0] branch_pc
);
    wire is_branch_instr = ~instr[31] & ~instr[29] & instr[28] & ~instr[27];
    wire is_jump_instr = ~instr[31] & ~instr[29] & ~instr[28] & instr[27];
    wire is_jump_register = ~instr[31] & ~instr[29] & ~instr[28] & ~instr[27] & ~instr[26] & ~instr[5] & instr[3] & ~instr[1];

    wire should_branch = (|(GPR_rs_data ^ GPR_rt_data)) ^~ instr[26];
    
    assign is_branch = is_jump_instr | is_jump_register | (is_branch_instr & should_branch);

    // assign id_is_branch_instr = is_branch_instr;

    wire[31:0] branch_instr_pc_offset = is_branch_instr & should_branch ? {{15{instr[15]}}, instr[14:0], 2'b00} : 32'h4;

    assign branch_pc = is_jump_instr ? {delay_slot_pc[31:28], instr[25:0], 2'b00} :
                        (is_jump_register ? GPR_rs_data :
                        delay_slot_pc + branch_instr_pc_offset);
endmodule