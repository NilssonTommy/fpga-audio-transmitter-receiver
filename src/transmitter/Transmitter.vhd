
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity Transmitter is
generic(
    periodTb_100kHz :integer := 500;         -- Use this one for frequency 100k Hz for TB
    periodTb_100Hz : integer := 500000;     -- Use this one for frequency 100 Hz for TB
    periodTa : integer := 10);
port(
    clk :  in std_logic;
    reset: in std_logic;
    Ta : buffer std_logic;
    Tb : buffer std_logic;
    Ts : buffer std_logic;
	B:	 in	std_logic;
	Q:	 buffer std_logic_vector(7 downto 0);
	LEDR: out std_logic_vector(7 downto 0)
);
 end entity;

architecture a of Transmitter is
    signal counter1: std_logic_vector(18 downto 0);
    signal counter2: std_logic_vector(3 downto 0);
	type StateType is
	(U,SAR0,SAR1,SAR2,SAR3,SAR4,SAR5,SAR6,SAR7, STOP, START);
	signal state: StateType;
begin
        
	process(clk)
    begin
        if rising_edge(clk) then
			if reset='0' then
				counter1 <= (others => '0');
                counter2 <= (others => '0');
                Tb <= '0';
                Ta <= '0';
            else
                 --Change frequency for Tb periodTb_100kHz for 100kHz  or periodTb_100Hz for 100Hz

                if counter1=periodTb_100kHz-1 then
                	counter1 <= (others => '0');
                    counter2 <= counter2+1;
                    Tb <= '1';
    
                    if counter2 = periodTa-1 then
                    	Ta <= '1';
                        counter2 <= (others => '0');
                    else
                        Ta <= '0';
                    end if;

				else
					counter1 <= counter1+1;
					Tb <= '0';                    
            	end if; 
        	end if;
       	end if;    
	end process;


	process(clk)
	begin
		if rising_edge(clk) then
			if reset='0' then
				Q <= (others => '0');
				state <= START;
            else
				if Ts = '1' then
					state <= SAR7;
					Q <= "10000000"; -- half of the maximum value
				elsif Tb = '1' then
					case state is
						when SAR7 =>
							Q(7) <= B; -- MSB
							Q(6) <= '1';
							state <= SAR6;
						when SAR6 =>
							Q(6) <= B;
							Q(5) <= '1';
							state <= SAR5;
						when SAR5 =>
							Q(5) <= B; 
							Q(4) <= '1';
							state <= SAR4;
						when SAR4 =>
							Q(4) <= B; 
							Q(3) <= '1';
							state <= SAR3;
						when SAR3 =>
							Q(3) <= B; 
							Q(2) <= '1';
							state <= SAR2;
						when SAR2 =>
							Q(2) <= B;
							Q(1) <= '1';
							state <= SAR1;
						when SAR1 =>
							Q(1) <= B;
							Q(0) <= '1';
							state <= SAR0;
						when SAR0 =>
							Q(0) <= B; -- LSB;
							state <= STOP;
						when others => -- do nothing in STOP state
					end case;
				end if;
			end if;
		end if;
	end process;

	Ts <= Tb and Ta;
	LEDR <= Q;
	

end architecture;
