EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Teensy 4.1 Theremin Main Board"
Date "2020-10-06"
Rev "0.1"
Comp "(c) Vadim Lopatin, 2020"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L teensy41-mcu_module:Teensy41 U1
U 1 1 5F6F5E98
P 5500 2850
F 0 "U1" H 5500 4265 50  0000 C CNN
F 1 "Teensy41" H 5500 4174 50  0000 C CNN
F 2 "Module:Teensy41" H 5500 4150 50  0001 C CNN
F 3 "https://www.pjrc.com/store/teensy41.html" H 5500 4150 50  0001 C CNN
	1    5500 2850
	1    0    0    -1  
$EndComp
$Comp
L teensy41_main_board-rescue:TeensyAudioD-MCU_Module U2
U 1 1 5F6F668C
P 8250 2300
F 0 "U2" H 8250 3215 50  0000 C CNN
F 1 "TeensyAudioD" H 8250 3124 50  0000 C CNN
F 2 "Module:TeensyAudioD" H 8250 3150 50  0001 C CNN
F 3 "https://www.pjrc.com/store/teensy3_audio.html" H 8250 3150 50  0001 C CNN
	1    8250 2300
	1    0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_02x15_Odd_Even J1
U 1 1 5F6F6FD9
P 2600 3150
F 0 "J1" H 2650 4167 50  0000 C CNN
F 1 "LCD_CONTROLS" H 2650 4076 50  0000 C CNN
F 2 "Connector_IDC:IDC-Header_2x15_P2.54mm_Vertical" H 2600 3150 50  0001 C CNN
F 3 "~" H 2600 3150 50  0001 C CNN
	1    2600 3150
	1    0    0    -1  
$EndComp
$Comp
L Connector:AudioJack3 J3
U 1 1 5F6FB224
P 9700 2900
F 0 "J3" H 9682 3225 50  0000 C CNN
F 1 "LINE_OUT_BIG" H 9682 3134 50  0000 C CNN
F 2 "Connector_Audio:Jack_6.35mm_ST_008G_04" H 9700 2900 50  0001 C CNN
F 3 "~" H 9700 2900 50  0001 C CNN
	1    9700 2900
	-1   0    0    1   
$EndComp
$Comp
L Connector:AudioJack3 J2
U 1 1 5F6FC123
P 9700 2300
F 0 "J2" H 9682 2625 50  0000 C CNN
F 1 "LINE_IN" H 9682 2534 50  0000 C CNN
F 2 "Connector_Audio:Jack_3.5mm_CUI_SJ1-3533NG_Horizontal" H 9700 2300 50  0001 C CNN
F 3 "~" H 9700 2300 50  0001 C CNN
	1    9700 2300
	-1   0    0    1   
$EndComp
$Comp
L Connector:Conn_01x03_Male J4
U 1 1 5F6FEF3F
P 3200 5000
F 0 "J4" H 3308 5281 50  0000 C CNN
F 1 "VOL_SENSOR" H 3308 5190 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Horizontal" H 3200 5000 50  0001 C CNN
F 3 "~" H 3200 5000 50  0001 C CNN
	1    3200 5000
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x03_Male J5
U 1 1 5F6FF6D4
P 3200 6300
F 0 "J5" H 3308 6581 50  0000 C CNN
F 1 "PITCH_SENSOR" H 3308 6490 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Horizontal" H 3200 6300 50  0001 C CNN
F 3 "~" H 3200 6300 50  0001 C CNN
	1    3200 6300
	1    0    0    -1  
$EndComp
Wire Wire Line
	8750 2400 8950 2400
Wire Wire Line
	8750 2300 8950 2300
Wire Wire Line
	8950 2300 8950 2400
Connection ~ 8950 2400
Wire Wire Line
	8950 2400 9300 2400
Wire Wire Line
	9500 2200 9250 2200
Wire Wire Line
	9250 2200 9250 2100
Wire Wire Line
	9250 2100 8750 2100
Wire Wire Line
	8750 2200 9150 2200
Wire Wire Line
	9150 2200 9150 2300
Wire Wire Line
	9150 2300 9500 2300
Wire Wire Line
	8750 2800 8900 2800
Wire Wire Line
	8900 2800 8900 3000
Wire Wire Line
	8900 3000 9300 3000
Wire Wire Line
	8750 2700 9000 2700
Wire Wire Line
	9000 2700 9000 2800
Wire Wire Line
	9000 2800 9200 2800
Wire Wire Line
	9500 2900 9100 2900
Wire Wire Line
	9100 2900 9100 2600
Wire Wire Line
	9100 2600 8750 2600
$Comp
L Connector:Conn_01x02_Male J6
U 1 1 5F70D684
P 2650 1750
F 0 "J6" H 2758 1931 50  0000 C CNN
F 1 "POWER_IN" H 2758 1840 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 2650 1750 50  0001 C CNN
F 3 "~" H 2650 1750 50  0001 C CNN
	1    2650 1750
	1    0    0    -1  
$EndComp
$Comp
L plt133t10w:PLT133T10W U3
U 1 1 5F765E12
P 7950 3450
F 0 "U3" H 8128 3321 50  0000 L CNN
F 1 "PLT133T10W" H 8128 3230 50  0000 L CNN
F 2 "Module:PLT133T10W" H 7950 3500 50  0001 C CNN
F 3 "" H 7950 3500 50  0001 C CNN
	1    7950 3450
	1    0    0    -1  
$EndComp
$Comp
L Connector:AudioJack3 J8
U 1 1 5F771708
P 9250 5550
F 0 "J8" H 9232 5875 50  0000 C CNN
F 1 "EXPR_PED" H 9232 5784 50  0000 C CNN
F 2 "Connector_Audio:Jack_6.35mm_ST_008G_04" H 9250 5550 50  0001 C CNN
F 3 "~" H 9250 5550 50  0001 C CNN
	1    9250 5550
	-1   0    0    1   
$EndComp
$Comp
L Connector:AudioJack3 J7
U 1 1 5F7723C9
P 9700 3500
F 0 "J7" H 9682 3825 50  0000 C CNN
F 1 "LINE_OUT_35" H 9682 3734 50  0000 C CNN
F 2 "Connector_Audio:Jack_3.5mm_CUI_SJ1-3533NG_Horizontal" H 9700 3500 50  0001 C CNN
F 3 "~" H 9700 3500 50  0001 C CNN
	1    9700 3500
	-1   0    0    1   
$EndComp
Wire Wire Line
	9500 3600 8900 3600
Wire Wire Line
	8900 3600 8900 3000
Connection ~ 8900 3000
Wire Wire Line
	9500 3500 9100 3500
Wire Wire Line
	9100 3500 9100 2900
Connection ~ 9100 2900
Wire Wire Line
	9500 3400 9200 3400
Wire Wire Line
	9200 3400 9200 2800
Connection ~ 9200 2800
Wire Wire Line
	9200 2800 9500 2800
NoConn ~ 8750 3000
NoConn ~ 8750 3100
NoConn ~ 8750 3200
NoConn ~ 7750 3000
NoConn ~ 7750 2900
NoConn ~ 7750 2800
NoConn ~ 7750 2700
NoConn ~ 7750 2600
Entry Wire Line
	4300 1600 4400 1700
Entry Wire Line
	6650 1700 6750 1800
Entry Wire Line
	6650 1800 6750 1900
Entry Wire Line
	6650 1900 6750 2000
Entry Wire Line
	9150 1900 9250 2000
Entry Wire Line
	9150 1800 9250 1900
Entry Wire Line
	9150 1700 9250 1800
Wire Wire Line
	8750 1700 9150 1700
Wire Wire Line
	8750 1800 9150 1800
Wire Wire Line
	8750 1900 9150 1900
Text Label 6200 1700 0    50   ~ 0
VIN
Text Label 6200 1800 0    50   ~ 0
GND
Text Label 6200 1900 0    50   ~ 0
3V3
Text Label 4500 1700 0    50   ~ 0
GND
Text Label 8900 1700 0    50   ~ 0
GND
Text Label 8900 1800 0    50   ~ 0
GND
Text Label 8900 1900 0    50   ~ 0
3V3
Text Label 8900 2100 0    50   ~ 0
LIN_L
Text Label 8900 2200 0    50   ~ 0
LIN_R
Text Label 8800 2600 0    50   ~ 0
LOUT_R
Text Label 8800 2700 0    50   ~ 0
LOUT_L
Entry Bus Bus
	6650 950  6750 1050
Entry Bus Bus
	7000 950  7100 1050
Wire Wire Line
	6000 1700 6650 1700
Wire Wire Line
	6000 1800 6650 1800
Wire Wire Line
	6000 1900 6650 1900
Entry Wire Line
	7100 1600 7200 1700
Entry Wire Line
	7100 1700 7200 1800
Entry Wire Line
	7100 1800 7200 1900
Entry Wire Line
	7100 1900 7200 2000
Entry Wire Line
	7100 2000 7200 2100
Entry Wire Line
	7100 2200 7200 2300
Entry Wire Line
	7100 2300 7200 2400
Wire Wire Line
	7200 1700 7750 1700
Wire Wire Line
	7200 1800 7750 1800
Wire Wire Line
	7200 1900 7750 1900
Wire Wire Line
	7200 2000 7750 2000
Wire Wire Line
	7200 2100 7750 2100
Wire Wire Line
	7200 2300 7750 2300
Wire Wire Line
	7200 2400 7750 2400
Entry Bus Bus
	4200 950  4300 1050
Wire Wire Line
	4400 1700 5000 1700
Text Label 7300 1700 0    50   ~ 0
I2S_MCLK
Text Label 7300 1800 0    50   ~ 0
I2S_BCLK
Text Label 7300 1900 0    50   ~ 0
I2S_LRCK
Text Label 7300 2300 0    50   ~ 0
I2C_SCL
Text Label 7300 2400 0    50   ~ 0
I2C_SDA
Entry Wire Line
	6650 2000 6750 2100
Entry Wire Line
	6650 2200 6750 2300
Entry Wire Line
	6650 2300 6750 2400
Entry Wire Line
	6650 2400 6750 2500
Entry Wire Line
	6650 2500 6750 2600
Entry Wire Line
	4300 2400 4400 2500
Entry Wire Line
	4300 2500 4400 2600
Wire Wire Line
	6000 2000 6650 2000
Wire Wire Line
	6000 2200 6650 2200
Wire Wire Line
	6000 2300 6650 2300
Wire Wire Line
	6000 2400 6650 2400
Wire Wire Line
	6000 2500 6650 2500
Wire Wire Line
	4400 2500 5000 2500
Wire Wire Line
	4400 2600 5000 2600
Text Label 6200 2000 0    50   ~ 0
I2S_MCLK
Text Label 6200 2200 0    50   ~ 0
I2S_BCLK
Text Label 6200 2300 0    50   ~ 0
I2S_LRCK
Text Label 6200 2400 0    50   ~ 0
I2C_SCL
Text Label 6200 2500 0    50   ~ 0
I2C_SDA
Text Label 4500 2500 0    50   ~ 0
I2S_DOUT1A
Text Label 4500 2600 0    50   ~ 0
I2S_DIN1
Entry Bus Bus
	3600 950  3700 1050
Entry Wire Line
	6650 3100 6750 3200
Entry Wire Line
	4300 3000 4400 3100
Wire Wire Line
	6000 3100 6650 3100
Wire Wire Line
	4400 3100 5000 3100
Text Label 6200 3100 0    50   ~ 0
GND
Text Label 4500 3100 0    50   ~ 0
3V3
Entry Wire Line
	4300 2700 4400 2800
Entry Wire Line
	4300 2600 4400 2700
Wire Wire Line
	4400 2700 5000 2700
Wire Wire Line
	4400 2800 5000 2800
Text Label 4500 2800 0    50   ~ 0
LCD_CS
Text Label 4500 3300 0    50   ~ 0
LCD_DC
Entry Wire Line
	4300 2800 4400 2900
Entry Wire Line
	4300 2900 4400 3000
Wire Wire Line
	4400 2900 5000 2900
Wire Wire Line
	4400 3000 5000 3000
Text Label 4500 2900 0    50   ~ 0
LCD_MOSI
Text Label 4500 3000 0    50   ~ 0
LCD_MISO
Entry Wire Line
	6650 3000 6750 3100
Wire Wire Line
	6000 3000 6650 3000
Text Label 6200 3000 0    50   ~ 0
LCD_SCK
Entry Wire Line
	4300 3100 4400 3200
Entry Wire Line
	4300 3200 4400 3300
Wire Wire Line
	4400 3200 5000 3200
Wire Wire Line
	4400 3300 5000 3300
Text Label 6200 3600 0    50   ~ 0
TOUCH_CS
Text Label 4500 3200 0    50   ~ 0
TOUCH_IRQ
Entry Wire Line
	1650 2350 1750 2450
Entry Wire Line
	1650 2450 1750 2550
Entry Wire Line
	1650 2550 1750 2650
Entry Wire Line
	1650 2650 1750 2750
Entry Wire Line
	1650 2750 1750 2850
Entry Wire Line
	1650 2850 1750 2950
Entry Wire Line
	1650 2950 1750 3050
Entry Wire Line
	1650 3050 1750 3150
Entry Wire Line
	1650 3150 1750 3250
Entry Wire Line
	1650 3250 1750 3350
Entry Wire Line
	1650 3350 1750 3450
Entry Wire Line
	1650 3450 1750 3550
Entry Wire Line
	1650 3550 1750 3650
Entry Wire Line
	1650 3650 1750 3750
Entry Wire Line
	1650 3750 1750 3850
Entry Wire Line
	3600 2450 3700 2550
Entry Wire Line
	3600 2550 3700 2650
Entry Wire Line
	3600 2650 3700 2750
Entry Wire Line
	3600 2750 3700 2850
Entry Wire Line
	3600 2850 3700 2950
Entry Wire Line
	3600 2950 3700 3050
Entry Wire Line
	3600 3050 3700 3150
Entry Wire Line
	3600 3150 3700 3250
Entry Wire Line
	3600 3250 3700 3350
Entry Wire Line
	3600 3350 3700 3450
Entry Wire Line
	3600 3450 3700 3550
Entry Wire Line
	3600 3550 3700 3650
Entry Wire Line
	3600 3650 3700 3750
Entry Wire Line
	3600 3750 3700 3850
Entry Wire Line
	3600 3850 3700 3950
Wire Wire Line
	1750 2450 2400 2450
Wire Wire Line
	2400 2550 1750 2550
Wire Wire Line
	1750 2650 2400 2650
Wire Wire Line
	2400 2750 1750 2750
Wire Wire Line
	1750 2850 2400 2850
Wire Wire Line
	2400 2950 1750 2950
Wire Wire Line
	1750 3050 2400 3050
Wire Wire Line
	2400 3150 1750 3150
Wire Wire Line
	1750 3250 2400 3250
Wire Wire Line
	2400 3350 1750 3350
Wire Wire Line
	1750 3450 2400 3450
Wire Wire Line
	2400 3550 1750 3550
Wire Wire Line
	1750 3650 2400 3650
Wire Wire Line
	1750 3750 2400 3750
Wire Wire Line
	2400 3850 1750 3850
Wire Wire Line
	2900 2450 3600 2450
Wire Wire Line
	2900 2550 3600 2550
Wire Wire Line
	2900 2650 3600 2650
Wire Wire Line
	2900 2750 3600 2750
Wire Wire Line
	2900 2850 3600 2850
Wire Wire Line
	2900 2950 3600 2950
Wire Wire Line
	2900 3050 3600 3050
Wire Wire Line
	2900 3150 3600 3150
Wire Wire Line
	2900 3250 3600 3250
Wire Wire Line
	2900 3350 3600 3350
Wire Wire Line
	2900 3450 3600 3450
Wire Wire Line
	2900 3550 3600 3550
Wire Wire Line
	2900 3650 3600 3650
Wire Wire Line
	2900 3750 3600 3750
Wire Wire Line
	2900 3850 3600 3850
Entry Wire Line
	3600 1750 3700 1850
Entry Wire Line
	3600 1850 3700 1950
Text Label 3250 1750 0    50   ~ 0
GND
Text Label 3250 1850 0    50   ~ 0
VIN
Entry Wire Line
	4300 1700 4400 1800
Entry Wire Line
	4300 1800 4400 1900
Entry Wire Line
	4300 1900 4400 2000
Entry Wire Line
	4300 2000 4400 2100
Entry Wire Line
	4300 2100 4400 2200
Entry Wire Line
	4300 2200 4400 2300
Wire Wire Line
	4400 1800 5000 1800
Wire Wire Line
	4400 1900 5000 1900
Wire Wire Line
	4400 2000 5000 2000
Wire Wire Line
	4400 2100 5000 2100
Wire Wire Line
	4400 2200 5000 2200
Wire Wire Line
	4400 2300 5000 2300
Text Label 4500 1800 0    50   ~ 0
ENC1_A
Text Label 4500 1900 0    50   ~ 0
ENC1_B
Text Label 4500 2000 0    50   ~ 0
ENC2_A
Text Label 4500 2100 0    50   ~ 0
ENC2_B
Text Label 4500 2200 0    50   ~ 0
ENC3_A
Text Label 4500 2300 0    50   ~ 0
ENC3_B
Entry Wire Line
	4300 3700 4400 3800
Entry Wire Line
	4300 3800 4400 3900
Wire Wire Line
	4400 3800 5000 3800
Wire Wire Line
	4400 3900 5000 3900
Entry Wire Line
	7100 3450 7200 3550
Entry Wire Line
	7100 3550 7200 3650
Entry Wire Line
	7100 3650 7200 3750
Wire Wire Line
	7200 3550 7750 3550
Wire Wire Line
	7200 3650 7650 3650
Wire Wire Line
	7200 3750 7450 3750
Text Label 7300 3650 0    50   ~ 0
3V3
Text Label 7300 3750 0    50   ~ 0
GND
$Comp
L Device:C C7
U 1 1 5F8897FB
P 7650 4050
F 0 "C7" H 7765 4096 50  0000 L CNN
F 1 "0.1uF" H 7765 4005 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 7688 3900 50  0001 C CNN
F 3 "~" H 7650 4050 50  0001 C CNN
	1    7650 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	7650 3650 7650 3900
Connection ~ 7650 3650
Wire Wire Line
	7650 3650 7750 3650
Wire Wire Line
	7450 3750 7450 4250
Wire Wire Line
	7450 4250 7650 4250
Wire Wire Line
	7650 4250 7650 4200
Connection ~ 7450 3750
Wire Wire Line
	7450 3750 7750 3750
Wire Wire Line
	7650 4250 7650 4350
Connection ~ 7650 4250
$Comp
L power:GND #PWR0101
U 1 1 5F89CEE9
P 7650 4350
F 0 "#PWR0101" H 7650 4100 50  0001 C CNN
F 1 "GND" H 7655 4177 50  0000 C CNN
F 2 "" H 7650 4350 50  0001 C CNN
F 3 "" H 7650 4350 50  0001 C CNN
	1    7650 4350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 5F89CF47
P 3450 2000
F 0 "#PWR0102" H 3450 1750 50  0001 C CNN
F 1 "GND" H 3455 1827 50  0000 C CNN
F 2 "" H 3450 2000 50  0001 C CNN
F 3 "" H 3450 2000 50  0001 C CNN
	1    3450 2000
	1    0    0    -1  
$EndComp
Wire Wire Line
	3450 2000 3450 1750
Connection ~ 3450 1750
Wire Wire Line
	3450 1750 3600 1750
Text Label 4500 3800 0    50   ~ 0
ENC4_A
Text Label 4500 3900 0    50   ~ 0
ENC4_B
Text Label 1950 2450 0    50   ~ 0
VIN
Text Label 3050 2450 0    50   ~ 0
GND
Text Label 1950 2550 0    50   ~ 0
ENC1_A
Text Label 3050 2550 0    50   ~ 0
ENC1_B
Text Label 1950 2650 0    50   ~ 0
ENC2_A
Text Label 3050 2650 0    50   ~ 0
ENC2_B
Text Label 1950 2750 0    50   ~ 0
ENC3_A
Text Label 3050 2750 0    50   ~ 0
ENC3_B
Entry Wire Line
	6650 2900 6750 3000
Wire Wire Line
	6000 2900 6650 2900
Text Label 6200 2900 0    50   ~ 0
SPDIF_OUT
Text Label 7300 3550 0    50   ~ 0
SPDIF_OUT
Text Label 3050 2950 0    50   ~ 0
LCD_MOSI
Text Label 3050 3050 0    50   ~ 0
LCD_MISO
Text Label 1950 3050 0    50   ~ 0
LCD_SCK
Text Label 1950 3150 0    50   ~ 0
3V3
Text Label 3050 3650 0    50   ~ 0
TOUCH_CS
Text Label 3050 2850 0    50   ~ 0
TOUCH_IRQ
Text Label 1950 3650 0    50   ~ 0
ENC4_A
Text Label 1950 3750 0    50   ~ 0
ENC4_B
Entry Wire Line
	4300 3300 4400 3400
Entry Wire Line
	4300 3400 4400 3500
Entry Wire Line
	4300 3500 4400 3600
Entry Wire Line
	4300 3600 4400 3700
Wire Wire Line
	4400 3400 5000 3400
Wire Wire Line
	4400 3500 5000 3500
Wire Wire Line
	4400 3600 5000 3600
Wire Wire Line
	4400 3700 5000 3700
Text Label 4500 3400 0    50   ~ 0
ENC1_C
Text Label 4500 3500 0    50   ~ 0
ENC2_C
Text Label 4500 3600 0    50   ~ 0
ENC3_C
Text Label 4500 3700 0    50   ~ 0
ENC4_C
Text Label 1950 3250 0    50   ~ 0
ENC1_C
Text Label 1950 3350 0    50   ~ 0
ENC2_C
Text Label 1950 3450 0    50   ~ 0
ENC3_C
Text Label 1950 3550 0    50   ~ 0
ENC4_C
Entry Wire Line
	6650 4000 6750 4100
Entry Wire Line
	6650 3700 6750 3800
Wire Wire Line
	6000 3700 6650 3700
Wire Wire Line
	6000 4000 6650 4000
Text Label 6200 3700 0    50   ~ 0
PITCH_OSC
Text Label 6200 4000 0    50   ~ 0
VOL_OSC
$Comp
L power:GND #PWR0103
U 1 1 5F8FC15B
P 3600 5300
F 0 "#PWR0103" H 3600 5050 50  0001 C CNN
F 1 "GND" H 3605 5127 50  0000 C CNN
F 2 "" H 3600 5300 50  0001 C CNN
F 3 "" H 3600 5300 50  0001 C CNN
	1    3600 5300
	1    0    0    -1  
$EndComp
Wire Wire Line
	3400 5100 3600 5100
Wire Wire Line
	3600 5100 3600 5300
$Comp
L power:GND #PWR0104
U 1 1 5F903DA4
P 3600 6550
F 0 "#PWR0104" H 3600 6300 50  0001 C CNN
F 1 "GND" H 3605 6377 50  0000 C CNN
F 2 "" H 3600 6550 50  0001 C CNN
F 3 "" H 3600 6550 50  0001 C CNN
	1    3600 6550
	1    0    0    -1  
$EndComp
Wire Wire Line
	3400 6400 3600 6400
Wire Wire Line
	3600 6400 3600 6550
$Comp
L Regulator_Linear:LD3985M47R_SOT23 U4
U 1 1 5F90C37E
P 1700 4750
F 0 "U4" H 1700 5092 50  0000 C CNN
F 1 "LD3985M47R_SOT23" H 1700 5001 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 1700 5075 50  0001 C CIN
F 3 "http://www.st.com/internet/com/TECHNICAL_RESOURCES/TECHNICAL_LITERATURE/DATASHEET/CD00003395.pdf" H 1700 4750 50  0001 C CNN
	1    1700 4750
	1    0    0    -1  
$EndComp
$Comp
L Device:C C3
U 1 1 5F90D451
P 2100 5050
F 0 "C3" H 2215 5096 50  0000 L CNN
F 1 "10nF" H 2215 5005 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2138 4900 50  0001 C CNN
F 3 "~" H 2100 5050 50  0001 C CNN
	1    2100 5050
	1    0    0    -1  
$EndComp
$Comp
L Device:C C5
U 1 1 5F90DACE
P 2600 5050
F 0 "C5" H 2715 5096 50  0000 L CNN
F 1 "1uF" H 2715 5005 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2638 4900 50  0001 C CNN
F 3 "~" H 2600 5050 50  0001 C CNN
	1    2600 5050
	1    0    0    -1  
$EndComp
$Comp
L Device:C C1
U 1 1 5F90DEBF
P 1200 5050
F 0 "C1" H 1315 5096 50  0000 L CNN
F 1 "1uF" H 1315 5005 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 1238 4900 50  0001 C CNN
F 3 "~" H 1200 5050 50  0001 C CNN
	1    1200 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	1200 4650 1400 4650
Wire Wire Line
	1200 4650 1200 4750
Wire Wire Line
	1400 4750 1200 4750
Connection ~ 1200 4750
Wire Wire Line
	1200 4750 1200 4900
Wire Wire Line
	2000 4750 2100 4750
Wire Wire Line
	2100 4750 2100 4900
Wire Wire Line
	2000 4650 2600 4650
Wire Wire Line
	2600 4650 2600 4900
$Comp
L power:GND #PWR0105
U 1 1 5F935A20
P 1700 5350
F 0 "#PWR0105" H 1700 5100 50  0001 C CNN
F 1 "GND" H 1705 5177 50  0000 C CNN
F 2 "" H 1700 5350 50  0001 C CNN
F 3 "" H 1700 5350 50  0001 C CNN
	1    1700 5350
	1    0    0    -1  
$EndComp
Wire Wire Line
	1200 5200 1200 5250
Wire Wire Line
	1200 5250 1700 5250
Wire Wire Line
	2600 5250 2600 5200
Wire Wire Line
	2100 5200 2100 5250
Connection ~ 2100 5250
Wire Wire Line
	2100 5250 2600 5250
Wire Wire Line
	1700 5050 1700 5250
Connection ~ 1700 5250
Wire Wire Line
	1700 5250 2100 5250
Wire Wire Line
	1700 5250 1700 5350
$Comp
L Regulator_Linear:LD3985M47R_SOT23 U5
U 1 1 5F9744A7
P 1700 6050
F 0 "U5" H 1700 6392 50  0000 C CNN
F 1 "LD3985M47R_SOT23" H 1700 6301 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 1700 6375 50  0001 C CIN
F 3 "http://www.st.com/internet/com/TECHNICAL_RESOURCES/TECHNICAL_LITERATURE/DATASHEET/CD00003395.pdf" H 1700 6050 50  0001 C CNN
	1    1700 6050
	1    0    0    -1  
$EndComp
$Comp
L Device:C C4
U 1 1 5F974777
P 2100 6400
F 0 "C4" H 2215 6446 50  0000 L CNN
F 1 "10nF" H 2215 6355 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2138 6250 50  0001 C CNN
F 3 "~" H 2100 6400 50  0001 C CNN
	1    2100 6400
	1    0    0    -1  
$EndComp
$Comp
L Device:C C6
U 1 1 5F974781
P 2600 6400
F 0 "C6" H 2715 6446 50  0000 L CNN
F 1 "1uF" H 2715 6355 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2638 6250 50  0001 C CNN
F 3 "~" H 2600 6400 50  0001 C CNN
	1    2600 6400
	1    0    0    -1  
$EndComp
$Comp
L Device:C C2
U 1 1 5F97478B
P 1200 6400
F 0 "C2" H 1315 6446 50  0000 L CNN
F 1 "1uF" H 1315 6355 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 1238 6250 50  0001 C CNN
F 3 "~" H 1200 6400 50  0001 C CNN
	1    1200 6400
	1    0    0    -1  
$EndComp
Wire Wire Line
	1200 5950 1400 5950
Wire Wire Line
	1200 5950 1200 6050
Wire Wire Line
	1400 6050 1200 6050
Connection ~ 1200 6050
Wire Wire Line
	1200 6050 1200 6250
Wire Wire Line
	2000 6050 2100 6050
Wire Wire Line
	2100 6050 2100 6250
Wire Wire Line
	2000 5950 2600 5950
Wire Wire Line
	2600 5950 2600 6250
$Comp
L power:GND #PWR0106
U 1 1 5F97479E
P 1700 6700
F 0 "#PWR0106" H 1700 6450 50  0001 C CNN
F 1 "GND" H 1705 6527 50  0000 C CNN
F 2 "" H 1700 6700 50  0001 C CNN
F 3 "" H 1700 6700 50  0001 C CNN
	1    1700 6700
	1    0    0    -1  
$EndComp
Wire Wire Line
	1200 6550 1200 6600
Wire Wire Line
	1200 6600 1700 6600
Wire Wire Line
	2600 6600 2600 6550
Wire Wire Line
	2100 6550 2100 6600
Connection ~ 2100 6600
Wire Wire Line
	2100 6600 2600 6600
Wire Wire Line
	1700 6350 1700 6600
Connection ~ 1700 6600
Wire Wire Line
	1700 6600 2100 6600
Wire Wire Line
	1700 6600 1700 6700
Wire Wire Line
	3400 6200 3600 6200
Wire Wire Line
	3600 6200 3600 5950
Wire Wire Line
	3600 5950 2600 5950
Connection ~ 2600 5950
Wire Wire Line
	3400 4900 3600 4900
Wire Wire Line
	3600 4900 3600 4650
Wire Wire Line
	3600 4650 2600 4650
Connection ~ 2600 4650
Entry Wire Line
	4200 5000 4300 5100
Entry Wire Line
	4200 6300 4300 6400
Wire Wire Line
	3400 5000 4200 5000
Wire Wire Line
	3400 6300 4200 6300
Entry Wire Line
	1550 3850 1650 3950
Wire Wire Line
	1550 3850 850  3850
Wire Wire Line
	850  3850 850  4650
Wire Wire Line
	850  5950 1200 5950
Connection ~ 1200 5950
Wire Wire Line
	850  4650 1200 4650
Connection ~ 850  4650
Wire Wire Line
	850  4650 850  5950
Connection ~ 1200 4650
Text Label 1300 3850 0    50   ~ 0
VIN
Text Label 3750 5000 0    50   ~ 0
VOL_OSC
Text Label 3750 6300 0    50   ~ 0
PITCH_OSC
Text Label 2750 4650 0    50   ~ 0
VCC_VOL
Text Label 2750 5950 0    50   ~ 0
VCC_PITCH
Text Label 3050 3150 0    50   ~ 0
POT1
Text Label 3050 3250 0    50   ~ 0
POT2
Text Label 3050 3350 0    50   ~ 0
POT3
Text Label 3050 3450 0    50   ~ 0
POT4
Text Label 3050 3550 0    50   ~ 0
POT5
Text Label 3050 3750 0    50   ~ 0
BTN_1
Text Label 3050 3850 0    50   ~ 0
BTN_2
Text Label 1950 3850 0    50   ~ 0
BTN_3
Entry Wire Line
	6650 3500 6750 3600
Entry Wire Line
	6650 3400 6750 3500
Entry Wire Line
	6650 3300 6750 3400
Entry Wire Line
	6650 3200 6750 3300
Wire Wire Line
	6000 3200 6650 3200
Wire Wire Line
	6000 3300 6650 3300
Wire Wire Line
	6000 3400 6650 3400
Wire Wire Line
	6000 3500 6650 3500
Text Label 6200 3500 0    50   ~ 0
POT5
Text Label 6200 3400 0    50   ~ 0
POT4
Text Label 6200 3300 0    50   ~ 0
POT3
Text Label 6200 3200 0    50   ~ 0
POT2
Entry Wire Line
	6650 2700 6750 2800
Wire Wire Line
	6000 2700 6650 2700
Text Label 6200 2700 0    50   ~ 0
POT1
Entry Wire Line
	6650 3900 6750 4000
Entry Wire Line
	6650 3800 6750 3900
Wire Wire Line
	6000 3900 6650 3900
Wire Wire Line
	6000 3800 6650 3800
Text Label 6200 3900 0    50   ~ 0
BTN_2
Text Label 4500 4000 0    50   ~ 0
BTN_3
Entry Wire Line
	4300 3900 4400 4000
Wire Wire Line
	4400 4000 5000 4000
Text Label 6200 3800 0    50   ~ 0
BTN_1
Entry Wire Line
	6650 3600 6750 3700
Wire Wire Line
	6000 3600 6650 3600
Text Label 1950 2850 0    50   ~ 0
LCD_DC
Text Label 1950 2950 0    50   ~ 0
LCD_CS
Text Label 7300 2000 0    50   ~ 0
I2S_DOUT1A
Text Label 7300 2100 0    50   ~ 0
I2S_DIN1
Entry Wire Line
	4300 2300 4400 2400
Wire Wire Line
	4400 2400 5000 2400
Text Label 4500 2400 0    50   ~ 0
I2S_DOUT1D
Text Label 4500 2700 0    50   ~ 0
I2S_DOUT1C
$Comp
L Connector:Conn_01x08_Male J9
U 1 1 5FB5FB74
P 5200 5950
F 0 "J9" H 5172 5924 50  0000 R CNN
F 1 "SPDIF_IN" H 5172 5833 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x08_P2.54mm_Vertical" H 5200 5950 50  0001 C CNN
F 3 "~" H 5200 5950 50  0001 C CNN
	1    5200 5950
	-1   0    0    -1  
$EndComp
Entry Wire Line
	4300 5550 4400 5650
Entry Wire Line
	4300 5650 4400 5750
Wire Wire Line
	4400 5650 5000 5650
Wire Wire Line
	4400 5750 5000 5750
Entry Wire Line
	6650 2800 6750 2900
Wire Wire Line
	6000 2800 6650 2800
Text Label 6200 2800 0    50   ~ 0
SPDIF_IN
Text Label 4450 5650 0    50   ~ 0
3V3
Text Label 4450 5750 0    50   ~ 0
GND
$Comp
L power:GND #PWR01
U 1 1 5FBB6713
P 8900 6050
F 0 "#PWR01" H 8900 5800 50  0001 C CNN
F 1 "GND" H 8905 5877 50  0000 C CNN
F 2 "" H 8900 6050 50  0001 C CNN
F 3 "" H 8900 6050 50  0001 C CNN
	1    8900 6050
	1    0    0    -1  
$EndComp
Wire Wire Line
	8900 5650 9050 5650
$Comp
L Device:R R1
U 1 1 5FBE2440
P 7850 5550
F 0 "R1" V 7750 5550 50  0000 C CNN
F 1 "200" V 7650 5550 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" V 7780 5550 50  0001 C CNN
F 3 "~" H 7850 5550 50  0001 C CNN
	1    7850 5550
	0    -1   -1   0   
$EndComp
$Comp
L Device:C C8
U 1 1 5FBF1125
P 8100 5800
F 0 "C8" H 8215 5846 50  0000 L CNN
F 1 "0.1uF" H 8215 5755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 8138 5650 50  0001 C CNN
F 3 "~" H 8100 5800 50  0001 C CNN
	1    8100 5800
	1    0    0    -1  
$EndComp
$Comp
L Device:C C9
U 1 1 5FC0070D
P 8550 5800
F 0 "C9" H 8665 5846 50  0000 L CNN
F 1 "0.1uF" H 8665 5755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 8588 5650 50  0001 C CNN
F 3 "~" H 8550 5800 50  0001 C CNN
	1    8550 5800
	1    0    0    -1  
$EndComp
Wire Wire Line
	8900 5650 8900 6000
Wire Wire Line
	8100 5950 8100 6000
Wire Wire Line
	8100 6000 8550 6000
Connection ~ 8900 6000
Wire Wire Line
	8900 6000 8900 6050
Wire Wire Line
	8550 5950 8550 6000
Connection ~ 8550 6000
Wire Wire Line
	8550 6000 8900 6000
Wire Wire Line
	8000 5550 8100 5550
Wire Wire Line
	8100 5550 8100 5650
Wire Wire Line
	8100 5550 9050 5550
Connection ~ 8100 5550
Wire Wire Line
	9050 5450 8550 5450
Entry Wire Line
	7100 5350 7200 5450
Entry Wire Line
	7100 5450 7200 5550
Wire Wire Line
	7200 5550 7700 5550
Wire Wire Line
	8550 5450 8550 5650
Connection ~ 8550 5450
Wire Wire Line
	8550 5450 7200 5450
Text Label 7250 5550 0    50   ~ 0
3V3
Entry Wire Line
	6650 2600 6750 2700
Wire Wire Line
	6000 2600 6650 2600
Text Label 6200 2600 0    50   ~ 0
EXPR_PED
Text Label 7250 5450 0    50   ~ 0
EXPR_PED
$Comp
L Connector:Conn_01x12_Male J10
U 1 1 5FCCF801
P 6250 5150
F 0 "J10" H 6358 5831 50  0000 C CNN
F 1 "AUDIO_OUT_EXT" H 6550 5750 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x12_P2.54mm_Vertical" H 6250 5150 50  0001 C CNN
F 3 "~" H 6250 5150 50  0001 C CNN
	1    6250 5150
	1    0    0    -1  
$EndComp
Entry Wire Line
	7000 4650 7100 4750
Entry Wire Line
	7000 4750 7100 4850
Entry Wire Line
	7000 4850 7100 4950
Entry Wire Line
	7000 4950 7100 5050
Entry Wire Line
	7000 5050 7100 5150
Entry Wire Line
	7000 5150 7100 5250
Entry Wire Line
	7000 5250 7100 5350
Entry Wire Line
	7000 5350 7100 5450
Entry Wire Line
	7000 5450 7100 5550
Entry Wire Line
	7000 5550 7100 5650
Entry Wire Line
	7000 5650 7100 5750
Entry Wire Line
	7000 5750 7100 5850
Wire Wire Line
	6450 4650 7000 4650
Wire Wire Line
	6450 4750 7000 4750
Wire Wire Line
	6450 4850 7000 4850
Wire Wire Line
	6450 4950 7000 4950
Wire Wire Line
	6450 5050 7000 5050
Wire Wire Line
	6450 5150 7000 5150
Wire Wire Line
	6450 5250 7000 5250
Wire Wire Line
	6450 5350 7000 5350
Wire Wire Line
	6450 5450 7000 5450
Wire Wire Line
	6450 5550 7000 5550
Wire Wire Line
	6450 5650 7000 5650
Wire Wire Line
	6450 5750 7000 5750
Text Label 6500 4850 0    50   ~ 0
VIN
Text Label 6500 4750 0    50   ~ 0
GND
Text Label 6500 4650 0    50   ~ 0
3V3
Text Label 6500 5150 0    50   ~ 0
I2S_MCLK
Entry Wire Line
	6650 2100 6750 2200
Wire Wire Line
	6000 2100 6650 2100
Text Label 6200 2100 0    50   ~ 0
PIN22
Text Label 6500 5650 0    50   ~ 0
PIN22
Text Label 6500 5250 0    50   ~ 0
I2S_BCLK
Text Label 6500 5350 0    50   ~ 0
I2S_LRCK
Text Label 6500 5450 0    50   ~ 0
I2C_SCL
Text Label 6500 5550 0    50   ~ 0
I2C_SDA
Text Label 6500 5050 0    50   ~ 0
I2S_DOUT1D
Text Label 6500 4950 0    50   ~ 0
I2S_DOUT1C
$Comp
L Connector:Conn_01x08_Male J12
U 1 1 5FE0CBB8
P 5200 6950
F 0 "J12" H 5172 6924 50  0000 R CNN
F 1 "SPDIF_IN2" H 5172 6833 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x08_P2.54mm_Vertical" H 5200 6950 50  0001 C CNN
F 3 "~" H 5200 6950 50  0001 C CNN
	1    5200 6950
	-1   0    0    -1  
$EndComp
Wire Wire Line
	2850 1850 3600 1850
Wire Wire Line
	2850 1750 3450 1750
NoConn ~ 5000 4200
NoConn ~ 5000 4300
NoConn ~ 5000 4400
NoConn ~ 5000 4600
Wire Wire Line
	9300 2400 9300 3000
Connection ~ 9300 2400
Wire Wire Line
	9300 2400 9500 2400
Connection ~ 9300 3000
Wire Wire Line
	9300 3000 9500 3000
$Comp
L power:GND #PWR0107
U 1 1 5FFCB741
P 8900 3700
F 0 "#PWR0107" H 8900 3450 50  0001 C CNN
F 1 "GND" H 8905 3527 50  0000 C CNN
F 2 "" H 8900 3700 50  0001 C CNN
F 3 "" H 8900 3700 50  0001 C CNN
	1    8900 3700
	1    0    0    -1  
$EndComp
Wire Wire Line
	8900 3600 8900 3700
Connection ~ 8900 3600
$Comp
L Switch:SW_Push SW1
U 1 1 5FFE21F8
P 5100 5100
F 0 "SW1" H 5100 5385 50  0000 C CNN
F 1 "SW_Push" H 5100 5294 50  0000 C CNN
F 2 "Button_Switch_THT:SW_Tactile_SKHH_Angled" H 5100 5300 50  0001 C CNN
F 3 "~" H 5100 5300 50  0001 C CNN
	1    5100 5100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR03
U 1 1 5FFE3882
P 5400 5200
F 0 "#PWR03" H 5400 4950 50  0001 C CNN
F 1 "GND" H 5405 5027 50  0000 C CNN
F 2 "" H 5400 5200 50  0001 C CNN
F 3 "" H 5400 5200 50  0001 C CNN
	1    5400 5200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5300 5100 5400 5100
Wire Wire Line
	5400 5100 5400 5200
Entry Wire Line
	4300 5000 4400 5100
Wire Wire Line
	4400 5100 4900 5100
Entry Wire Line
	4300 4400 4400 4500
Wire Wire Line
	4400 4500 5000 4500
Text Label 4500 4500 0    50   ~ 0
PROG
Text Label 4500 5100 0    50   ~ 0
PROG
NoConn ~ 5000 6850
NoConn ~ 5000 6950
Entry Wire Line
	4300 6550 4400 6650
Wire Wire Line
	4400 6650 5000 6650
Text Label 4450 6750 0    50   ~ 0
GND
Entry Wire Line
	4300 7050 4400 7150
Entry Wire Line
	4300 7150 4400 7250
Entry Wire Line
	4300 7250 4400 7350
Wire Wire Line
	4400 7150 5000 7150
Wire Wire Line
	4400 7250 5000 7250
Wire Wire Line
	4400 7350 5000 7350
Text Label 4450 7150 0    50   ~ 0
PIN22
Entry Wire Line
	4300 6950 4400 7050
Wire Wire Line
	4400 7050 5000 7050
Text Label 4450 7050 0    50   ~ 0
EXPR_PED
Entry Wire Line
	4300 6050 4400 6150
Entry Wire Line
	4300 6150 4400 6250
Entry Wire Line
	4300 6250 4400 6350
Wire Wire Line
	4400 6150 5000 6150
Wire Wire Line
	4400 6250 5000 6250
Wire Wire Line
	4400 6350 5000 6350
Text Label 4450 6150 0    50   ~ 0
PIN22
Entry Wire Line
	4300 5950 4400 6050
Wire Wire Line
	4400 6050 5000 6050
Text Label 4450 6050 0    50   ~ 0
EXPR_PED
Entry Wire Line
	4300 6650 4400 6750
Wire Wire Line
	4400 6750 5000 6750
Text Label 4450 6650 0    50   ~ 0
3V3
NoConn ~ 5000 5850
NoConn ~ 5000 5950
Text Label 4450 7350 0    50   ~ 0
SPDIF_OUT
Text Label 4450 7250 0    50   ~ 0
SPDIF_IN
Text Label 4450 6350 0    50   ~ 0
SPDIF_OUT
Text Label 4450 6250 0    50   ~ 0
SPDIF_IN
Text Label 6500 5750 0    50   ~ 0
SPDIF_IN
$Comp
L Connector:Conn_01x01_Male J11
U 1 1 6032987F
P 2650 1200
F 0 "J11" H 2758 1381 50  0000 C CNN
F 1 "Grounding" H 2758 1290 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Vertical" H 2650 1200 50  0001 C CNN
F 3 "~" H 2650 1200 50  0001 C CNN
	1    2650 1200
	1    0    0    -1  
$EndComp
Entry Wire Line
	3600 1200 3700 1300
Wire Wire Line
	2850 1200 3600 1200
Text Label 3250 1200 0    50   ~ 0
GND
$Comp
L Connector:Conn_01x01_Male J13
U 1 1 6033F9B7
P 3100 7200
F 0 "J13" H 3208 7381 50  0000 C CNN
F 1 "ProtoGrid" H 3208 7290 50  0000 C CNN
F 2 "Module:Teensy41ThereminProtoGrid" H 3100 7200 50  0001 C CNN
F 3 "~" H 3100 7200 50  0001 C CNN
	1    3100 7200
	1    0    0    -1  
$EndComp
NoConn ~ 3300 7200
$Comp
L Connector:Conn_01x01_Male J14
U 1 1 60440E22
P 2650 1450
F 0 "J14" H 2758 1631 50  0000 C CNN
F 1 "Grounding2" H 2758 1540 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Horizontal" H 2650 1450 50  0001 C CNN
F 3 "~" H 2650 1450 50  0001 C CNN
	1    2650 1450
	1    0    0    -1  
$EndComp
Entry Wire Line
	3600 1450 3700 1550
Wire Wire Line
	2850 1450 3600 1450
Text Label 3250 1450 0    50   ~ 0
GND
$Comp
L Connector:TestPoint TP1
U 1 1 5F993081
P 1200 4350
F 0 "TP1" H 1258 4468 50  0000 L CNN
F 1 "VIN1" H 1258 4377 50  0000 L CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x01_P1.27mm_Vertical" H 1400 4350 50  0001 C CNN
F 3 "~" H 1400 4350 50  0001 C CNN
	1    1200 4350
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint TP3
U 1 1 5F993B3F
P 2600 4350
F 0 "TP3" H 2658 4468 50  0000 L CNN
F 1 "VCCVOL" H 2658 4377 50  0000 L CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x01_P1.27mm_Vertical" H 2800 4350 50  0001 C CNN
F 3 "~" H 2800 4350 50  0001 C CNN
	1    2600 4350
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint TP2
U 1 1 5F993FDD
P 1200 5700
F 0 "TP2" H 1258 5818 50  0000 L CNN
F 1 "VIN2" H 1258 5727 50  0000 L CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x01_P1.27mm_Vertical" H 1400 5700 50  0001 C CNN
F 3 "~" H 1400 5700 50  0001 C CNN
	1    1200 5700
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint TP4
U 1 1 5F99456C
P 2600 5700
F 0 "TP4" H 2658 5818 50  0000 L CNN
F 1 "VCCPITCH" H 2658 5727 50  0000 L CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x01_P1.27mm_Vertical" H 2800 5700 50  0001 C CNN
F 3 "~" H 2800 5700 50  0001 C CNN
	1    2600 5700
	1    0    0    -1  
$EndComp
Wire Wire Line
	1200 5700 1200 5950
Wire Wire Line
	2600 5700 2600 5950
Wire Wire Line
	2600 4350 2600 4650
Wire Wire Line
	1200 4350 1200 4650
Wire Bus Line
	9250 950  9250 2000
Wire Bus Line
	1650 950  9250 950 
Wire Bus Line
	3700 1050 3700 4050
Wire Bus Line
	1650 950  1650 4050
Wire Bus Line
	7100 1050 7100 5950
Wire Bus Line
	6750 1050 6750 4200
Wire Bus Line
	4300 1050 4300 7500
$EndSCHEMATC
