


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--Receiver

entity receiver is
generic(
	tbperiod:integer := 500 -- number of clockpulses per time slot
	tbperiod_24kHz : integer := 208 -- For frequency of 24k Hz. (LAB6)
);
port(
	reset, cp2: in std_logic;
	DRx: in std_logic;
	Tb2: buffer std_logic;
	Ts2: buffer std_logic;
	Q2: out std_logic_vector(7 downto 0);
	LEDR: out std_logic_vector(7 downto 0)
);
end entity;

architecture arch of receiver is

	type StateType is (U,STOP,START,TRIG);
	signal state: StateType;
	signal counter: std_logic_vector(8 downto 0);
	signal bitcounter: std_logic_vector(3 downto 0);
	signal shift_Register: std_logic_vector(9 downto 0);
	signal flag: std_logic;
	signal DRx_1: std_logic;
	signal DRx_2: std_logic;

begin

	process(cp2) begin
		if rising_edge(cp2) then
			DRx_1 <= DRx;
			DRx_2 <= DRx_1;
		end if;
	end process;

	process(cp2) -- generate trig signals, sync'd to input
	begin
		if rising_edge(cp2) then
			if reset='0' then
				state <= STOP;
				Ts2 <= '0';
				Tb2 <= '0';
			else
				Tb2 <= '0'; -- default
				Ts2 <= '0';
				case state is
					when STOP => -- wait for stop bit
						if DRx_2='1' then
							state <= START;
							Ts2 <= '0';
						end if;
					when START => -- wait for start bit
						if DRx_2='0' then
							state <= TRIG;
							counter <= (others => '0');
							bitcounter <= (others => '0');
						end if;
					when others => -- state TRIG
						counter <= counter+1;
						if counter=tbperiod_24kHz/2-1 then
							Tb2 <= '1';
							bitcounter <= bitcounter+1;
							if bitcounter=9 then
								state <= STOP;
								Ts2 <= '1';
							end if;
						elsif counter=tbperiod_24kHz-1 then
							counter <= (others => '0');
						end if;
				end case;
			end if;
		end if;
	end process;

 	process(cp2)
    begin
        if rising_edge(cp2) then
            if Tb2 = '1' then
                shift_Register(9) <= DRx_2;
                shift_Register(8 downto 0) <= shift_Register(9 downto 1);
				if Ts2 = '1' then
					flag <= '1';
	       		end if;
			end if;

			if flag = '1' then
				Q2 <= shift_Register(8 downto 1);
				LEDR <= shift_Register(8 downto 1);
				flag <= '0';
			end if;


        end if;
    end process;


end architecture;
