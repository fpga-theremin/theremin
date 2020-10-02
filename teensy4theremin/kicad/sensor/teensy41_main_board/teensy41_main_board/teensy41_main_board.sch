EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L teensy41_main_board-rescue:Teensy41-MCU_Module U1
U 1 1 5F6F5E98
P 3850 2700
F 0 "U1" H 3850 4115 50  0000 C CNN
F 1 "Teensy41" H 3850 4024 50  0000 C CNN
F 2 "Module:Teensy41" H 3850 4000 50  0001 C CNN
F 3 "https://www.pjrc.com/store/teensy41.html" H 3850 4000 50  0001 C CNN
	1    3850 2700
	1    0    0    -1  
$EndComp
$Comp
L teensy41_main_board-rescue:TeensyAudioD-MCU_Module U2
U 1 1 5F6F668C
P 6850 2250
F 0 "U2" H 6850 3165 50  0000 C CNN
F 1 "TeensyAudioD" H 6850 3074 50  0000 C CNN
F 2 "Module:TeensyAudioD" H 6850 3100 50  0001 C CNN
F 3 "https://www.pjrc.com/store/teensy3_audio.html" H 6850 3100 50  0001 C CNN
	1    6850 2250
	1    0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_02x15_Odd_Even J1
U 1 1 5F6F6FD9
P 1750 2850
F 0 "J1" H 1800 3867 50  0000 C CNN
F 1 "Conn_02x20_Odd_Even" H 1800 3776 50  0000 C CNN
F 2 "Connector_IDC:IDC-Header_2x15_P2.54mm_Vertical" H 1750 2850 50  0001 C CNN
F 3 "~" H 1750 2850 50  0001 C CNN
	1    1750 2850
	1    0    0    -1  
$EndComp
$Comp
L Connector:AudioJack3 J3
U 1 1 5F6FB224
P 8150 2850
F 0 "J3" H 8132 3175 50  0000 C CNN
F 1 "AudioJack3" H 8132 3084 50  0000 C CNN
F 2 "Connector_Audio:Jack_6.35mm_ST_008G_04" H 8150 2850 50  0001 C CNN
F 3 "~" H 8150 2850 50  0001 C CNN
	1    8150 2850
	-1   0    0    1   
$EndComp
$Comp
L Connector:AudioJack3 J2
U 1 1 5F6FC123
P 8150 2250
F 0 "J2" H 8132 2575 50  0000 C CNN
F 1 "AudioJack3" H 8132 2484 50  0000 C CNN
F 2 "Connector_Audio:Jack_3.5mm_CUI_SJ1-3533NG_Horizontal" H 8150 2250 50  0001 C CNN
F 3 "~" H 8150 2250 50  0001 C CNN
	1    8150 2250
	-1   0    0    1   
$EndComp
$Comp
L Connector:Conn_01x03_Male J4
U 1 1 5F6FEF3F
P 1600 4800
F 0 "J4" H 1708 5081 50  0000 C CNN
F 1 "Conn_01x03_Male" H 1708 4990 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Horizontal" H 1600 4800 50  0001 C CNN
F 3 "~" H 1600 4800 50  0001 C CNN
	1    1600 4800
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x03_Male J5
U 1 1 5F6FF6D4
P 1600 5750
F 0 "J5" H 1708 6031 50  0000 C CNN
F 1 "Conn_01x03_Male" H 1708 5940 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Horizontal" H 1600 5750 50  0001 C CNN
F 3 "~" H 1600 5750 50  0001 C CNN
	1    1600 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	7350 2350 7550 2350
Wire Wire Line
	7350 2250 7550 2250
Wire Wire Line
	7550 2250 7550 2350
Connection ~ 7550 2350
Wire Wire Line
	7550 2350 7950 2350
Wire Wire Line
	7950 2150 7850 2150
Wire Wire Line
	7850 2150 7850 2050
Wire Wire Line
	7850 2050 7350 2050
Wire Wire Line
	7350 2150 7750 2150
Wire Wire Line
	7750 2150 7750 2250
Wire Wire Line
	7750 2250 7950 2250
Wire Wire Line
	7350 2750 7500 2750
Wire Wire Line
	7500 2750 7500 2950
Wire Wire Line
	7500 2950 7950 2950
Wire Wire Line
	7350 2650 7600 2650
Wire Wire Line
	7600 2650 7600 2750
Wire Wire Line
	7600 2750 7950 2750
Wire Wire Line
	7950 2850 7700 2850
Wire Wire Line
	7700 2850 7700 2550
Wire Wire Line
	7700 2550 7350 2550
$Comp
L Connector:Conn_01x02_Male J6
U 1 1 5F70D684
P 1650 1250
F 0 "J6" H 1758 1431 50  0000 C CNN
F 1 "Conn_01x02_Male" H 1758 1340 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 1650 1250 50  0001 C CNN
F 3 "~" H 1650 1250 50  0001 C CNN
	1    1650 1250
	1    0    0    -1  
$EndComp
$Comp
L plt133t10w:PLT133T10W U3
U 1 1 5F765E12
P 6850 3650
F 0 "U3" H 7028 3521 50  0000 L CNN
F 1 "PLT133T10W" H 7028 3430 50  0000 L CNN
F 2 "Module:PLT133T10W" H 6850 3700 50  0001 C CNN
F 3 "" H 6850 3700 50  0001 C CNN
	1    6850 3650
	1    0    0    -1  
$EndComp
$EndSCHEMATC
