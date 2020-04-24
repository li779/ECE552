/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err, 
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output Done;
   output Stall;
   output CacheHit;
   output err;

   wire hit, dirty, valid, stall_in, stall_out, CacheHit, mem_wr, mem_rd, 
      enable, comp, write, valid_in, select_wb, select_rd, select_all, err_cache, err_mem, stall_memOut;
   wire [1:0] offset_cache, offset_mem;
   wire [2:0] offset_cache_fin, offset_mem_fin, offset_cache_in;
   wire [4:0] tag_out_cache;
   wire [15:0] data_in_cache, data_out_mem, addr_mem;
   wire [3:0] busy;
   wire hit0, dirty0, valid0, err_cache0, hit1, dirty1, valid1, err_cache1; 
   wire [15:0] DataOut0, DataOut1;
   wire [4:0] tag_out_cache0, tag_out_cache1;

   wire select;


   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out_cache0),
                          .data_out             (DataOut0),
                          .hit                  (hit0),
                          .dirty                (dirty0),
                          .valid                (valid0),
                          .err                  (err_cache0),
                          // Inputs
                          .enable               (enable0),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset_cache_in),
                          .data_in              (data_in_cache),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (valid_in));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag_out_cache1),
                          .data_out             (DataOut1),
                          .hit                  (hit1),
                          .dirty                (dirty1),
                          .valid                (valid1),
                          .err                  (err_cache1),
                          // Inputs
                          .enable               (enable1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset_cache_in),
                          .data_in              (data_in_cache),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (valid_in));
   


   four_bank_mem mem(// Outputs
                     .data_out          (data_out_mem),
                     .stall             (stall_memOut),
                     .busy              (busy),
                     .err               (err_mem),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (addr_mem),
                     .data_in           (DataOut),
                     .wr                (mem_wr),
                     .rd                (mem_rd));
   
// your code here

   
   assign dirty = select? dirty1 : dirty0;
   assign valid = select? valid1 : valid0;
   assign DataOut = select? DataOut1 : DataOut0;
   assign tag_out_cache = select ? tag_out_cache1 : tag_out_cache0;
   assign err_cache = err_cache0 | err_cache1;
   assign err = err_cache | err_mem; 
   assign hit = hit0 | hit1;
   
   assign offset_mem_fin = {offset_mem, {Addr[0]}};
   assign offset_cache_fin = {offset_cache, {Addr[0]}};
   assign addr_mem = select_rd? {tag_out_cache, Addr[10:3], offset_mem_fin} : {Addr[15:3], offset_mem_fin};
   assign data_in_cache = select_wb? data_out_mem : DataIn;

   assign select_all = select_rd | select_wb; 
   assign offset_cache_in = select_all? offset_cache_fin : Addr[2:0];

   wire [15:0] Addr_ff, DataIn_ff, Addr_in, DataIn_in;
   wire Rd_ff, Wr_ff, Rd_in, Wr_in;
   wire comp_stage;
   single_reg jr(.writeData(Addr), .rst(rst), .clk(clk), .readData(Addr_ff), .writeEn(Done));
   single_reg jk(.writeData(DataIn), .rst(rst), .clk(clk), .readData(DataIn_ff), .writeEn(Done));
   single_reg #(1) jj(.writeData(Rd), .rst(rst), .clk(clk), .readData(Rd_ff), .writeEn(Done));
   single_reg #(1) rr(.writeData(Wr), .rst(rst), .clk(clk), .readData(Wr_ff), .writeEn(Done));

   assign Addr_in = comp_stage? Addr : Addr_ff;
   assign DataIn_in = comp_stage ? DataIn : DataIn_ff;
   assign Rd_in = comp_stage? Rd : Rd_ff;
   assign Wr_in = comp_stage? Wr : Wr_ff; 
   
cache_ctrl cc(.clk(clk), .rst(rst), .Rd(Rd), .wr(Wr), .hit(hit), .valid1(valid1), .valid0(valid0), .comp_stage(comp_stage),
    .dirty(dirty), .valid(valid), .stall_in(stall_memOut), .Done(Done), .req_addr(Addr[2:1]), .select(select),
    .stall_out(Stall), .CacheHit(CacheHit), .mem_wr(mem_wr), .mem_rd(mem_rd), .hit0(hit0), .hit1(hit1),
    .enable0(enable0), .enable1(enable1), .comp(comp), .write(write), .valid_in(valid_in), .select_wb(select_wb), 
    .select_rd(select_rd), .offset_cache(offset_cache), .offset_mem(offset_mem));
   
   
endmodule // mem_system

   


// DUMMY LINE FOR REV CONTROL :9:
