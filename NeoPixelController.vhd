-- WS2812 communication interface starting point for
-- ECE 2031 final project spring 2022.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
-- use ieee.std_logic_arith.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity NeoPixelController is

	port(
		clk_10M  				: in   	std_logic;
		resetn					: in   	std_logic;
		io_write					: in   	std_logic;
		data_inout   			: inout	std_logic_vector(15 downto 0); -- input data
		PXL_ADDR1				: in		std_logic;
		PXL_ADDR2				: in		std_logic;
		RGB_16					: in		std_logic;
		GREEN_24					: in		std_logic;
		RED_24					: in		std_logic;
		BLUE_24					: in		std_logic;
		AUTO_INC					: in		std_logic;
		SET_ALL					: in		std_logic;
		SET_RANGE				: in		std_logic;
		X							: in		std_logic;
		SET_ALL_X				: in		std_logic;
		SET_RANGE_X				: in		std_logic;
		CLEAR_ALL				: in		std_logic;
		CLEAR_RANGE				: in		std_logic;
		SET_RANGE_X_BLUE_24	: in		std_logic;
		GET_BUSY					: in		std_logic;
		sda   					: out		std_logic -- output to neopixel
	); 

end entity;

architecture internals of NeoPixelController is
	
	-- Signals for the RAM read and write addresses
	signal ram_read_addr, ram_write_addr : std_logic_vector(7 downto 0);
	-- RAM write enable
	signal ram_we : std_logic;

	-- Signals for data coming out of memory
	signal ram_read_data : std_logic_vector(23 downto 0);
	-- Signal to store the current output pixel's color data
	signal pixel_buffer : std_logic_vector(23 downto 0);

	-- Signal SCOMP will write to before it gets stored into memory
	signal ram_write_buffer : std_logic_vector(23 downto 0);

	-- RAM interface state machine signals
	type write_states is (idle, storing, set_all_pixels, set_range_pixels, set_all_x_pixels, set_range_x_pixels);
	signal wstate: write_states;
	
	signal save_ram_write_addr : std_logic_vector(7 downto 0);  -- signal used to store the original ram_write_addr value so that we can revert back to this address after the peripheral is finished performing its task
	signal ram_read_buffer		: std_logic_vector(23 downto 0); -- signal used to store pixel data at specified address
	signal address_1				: std_logic_vector(7 downto 0);  -- signal used to store pixel address 1
	signal address_2				: std_logic_vector(7 downto 0);  -- signal used to store pixel address 2
	signal green_bits 			: std_logic_vector(7 downto 0);	-- signal used to store G component of 24-bit color update
	signal red_bits				: std_logic_vector(7 downto 0);  -- signal used to store R component of 24-bit color update
	signal blue_bits				: std_logic_vector(7 downto 0);  -- signal used to store B component of 24-bit color update
	signal auto_inc_value		: std_logic_vector(7 downto 0);  -- signal used to store auto-increment value
	signal x_value					: std_logic_vector(7 downto 0);  -- signal used to store x-value for EVERY_XTH_PIXEL mode
	signal is_busy					: std_logic;							-- signal used to communicate with SCOMP that the NeoPixel Peripheral is currently performing a task
	
begin

	-- This is the RAM that will store the pixel data.
	-- It is dual-ported.  SCOMP will access port "A",
	-- and the NeoPixel controller will access port "B".
	pixelRAM : altsyncram
	GENERIC MAP (
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_a => "BYPASS",
		clock_enable_output_b => "BYPASS",
		indata_reg_b => "CLOCK0",
		init_file => "pixeldata.mif",
		intended_device_family => "Cyclone V",
		lpm_type => "altsyncram",
		numwords_a => 256,
		numwords_b => 256,
		operation_mode => "BIDIR_DUAL_PORT",
		outdata_aclr_a => "NONE",
		outdata_aclr_b => "NONE",
		outdata_reg_a => "UNREGISTERED",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
		read_during_write_mode_port_b => "NEW_DATA_NO_NBE_READ",
		widthad_a => 8,
		widthad_b => 8,
		width_a => 24,
		width_b => 24,
		width_byteena_a => 1,
		width_byteena_b => 1,
		wrcontrol_wraddress_reg_b => "CLOCK0"
	)
	PORT MAP (
		address_a => ram_write_addr,
		address_b => ram_read_addr,
		clock0 => clk_10M,
		data_a => ram_write_buffer,
		data_b => x"000000",
		wren_a => ram_we,
		wren_b => '0',
		q_a => ram_read_buffer,
		q_b => ram_read_data
	);
	
	-- Read address 1
	data_inout <= "00000000" & address_1 when ((PXL_ADDR1 = '1') and (io_write = '0')) else "ZZZZZZZZZZZZZZZZ";
	
	-- Read address 2
	data_inout <= "00000000" & address_2 when ((PXL_ADDR2 = '1') and (io_write = '0')) else "ZZZZZZZZZZZZZZZZ";
	
	-- Read 16-bit color
	data_inout <= ram_read_buffer(15 downto 11) & ram_read_buffer(23 downto 18) & ram_read_buffer(7 downto 3) when ((RGB_16 = '1') and (io_write = '0')) else "ZZZZZZZZZZZZZZZZ";
	
	-- Read 24-bit color
	data_inout <= "00000000" & ram_read_buffer(23 downto 16) 	when ((GREEN_24 = '1') and (io_write = '0')) 	else "ZZZZZZZZZZZZZZZZ";
	data_inout <= "00000000" & ram_read_buffer(15 downto 8)	 	when ((RED_24 = '1') and (io_write = '0')) 		else "ZZZZZZZZZZZZZZZZ";
	data_inout <= "00000000" & ram_read_buffer(7 downto 0) 		when ((BLUE_24 = '1') and (io_write = '0')) 		else "ZZZZZZZZZZZZZZZZ";
	
	-- Read auto-increment value
	data_inout <= "00000000" & auto_inc_value when ((AUTO_INC = '1') and (io_write = '0')) else "ZZZZZZZZZZZZZZZZ";
	
	-- Read x value
	data_inout <= "00000000" & x_value when ((X = '1') and (io_write = '0')) else "ZZZZZZZZZZZZZZZZ";
	
	-- Read the is_busy signal to see if the NeoPixel Peripheral is currently performing a task
	data_inout <= "000000000000000" & is_busy when ((GET_BUSY = '1') and (io_write = '0')) else "ZZZZZZZZZZZZZZZZ";


	-- This process implements the NeoPixel protocol by
	-- using several counters to keep track of clock cycles,
	-- which pixel is being written to, and which bit within
	-- that data is being written.
	process (clk_10M, resetn)
		-- protocol timing values (in 100s of ns)
		constant t1h : integer := 8; -- high time for '1'
		constant t0h : integer := 3; -- high time for '0'
		constant ttot : integer := 12; -- total bit time
		
		constant npix : integer := 256;

		-- which bit in the 24 bits is being sent
		variable bit_count   : integer range 0 to 31;
		-- counter to count through the bit encoding
		variable enc_count   : integer range 0 to 31;
		-- counter for the reset pulse
		variable reset_count : integer range 0 to 1000;
		-- Counter for the current pixel
		variable pixel_count : integer range 0 to 255;
		
		
	begin
		
		if resetn = '0' then
			-- reset all counters
			bit_count := 23;
			enc_count := 0;
			reset_count := 1000;
			-- set sda inactive
			sda <= '0';

		elsif (rising_edge(clk_10M)) then

			-- This IF block controls the various counters
			if reset_count /= 0 then -- in reset/end-of-frame period
				-- during reset period, ensure other counters are reset
				pixel_count := 0;
				bit_count := 23;
				enc_count := 0;
				-- decrement the reset count
				reset_count := reset_count - 1;
				-- load data from memory
				pixel_buffer <= ram_read_data;
				
			else -- not in reset period (i.e. currently sending data)
				-- handle reaching end of a bit
				if enc_count = (ttot-1) then -- is end of this bit?
					enc_count := 0;
					-- shift to next bit
					pixel_buffer <= pixel_buffer(22 downto 0) & '0';
					if bit_count = 0 then -- is end of this pixels's data?
						bit_count := 23; -- start a new pixel
						pixel_buffer <= ram_read_data;
						if pixel_count = npix-1 then -- is end of all pixels?
							-- begin the reset period
							reset_count := 1000;
						else
							pixel_count := pixel_count + 1;
						end if;
					else
						-- if not end of this pixel's data, decrement count
						bit_count := bit_count - 1;
					end if;
				else
					-- within a bit, count to achieve correct pulse widths
					enc_count := enc_count + 1;
				end if;
			end if;
			
			
			-- This IF block controls the RAM read address to step through pixels
			if reset_count /= 0 then
				ram_read_addr <= x"00";
			elsif (bit_count = 1) AND (enc_count = 0) then
				-- increment the RAM address as each pixel ends
				ram_read_addr <= ram_read_addr + 1;
			end if;
			
			
			-- This IF block controls sda
			if reset_count > 0 then
				-- sda is 0 during reset/latch
				sda <= '0';
			elsif 
				-- sda is 1 in the first part of a bit.
				-- Length of first part depends on if bit is 1 or 0
				( (pixel_buffer(23) = '1') and (enc_count < t1h) )
				or
				( (pixel_buffer(23) = '0') and (enc_count < t0h) )
				then sda <= '1';
			else
				sda <= '0';
			end if;
			
		end if;
	end process;
	
	
	
	process(clk_10M, resetn, PXL_ADDR1)
	begin
		
		case wstate is
			when idle =>
				is_busy <= '0';
			when others =>
				is_busy <= '1';
		end case;
	
		-- For this implementation, saving the memory address
		-- doesn't require anything special.  Just latch it when
		-- SCOMP sends it.
		if resetn = '0' then
			ram_write_addr 		<= x"00";
			ram_write_buffer 		<= x"000000";
			save_ram_write_addr 	<= x"00";
			address_1 				<= x"00";
			address_2 				<= x"FF";
			green_bits				<= x"00";
			red_bits 				<= x"00";
			blue_bits 				<= x"00";
			auto_inc_value 		<= x"01";
			x_value 					<= x"01";
			is_busy 					<= '0';
			ram_we 					<= '0';
			wstate 					<= idle;
		
		elsif rising_edge(clk_10M) then
		-- The sequnce of events needed to store data into memory will be
		-- implemented with a state machine.
		-- Although there are ways to more simply connect SCOMP's I/O system
		-- to an altsyncram module, it would only work with under specific 
		-- circumstances, and would be limited to just simple writes.  Since
		-- you will probably want to do more complicated things, this is an
		-- example of something that could be extended to do more complicated
		-- things.
		-- Note that 'ram_we' is *not* implemented as a Moore output of this state
		-- machine, because Moore outputs are susceptible to glitches, and
		-- that's a bad thing for memory control signals.
			case wstate is
			
				when idle =>
		
					-- If SCOMP is writing to the address register...
					if (io_write = '1') and (PXL_ADDR1 = '1') then
						ram_write_addr <= data_inout(7 downto 0);
						address_1 <= data_inout(7 downto 0);
						
					-- Sets address_2 to some user-defined address
					elsif (io_write = '1') and (PXL_ADDR2 = '1') then
						address_2 <= data_inout(7 downto 0);
						if (data_inout(7 downto 0) < address_1) then
							address_2 <= address_1;
						end if;
						
					-- Automatically increments the ram-write address to the user-set auto-increment value
					elsif ((RGB_16 = '1') and (io_write = '0')) or ((BLUE_24 = '1') and (io_write = '0')) then
						ram_write_addr <= ram_write_addr + auto_inc_value;
					
					
					elsif (io_write = '1') then
				
						-- Stores RGB value in respective registers and sets pixel to 16-bit color
						if (RGB_16 = '1') then
							-- latch the current data into the temporary storage register,
							-- because this is the only time it'll be available.
							-- Convert RGB565 to 24-bit color
							green_bits <= data_inout(10 downto 5) & "00";
							red_bits <= data_inout(15 downto 11) & "000";
							blue_bits <= data_inout(4 downto 0) & "000";
							ram_write_buffer <= data_inout(10 downto 5) & "00" & data_inout(15 downto 11) & "000" & data_inout(4 downto 0) & "000";
							-- can raise ram_we on the upcoming transition, because data
							-- won't be stored until next clock cycle.
							ram_we <= '1';
							-- Change state
							wstate <= storing;
						
						-- Stores G component of 24-bit color
						elsif (GREEN_24 ='1') then
							green_bits <= data_inout(7 downto 0);
							wstate <= idle;
							
						-- Stores R component of 24-bit color
						elsif (RED_24 ='1') then
							red_bits <= data_inout(7 downto 0);
							wstate <= idle;
						
						-- Stores B component of 24-bit color and writes 24-bit RGB value
						elsif (BLUE_24 ='1') then
							blue_bits <= data_inout(7 downto 0);
							ram_write_buffer <= green_bits & red_bits & data_inout(7 downto 0);
							ram_we <= '1';
							wstate <= storing;
						
						-- Sets user-specified auto-increment value
						elsif (AUTO_INC = '1') then 
							auto_inc_value <= data_inout(7 downto 0);
							wstate <= idle;
							
						-- Sets all pixels to user-specified 16-bit color
						elsif (SET_ALL = '1') then
							save_ram_write_addr <= ram_write_addr;
							ram_write_addr <= x"00";
							green_bits <= data_inout(10 downto 5) & "00";
							red_bits <= data_inout(15 downto 11) & "000";
							blue_bits <= data_inout(4 downto 0) & "000";
							ram_write_buffer <= data_inout(10 downto 5) & "00" & data_inout(15 downto 11) & "000" & data_inout(4 downto 0) & "000";							
							ram_we <= '1';
							wstate <= set_all_pixels;
						
						-- Sets all pixels within the range of address 1 to address 2 to user-specified 16-bit color
						elsif (SET_RANGE = '1') then
							save_ram_write_addr <= ram_write_addr;
							ram_write_addr <= address_1;
							green_bits <= data_inout(10 downto 5) & "00";
							red_bits <= data_inout(15 downto 11) & "000";
							blue_bits <= data_inout(4 downto 0) & "000";
							ram_write_buffer <= data_inout(10 downto 5) & "00" & data_inout(15 downto 11) & "000" & data_inout(4 downto 0) & "000";
							ram_we <= '1';
							wstate <= set_range_pixels;
							
						-- Sets x value for the set-every-xth-pixel mode
						elsif (X = '1') then
							x_value <= data_inout(7 downto 0);
							wstate <= idle;
						
						-- Sets every xth pixel to a user-specified 16-bit address
						elsif (SET_ALL_X = '1') then
							save_ram_write_addr <= ram_write_addr;
							ram_write_addr <= x"00";
							green_bits <= data_inout(10 downto 5) & "00";
							red_bits <= data_inout(15 downto 11) & "000";
							blue_bits <= data_inout(4 downto 0) & "000";
							ram_write_buffer <= data_inout(10 downto 5) & "00" & data_inout(15 downto 11) & "000" & data_inout(4 downto 0) & "000";
							ram_we <= '1';
							wstate <= set_all_x_pixels;
						
						-- Sets every xth pixel within the range of address 1 to address 2 to a user-specified 16-bit color						
						elsif (SET_RANGE_X = '1') then
							save_ram_write_addr <= ram_write_addr;
							ram_write_addr <= address_1;
							green_bits <= data_inout(10 downto 5) & "00";
							red_bits <= data_inout(15 downto 11) & "000";
							blue_bits <= data_inout(4 downto 0) & "000";
							ram_write_buffer <= data_inout(10 downto 5) & "00" & data_inout(15 downto 11) & "000" & data_inout(4 downto 0) & "000";
							ram_we <= '1';
							wstate <= set_range_x_pixels;
						
						-- Sets all pixels to 0 (clears entire NeoPixel board)
						elsif (CLEAR_ALL = '1') then
							save_ram_write_addr <= ram_write_addr;
							ram_write_addr <= x"00";						
							ram_write_buffer <= "000000000000000000000000";
							ram_we <= '1';
							wstate <= set_all_pixels;
						
						-- Clears all pixels within range of address 1 to address 2
						elsif (CLEAR_RANGE = '1') then
							save_ram_write_addr <= ram_write_addr;
							ram_write_addr <= address_1;
							ram_write_buffer <= "000000000000000000000000";
							ram_we <= '1';
							wstate <= set_range_pixels;
							
						-- Sets every xth pixel within the range of address 1 to address 2 to a user-specificed 24-bit color
						elsif (SET_RANGE_X_BLUE_24 = '1') then
							save_ram_write_addr <= ram_write_addr;
							ram_write_addr <= address_1;
							blue_bits <= data_inout(7 downto 0);
							ram_write_buffer <= green_bits & red_bits & data_inout(7 downto 0);
							ram_we <= '1';
							wstate <= set_range_x_pixels;
						
						end if;
						
					end if;
				
				-- Storing state to store a 16-bit or 24-bit color to pixel address in ram_write_addr
				when storing =>
					ram_we <= '0';
					ram_write_addr <= ram_write_addr + auto_inc_value;
					wstate <= idle;
				
				-- State to set all pixels to a user-specified 16-bit color
				when set_all_pixels =>
					if (ram_write_addr >= 255) then
						ram_write_addr <= save_ram_write_addr;
						ram_we <= '0';
						wstate <= idle;
					else
						ram_write_addr <= ram_write_addr + 1;
						wstate <= set_all_pixels;
					end if;
						
				-- State to set all pixels within a range of address 1 to address 2 to a user-specified 16-bit color
				when set_range_pixels =>
					if (ram_write_addr >= address_2) then
						ram_write_addr <= save_ram_write_addr;
						ram_we <= '0';
						wstate <= idle;
					else
						ram_write_addr <= ram_write_addr + 1;
						wstate <= set_range_pixels;
					end if;				
				
				-- State to set every xth pixel to a user-specified 16-bit color
				when set_all_x_pixels =>
					if ((ram_write_addr >= 255 - x_value) or x_value < 1) then
						ram_write_addr <= save_ram_write_addr;
						ram_we <= '0';
						wstate <= idle;
					else
						ram_write_addr <= ram_write_addr + x_value;
						wstate <= set_all_x_pixels;
					end if;
				
				-- State to set every xth pixel within a range of address 1 and address 2 to a user-specified 16-bit or 24-bit color
				when set_range_x_pixels =>
					if ((ram_write_addr >= address_2 - x_value) or x_value < 1) then
						ram_write_addr <= save_ram_write_addr;
						ram_we <= '0';
						wstate <= idle;
					else
						ram_write_addr <= ram_write_addr + x_value;
						wstate <= set_range_x_pixels;
					end if;
					
				--Edge cases
				when others =>
					wstate <= idle;
				
			end case;
			
		end if;
		
	end process;
	
end internals;
