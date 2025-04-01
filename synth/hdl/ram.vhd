library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram_unit is
    generic (
        N_CHANNELS : integer; -- Number of channels (processing units)
        DATA_WIDTH : integer  -- Width of each integer
    );
    port (
        clk           : in  STD_LOGIC;                                  -- Clock
        rst           : in  STD_LOGIC;                                  -- Reset
        data_in       : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);    -- Input data
        write_en      : in  STD_LOGIC;                                  -- Write enable
        read_en       : in  STD_LOGIC;                                  -- Read enable
        ram_full      : out STD_LOGIC;                                  -- RAM full flag
        data_out      : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);    -- Data output for processing units
        channel_index : out integer range 0 to N_CHANNELS-1             -- Current channel being processed
    );
end ram_unit;

architecture Behavioral of ram_unit is

    -- RAM storage: Array of integers (each channel holds one integer)
    type ram_array_type is array (0 to N_CHANNELS-1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal ram : ram_array_type;

    -- Internal signals
    signal write_pointer : integer range 0 to N_CHANNELS-1;
    signal read_pointer  : integer range 0 to N_CHANNELS-1;
    signal full_flag     : STD_LOGIC;
    signal process_flag  : STD_LOGIC;

begin

    -- Write Operation
    process(clk, rst)
    begin
        if rst = '1' then
            write_pointer <= 0;
            full_flag <= '0';
        elsif rising_edge(clk) then
            if write_en = '1' and full_flag = '0' then
                ram(write_pointer) <= data_in;
                if write_pointer = N_CHANNELS - 1 then
                    full_flag <= '1'; -- RAM full
                else
                    write_pointer <= write_pointer + 1;
                end if;
            end if;
        end if;
    end process;

    -- Read Operation
    process(clk, rst)
    begin
        if rst = '1' then
            read_pointer <= 0;
            process_flag <= '0';
        elsif rising_edge(clk) then
            if full_flag = '1' and read_en = '1' then
                data_out <= ram(read_pointer); -- Output data
                channel_index <= read_pointer;
                if read_pointer = N_CHANNELS - 1 then
                    process_flag <= '1'; -- Processing completed
                else
                    read_pointer <= read_pointer + 1;
                end if;
            end if;
        end if;
    end process;

    -- Map internal signals to output
    ram_full <= full_flag;

end Behavioral;
