library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity neo is
    Port (
        clk            : in  STD_LOGIC;
        rst            : in  STD_LOGIC;
        data_in        : in  STD_LOGIC_VECTOR(15 downto 0);
        threshold_in   : in  STD_LOGIC_VECTOR(15 downto 0); -- External threshold input (16-bit)
        spike_detected : out STD_LOGIC  -- Spike detection signal
    );
end neo;

architecture Behavioral of neo is
    -- State enumeration
    type state_type is (TRAINING, OPERATION);
    signal state       : state_type;

    -- Internal signals
    signal x1, x2, x3 : signed(15 downto 0);
    signal neo        : signed(15 downto 0);
    signal threshold  : signed(15 downto 0); -- Internal threshold (16-bit)

    -- Intermediate signals for wider calculations
    signal mult_x2_x2, mult_x3_x1 : signed(31 downto 0);
    signal diff_result            : signed(31 downto 0);

begin
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset signals
            x1 <= (others => '0');
            x2 <= (others => '0');
            x3 <= (others => '0');
            neo <= (others => '0');
            threshold <= to_signed(10000, 16); -- Default threshold during reset
            state <= TRAINING;
            spike_detected <= '0';
        elsif rising_edge(clk) then
            -- Shift samples
            x1 <= x2;
            x2 <= x3;
            x3 <= signed(data_in);

            -- State machine
            case state is
                when TRAINING =>
                    threshold <= to_signed(10000, 16); -- Default training threshold
                    state <= OPERATION;

                when OPERATION =>
                    -- Use external threshold input
                    threshold <= signed(threshold_in);

                    -- Perform calculations
                    mult_x2_x2 <= x2 * x2;
                    mult_x3_x1 <= x3 * x1;
                    diff_result <= abs(mult_x2_x2 - mult_x3_x1);
                    neo <= resize(diff_result, neo'length);

                    -- Spike detection with resized neo
                    if resize(neo, 16) > threshold then
                        spike_detected <= '1';
                    else
                        spike_detected <= '0';
                    end if;

            end case;
        end if;
    end process;
end Behavioral;
