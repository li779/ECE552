module cache_ctrl(clk, rst, Rd, wr, hit, dirty, valid, stall_in, Done, stall_out, CacheHit, mem_wr, mem_rd, enable, comp, write, valid_in, select_wb, select_rd, offset_cache, offset_mem, req_addr);
    input clk, rst, Rd, wr, hit, dirty, valid, stall_in;
    input [1:0] req_addr;
    output reg Done, stall_out, CacheHit, mem_wr, mem_rd, enable, comp, write, valid_in, select_wb, select_rd;
    output [1:0] offset_cache, offset_mem;

    localparam COMP = 3'b000;
    localparam COMP_WR = 3'b001;
    localparam MEM_WB = 3'b010;
    localparam CACHE_WB = 3'b011;
    localparam FINISH = 3'b100;

    wire [2:0] state;
    reg[2:0] next_state;
    dff state_reg [2:0] (.d(next_state), .q(state), .clk(clk), .rst(rst)); 

    reg [1:0] Cache_offset;
    reg [1:0] Mem_offset;
    wire [1:0] Cache_offset_add;
    wire [1:0] Mem_offset_add;
    wire [3:0] cache_res;
    wire [3:0] mem_res;
    wire go;

    dff cache_reg [1:0] (.d(Cache_offset), .q(offset_cache), .clk(clk), .rst(rst));
    dff mem_reg [1:0] (.d(Mem_offset), .q(offset_mem), .clk(clk), .rst(rst));
    cla_4b cache_adder (.A({2'b00,offset_cache}), .B(4'h0), .C_in(1'b1), .S(cache_res), .C_out(), .G_out(), .P_out());
    cla_4b mem_adder (.A({2'b00,offset_mem}), .B(4'h0), .C_in(1'b1), .S(mem_res), .C_out(), .G_out(), .P_out());
    assign Cache_offset_add = cache_res[1:0];
    assign Mem_offset_add = mem_res[1:0];
    assign go =  Rd | wr;

    // wire miss;
    // reg miss_set; 
    // dff miss_reg(.d(miss_set), .q(miss), .clk(clk), .rst(rst));

    always@(*) begin
        Done = 1'b0;
        stall_out = 1'b0;
        CacheHit = 1'b0;
        mem_wr = 1'b0;
        mem_rd = 1'b0;
        enable = 1'b0;
        comp = 1'b0;
        write = 1'b0;
        valid_in = 1'b1;
        select_wb = 1'b0;  // read from mem and write to cache
        select_rd = 1'b0;  // read from cache and write to mem
        Cache_offset = 2'b00;
        Mem_offset = 2'b00;
        next_state = COMP;
        // miss_set = miss;
        case(state)
            COMP : begin
                Done = hit&Rd&valid;
                stall_out = (~(hit&Rd&valid)) & go;
                //miss_set = ~(hit&Rd&valid);
                CacheHit = hit&go&valid;
                enable = 1;
                comp = 1;
                write = wr;
                next_state = hit&wr&valid ? COMP_WR :
                            (~hit)&dirty&valid&go ? MEM_WB :
                            ((~valid)&go)|(~hit & ~dirty) ? CACHE_WB: COMP;
            end
            COMP_WR: begin
                Done = hit&valid;
                stall_out = ~(hit&valid);
                //miss_set = ~(hit&wr&valid);
                CacheHit = hit&valid;
                enable = 1;
                comp = 1;
                write = wr;
                next_state = COMP;
            end
            MEM_WB: begin
                stall_out = 1;
                mem_wr = 1;
                enable = 1;
                select_rd = 1;
                Cache_offset = Cache_offset_add;
                Mem_offset = Mem_offset_add;
                next_state = (&offset_cache) ? CACHE_WB : MEM_WB;
            end
            CACHE_WB: begin
                stall_out = 1;
                mem_rd = ~(offset_cache[1] == 1'b1);
                enable = 1;
                select_wb = Rd | (wr&(offset_cache != req_addr));
                comp = ~(offset_cache == 2'b0);
                write = (offset_mem[1] == 1'b1);
                Cache_offset = (offset_mem[1] == 1'b1) ? Cache_offset_add : 2'b00;
                Mem_offset = (&offset_mem) ? offset_mem : Mem_offset_add;
                next_state = (&offset_cache) ? FINISH : CACHE_WB;
            end
            FINISH: begin
                enable = 1;
                //stall_out = 1;
                Done = 1;
            end
        endcase
    end


endmodule