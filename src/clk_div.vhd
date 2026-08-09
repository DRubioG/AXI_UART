library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clk_div is
    generic (
        G_CYCLE : integer := 100
    );
    port (
        CLK_I : in std_logic;
        RST_N_I : in std_logic;
        EN_I : in std_logic;
        CLK_MID_O : out std_logic;
        CLK_DIV_O : out std_logic
    );
end entity clk_div;

architecture rtl of clk_div is

signal r_cont : integer range 0 to G_CYCLE;

begin


    process (CLK_I)
    begin
        if rising_edge(CLK_I) then
            if RST_N_I = '0' then
                r_cont <= 0;
            elsif EN_I = '1' then
                r_cont <= r_cont+1;
                if r_cont >= G_CYCLE-1 then
                    r_cont <= 0;
                end if;
            end if;
        end if;
    end process;
    

    process (CLK_I)
    begin
        if rising_edge(CLK_I) then
            if RST_N_I = '0' then
                CLK_MID_O <= '0';
            elsif EN_I = '1' then
                CLK_MID_O <= '0';
                if r_cont = G_CYCLE/2-1 then
                    CLK_MID_O <= '1';
                end if;
            end if;
        end if;
    end process;

    
    process (CLK_I)
    begin
        if rising_edge(CLK_I) then
            if RST_N_I = '0' then
                CLK_DIV_O <= '0';
            elsif EN_I = '1' then
                CLK_DIV_O <= '0';
                if r_cont >= G_CYCLE-1 then
                    CLK_DIV_O <= '1';
                end if;
            end if;
        end if;
    end process;

end architecture;