
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pipeline_registers is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        start_stall : in  STD_LOGIC;
        stall_counter : in integer;
      
        -- inputs from IF stage
        reg_write : in STD_LOGIC;
        alu_src : in STD_LOGIC;
        mem_read : in STD_LOGIC;
        mem_write : in STD_LOGIC;
        branch : in STD_LOGIC;
        jump : in STD_LOGIC;
        load_addr : in STD_LOGIC;
        instr : in  STD_LOGIC_VECTOR(31 downto 0);
        npc    : in  STD_LOGIC_VECTOR(31 downto 0);
        rd : in STD_LOGIC_VECTOR(4 downto 0);
        alu_op: in STD_LOGIC_VECTOR(3 downto 0);
        mem_data : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- IF/ID pipeline registers
        if_id_reg_write : inout STD_LOGIC;
        if_id_alu_src : inout STD_LOGIC;
        if_id_mem_read : inout STD_LOGIC;
        if_id_mem_write : inout STD_LOGIC;
        if_id_branch : inout STD_LOGIC;
        if_id_jump : inout STD_LOGIC;
        if_id_load_addr : inout STD_LOGIC;
        if_id_instr : inout  STD_LOGIC_VECTOR(31 downto 0);
        if_id_npc : inout  STD_LOGIC_VECTOR(31 downto 0);
        if_id_rd: inout STD_LOGIC_VECTOR(4 downto 0); -- gonna try not using this at all
        if_id_reg1_data  : in  STD_LOGIC_VECTOR(31 downto 0);
        if_id_reg2_data  : in  STD_LOGIC_VECTOR(31 downto 0);
        if_id_imm        : in  STD_LOGIC_VECTOR(31 downto 0);
        if_id_alu_op : inout STD_LOGIC_VECTOR(3 downto 0);
        -- did not include rs1, or rs2
        
        -- ID/EX pipeline registers
        id_ex_reg_write : inout STD_LOGIC;
        id_ex_alu_src : inout STD_LOGIC;
        id_ex_mem_read : inout STD_LOGIC;
        id_ex_mem_write : inout STD_LOGIC;
        id_ex_branch : inout STD_LOGIC;
        id_ex_jump : inout STD_LOGIC;
        id_ex_load_addr : inout STD_LOGIC;
        id_ex_instr : out STD_LOGIC_VECTOR(31 downto 0);
        id_ex_npc  : inout  STD_LOGIC_VECTOR(31 downto 0);
        id_ex_rd  : inout  STD_LOGIC_VECTOR(4 downto 0); -- why needed?
        id_ex_reg1_data  : inout  STD_LOGIC_VECTOR(31 downto 0);
        id_ex_reg2_data  : inout  STD_LOGIC_VECTOR(31 downto 0);
        -- <add other id_ex registers>
        id_ex_imm  : inout  STD_LOGIC_VECTOR(31 downto 0);
        id_ex_alu_op  : out  STD_LOGIC_VECTOR(3 downto 0);
        id_ex_alu_result : in STD_LOGIC_VECTOR(31 downto 0); -- maybe not need?
        -- did not include rs1, or rs2
        
        
        -- EX/MEM pipeline registers        
        ex_mem_reg_write : inout STD_LOGIC;
        ex_mem_alu_src : inout STD_LOGIC;
        ex_mem_mem_read : inout STD_LOGIC;
        ex_mem_mem_write : inout STD_LOGIC;
        ex_mem_branch : out STD_LOGIC;
        ex_mem_jump : out STD_LOGIC;
        ex_mem_load_addr : inout STD_LOGIC;
        ex_mem_reg1_data : out STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_reg2_data : out STD_LOGIC_VECTOR(31 downto 0);
        -- <add other ex_mem registers>
        ex_mem_npc : out STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_imm : out STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_rd : inout  STD_LOGIC_VECTOR(4 downto 0); -- don't really know why this was included in id_ex register?
        ex_mem_alu_result : inout STD_LOGIC_VECTOR(31 downto 0); -- probs don't need?
        -- did not include alu_result, alu_op, instr, rs1, rs2, or rd
        
        -- MEM/WB pipeline registers
        mem_wb_reg_write : out STD_LOGIC;
        mem_wb_alu_src : out STD_LOGIC;
        mem_wb_mem_read : out STD_LOGIC;
        mem_wb_mem_write : out STD_LOGIC;
        mem_wb_load_addr : out STD_LOGIC;
        mem_wb_alu_result  : out STD_LOGIC_VECTOR(31 downto 0); -- did not use and possibly delete?
        mem_wb_rd : out STD_LOGIC_VECTOR(4 downto 0);
        -- <add other mem_wb registers>
        mem_wb_mem_data : out STD_LOGIC_VECTOR(31 downto 0)
        -- did not include jump, branch, npc, alu_op, imm, instr, reg1_data, reg2_data, rs1, rs2, or rd
      
    );
end pipeline_registers;

architecture Behavioral of pipeline_registers is
begin
    process(clk, reset)
    begin
        if (reset = '1') then
            if_id_reg_write <= '0';
            if_id_alu_src <= '0';
            if_id_mem_read <= '0';
            if_id_mem_write <= '0';
            if_id_branch <= '0';
            if_id_jump <= '0';
            if_id_load_addr <= '0';
            if_id_instr <= (others => '0');
            if_id_npc    <= (others => '0');
            if_id_rd   <= (others => '0');
            if_id_alu_op <= (others => '0');
            -- not doing if_id_reg1_data, if_id_reg2_data, or if_id_imm since they are set to in and not inout
            
            id_ex_reg_write <= '0';
            id_ex_alu_src <= '0';
            id_ex_mem_read <= '0';
            id_ex_mem_write <= '0';
            id_ex_branch <= '0';
            id_ex_jump <= '0';
            id_ex_load_addr <= '0';
            id_ex_npc  <= (others => '0');
            id_ex_rd  <= (others => '0'); -- why needed?
            id_ex_reg1_data  <= (others => '0');
            id_ex_reg2_data  <= (others => '0');
            -- <add other id_ex registers>
            id_ex_imm  <= (others => '0');
            
            ex_mem_reg_write  <= '0';
            ex_mem_alu_src  <= '0';
            ex_mem_mem_read  <= '0';
            ex_mem_mem_write  <= '0';
            ex_mem_load_addr  <= '0';
            ex_mem_reg1_data <= (others => '0');
            ex_mem_reg2_data <= (others => '0');
            -- <add other ex_mem registers>
            ex_mem_npc <= (others => '0');
            ex_mem_imm <= (others => '0');
            ex_mem_rd <= (others => '0');

        elsif rising_edge(clk) then                  -- basically acts as a NOP Stall
            if (stall_counter > 1 or start_stall = '1' or if_id_branch = '1') then  -- if stall, then insert a NOP
                if_id_reg_write <= '0';
                if_id_alu_src <= '0';
                if_id_mem_read <= '0';
                if_id_mem_write <= '0';
                if_id_branch <= '0';
                if_id_jump <= '0';
                if_id_load_addr <= '0';
                if_id_instr <= (others => '0');
                if_id_npc    <= (others => '0');
                if_id_alu_op    <= (others => '0');
                if_id_rd    <= (others => '0');
            
            else               -- when stall resumes, the old fetched instruction should still be there

                if_id_reg_write <= reg_write;
                if_id_alu_src <= alu_src;
                if_id_mem_read <= mem_read;
                if_id_mem_write <= mem_write;
                if_id_branch <= branch;
                if_id_jump <= jump;
                if_id_load_addr <= load_addr;
                if_id_instr <= instr;
                if_id_npc <= npc;
                if_id_alu_op <= alu_op;
                if_id_rd <= rd;
                
            end if;    
            
              
            -- let instructions prior to stall complete, or move to next state
            
            -- if_id --> id_ex cascade       
            id_ex_reg_write <= if_id_reg_write;
            id_ex_alu_src <= if_id_alu_src;
            id_ex_mem_read <= if_id_mem_read;
            id_ex_mem_write <= if_id_mem_write;
            id_ex_branch <= if_id_branch;
            id_ex_jump <= if_id_jump;
            id_ex_load_addr <= if_id_load_addr;
            id_ex_instr <= if_id_instr;
            id_ex_npc <= if_id_npc;
            id_ex_reg1_data <= if_id_reg1_data; -- loaded from in port
            id_ex_reg2_data <= if_id_reg2_data; -- loaded from in port
            -- <add other id_ex registers>
            id_ex_imm <= if_id_imm; -- loaded from in port
            id_ex_alu_op <= if_id_alu_op; -- id_ex is an out
            id_ex_rd <= if_id_rd;

            -- id_ex --> ex_mem cascade                        
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_alu_src <= id_ex_alu_src;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_branch <= id_ex_branch;
            ex_mem_jump <= id_ex_jump;
            ex_mem_load_addr <= id_ex_load_addr;
            ex_mem_reg1_data <= id_ex_reg1_data;
            ex_mem_reg2_data <= id_ex_reg2_data;
            -- <add other ex_mem registers>
            ex_mem_npc <= id_ex_npc;
            ex_mem_imm <= id_ex_imm; -- ex_mem is an out
            ex_mem_alu_result <= id_ex_alu_result;
            ex_mem_rd <= id_ex_rd;

            -- ex_mem --> mem_wb cascade
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_alu_src <= ex_mem_alu_src;
            mem_wb_mem_read <= ex_mem_mem_read;
            mem_wb_mem_write <= ex_mem_mem_write;
            mem_wb_load_addr <= ex_mem_load_addr;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_mem_data <= mem_data;

        end if;
    end process;
end Behavioral;