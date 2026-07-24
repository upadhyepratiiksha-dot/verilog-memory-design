`timescale 1ns/1ps

module asynch_ram_tb;

  reg  [9:0] addr;
  reg        rd, wr, cs;
  reg  [7:0] data_drive;
  reg        drive_en;
  wire [7:0] data;
  integer    i, errors;
  reg  [7:0] expected;

  assign data = drive_en ? data_drive : 8'bz;

  ram_2 RAM (.addr(addr), .data(data), .rd(rd), .wr(wr), .cs(cs));

  initial begin
    errors     = 0;
    addr       = 0;
    rd         = 0;
    wr         = 0;
    cs         = 0;
    drive_en   = 0;
    data_drive = 0;
    #5;

    // ---- Write phase: write a known pattern to 32 locations ----
    cs = 1; wr = 1; rd = 0; drive_en = 1;
    for (i = 0; i < 32; i = i + 1) begin
      addr       = i;
      data_drive = (i * 5 + 1) % 256;
      #5;   // level-sensitive always block captures on this change
    end
    wr = 0; cs = 0; drive_en = 0;
    #5;

    // ---- Read phase: read back and check ----
    cs = 1; rd = 1; wr = 0; drive_en = 0;
    for (i = 0; i < 32; i = i + 1) begin
      addr = i;
      #5;
      expected = (i * 5 + 1) % 256;
      if (data !== expected) begin
        errors = errors + 1;
        $display("MISMATCH addr=%0d expected=%0d got=%0d", i, expected, data);
      end else begin
        $display("OK addr=%0d data=%0d", i, data);
      end
    end

    if (errors == 0)
      $display("asynch_ram_tb: PASS, all %0d locations verified", 32);
    else
      $display("asynch_ram_tb: FAIL, %0d mismatches", errors);

    $finish;
  end

endmodule
