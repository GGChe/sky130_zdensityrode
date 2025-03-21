library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity classify_event_unit_tb is
-- Testbench entity has no ports
end classify_event_unit_tb;

architecture Behavioral of classify_event_unit_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component processing_unit is
        Port (
            clk                 : in  std_logic;
            reset               : in  std_logic;
            current_detection   : in  std_logic;
            event_out           : out integer
        );
    end component;

    -- Signals for the testbench
    signal clk                 : std_logic := '0';
    signal reset               : std_logic := '1';
    signal current_detection   : std_logic := '0';
    signal event_out           : integer;

    -- Clock period definition
    constant clk_period        : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: processing_unit
        Port map (
            clk                 => clk,
            reset               => reset,
            current_detection   => current_detection,
            event_out           => event_out
        );

    -- Clock generation process
    clk_process :process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset for a few clock cycles
        reset <= '1';
        wait for clk_period * 5;
        reset <= '0';  -- Release reset

        -- First, no spikes for 1000 samples
        current_detection <= '0';
        wait for clk_period * 1000;

        -- Add 1 spike
        current_detection <= '1';
        wait for clk_period;
        current_detection <= '0';

        -- Wait for 5000 samples
        wait for clk_period * 5000;

        for i in 1 to 5 loop
            current_detection <= '1';
            wait for clk_period;
            current_detection <= '0';
            wait for clk_period * 100;
        end loop;

        -- Wait for some time to observe the outputs
        wait for clk_period * 5000;

        -- Third test case
        for i in 1 to 10 loop
            current_detection <= '1';
            wait for clk_period;
            current_detection <= '0';
            wait for clk_period * 100;
        end loop;

        -- Wait for some time to observe the outputs
        wait for clk_period * 1000;

        -- End simulation
        wait;
    end process;

    -- Monitor process to display the event_out signal
    monitor_proc: process(clk)
    begin
        if rising_edge(clk) then
            -- Display event_out and current_detection at each clock cycle
            report "Time: " & integer'image(integer(now / 1 ns)) & " ns, current_detection: " &
                   std_logic'image(current_detection) & ", event_out: " & integer'image(event_out);
        end if;
    end process;

end Behavioral;
