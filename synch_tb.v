`timescale 1ns/1ps

module synch_ram_tb;

  reg  [9:0] addr;
  reg        clk, rd, wr, cs;
  reg  [7:0] data_drive;
  reg        drive_en;
  wire [7:0] data;
  integer    i, errors;
  reg  [7:0] expected;

  // testbench drives the bus only when drive_en=1, otherwise releases it
  // so the DUT can drive it back during a read
  assign data = drive_en ? data_drive : 8'bz;

  ram_1 RAM (.addr(addr), .data(data), .clk(clk), .rd(rd), .wr(wr), .cs(cs));

  // 10ns clock period
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    errors   = 0;
    addr     = 0;
    rd       = 0;
    wr       = 0;
    cs       = 0;
    drive_en = 0;
    data_drive = 0;

    @(negedge clk);

    // ---- Write phase: write a known pattern to 32 locations ----
    wr = 1; rd = 0; cs = 1; drive_en = 1;
    for (i = 0; i < 32; i = i + 1) begin
      addr       = i;
      data_drive = (i * 7 + 3) % 256;
      @(negedge clk);   // hold addr/data stable across the posedge that captures it
    end
    wr = 0; cs = 0; drive_en = 0;

    // ---- Read phase: read back and check ----
    rd = 1; cs = 1; wr = 0; drive_en = 0;
    for (i = 0; i < 32; i = i + 1) begin
      addr = i;
      @(posedge clk);   // DUT latches d_out = mem[addr] here
      @(negedge clk);   // bus settled, safe to sample
      expected = (i * 7 + 3) % 256;
      if (data !== expected) begin
        errors = errors + 1;
        $display("MISMATCH addr=%0d expected=%0d got=%0d", i, expected, data);
      end else begin
        $display("OK addr=%0d data=%0d", i, data);
      end
    end

    if (errors == 0)
      $display("synch_ram_tb: PASS, all %0d locations verified", 32);
    else
      $display("synch_ram_tb: FAIL, %0d mismatches", errors);

    $finish;
  end

endmodule
