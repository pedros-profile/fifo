`timescale 1ns/1ps

module test_under_and_overflow;
    localparam int WIDTH = 32;
    localparam int DEPTH = 8;
    localparam int SEQ_LEN = DEPTH + 3;

    logic clk = 1'b0;
    logic rst_n;
    logic i_wr_rqst;
    logic i_rd_rqst;
    logic [WIDTH-1:0] i_data;
    logic o_empty;
    logic o_full;
    logic o_new_output;
    logic [WIDTH-1:0] o_data;

    fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .i_wr_rqst(i_wr_rqst),
        .i_rd_rqst(i_rd_rqst),
        .i_data(i_data),
        .o_empty(o_empty),
        .o_full(o_full),
        .o_new_output(o_new_output),
        .o_data(o_data)
    );

    always #5 clk <= ~clk;

    int unsigned error_count;
    typedef struct packed {
        logic err_empty_mismatch;
        logic err_full_mismatch;
        logic err_missing_new_output;
        logic err_data_mismatch;
        logic err_spurious_new_output;
    } err_flags_t;
    err_flags_t err_flags;
    logic [4:0] err_flags_bus;

    assign err_flags_bus = {
        err_flags.err_empty_mismatch,
        err_flags.err_full_mismatch,
        err_flags.err_missing_new_output,
        err_flags.err_data_mismatch,
        err_flags.err_spurious_new_output
    };

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            err_flags <= '0;
        end else begin
            err_flags <= '0;
        end
    end

    int signed seq0 [0:SEQ_LEN-1] = '{
        32'sd17, -32'sd3, 32'sd45, 32'sd1024, -32'sd2048,
        32'sd7, -32'sd99, 32'sd0, 32'sd555, -32'sd1, 32'sd88
    };
    int signed seq1 [0:SEQ_LEN-1] = '{
        -32'sd11, 32'sd200, 32'sd5, -32'sd300, 32'sd77,
        -32'sd8, 32'sd1234, -32'sd56, 32'sd9, 32'sd42, -32'sd999
    };

    task automatic drive_write(input logic [WIDTH-1:0] data);
        @(negedge clk);
        i_data = data;
        i_wr_rqst = 1'b1;
        @(negedge clk);
        i_wr_rqst = 1'b0;
    endtask

    task automatic drive_read;
        @(negedge clk);
        i_rd_rqst = 1'b1;
        @(negedge clk);
        i_rd_rqst = 1'b0;
    endtask

    task automatic check_flags(input logic exp_empty, input logic exp_full);
        if (o_empty !== exp_empty) begin
            error_count++;
            err_flags.err_empty_mismatch = 1'b1;
            $display("TB ERR: o_empty exp=%0b got=%0b", exp_empty, o_empty);
        end
        if (o_full !== exp_full) begin
            error_count++;
            err_flags.err_full_mismatch = 1'b1;
            $display("TB ERR: o_full exp=%0b got=%0b", exp_full, o_full);
        end
    endtask

    task automatic read_and_check(input logic expect_valid, input logic [WIDTH-1:0] exp_data);
        drive_read();
        @(posedge clk);
        #1;
        if (expect_valid) begin
            if (!o_new_output) begin
                error_count++;
                err_flags.err_missing_new_output = 1'b1;
                $display("TB ERR: Expected o_new_output on read");
            end
            if (o_data !== exp_data) begin
                error_count++;
                err_flags.err_data_mismatch = 1'b1;
                $display("TB ERR: o_data mismatch exp=%0h got=%0h", exp_data, o_data);
            end
        end else begin
            if (o_new_output) begin
                error_count++;
                err_flags.err_spurious_new_output = 1'b1;
                $display("TB ERR: Spurious o_new_output on empty read");
            end
        end
    endtask

    task automatic run_cycle(input int signed seq [0:SEQ_LEN-1]);
        int idx;
        logic [WIDTH-1:0] exp_data;

        for (idx = 0; idx < DEPTH - 1; idx++) begin
            drive_write(seq[idx][WIDTH-1:0]);
            @(posedge clk);
            #1;
            check_flags(1'b0, 1'b0);
        end

        drive_write(seq[DEPTH-1][WIDTH-1:0]);
        @(posedge clk);
        #1;
        check_flags(1'b0, 1'b1);

        for (idx = 0; idx < DEPTH - 1; idx++) begin
            exp_data = seq[idx][WIDTH-1:0];
            read_and_check(1'b1, exp_data);
            check_flags(1'b0, 1'b0);
        end

        exp_data = seq[DEPTH-1][WIDTH-1:0];
        read_and_check(1'b1, exp_data);
        check_flags(1'b1, 1'b0);

        read_and_check(1'b0, '0);
        check_flags(1'b1, 1'b0);
    endtask

    initial begin
        int exit_code;

        if (DEPTH != 8) begin
            $fatal(1, "This test expects DEPTH=8");
        end

        $dumpfile("build/verilator/test_under_and_overflow.vcd");
        $dumpvars(0, test_under_and_overflow);

        rst_n = 1'b0;
        i_wr_rqst = 1'b0;
        i_rd_rqst = 1'b0;
        i_data = '0;
        error_count = 0;

        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        run_cycle(seq0);
        run_cycle(seq1);

        $display("TB err_flags_bus=%0b", err_flags_bus);

        if (error_count == 0) begin
            $display("TB PASS");
            exit_code = 0;
        end else begin
            $display("TB FAIL: %0d error(s)", error_count);
            exit_code = error_count;
        end
        $display("TB exit_code=%0d", exit_code);
        $finish(exit_code);
    end
endmodule
