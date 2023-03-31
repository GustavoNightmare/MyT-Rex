library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.all;
--use ieee.numeric_std.ALL;
use ieee.std_logic_arith.ALL;

entity draw_trex is
	generic(
		H_counter_size: natural:= 10;
		V_counter_size: natural:= 10
	);
	port(
		clk: in std_logic;
		jump: in std_logic;
		pixel_x: in integer;
		pixel_y: in integer;
		rgbDrawColor: out std_logic_vector(11 downto 0) := (others => '0');
		
		agachado: in std_logic
	);
end draw_trex;

architecture arch of draw_trex is
	constant PIX : integer := 16;
	constant COLS : integer := 40;
	constant T_FAC : integer := 100000;
	constant nubeSpeed : integer := 60;
 
	signal Cambio_movimiento: std_logic :='0';
	signal resetear_actual:std_logic:='1';
	signal subirybajar: std_logic :='0';
	signal cloudX_1: integer := 40;
	signal cloudY_1: integer := 8;
	signal nube_2X: integer := COLS;
	signal nube_2Y: integer := 3;
	signal ojo_rex: integer:=2;
	
	-- T-Rex
	signal trexX: integer := 8;
	signal trexY: integer := 24;
	signal saltando: std_logic := '0';	
	signal agachando: std_logic:='0';
	signal cactusSpeed : integer := 40;
	-- Pterodactilo
	signal PterodactiloX: integer := COLS; 
	signal pterodactiloY: integer :=24;
	
	-- Cactus	
	signal cactusX_1: integer := COLS;
	signal cactusY: integer := 24;
	signal cactusX_2: integer := COLS;
	signal cactusY_2: integer := 24;
	signal cactusX_3: integer := COLS;	
	signal velocidad_Increase: integer := 0;

	
	---- Game over
	signal GameOver: std_logic :='1';
-- Sprites
type sprite_block is array(0 to 15, 0 to 15) of integer range 0 to 1;
constant cloud: sprite_block:=(  
                            (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 5
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 6
									 (0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0), -- 7
									 (0,0,0,0,0,1,1,0,0,0,1,1,1,1,0,0), -- 8
									 (0,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1), -- 9
									 (1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1), -- 10
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 11
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15

constant trex_2: sprite_block:=(
                           (0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 0 
									(0,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1), -- 1 
									(0,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1), -- 2
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 3
									(0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0), -- 4
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0), -- 5
									(0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 6
									(1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 7
									(1,1,0,0,1,1,1,1,1,1,1,0,0,1,0,0), -- 8
									(1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
									(0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 10
									(0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 11
									(0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
		 							(0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0), -- 13
									(0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0), -- 14
									(0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0));-- 15
constant trex_3: sprite_block:=(
                           (0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 0 
									(0,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1), -- 1 
									(0,0,0,0,0,0,0,1,1,0,0,1,1,1,1,1), -- 2
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 3
									(0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0), -- 4
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0), -- 5
									(0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 6
									(1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 7
									(1,1,0,0,1,1,1,1,1,1,1,0,0,1,0,0), -- 8
									(1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
									(0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 10
									(0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 11
									(0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
		 							(0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0), -- 13
									(0,0,0,0,0,1,0,0,1,1,0,0,0,0,0,0), -- 14
									(0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0));-- 15		

constant cactus: sprite_block :=((0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,1,0,1,1,1,0,1,1,0,0,0), -- 4
									 (0,0,0,0,1,1,0,1,1,1,0,1,1,0,0,0), -- 5
									 (0,0,0,0,1,1,0,1,1,1,0,1,1,0,0,0), -- 6
									 (0,0,0,0,1,1,0,1,1,1,0,1,1,0,0,0), -- 7
									 (0,0,0,0,1,1,0,1,1,1,0,1,1,0,0,0), -- 8
									 (0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0), -- 9
									 (0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0), -- 10
									 (0,0,0,0,0,0,0,1,1,1,0,0,1,0,0,0), -- 11
									 (0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0));-- 15		
constant nube_2: sprite_block :=(
                            (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 5
									 (0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0), -- 6
									 (0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0), -- 7
									 (0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 8
									 (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 9
									 (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 10
									 (0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0), -- 11
									 (0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0), -- 12
		 							 (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 13
									 (0,0,0,0,1,1,1,0,0,1,1,1,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15											 
 constant cactus_2: sprite_block :=(
                            (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,1,1,1,1,1,0,0,1,0,0), -- 3
									 (0,0,0,0,0,0,1,1,1,1,1,0,0,1,0,0), -- 4
									 (0,0,0,0,0,1,1,1,1,1,1,0,0,1,1,0), -- 5
									 (0,0,0,1,1,1,1,1,1,1,1,0,0,1,1,0), -- 6
									 (0,0,1,1,1,1,1,1,1,1,1,0,1,1,1,0), -- 7
									 (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 8
									 (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 9
									 (0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,0), -- 10
									 (0,1,0,0,0,1,1,1,1,1,1,0,0,0,0,0), -- 11
									 (0,1,0,0,0,1,1,1,1,1,1,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0));-- 15		
 constant dibujo_sol: sprite_block :=(
                            (1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1), -- 0 
									 (0,1,0,0,0,0,1,0,0,1,0,0,0,0,1,0), -- 1 
									 (0,0,1,0,0,0,1,1,1,1,0,0,0,1,0,0), -- 2
									 (0,0,0,1,0,1,1,1,1,1,1,0,1,0,0,0), -- 3
									 (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 4
									 (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 5
									 (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 6
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 7
									 (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 8
									 (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 9
									 (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 10
									 (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 11
									 (0,0,0,1,0,0,1,1,1,1,0,0,1,0,0,0), -- 12
		 							 (0,0,1,0,0,0,1,0,0,1,0,0,0,1,0,0), -- 13
									 (0,1,0,0,0,0,1,0,0,1,0,0,0,0,1,0), -- 14
									 (1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1));-- 15	
constant dibujo_pterodactilo: sprite_block :=
(
                            (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0), -- 3
									 (0,0,0,0,1,0,0,1,1,1,1,0,0,0,0,0), -- 4
									 (0,0,0,1,1,0,1,1,1,1,1,1,0,0,0,0), -- 5
									 (0,0,1,0,1,1,1,1,1,1,1,1,1,0,0,0), -- 6
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 7
									 (0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0), -- 8
									 (0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0), -- 9
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 10
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 11
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15
constant dibujo_pterodactilo2: sprite_block :=
(
                            (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0), -- 3
									 (0,0,0,0,1,0,0,0,1,1,1,0,0,0,0,0), -- 4
									 (0,0,0,1,1,0,0,1,1,1,0,0,0,0,0,0), -- 5
									 (0,0,1,0,1,1,1,1,1,1,1,1,1,0,0,0), -- 6
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 7
									 (0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0), -- 8
									 (0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0), -- 9
									 (0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0), -- 10
									 (0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0), -- 11
									 (0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15
constant deadTrex: sprite_block :=(
                            (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 5
									 (0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0), -- 6
									 (0,0,0,0,0,0,0,1,0,0,1,1,0,0,0,1), -- 7
									 (0,0,1,1,1,0,0,1,0,1,1,0,0,1,1,1), -- 8
									 (0,1,1,1,1,1,0,1,0,1,0,1,1,1,1,1), -- 9
									 (0,1,1,1,1,1,0,1,0,1,1,1,1,1,1,0), -- 10
									 (0,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0), -- 11
									 (1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 12
		 							 (1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0), -- 13
									 (1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1), -- 14
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1));-- 15		
type color_arr is array(0 to 1) of std_logic_vector(11 downto 0);
									 
constant sprite_color : color_arr := ("001010111110", "000011110000");
constant sprite_color_ojo : color_arr := ("001010111110", "111111111111");
--10001100001
constant sprite_color_catus2 : color_arr := ("001010111110", "010001100001");
constant sprite_color_NUBE2 : color_arr := ("001010111110", "000110101111");
constant sprite_color_sol: color_arr :=("001010111110", "111111110000");
constant sprite_color_pterodactilo: color_arr :=("001010111110", "101000101101");
constant sprite_color_dinomuerto: color_arr :=("111111111111", "111100000000");
type sprite_block2 is array(0 to 15, 0 to 25) of integer range 0 to 1;
constant trex_agachado : sprite_block2 :=(
                            (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 3
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,1,1), -- 4
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,1,1), -- 5
									 (0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 6
									 (0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 7
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 8
									 (0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0), -- 9
									 (0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0), -- 10
									 (0,0,0,0,0,1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,0,0,0), -- 11
									 (0,0,0,0,0,0,1,1,1,0,1,1,0,0,0,0,0,0,1,1,1,0,1,1,0,0), -- 12
		 							 (0,0,0,0,0,0,0,1,1,1,0,1,1,1,0,0,0,0,1,1,0,0,1,1,1,0), -- 13
									 (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,1,1,1,0,1,0,0,0,0));-- 15	
begin
	draw_objects: process(clk, pixel_x, pixel_y)	
	
	variable sprite_x : integer := 0;
	variable sprite_y : integer := 0;
	
	begin			
		if(clk'event and clk='1') then		
		
		if(gameOver='0') then 
			-- Dibuja el fondo 1010111110
			rgbDrawColor <= "0010" & "1011" & "1110";
					
			-- Dibuja el suelo 11001100110
			if(pixel_y > 399 and pixel_y <406 ) then
				rgbDrawColor <= "0110" & "0110" & "0110";	
				
			end if;
				if(pixel_y >405) then
				rgbDrawColor <= "1001" & "0101" & "0000";	
				--100101010000
			end if;
			
			sprite_x := pixel_x mod PIX;
			sprite_y := pixel_y mod PIX;
							
			-- Nube 1
			if (pixel_x / PIX = 5 ) and (pixel_y / PIX = 2) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
				end if;
					if (pixel_x / PIX = 6 ) and (pixel_y / PIX = 2) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
				end if;
					if (pixel_x / PIX = 8 ) and (pixel_y / PIX = 1) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
				end if;
					if (pixel_x / PIX = 17 ) and (pixel_y / PIX = 3) then 
				rgbDrawColor <= sprite_color_NUBE2(nube_2(sprite_y, sprite_x));
				end if;
				if (pixel_x / PIX = 18 ) and (pixel_y / PIX = 3) then 
				rgbDrawColor <= sprite_color_NUBE2(nube_2(sprite_y, sprite_x));
				end if;
				if (pixel_x / PIX = 20 ) and (pixel_y / PIX = 3) then 
				rgbDrawColor <= sprite_color(cloud(sprite_y, sprite_x));
				end if;
				if (pixel_x / PIX = 30) and (pixel_y / PIX = 3) then 
				rgbDrawColor <= sprite_color_NUBE2(nube_2(sprite_y, sprite_x));
				end if;
			
				
				-- sol
		
		if ((pixel_x / PIX = 13) and (pixel_y / PIX = 3)) then 
				rgbDrawColor <= sprite_color_sol(dibujo_sol(sprite_y, sprite_x));
				
			end if;	
						
			-- Cactus1
			if ((pixel_x / PIX = cactusX_1) and (pixel_y / PIX = cactusY)) then 
				rgbDrawColor <= sprite_color(cactus(sprite_y, sprite_x));
			end if;	
			if ((pixel_x / PIX = cactusX_3) and (pixel_y / PIX = cactusY)) then 
				rgbDrawColor <= sprite_color(cactus_2(sprite_y, sprite_x));
			end if;
		--cactus 2	
		if ((pixel_x / PIX = cactusx_2) and (pixel_y / PIX = cactusY)) then 
				rgbDrawColor <= sprite_color_catus2(cactus_2(sprite_y, sprite_x));
			end if;				
		--- nube 2
	if ((pixel_x / PIX = nube_2X) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_nUBE2(nube_2(sprite_y, sprite_x));
			end if;		
			-- Pterodactilo
		
			if ((pixel_x / PIX = pterodactiloX) and (pixel_y / PIX = pterodactiloY)) then 
			   if(pterodactiloX mod 2 = 0 ) then
				rgbDrawColor <= sprite_color_pterodactilo(dibujo_pterodactilo(sprite_y, sprite_x));
				else
				rgbDrawColor <= sprite_color_pterodactilo(dibujo_pterodactilo2(sprite_y, sprite_x));
				end if;
				end if;		
			
			-- T-Rex
			
		
			if (saltando = '1') then
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
		
					rgbDrawColor <= sprite_color_ojo(trex_2(sprite_y, sprite_x));
					
					end if;
		      	
			else
				if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
			rgbDrawColor <= sprite_color_ojo(trex_2(sprite_y, sprite_x));
				end if;
			end if;

		---- agacharse
		if(agachando = '0') then
				if	((pixel_x / pix = trexX) and (pixel_y /pix  = trexY)) then
			rgbDrawColor <=SPRite_color_ojo(trex_agachado(sprite_y,sprite_x));
				end if;
	
			else
				if	((pixel_x / pix = trexX) and (pixel_y / PIX = trexY)) then
					
			rgbDrawColor <= sprite_color_ojo(trex_2(sprite_y, sprite_x));		
				end if;
			end if;
	
	else
	 rgbDrawColor <= "0000" & "0000" & "0000";
	 if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
	 
			rgbDrawColor <= sprite_color_dinomuerto(deadTrex(sprite_y, sprite_x));
			
				end if;
			end if;
			
	
	
	end if;
	end process;
	
	actions: process(clk, jump)	
	variable cactusCount: integer := 0;
	variable nubeCount: integer := 0;
	variable cactusCount2: integer := 0;
		variable cactusCount3: integer := 0;
	variable pterodactiloCount: integer :=0;
	

	begin		
		
			if(clk'event and clk = '1') then
			
			-- Salto
			if(jump = '1') then
				saltando <= '1';
				if (trexY > 20) then
					trexY <= trexY - 1;
				else
					saltando <= '0';
				end if;
			else
			   saltando <= '0';
				if (trexY < 24) then
					trexY <= trexY + 1;
				end if;
			end if;		
			-- agachando
			
			if(agachado = '0') then
				agachando <= '0';
				else 
				agachando <='1';
				
			end if;		
			
			-- Movimiento del Cactus
			-- Cactus Movement
		
			
			if (cactusCount >= T_FAC * cactusSpeed) then
				if (cactusX_1 <= 0) then
					cactusX_1 <= COLS;
					
					Velocidad_Increase <=Velocidad_Increase + 1;
	            				
				else
					cactusX_1 <= cactusX_1 - 1;					
				end if;
				cactusCount := 0;
			end if;
			cactusCount := cactusCount + 1;
				-- CACTUS 2
				if (cactusCount3 >= T_FAC * cactusSpeed+5000) then
				if (cactusX_2 <= 0) then
					
					cactusx_2<=COLS+11;

	            				
				else
					
	            cactusX_2 <= cactusX_2 - 1;				
				end if;
				cactusCount3 := 0;
			end if;
			cactusCount3 := cactusCount3 + 1;
			-- CACTUS 3
			if (cactusCount2 >= T_FAC * cactusSpeed * 2 ) then
				if (cactusX_3 <= 0) then
					cactusX_3 <= COLS + 9;
				else
					cactusX_3 <= cactusX_3 - 1;			
				end if;
				cactusCount2 := 0;
			end if;
			cactusCount2 := cactusCount2 + 1;
			
			--Pterodactilo
			if (PterodactiloCount >= T_FAC * cactusSpeed/2) then
				if (pterodactiloX <= 0) then
					pterodactiloX <= COLS+5;
	            			
				else
					pterodactiloX <= pterodactiloX - 1;				
				end if;
				pterodactiloCount := 0;
			end if;
			pterodactiloCount := pterodactiloCount + 1;
			
			
			--colisiones
			
			if(cactusX_1=trexX and cactusY= trexY ) then
		gameOver<= '1';
		elsif (cactusX_2=trexX and cactusy= trexY ) then	
		gameOver<= '1';
		elsif (cactusX_3=trexX and cactusY= trexY ) then
		gameOver<= '1';
		elsif (pterodactiloX=trexX and pterodactiloY = trexY ) then
		 if(agachando='1') then 
		  gameOver<= '1';
		else 
		gameOver<='0';
		end if;
		else 
		gameOver<='0';
		end if;
			
				------ Aumento gradual de la velocidad
		
			
			------ Reseteo de valores
			if (GameOver= '1' ) then
			CactusX_1<=COLS;
			cactusX_2<=COLS+12;
			cactusX_3<=COLS+15;
			pterodactiloX<=COLS+18;
			cactusSpeed<=40;
		
			end if;
	
		
			
			
				-- MOVIMIENto de nube 
				if (nubeCount >= T_FAC * cactusSpeed ) then
				if (nube_2X <= 0) then
					nube_2X <= COLS;			
				else
					nube_2X <= nube_2X -1;			
				end if;
				nubeCount := 0;
			end if;
			nubeCount := nubeCount + 1;
			
		end if;
	end process;
	
end arch;