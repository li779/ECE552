/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc_hier_pbench();

   /* BEGIN DO NOT TOUCH */
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   // End of automatics
   

   wire [15:0] PC;
   wire [15:0] Inst;           /* This should be the 15 bits of the FF that
                                  stores instructions fetched from instruction memory
                               */
   wire        RegWrite;       /* Whether register file is being written to */
   wire [2:0]  WriteRegister;  /* What register is written */
   wire [15:0] WriteData;      /* Data */
   wire        MemWrite;       /* Similar as above but for memory */
   wire        MemRead;
   wire [15:0] MemAddress;
   wire [15:0] MemDataIn;
   wire [15:0] MemDataOut;
   wire [2:0] haz_Rd_exe, haz_Rd_mem ,haz_Rd_wb, haz_Rs, haz_Rt;//ReadData_s;
   wire [15:0] pc_in, pc_pred, pc_raw;
   wire [1:0] e2e_sel, m2e_sel;
   wire [15:0] data_e2e, instr_pre;
   wire err;
   wire predict;
   wire        DCacheHit;
   wire        ICacheHit;
   wire        DCacheReq;
   wire        ICacheReq;
   
   wire Memread;
   wire Memwrite;
   wire m2m_sel_ex;
   wire m2m_sel;
   wire data_m2m;
   wire mem_stall;
   wire Dcache_rd, Dcache_wr, Icache_rd, Icache_wr;
   wire [15:0] Dcache_addr, Dcache_dataOut, Icache_addr, Icache_dataOut;
   wire [2:0] Dcache_state, Icache_state; 

   wire        Halt;         /* Halt executed and in Memory or writeback stage */
        
   integer     inst_count;
   integer     trace_file;
   integer     sim_log_file;
     
   integer     DCacheHit_count;
   integer     ICacheHit_count;
   integer     DCacheReq_count;
   integer     ICacheReq_count;
   
   proc_hier DUT();

   

   initial begin
      $display("Hello world...simulation starting");
      $display("See verilogsim.log and verilogsim.ptrace for output");
      inst_count = 0;
      DCacheHit_count = 0;
      ICacheHit_count = 0;
      DCacheReq_count = 0;
      ICacheReq_count = 0;

      trace_file = $fopen("verilogsim.ptrace");
      sim_log_file = $fopen("verilogsim.log");
      
   end

   always @ (posedge DUT.c0.clk) begin
      if (!DUT.c0.rst) begin
         if (Halt || RegWrite || MemWrite) begin
            inst_count = inst_count + 1;
         end
         if (DCacheHit) begin
            DCacheHit_count = DCacheHit_count + 1;      
         end    
         if (ICacheHit) begin
            ICacheHit_count = ICacheHit_count + 1;      
         end    
         if (DCacheReq) begin
            DCacheReq_count = DCacheReq_count + 1;      
         end    
         if (ICacheReq) begin
            ICacheReq_count = ICacheReq_count + 1;      
         end    

         $fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %8x R: %d %3d %8x M: %d %d %8x %8x %8x i_pre: %8x Mem_stall: %b ERR: %b PRE: %b pc_pred:  %8x, pc_raw:  %8x",
                   DUT.c0.cycle_count,
                   PC,
                   Inst,
                   RegWrite,
                   WriteRegister,
                   WriteData,
                   MemRead,
                   MemWrite,
                   MemAddress,
                   MemDataIn,
                   MemDataOut,
                   instr_pre,
                   mem_stall,
                   err,
                   predict,
                   pc_pred,
                   pc_raw 
                  );
         
         $fdisplay(sim_log_file, "SIMLOG:: EXE_WR: %b MEM_WR: %b EXE_RD: %3d MEM_RD: %3d WB_WR: %3d Rs: %3d Rt: %3d HAZ: %d E2E: %2b M2E: %2b data_e2e: %8x",
                   haz_Reg_write_exe,
                   haz_Reg_write_mem,
                   haz_Rd_exe,
                   haz_Rd_mem,
                   haz_Rd_wb,
                   haz_Rs,
                   haz_Rt,
                   haz_detect,
                   e2e_sel,
                   m2e_sel,
                   data_e2e,
                  );

         $fdisplay(sim_log_file, "SIMLOG:: MEM_RD: %b MEM_WR: %b EXE_RD: %3d Rs: %3d Rt: %3d HAZ: %d m2m_sel_ex: %b m2m_sel_mem: %b data_m2m: %8x",
                   Memread,
                   Memwrite,
                   haz_Rd_exe,
                   haz_Rs,
                   haz_Rt,
                   haz_detect,
                   m2m_sel_ex,
                   m2m_sel,
                   data_m2m,
                  );

         $fdisplay(sim_log_file, "SIMLOG:: DataCache RD: %b WR: %b ADDR: %8x STATE: %d DATAOUT: %8x",
                   Dcache_rd,
                   Dcache_wr,
                   Dcache_addr,
                   Dcache_state,
                   Dcache_dataOut,
                  );

         $fdisplay(sim_log_file, "SIMLOG:: InsCache RD: %b WR: %b ADDR: %8x STATE: %d DATAOUT: %8x",
                   Icache_rd,
                   Icache_wr,
                   Icache_addr,
                   Icache_state,
                   Icache_dataOut
                  );         
         $fdisplay(sim_log_file, "---------End-------------");

         if (RegWrite) begin
            $fdisplay(trace_file,"REG: %d VALUE: 0x%04x",
                      WriteRegister,
                      WriteData);            
         end
         if (MemRead) begin
            $fdisplay(trace_file,"LOAD: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataOut );
         end

         if (MemWrite) begin
            $fdisplay(trace_file,"STORE: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataIn  );
         end
         if (Halt) begin
            $fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
            $fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", DUT.c0.cycle_count);
            $fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);
            $fdisplay(sim_log_file, "SIMLOG:: dcachehit_count %d\n", DCacheHit_count);
            $fdisplay(sim_log_file, "SIMLOG:: icachehit_count %d\n", ICacheHit_count);
            $fdisplay(sim_log_file, "SIMLOG:: dcachereq_count %d\n", DCacheReq_count);
            $fdisplay(sim_log_file, "SIMLOG:: icachereq_count %d\n", ICacheReq_count);

            $fclose(trace_file);
            $fclose(sim_log_file);
            #5;
            $finish;
         end 
      end
      
   end

   /* END DO NOT TOUCH */

   /* Assign internal signals to top level wires
      The internal module names and signal names will vary depending
      on your naming convention and your design */

   // Edit the example below. You must change the signal
   // names on the right hand side
    
   assign PC = DUT.p0.pc;
   assign Inst = DUT.p0.instr;
   
   assign RegWrite = DUT.p0.decode0.regFile0.writeEn;
   //assign RegWrite = DUT.p0.decode0.Reg_write_wd;
   // Is register file being written to, one bit signal (1 means yes, 0 means no)
   //    
   assign WriteRegister = DUT.p0.decode0.regFile0.writeRegSel;
   //assign WriteRegister = DUT.p0.decode0.Reg_d_sel;
   // The name of the register being written to. (3 bit signal)
   
   assign WriteData = DUT.p0.decode0.regFile0.writeData;
   //assign WriteData = DUT.p0.decode0.WriteData_d;
   // Data being written to the register. (16 bits)
   
   //assign MemRead =  (DUT.p0.memRxout & ~DUT.p0.notdonem);
   assign MemRead =  DUT.p0.memory0.memRead & DUT.p0.memory0.Done & ~err;
   // Is memory being read, one bit signal (1 means yes, 0 means no)
   
   //assign MemWrite = (DUT.p0.memWxout & ~DUT.p0.notdonem);
   assign MemWrite = DUT.p0.memory0.memWrite & DUT.p0.memory0.Done & ~err;
   // Is memory being written to (1 bit signal)
   
   assign MemAddress = DUT.p0.memory0.addr_pre;
   // Address to access memory with (for both reads and writes to memory, 16 bits)
   
   assign MemDataIn = DUT.p0.memory0.data_in;
   // Data to be written to memory for memory writes (16 bits)
   
   assign MemDataOut = DUT.p0.memory0.mem_data;
   // Data read from memory for memory reads (16 bits)

   
   // new added 05/03
   assign ICacheReq = DUT.p0.fetch0.instr_file.Done;
   // Signal indicating a valid instruction read request to cache
   // Above assignment is a dummy example
   
   assign ICacheHit = DUT.p0.fetch0.instr_file.CacheHit;
   // Signal indicating a valid instruction cache hit
   // Above assignment is a dummy example

   assign DCacheReq = DUT.p0.memory0.memRead|DUT.p0.memory0.memWrite;
   // Signal indicating a valid instruction data read or write request to cache
   // Above assignment is a dummy example
   //    
   assign DCacheHit = DUT.p0.memory0.memory_file.CacheHit;
   // Signal indicating a valid data cache hit
   // Above assignment is a dummy example
   
   
   assign Halt = DUT.p0.memory0.halt;
   // Processor halted
   
   
   /* Add anything else you want here */
   
   assign haz_Reg_write_exe = DUT.p0.hazard0.Reg_wr_exe;
   assign haz_Reg_write_mem = DUT.p0.hazard0.Reg_wr_mem;
   //assign haz_Reg_write_wb =  DUT.p0.hazard0.Reg_wr_wb;
   assign haz_Rd_exe = DUT.p0.conditions_de[18:16];
   assign haz_Rd_mem = DUT.p0.pass_em[8:6];
   assign haz_Rd_wb = DUT.p0.Reg_d_sel_mw;
   assign haz_Rs = DUT.p0.hazard0.Rs;
   assign haz_Rt = DUT.p0.hazard0.Rt;//ReadData_s;
   assign haz_detect = DUT.p0.hazard0.Reg_haz;
   assign st_sel = DUT.p0.decode0.decoder.St_sel;
   assign pc_in = DUT.p0.fetch0.newPc;
   assign e2e_sel = DUT.p0.hazard0.e2e_sel;
   assign m2e_sel = DUT.p0.hazard0.m2e_sel;
   assign data_e2e = DUT.p0.data_e2e;
   assign data_m2m = DUT.p0.memory0.mem_data;
   assign Memread = DUT.p0.hazard0.Memread;
   assign Memwrite = DUT.p0.hazard0.Memwrite;
   assign m2m_sel = DUT.p0.execute0.m2m_sel_dff;
   assign m2m_sel_ex = DUT.p0.hazard0.m2m_sel;
   assign mem_stall = DUT.p0.memory0.data_stall;
   assign Dcache_rd = DUT.p0.memory0.memory_file.cc.Rd;
   assign Dcache_wr  = DUT.p0.memory0.memory_file.cc.wr;
   assign Dcache_addr = DUT.p0.memory0.memory_file.Addr;
   assign Dcache_state = DUT.p0.memory0.memory_file.cc.state;
   assign Dcache_dataOut = DUT.p0.memory0.memory_file.DataOut;
   assign err = DUT.p0.memory0.memory_file.err;
   //assign predict = DUT.p0.fetch0.predict_taken;
   //assign pc_pred = DUT.p0.fetch0.pc_pred;
   assign pc_raw = DUT.p0.fetch0.PC_raw;

   assign Icache_rd = DUT.p0.fetch0.instr_file.cc.Rd;
   assign Icache_wr  = DUT.p0.fetch0.instr_file.cc.wr;
   assign Icache_addr = DUT.p0.fetch0.instr_file.Addr;
   assign Icache_state = DUT.p0.fetch0.instr_file.cc.state;
   assign Icache_dataOut = DUT.p0.fetch0.instr_file.DataOut;
   assign instr_pre = DUT.p0.fetch0.instr_pre;
endmodule

// DUMMY LINE FOR REV CONTROL :0:
