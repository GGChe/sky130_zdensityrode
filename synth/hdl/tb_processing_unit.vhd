library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity processing_unit_tb is
end processing_unit_tb;

architecture Behavioral of processing_unit_tb is
    -- Testbench signals
    signal clk               : STD_LOGIC := '0';
    signal rst               : STD_LOGIC := '1';
    signal data_in           : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal threshold_in      : STD_LOGIC_VECTOR(15 downto 0) := x"01F4"; -- Default threshold: 500
    signal class_a_thresh_in : STD_LOGIC_VECTOR(7 downto 0) := x"05"; -- Default Class A threshold: 5
    signal class_b_thresh_in : STD_LOGIC_VECTOR(7 downto 0) := x"01"; -- Default Class B threshold: 1
    signal timeout_period_in : STD_LOGIC_VECTOR(15 downto 0) := x"1388"; -- Default Timeout: 5000
    signal spike_detection   : STD_LOGIC;
    signal event_out         : STD_LOGIC_VECTOR(1 downto 0);

begin
    -- Instantiate the processing_unit
    processing_unit_uut: entity work.processing_unit
        Port Map (
            clk               => clk,
            rst               => rst,
            data_in           => data_in,
            threshold_in      => threshold_in,
            class_a_thresh_in => class_a_thresh_in,
            class_b_thresh_in => class_b_thresh_in,
            timeout_period_in => timeout_period_in,
            spike_detection   => spike_detection,
            event_out         => event_out
        );

    -- Clock Generation
    clk_process : process
    begin
        while True loop
            clk <= '0';
            wait for 10 ns; -- Half clock period
            clk <= '1';
            wait for 10 ns; -- Half clock period
        end loop;
    end process;

    -- Stimulus Process
    stim_proc: process
        file data_file : text open read_mode is "../rtl/20170224_slice02_04_CTRL2_0005_17_int_downsampled_chunk_int16.txt";
        variable row     : line;
        variable int_in  : integer;
    begin
        -- Wait for global reset to finish
        wait for 50 ns;
        rst <= '0';  -- Release reset

        -- Apply initial values for thresholds
        threshold_in <= x"01F4"; -- Threshold: 1000
        class_a_thresh_in <= x"0A"; -- Class A threshold: 10
        class_b_thresh_in <= x"02"; -- Class B threshold: 2
        timeout_period_in <= x"1F40"; -- Timeout: 8000

        -- Read and apply data from the file
        while not endfile(data_file) loop
            readline(data_file, row);
            read(row, int_in);
            data_in <= std_logic_vector(to_signed(int_in, data_in'length));
            wait until rising_edge(clk); -- Synchronize with clock
        end loop;

        -- End simulation after all data is read
        report "Simulation complete. No more data available." severity NOTE;
        wait;
    end process;

end Behavioral;
