library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processing_unit is
    Port (
        clk                 : in  STD_LOGIC;
        rst                 : in  STD_LOGIC;
        data_in             : in  STD_LOGIC_VECTOR(15 downto 0);
        threshold_in        : in  STD_LOGIC_VECTOR(15 downto 0);
        class_a_thresh_in   : in  STD_LOGIC_VECTOR(7 downto 0);
        class_b_thresh_in   : in  STD_LOGIC_VECTOR(7 downto 0);
        timeout_period_in   : in  STD_LOGIC_VECTOR(15 downto 0);
        spike_detection     : out STD_LOGIC;
        event_out           : out STD_LOGIC_VECTOR(1 downto 0)
    );
end processing_unit;

architecture Behavioral of processing_unit is

    -- Signal declarations
    signal spike_detected_internal : STD_LOGIC; -- Internal signal for spike detection
    
    -- Component declarations
    component aso is
        Port (
            clk            : in  STD_LOGIC;
            rst            : in  STD_LOGIC;
            data_in        : in  STD_LOGIC_VECTOR(15 downto 0);
            threshold_in   : in  STD_LOGIC_VECTOR(15 downto 0);
            spike_detected : out STD_LOGIC
        );
    end component;
    
    component classifier is
        Port (
            clk                 : in  std_logic;
            reset               : in  std_logic;
            current_detection   : in  std_logic;
            event_out           : out STD_LOGIC_VECTOR(1 downto 0);
            class_a_thresh_in   : in  STD_LOGIC_VECTOR(7 downto 0);
            class_b_thresh_in   : in  STD_LOGIC_VECTOR(7 downto 0);
            timeout_period_in   : in  STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

begin

    -- Instantiate the `aso` spike detector
    spike_detector_instance : aso
        Port map (
            clk            => clk,
            rst            => rst,
            data_in        => data_in,
            threshold_in   => threshold_in, -- Pass threshold signal
            spike_detected => spike_detected_internal
        );

    -- Instantiate the `classifier`
    classifier_instance : classifier
        Port map (
            clk                 => clk,
            reset               => rst,
            current_detection   => spike_detected_internal,
            event_out           => event_out,
            class_a_thresh_in   => class_a_thresh_in,
            class_b_thresh_in   => class_b_thresh_in,
            timeout_period_in   => timeout_period_in
        );

    -- Assign the internal spike_detected signal to the output port
    spike_detection <= spike_detected_internal;

end Behavioral;
