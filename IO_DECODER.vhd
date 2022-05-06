-- IO DECODER for SCOMP
-- This eliminates the need for a lot of AND decoders or Comparators
--	that would otherwise be spread around the top-level BDF

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IO_DECODER IS

  PORT
  (
	IO_ADDR   				: IN		STD_LOGIC_VECTOR(10 downto 0);
	IO_CYCLE  				: IN		STD_LOGIC;
	SWITCH_EN 				: OUT 	STD_LOGIC;
	LED_EN    				: OUT 	STD_LOGIC;
	TIMER_EN  				: OUT 	STD_LOGIC;
	HEX0_EN   				: OUT 	STD_LOGIC;
	HEX1_EN   				: OUT 	STD_LOGIC;
	PXL_ADDR1				: OUT		STD_LOGIC;
	PXL_ADDR2				: OUT		STD_LOGIC;
	RGB_16					: OUT		STD_LOGIC;
	GREEN_24					: OUT		STD_LOGIC;
	RED_24					: OUT		STD_LOGIC;
	BLUE_24					: OUT		STD_LOGIC;
	AUTO_INC					: OUT		STD_LOGIC;
	SET_ALL					: OUT		STD_LOGIC;
	SET_RANGE				: OUT		STD_LOGIC;
	X							: OUT		STD_LOGIC;
	SET_ALL_X				: OUT		STD_LOGIC;
	SET_RANGE_X				: OUT		STD_LOGIC;
	CLEAR_ALL				: OUT		STD_LOGIC;
	CLEAR_RANGE				: OUT		STD_LOGIC;
	SET_RANGE_X_BLUE_24	: OUT		STD_LOGIC;
	GET_BUSY					: OUT		STD_LOGIC
  );

END ENTITY;

ARCHITECTURE a OF IO_DECODER IS

  SIGNAL  ADDR_INT  : INTEGER RANGE 0 TO 2047;
 
begin

	ADDR_INT <= TO_INTEGER(UNSIGNED(IO_ADDR));
			 
	SWITCH_EN    			<= '1' WHEN (ADDR_INT = 16#000#) and (IO_CYCLE = '1') ELSE '0';
	LED_EN       			<= '1' WHEN (ADDR_INT = 16#001#) and (IO_CYCLE = '1') ELSE '0';
	TIMER_EN     			<= '1' WHEN (ADDR_INT = 16#002#) and (IO_CYCLE = '1') ELSE '0';
	HEX0_EN      			<= '1' WHEN (ADDR_INT = 16#004#) and (IO_CYCLE = '1') ELSE '0';
	HEX1_EN      			<= '1' WHEN (ADDR_INT = 16#005#) and (IO_CYCLE = '1') ELSE '0';

	PXL_ADDR1				<= '1' WHEN (ADDR_INT = 16#0B0#) and (IO_CYCLE = '1') ELSE '0';
	PXL_ADDR2				<= '1' WHEN (ADDR_INT = 16#0B1#) and (IO_CYCLE = '1') ELSE '0';
	RGB_16					<= '1' WHEN (ADDR_INT = 16#0B2#) and (IO_CYCLE = '1') ELSE '0';
	GREEN_24					<= '1' WHEN (ADDR_INT = 16#0B3#) and (IO_CYCLE = '1') ELSE '0';
	RED_24					<= '1' WHEN (ADDR_INT = 16#0B4#) and (IO_CYCLE = '1') ELSE '0';
	BLUE_24					<= '1' WHEN (ADDR_INT = 16#0B5#) and (IO_CYCLE = '1') ELSE '0';
	AUTO_INC					<= '1' WHEN (ADDR_INT = 16#0B6#) and (IO_CYCLE = '1') ELSE '0';
	SET_ALL					<= '1' WHEN (ADDR_INT = 16#0B7#) and (IO_CYCLE = '1') ELSE '0';
	SET_RANGE				<= '1' WHEN (ADDR_INT = 16#0B8#) and (IO_CYCLE = '1') ELSE '0';
	X							<= '1' WHEN (ADDR_INT = 16#0B9#) and (IO_CYCLE = '1') ELSE '0';
	SET_ALL_X				<= '1' WHEN (ADDR_INT = 16#0BA#) and (IO_CYCLE = '1') ELSE '0';
	SET_RANGE_X				<= '1' WHEN (ADDR_INT = 16#0BB#) and (IO_CYCLE = '1') ELSE '0';
	CLEAR_ALL				<= '1' WHEN (ADDR_INT = 16#0BC#) and (IO_CYCLE = '1') ELSE '0';
	CLEAR_RANGE				<= '1' WHEN (ADDR_INT = 16#0BD#) and (IO_CYCLE = '1') ELSE '0';
	SET_RANGE_X_BLUE_24	<= '1' WHEN (ADDR_INT = 16#0BE#) and (IO_CYCLE = '1') ELSE '0';
	GET_BUSY					<= '1' WHEN (ADDR_INT = 16#0BF#) and (IO_CYCLE = '1') ELSE '0';
 
END a;