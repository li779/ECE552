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
      enable, comp, write, valid_in, select_wb, select_rd, select, err_cache, err_mem, stall_memOut;
   wire [1:0] offset_cache, offset_mem;
   wire [2:0] offset_cache_fin, offset_mem_fin, offset_cache_in;
   wire [4:0] tag_out_cache;
   wire [15:0] data_in_cache, data_out_mem, addr_mem;
   wire [3:0] busy;
   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out_cache),
                          .data_out             (DataOut),
                          .hit                  (hit),
                          .dirty                (dirty),
                          .valid                (valid),
                          .err                  (err_cache),
                          // Inputs
                          .enable               (enable),
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
   assign err = err_cache | err_mem; 
   
   assign offset_mem_fin = {offset_mem, {Addr[0]}};
   assign offset_cache_fin = {offset_cache, {Addr[0]}};
   assign addr_mem = select_rd? {tag_out_cache, Addr[10:3], offset_mem_fin} : {Addr[15:3], offset_mem_fin};
   assign data_in_cache = select_wb? data_out_mem : DataIn;

   assign select = select_rd | select_wb; 
   assign offset_cache_in = select? offset_cache_fin : Addr[2:0];

    cache_ctrl cc(.clk(clk), .rst(rst), .Rd(Rd), .wr(Wr), .hit(hit), 
    .dirty(dirty), .valid(valid), .stall_in(stall_memOut), .Done(Done), 
    .stall_out(Stall), .CacheHit(CacheHit), .mem_wr(mem_wr), .mem_rd(mem_rd), 
    .enable(enable), .comp(comp), .write(write), .valid_in(valid_in), .select_wb(select_wb), 
    .select_rd(select_rd), .offset_cache(offset_cache), .offset_mem(offset_mem));
   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
