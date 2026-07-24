module ram_2(addr, data, rd, wr, cs);
input [9:0] addr;
input rd, wr, cs;
inout [7:0] data;
reg [7:0] mem[1023:0];
reg [7:0] d_out;

assign data = (cs && rd) ? d_out : 8'bz;

always @(addr or data or cs or rd or wr)
 if (cs && wr && !rd) mem[addr] = data;
 
always @(addr or cs or rd or wr)
 if (cs && rd && !wr) d_out = mem[addr];

endmodule 
 