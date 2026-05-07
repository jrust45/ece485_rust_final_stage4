library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hazard_detection_unit is
    Port (
        reset :          in STD_LOGIC;
        if_id_mem_read : in STD_LOGIC;                      -- previous instr mem read
        if_id_load_addr : in STD_LOGIC;                     -- previous instr load addr
        if_id_reg_write : in STD_LOGIC;     -- added for previous instr writes to a reg
        instr    : in STD_LOGIC_VECTOR(31 downto 0);        -- current  instr
        if_id_instr    : in STD_LOGIC_VECTOR(31 downto 0);  -- previous instr
        --if_id_rd       : in STD_LOGIC_VECTOR(4 downto 0);   -- previous instr destination register
        rs1      : in STD_LOGIC_VECTOR(4 downto 0);         -- current  instr source register
        rs2      : in STD_LOGIC_VECTOR(4 downto 0);         -- current  instr source register
        -- need any other input registers?
        stall_counter  : in integer range 0 to 3 := 0;
        start_stall    : out STD_LOGIC
    );
end hazard_detection_unit;

-- NOTE: only looking  one instruction before dependency (not two or three before)
architecture Behavioral of hazard_detection_unit is
   signal opcode, if_id_opcode       : STD_LOGIC_VECTOR(6 downto 0);
   signal double_stall : STD_LOGIC := '0';
   signal if_id_rd_sig : STD_LOGIC_VECTOR(4 downto 0);
begin
    -- would opcodes of current and previous instructions be useful?
    opcode <= instr(6 downto 0);
    if_id_opcode <= if_id_instr(6 downto 0);
    if_id_rd_sig <= if_id_instr(11 downto 7);
    
    process(if_id_mem_read, if_id_load_addr, if_id_reg_write, if_id_rd_sig, rs1, rs2, if_id_opcode, opcode, stall_counter, reset) --ignored for rn -- any others?)
    begin      
        if (reset = '1') then
            start_stall <= '0';
        -- stall cases, dependency on a (1)load from memory, (2) load_addr, (3) add, (4) addi/subi
        
        elsif (stall_counter > 0) then
            start_stall <= '0';
            
        -- Load hazard (so if instr in IF/ID is lw or la and its destination matches rs1 or rs2 of current instr)
        elsif ( (if_id_mem_read = '1' or if_id_load_addr = '1') and (if_id_rd_sig = rs1 or if_id_rd_sig = rs2) and (if_id_rd_sig /= "00000") ) then
            start_stall <= '1';
            
        -- branch hazard
        elsif ( opcode = "1100011" and if_id_reg_write = '1' and if_id_rd_sig /= "00000" and (if_id_rd_sig = rs1 or if_id_rd_sig = rs2) ) then
            start_stall <= '1';
           
        -- stall cases for branch or jump, needing time to calulate branch address, etc
        else        
                start_stall <= '0';
        end if;    
        
    end process;
end Behavioral;