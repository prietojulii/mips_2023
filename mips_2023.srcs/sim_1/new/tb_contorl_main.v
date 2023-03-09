`timescale 1ns / 1ps
module tb_ControlMain;
    reg [31:0] i_instruction;
    reg i_is_A_B_equal_flag;
    wire [1:0] o_next_pc_select;
    wire o_ex_alu_src_a;
    wire [1:0] o_ex_alu_src_b;
    wire [1:0] o_ex_reg_dest_sel;
    wire o_mem_write_to_register_flag;
    wire o_mem_write_read_flag;
    wire [2:0] o_mem_load_mask;
    wire o_mem_store_mask;
    wire o_wb_mem_to_reg_sel;
    wire o_wb_write_back_flag;
    
    ControlMain control_main(
        .i_instruction(i_instruction),
        .i_is_A_B_equal_flag(i_is_A_B_equal_flag),
        .o_next_pc_select(o_next_pc_select),
        .o_ex_alu_src_a(o_ex_alu_src_a),
        .o_ex_alu_src_b(o_ex_alu_src_b),
        .o_ex_reg_dest_sel(o_ex_reg_dest_sel),
        .o_mem_write_to_register_flag(o_mem_write_to_register_flag),
        .o_mem_write_read_flag(o_mem_write_read_flag),
        .o_mem_load_mask(o_mem_load_mask),
        .o_mem_store_mask(o_mem_store_mask),
        .o_wb_mem_to_reg_sel(o_wb_mem_to_reg_sel),
        .o_wb_write_back_flag(o_wb_write_back_flag)
    );
    
    localparam OPCODE_BEQ = 6'b000100;
    localparam OPCODE_BNE = 6'b000101;
    initial begin
        // Test instruction beq when i_is_A_B_equal_flag is 1
        i_instruction = 32'h10000002; // beq $0, $0, 2
        i_is_A_B_equal_flag = 1'b1;
        #10; // Wait a few clock cycles for the output to stabilize
        if (o_next_pc_select !== 2'b10) $display("Test failed: o_next_pc_select should be 2 for beq instruction");
        
        // Test instruction bne when i_is_A_B_equal_flag is 0
        i_instruction = 32'h15000002; // bne $0, $0, 2
        i_is_A_B_equal_flag = 1'b0;
        #10; // Wait a few clock cycles for the output to stabilize
        if (o_next_pc_select !== 2'b10) $display("Test failed: o_next_pc_select should be 2 for bne instruction");
        
        // Test 1: BEQ when i_is_A_B_equal_flag is 1
        i_instruction = {OPCODE_BEQ, 5'b00001, 5'b00010, 16'b10};
        i_is_A_B_equal_flag = 1'b1;
        #1;
        if (o_next_pc_select !== 2'b10) $display("Test faild: BEQ : o_next_pc_select ");
        if (o_ex_alu_src_a !== 1'b0) $display("Test faild: BEQ : o_ex_alu_src_a");
        if (o_ex_alu_src_b !== 2'b00) $display("Test faild: BEQ : o_ex_alu_src_b ");
        if (o_ex_reg_dest_sel !== 2'b00) $display("Test faild: BEQ : o_ex_reg_dest_sel  ");
        if (o_mem_write_to_register_flag !== 1'b0) $display("Test faild: BEQ : o_mem_write_to_register_flag");
        if (o_mem_write_read_flag !== 1'b0) $display("Test faild: BEQ : o_mem_write_read_flag ");
        if (o_mem_load_mask !== 3'b000) $display("Test faild: BEQ : o_mem_load_mask  ");
        if (o_mem_store_mask !== 1'b0) $display("Test faild: BEQ : o_mem_store_mask  ");
        if (o_wb_mem_to_reg_sel !== 1'b0) $display("Test faild: BEQ : o_wb_mem_to_reg_sel ");
        if (o_wb_write_back_flag !== 1'b0) $display("Test faild: BEQ : o_wb_write_back_flag ");

        // Test 2: BNE when i_is_A_B_equal_flag is 0
        i_instruction = {OPCODE_BNE, 5'b00001, 5'b00010, 16'b10};
        i_is_A_B_equal_flag = 1'b0;
        #1;
        if (o_next_pc_select !== 2'b10) $display("Test faild BNE: o_next_pc_select  ");
        if (o_ex_alu_src_a !== 1'b0) $display("Test faild BNE: o_ex_alu_src_a   ");
        if (o_ex_alu_src_b !== 2'b00) $display("Test faild BNE: o_ex_alu_src_b   ");
        if (o_ex_reg_dest_sel !== 2'b00) $display("Test faild BNE: o_ex_reg_dest_sel  ");
        if (o_mem_write_to_register_flag !== 1'b0) $display("Test faild BNE: o_mem_write_to_register_flag");
        if (o_mem_write_read_flag !== 1'b0) $display("Test faild BNE: o_mem_write_read_flag");
        if (o_mem_load_mask !== 3'b000) $display("Test faild BNE: o_mem_load_mask ");
        if (o_mem_store_mask !== 1'b0) $display("Test faild BNE: o_mem_store_mask ");
        if (o_wb_mem_to_reg_sel !== 1'b0) $display("Test faild BNE: o_wb_mem_to_reg_sel");
        if (o_wb_write_back_flag !== 1'b0) $display("Test faild BNE: o_wb_write_back_flag ");



        // Test complete
        $display("Test complete");
        $finish;
    end
endmodule