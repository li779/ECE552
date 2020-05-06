module cache_ctrl(clk, rst, Rd, wr, hit, dirty, valid, stall_in, Done, stall_out, CacheHit, mem_wr, mem_rd, enable0, enable1, comp, write, valid_in, select_wb, select_rd, offset_cache, offset_mem, req_addr, valid0, valid1, hit0, hit1, select, comp_stage, index);
    input clk, rst, Rd, wr, hit, dirty, valid, stall_in, valid0, valid1, hit0, hit1;
    input [1:0] req_addr;
    input [7:0] index;
    output reg Done, stall_out, CacheHit, mem_wr, mem_rd, enable0, enable1, comp, write, valid_in, select_wb, select_rd, select;
    output [1:0] offset_cache, offset_mem;
    output comp_stage;

    localparam COMP = 3'b000;
    localparam COMP_WR = 3'b001;
    localparam MEM_WB = 3'b010;
    localparam CACHE_WB = 3'b011;
    localparam FINISH = 3'b100;

    wire [2:0] state;
    reg[2:0] next_state;
    wire [2:0] pre_state;
    dff state_reg [2:0] (.d(next_state), .q(state), .clk(clk), .rst(rst)); 

    reg [1:0] Cache_offset;
    reg [1:0] Mem_offset;
    wire [1:0] Cache_offset_add;
    wire [1:0] Mem_offset_add;
    wire [3:0] cache_res;
    wire [3:0] mem_res;
    wire go;
    wire pre_select;
    wire select_vict;
    wire select_in;
    wire hit_cond;
    wire victimway, victim_set;
    wire refbit;

    dff cache_reg [1:0] (.d(Cache_offset), .q(offset_cache), .clk(clk), .rst(rst));
    dff mem_reg [1:0] (.d(Mem_offset), .q(offset_mem), .clk(clk), .rst(rst));
    cla_4b cache_adder (.A({2'b00,offset_cache}), .B(4'h0), .C_in(1'b1), .S(cache_res), .C_out(), .G_out(), .P_out());
    cla_4b mem_adder (.A({2'b00,offset_mem}), .B(4'h0), .C_in(1'b1), .S(mem_res), .C_out(), .G_out(), .P_out());
    assign Cache_offset_add = cache_res[1:0];
    assign Mem_offset_add = mem_res[1:0];
    assign go =  Rd | wr;
    assign pre_select = ({valid1,valid0} == 2'b00) ? 0 :
                        ({valid1,valid0} == 2'b01) ? 1 :
                        ({valid1,valid0} == 2'b10) ? 0 : ~refbit;
    assign select_in = (state == 3'b000) ? pre_select : select_vict;
    dff victim_ff(.d(select_in), .q(select_vict), .clk(clk), .rst(rst));
    assign hit_cond = (valid0&hit0)|(valid1&hit1);

    dff pre_reg[2:0] (.d(state), .q(pre_state), .clk(clk), .rst(rst)); 
    dff victim (.d(victim_set), .q(victimway), .clk(clk), .rst(rst));
    assign victim_set = (state == COMP)&go ? (victimway ^ 1) : victimway;

    assign comp_stage = (state == COMP);

    
    memc #( 1) reference (refbit,index, select_in, comp_stage, clk, rst, 1'b0, 5'b0);

    // wire miss;
    // reg miss_set; 
    // dff miss_reg(.d(miss_set), .q(miss), .clk(clk), .rst(rst));

    always@(*) begin
        Done = 1'b0;
        stall_out = 1'b0;
        CacheHit = 1'b0;
        mem_wr = 1'b0;
        mem_rd = 1'b0;
        enable0 = 1'b0;
        enable1 = 1'b0;
        select = 1'b0;
        comp = 1'b0;
        write = 1'b0;
        valid_in = 1'b1;
        select_wb = 1'b0;  // read from mem and write to cache
        select_rd = 1'b0;  // read from cache and write to mem
        Cache_offset = 2'b00;
        Mem_offset = 2'b00;
        next_state = COMP;
        case(state)
            COMP : begin
                Done = 0;
                stall_out = go;
                CacheHit = 0;
                enable0 = 1;
                enable1 = 1;
                select = hit_cond&(valid1&hit1) | (~hit_cond)&(pre_select);
                comp = 1;
                write = wr;
                next_state = go&hit_cond ? COMP_WR :
                            (~hit)&dirty&valid&go ? MEM_WB :
                            ((~valid)&go)|(~hit & ~dirty & go) ? CACHE_WB : COMP;
            end
            COMP_WR: begin
                Done = 1;
                stall_out = 0;
                CacheHit = go&hit_cond;
                enable0 = valid0&hit0;
                enable1 = valid1&hit1;
                select = valid1&hit1;
                comp = 1;
                write = wr;
                next_state = COMP;
            end
            MEM_WB: begin
                stall_out = go;
                mem_wr = 1;
                enable0 = ~select_vict;
                enable1 = select_vict;
                select = select_vict;
                select_rd = 1;
                Cache_offset = Cache_offset_add;
                Mem_offset = Mem_offset_add;
                next_state = (&offset_cache) ? CACHE_WB : MEM_WB;
            end
            CACHE_WB: begin
                stall_out = go;
                mem_rd = ~(offset_cache[1] == 1'b1);
                enable0 = ~select_vict;
                enable1 = select_vict;
                select = select_vict;
                select_wb = Rd | (wr&(offset_cache != req_addr));
                comp = (~(offset_cache == 1'b0))&wr;
                write = (offset_mem[1] == 1'b1);
                Cache_offset = (offset_mem[1] == 1'b1) ? Cache_offset_add : 2'b00;
                Mem_offset = (&offset_mem) ? offset_mem : Mem_offset_add;
                next_state = (&offset_cache) ? FINISH : CACHE_WB;
            end
            FINISH: begin
                enable0 = ~select_vict;
                enable1 = select_vict;
                select = select_vict;
                Done = 1;
            end
        endcase
    end


endmodule