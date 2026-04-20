`timescale 1ns/1ps

// WIDTH
`ifndef WIDTH
`define WIDTH 32
`endif

// DEPTH
`ifndef DEPTH
`define DEPTH 8
`endif

// VCD DUMPFILE -- only generated if run from <root_dir>/sv!
`ifndef DUMPFILE
`define DUMPFILE "build/verilator/tb_fifo.vcd"
`endif

module tb_fifo;
    localparam WIDTH = `WIDTH;
    localparam DEPTH = `DEPTH;

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

    task write_byte(input [WIDTH-1:0] data);
        begin
            @(negedge clk);
            i_data = data;
            i_wr_rqst = 1'b1;
            @(negedge clk);
            i_wr_rqst = 1'b0;
        end
    endtask

    task read_byte;
        begin
            @(negedge clk);
            i_rd_rqst = 1'b1;
            @(negedge clk);
            i_rd_rqst = 1'b0;
        end
    endtask

    // Reference model using a queue to avoid internal-structure assumptions.
    logic [WIDTH-1:0] exp_queue[$];
    wire exp_empty = (exp_queue.size() == 0);
    wire exp_full = (exp_queue.size() == DEPTH);

    logic exp_new_output;
    int unsigned error_count;
    logic err_missing_new_output;
    logic err_data_mismatch;
    logic err_spurious_new_output;
    logic [2:0] err_flags;

    assign err_flags = {err_missing_new_output, err_data_mismatch, err_spurious_new_output};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            exp_queue.delete();
            exp_new_output <= 1'b0;
            error_count <= 0;
            err_missing_new_output <= 1'b0;
            err_data_mismatch <= 1'b0;
            err_spurious_new_output <= 1'b0;
        end else begin
            logic exp_rd_accept;
            logic exp_wr_accept;
            logic [WIDTH-1:0] exp_front;

            exp_rd_accept = i_rd_rqst && !exp_empty;
            exp_wr_accept = i_wr_rqst && (!exp_full || exp_rd_accept);
            exp_front = exp_empty ? '0 : exp_queue[0];

            exp_new_output <= exp_rd_accept;
            err_missing_new_output <= 1'b0;
            err_data_mismatch <= 1'b0;
            err_spurious_new_output <= 1'b0;

            #1;
            if (exp_new_output) begin
                if (!o_new_output) begin
                    err_missing_new_output <= 1'b1;
                    error_count <= error_count + 1;
                    $display("TB ERR: Expected o_new_output when read is accepted");
                end
                if (o_data !== exp_front) begin
                    err_data_mismatch <= 1'b1;
                    error_count <= error_count + 1;
                    $display("TB ERR: o_data mismatch. exp=%0h got=%0h", exp_front, o_data);
                end
            end else begin
                if (o_new_output) begin
                    err_spurious_new_output <= 1'b1;
                    error_count <= error_count + 1;
                    $display("TB ERR: o_new_output asserted without an accepted read");
                end
            end

            if (exp_rd_accept) begin
                exp_queue.pop_front();
            end
            if (exp_wr_accept) begin
                exp_queue.push_back(i_data);
            end

            if (err_flags != 3'b000) begin
                $display("TB ERR flags: missing=%0b data=%0b spurious=%0b", err_missing_new_output, err_data_mismatch, err_spurious_new_output);
            end
        end
    end

    initial begin
        int exit_code;

        $dumpfile(`DUMPFILE);
        $dumpvars(0, tb_fifo);

        rst_n = 1'b0;
        i_wr_rqst = 1'b0;
        i_rd_rqst = 1'b0;
        i_data = '0;

        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        write_byte('hA5);
        write_byte('h5A);
        write_byte('h3C);
        read_byte();
        read_byte();
        read_byte();

        repeat (2) @(negedge clk);
        $display("o_data=%0h o_empty=%0b o_full=%0b o_new_output=%0b", o_data, o_empty, o_full, o_new_output);
        if (error_count == 0) begin
            $display("TB PASS");
            exit_code = 1;
        end else begin
            $display("TB FAIL: %0d error(s)", error_count);
            exit_code = -error_count;
        end
        $display("TB exit_code=%0d", exit_code);
        $finish(exit_code);
    end
endmodule
