`timescale 1ns/1ps

module tb_alu;

    logic [31:0] A, B;
    logic [3:0] ALU_Control;
    logic [31:0] Result;
    logic Zero;

    integer passed = 0;
    integer failed = 0;
    integer i;

    logic [31:0] expected_result;
    logic expected_zero;

    // Instantiate the ALU
    alu dut (
        .A(A),
        .B(B),
        .ALU_Control(ALU_Control),
        .Result(Result),
        .Zero(Zero)
    );

    // Calculate expected output
    task calculate_expected;
        begin
            case (ALU_Control)

                4'b0000: expected_result = A & B;
                4'b0001: expected_result = A | B;
                4'b0010: expected_result = A + B;
                4'b0011: expected_result = A << B[4:0];
                4'b0100: expected_result = A ^ B;
                4'b0110: expected_result = A - B;

                4'b0111:
                    expected_result =
                    ($signed(A) < $signed(B)) ? 1 : 0;

                4'b1000: expected_result = A >> B[4:0];

                4'b1001:
                    expected_result =
                    $signed(A) >>> B[4:0];

                4'b1010:
                    expected_result = (A < B) ? 1 : 0;

                4'b1011: expected_result = B;

                default: expected_result = 0;

            endcase

            expected_zero = (expected_result == 0);
        end
    endtask

    // Compare actual and expected outputs
    task check_result;
        begin
            #10;

            if (Result !== expected_result ||
                Zero !== expected_zero) begin

                $display("FAILED: Control=%b", ALU_Control);

                $display("Expected Result=%h Zero=%b",
                         expected_result, expected_zero);

                $display("Actual Result=%h Zero=%b",
                         Result, Zero);

                failed = failed + 1;
            end
            else begin
                passed = passed + 1;
            end
        end
    endtask

    // Run one test, deriving the expected value from the golden model
    task run_test;
        input [31:0] test_A;
        input [31:0] test_B;
        input [3:0] test_control;

        begin
            A = test_A;
            B = test_B;
            ALU_Control = test_control;

            calculate_expected();
            check_result();
        end
    endtask

    // Run one directed test with an independently known expected value
    task run_test_expected;
        input [31:0] test_A;
        input [31:0] test_B;
        input [3:0] test_control;
        input [31:0] exp_result;

        begin
            A = test_A;
            B = test_B;
            ALU_Control = test_control;

            expected_result = exp_result;
            expected_zero = (exp_result == 0);
            check_result();
        end
    endtask

    // Main testing process
    initial begin

        $display("Starting RV32I ALU Testing...");
        $display("--------------------------------");

        // Test all 11 operations with independently computed expected values

        run_test_expected(15, 3, 4'b0000, 32'd3);             // AND
        run_test_expected(15, 3, 4'b0001, 32'd15);            // OR
        run_test_expected(5, 3, 4'b0010, 32'd8);              // ADD
        run_test_expected(1, 2, 4'b0011, 32'd4);              // SLL
        run_test_expected(15, 3, 4'b0100, 32'd12);            // XOR
        run_test_expected(5, 5, 4'b0110, 32'd0);              // SUB
        run_test_expected(32'hFFFFFFFF, 1, 4'b0111, 32'd1);   // SLT
        run_test_expected(32'h80000000, 4, 4'b1000, 32'h08000000); // SRL
        run_test_expected(32'h80000000, 4, 4'b1001, 32'hF8000000); // SRA
        run_test_expected(32'hFFFFFFFF, 1, 4'b1010, 32'd0);   // SLTU
        run_test_expected(10, 25, 4'b1011, 32'd25);           // PASS_B

        // Edge cases

        run_test_expected(32'h7FFFFFFF, 1, 4'b0010, 32'h80000000);
        run_test_expected(0, 1, 4'b0110, 32'hFFFFFFFF);
        run_test_expected(1, 37, 4'b0011, 32'd32);            // shamt = 5
        run_test_expected(10, 20, 4'b0101, 32'd0);            // unused code
        run_test_expected(32'h00000001, 0, 4'b0011, 32'h00000001); // SLL by 0
        run_test_expected(32'h80000000, 31, 4'b1000, 32'd1);  // SRL by 31
        run_test_expected(32'h80000000, 31, 4'b1001, 32'hFFFFFFFF); // SRA by 31

        // 200 random tests

        $display("Starting 200 random tests...");

        for (i = 0; i < 200; i = i + 1) begin

            A = $random;
            B = $random;

            case (i % 11)

                0: ALU_Control = 4'b0000;
                1: ALU_Control = 4'b0001;
                2: ALU_Control = 4'b0010;
                3: ALU_Control = 4'b0011;
                4: ALU_Control = 4'b0100;
                5: ALU_Control = 4'b0110;
                6: ALU_Control = 4'b0111;
                7: ALU_Control = 4'b1000;
                8: ALU_Control = 4'b1001;
                9: ALU_Control = 4'b1010;
                10: ALU_Control = 4'b1011;

            endcase

            calculate_expected();
            check_result();

        end

        // Final report

        $display("--------------------------------");
        $display("RV32I ALU TESTING COMPLETED");
        $display("Total Tests  = %0d", passed + failed);
        $display("Passed Tests = %0d", passed);
        $display("Failed Tests = %0d", failed);
        $display("--------------------------------");

        if (failed == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");

        $finish;

    end

endmodule
