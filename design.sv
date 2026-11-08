
`timescale 1ns/1ps

// RV32I ALU
// Supports 11 operations.
// Inputs A and B are 32-bit operands.
// ALU_Control selects the operation.
// Zero is HIGH whenever Result is zero.

module alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0]  ALU_Control,
    output logic [31:0] Result,
    output logic        Zero
);

    // ALU control codes
    localparam AND_OP  = 4'b0000;
    localparam OR_OP   = 4'b0001;
    localparam ADD_OP  = 4'b0010;
    localparam SLL_OP  = 4'b0011;
    localparam XOR_OP  = 4'b0100;
    localparam SUB_OP  = 4'b0110;
    localparam SLT_OP  = 4'b0111;
    localparam SRL_OP  = 4'b1000;
    localparam SRA_OP  = 4'b1001;
    localparam SLTU_OP = 4'b1010;
    localparam PASS_B  = 4'b1011;

    always_comb begin

        case (ALU_Control)

            AND_OP:
                Result = A & B;

            OR_OP:
                Result = A | B;

            ADD_OP:
                Result = A + B;

            SLL_OP:
                Result = A << B[4:0];

            XOR_OP:
                Result = A ^ B;

            SUB_OP:
                Result = A - B;

            SLT_OP:
                Result = ($signed(A) < $signed(B))
                         ? 32'd1 : 32'd0;

            SRL_OP:
                Result = A >> B[4:0];

            SRA_OP:
                Result = $signed(A) >>> B[4:0];

            SLTU_OP:
                Result = (A < B) ? 32'd1 : 32'd0;

            PASS_B:
                Result = B;

            default:
                Result = 32'b0;

        endcase

        Zero = (Result == 32'b0);

    end

endmodule
