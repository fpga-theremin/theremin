EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Theremin Oscillator"
Date "2020-10-24"
Rev "v1.2"
Comp ""
Comment1 "Teensy 4 / FPGA Theremin Projects"
Comment2 "(c) Vadim Lopatin 2020"
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector:Conn_01x01_Male J3
U 1 1 5D9FD8BA
P 1400 3650
F 0 "J3" H 1372 3530 50  0000 R CNN
F 1 "INDUCTOR_IN" H 1372 3621 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Horizontal" H 1400 3650 50  0001 C CNN
F 3 "~" H 1400 3650 50  0001 C CNN
	1    1400 3650
	1    0    0    1   
$EndComp
$Comp
L Connector:Conn_01x01_Male J2
U 1 1 5D9FD952
P 1450 2550
F 0 "J2" H 1422 2430 50  0000 R CNN
F 1 "INDUCTOR_OUT" H 1422 2521 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Horizontal" H 1450 2550 50  0001 C CNN
F 3 "~" H 1450 2550 50  0001 C CNN
	1    1450 2550
	1    0    0    1   
$EndComp
$Comp
L Connector:Conn_01x02_Male J1
U 1 1 5D9FD990
P 1450 1850
F 0 "J1" H 1422 1730 50  0000 R CNN
F 1 "ANTENNA" H 1422 1821 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Horizontal" H 1450 1850 50  0001 C CNN
F 3 "~" H 1450 1850 50  0001 C CNN
	1    1450 1850
	1    0    0    1   
$EndComp
Text Notes 1000 1600 0    79   ~ 0
To theremin antenna
Text Notes 700  1050 0    79   ~ 0
Theremin oscillator\ndigital output square 3.3V 700..2000KHz\nPower input: +3.6 .. 6V, 50mA\n
Text Notes 900  3300 0    79   ~ 0
L: Air core coil, 1.5-3 mH\n0.1mm/0.125mm copper wire, \n32mm frame diameter, \n40..70mm winding length
$Comp
L Device:C C10
U 1 1 5DF1ED56
P 4100 4750
F 0 "C10" H 4215 4796 50  0000 L CNN
F 1 "0.1uF" H 4215 4705 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4138 4600 50  0001 C CNN
F 3 "~" H 4100 4750 50  0001 C CNN
	1    4100 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	4100 4600 4100 4500
$Comp
L power:GND #PWR08
U 1 1 5DF1ED64
P 4100 5000
F 0 "#PWR08" H 4100 4750 50  0001 C CNN
F 1 "GND" H 4105 4827 50  0000 C CNN
F 2 "" H 4100 5000 50  0001 C CNN
F 3 "" H 4100 5000 50  0001 C CNN
	1    4100 5000
	1    0    0    -1  
$EndComp
Text Notes 2250 5150 0    50   ~ 0
IP4220CZ6 ESD protection is mandatory!\nThere is 200V voltage swing on antenna!!!
Wire Wire Line
	3450 4500 4100 4500
$Comp
L Connector:Conn_01x03_Male J6
U 1 1 5E5208E1
P 7950 3650
F 0 "J6" H 7923 3580 50  0000 R CNN
F 1 "OSC" H 7923 3671 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Horizontal" H 7950 3650 50  0001 C CNN
F 3 "~" H 7950 3650 50  0001 C CNN
	1    7950 3650
	-1   0    0    1   
$EndComp
Wire Wire Line
	7750 3750 7250 3750
Connection ~ 4100 4500
Text Label 7400 3750 0    50   ~ 0
GND
Text Label 7400 3550 0    50   ~ 0
5V
Text Label 7400 3650 0    50   ~ 0
OUT_P
Wire Wire Line
	4950 1400 4900 1400
Wire Wire Line
	4900 1400 4900 1300
$Comp
L Device:C C6
U 1 1 5F6ADCE2
P 4900 1800
F 0 "C6" H 5015 1846 50  0000 L CNN
F 1 "1uF" H 5015 1755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4938 1650 50  0001 C CNN
F 3 "~" H 4900 1800 50  0001 C CNN
	1    4900 1800
	1    0    0    -1  
$EndComp
$Comp
L Device:C C7
U 1 1 5F6B2AB2
P 5600 1800
F 0 "C7" H 5715 1846 50  0000 L CNN
F 1 "10nF" H 5715 1755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 5638 1650 50  0001 C CNN
F 3 "~" H 5600 1800 50  0001 C CNN
	1    5600 1800
	-1   0    0    -1  
$EndComp
$Comp
L Device:C C8
U 1 1 5F6B3869
P 5850 1800
F 0 "C8" H 5965 1846 50  0000 L CNN
F 1 "1uF" H 5965 1755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 5888 1650 50  0001 C CNN
F 3 "~" H 5850 1800 50  0001 C CNN
	1    5850 1800
	1    0    0    -1  
$EndComp
Wire Wire Line
	4900 1400 4900 1650
Connection ~ 4900 1400
Wire Wire Line
	5550 1300 5850 1300
Wire Wire Line
	5850 1300 5850 1650
Wire Wire Line
	5850 1950 5850 2000
Wire Wire Line
	5850 2000 5600 2000
Wire Wire Line
	4900 2000 4900 1950
Wire Wire Line
	5250 1700 5250 2000
Connection ~ 5250 2000
Wire Wire Line
	5250 2000 4900 2000
Wire Wire Line
	5600 1950 5600 2000
Connection ~ 5600 2000
Wire Wire Line
	5600 2000 5250 2000
$Comp
L power:GND #PWR04
U 1 1 5F6BA595
P 5250 2000
F 0 "#PWR04" H 5250 1750 50  0001 C CNN
F 1 "GND" H 5255 1827 50  0000 C CNN
F 2 "" H 5250 2000 50  0001 C CNN
F 3 "" H 5250 2000 50  0001 C CNN
	1    5250 2000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C5
U 1 1 5F6D6261
P 3100 3000
F 0 "C5" H 3215 3046 50  0000 L CNN
F 1 "6.8pF" H 3215 2955 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3138 2850 50  0001 C CNN
F 3 "~" H 3100 3000 50  0001 C CNN
	1    3100 3000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C3
U 1 1 5F6D5D81
P 3100 2300
F 0 "C3" H 3215 2346 50  0000 L CNN
F 1 "6.8pF" H 3215 2255 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3138 2150 50  0001 C CNN
F 3 "~" H 3100 2300 50  0001 C CNN
	1    3100 2300
	1    0    0    -1  
$EndComp
Connection ~ 5850 1300
$Comp
L Regulator_Linear:LD3985M33R_SOT23 U2
U 1 1 5F6A75CD
P 5250 1400
F 0 "U2" H 5250 1742 50  0000 C CNN
F 1 "LD3985M33R_SOT23" H 5250 1651 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 5250 1725 50  0001 C CIN
F 3 "http://www.st.com/internet/com/TECHNICAL_RESOURCES/TECHNICAL_LITERATURE/DATASHEET/CD00003395.pdf" H 5250 1400 50  0001 C CNN
	1    5250 1400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5550 1400 5600 1400
Wire Wire Line
	5600 1400 5600 1650
Wire Wire Line
	4750 750  4750 1300
Wire Wire Line
	4750 1300 4900 1300
$Comp
L power:GND #PWR015
U 1 1 5F7D2E8E
P 7250 3850
F 0 "#PWR015" H 7250 3600 50  0001 C CNN
F 1 "GND" H 7255 3677 50  0000 C CNN
F 2 "" H 7250 3850 50  0001 C CNN
F 3 "" H 7250 3850 50  0001 C CNN
	1    7250 3850
	1    0    0    -1  
$EndComp
Wire Wire Line
	7250 3750 7250 3850
Wire Wire Line
	4100 4900 4100 5000
Wire Wire Line
	4100 4500 4600 4500
Wire Wire Line
	1650 1850 1850 1850
Wire Wire Line
	1850 1850 1850 2550
Wire Wire Line
	1850 2550 1650 2550
Wire Wire Line
	1650 1750 1850 1750
Wire Wire Line
	1850 1750 1850 1850
Connection ~ 1850 1850
$Comp
L Device:C C2
U 1 1 5F878579
P 3100 1950
F 0 "C2" H 3215 1996 50  0000 L CNN
F 1 "6.8pF" H 3215 1905 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3138 1800 50  0001 C CNN
F 3 "~" H 3100 1950 50  0001 C CNN
	1    3100 1950
	1    0    0    -1  
$EndComp
$Comp
L Device:C C4
U 1 1 5F878E10
P 3100 2650
F 0 "C4" H 3215 2696 50  0000 L CNN
F 1 "6.8pF" H 3215 2605 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3138 2500 50  0001 C CNN
F 3 "~" H 3100 2650 50  0001 C CNN
	1    3100 2650
	1    0    0    -1  
$EndComp
Text Notes 4950 950  0    50   ~ 0
Analog part LDO
Text Notes 7350 3400 0    50   ~ 0
To MCU or FPGA
Wire Wire Line
	4900 1300 4950 1300
Connection ~ 4900 1300
NoConn ~ 3450 4300
Text Label 5900 1300 0    50   ~ 0
3V3_A
$Comp
L Comparator:LT1711xMS8 U3
U 1 1 5F930D29
P 5600 3050
F 0 "U3" H 5944 3096 50  0000 L CNN
F 1 "LT1711xMS8" H 5944 3005 50  0000 L CNN
F 2 "Package_SO:MSOP-8_3x3mm_P0.65mm" H 5600 2650 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/171112f.pdf" H 5600 3050 50  0001 C CNN
	1    5600 3050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR02
U 1 1 5F957CCB
P 3100 3200
F 0 "#PWR02" H 3100 2950 50  0001 C CNN
F 1 "GND" H 3105 3027 50  0000 C CNN
F 2 "" H 3100 3200 50  0001 C CNN
F 3 "" H 3100 3200 50  0001 C CNN
	1    3100 3200
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 3150 3100 3200
Wire Wire Line
	3100 2100 3100 2150
Wire Wire Line
	3100 2450 3100 2500
Wire Wire Line
	3100 2800 3100 2850
$Comp
L Device:C C1
U 1 1 5F95F4DD
P 3650 1550
F 0 "C1" H 3765 1596 50  0000 L CNN
F 1 "1pF" H 3765 1505 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3688 1400 50  0001 C CNN
F 3 "~" H 3650 1550 50  0001 C CNN
	1    3650 1550
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint TP1
U 1 1 5F95FFE3
P 3650 1400
F 0 "TP1" H 3708 1518 50  0000 L CNN
F 1 "Antenna Voltage Swing" H 3708 1427 50  0000 L CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x01_P1.27mm_Vertical" H 3850 1400 50  0001 C CNN
F 3 "~" H 3850 1400 50  0001 C CNN
	1    3650 1400
	1    0    0    -1  
$EndComp
Text Notes 3450 2200 0    50   ~ 0
Optional caps to reduce \noscillator frequency.\nDecreases sensitivity.\nRecommended for using \nwith Volume antenna only.
Text Notes 3400 1150 0    50   ~ 0
Test point for checking of\nantenna voltage swing.\nDecoupled by 1pF cap.
$Comp
L Device:R R1
U 1 1 5F970343
P 4850 3650
F 0 "R1" V 4643 3650 50  0000 C CNN
F 1 "12" V 4734 3650 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" V 4780 3650 50  0001 C CNN
F 3 "~" H 4850 3650 50  0001 C CNN
	1    4850 3650
	0    1    1    0   
$EndComp
Wire Wire Line
	6050 3650 6050 3150
Wire Wire Line
	6050 3150 5900 3150
Wire Wire Line
	4700 3650 4500 3650
Text Notes 4350 4100 0    50   ~ 0
Current sensing resistor.\nRecommended values: 10..47 Ohm.\nSmaller value gives bigger \nantenna voltage swing.
Wire Wire Line
	5300 2950 4500 2950
Wire Wire Line
	4500 2950 4500 3650
Connection ~ 4500 3650
Wire Wire Line
	5300 3150 5150 3150
Wire Wire Line
	5150 3150 5150 3650
Wire Wire Line
	5000 3650 5150 3650
Connection ~ 5150 3650
Wire Wire Line
	5150 3650 6050 3650
$Comp
L power:GND #PWR05
U 1 1 5F9798D4
P 5600 3400
F 0 "#PWR05" H 5600 3150 50  0001 C CNN
F 1 "GND" H 5605 3227 50  0000 C CNN
F 2 "" H 5600 3400 50  0001 C CNN
F 3 "" H 5600 3400 50  0001 C CNN
	1    5600 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5600 3400 5600 3350
Wire Wire Line
	5500 3350 5600 3350
Connection ~ 5600 3350
$Comp
L power:GND #PWR06
U 1 1 5F97E7A3
P 5700 2750
F 0 "#PWR06" H 5700 2500 50  0001 C CNN
F 1 "GND" H 5705 2577 50  0000 C CNN
F 2 "" H 5700 2750 50  0001 C CNN
F 3 "" H 5700 2750 50  0001 C CNN
	1    5700 2750
	-1   0    0    1   
$EndComp
Wire Wire Line
	5500 2750 5500 2300
Wire Wire Line
	5500 2300 6150 2300
Wire Wire Line
	6150 2300 6150 1300
$Comp
L Device:C C9
U 1 1 5F99A62F
P 6450 2500
F 0 "C9" H 6565 2546 50  0000 L CNN
F 1 "0.1uF" H 6565 2455 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6488 2350 50  0001 C CNN
F 3 "~" H 6450 2500 50  0001 C CNN
	1    6450 2500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR07
U 1 1 5F99B51E
P 6450 2650
F 0 "#PWR07" H 6450 2400 50  0001 C CNN
F 1 "GND" H 6455 2477 50  0000 C CNN
F 2 "" H 6450 2650 50  0001 C CNN
F 3 "" H 6450 2650 50  0001 C CNN
	1    6450 2650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR09
U 1 1 5F99B92A
P 6900 2650
F 0 "#PWR09" H 6900 2400 50  0001 C CNN
F 1 "GND" H 6905 2477 50  0000 C CNN
F 2 "" H 6900 2650 50  0001 C CNN
F 3 "" H 6900 2650 50  0001 C CNN
	1    6900 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	6900 2350 6900 2300
Wire Wire Line
	6450 2300 6450 2350
$Comp
L Device:CP C11
U 1 1 5F9AC08F
P 6900 2500
F 0 "C11" H 7018 2546 50  0000 L CNN
F 1 "4.7uF" H 7018 2455 50  0000 L CNN
F 2 "Capacitor_Tantalum_SMD:CP_EIA-3528-21_Kemet-B_Pad1.50x2.35mm_HandSolder" H 6938 2350 50  0001 C CNN
F 3 "~" H 6900 2500 50  0001 C CNN
	1    6900 2500
	1    0    0    -1  
$EndComp
$Comp
L Device:C C12
U 1 1 5F9E3DBA
P 4600 4750
F 0 "C12" H 4715 4796 50  0000 L CNN
F 1 "1uF" H 4715 4705 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4638 4600 50  0001 C CNN
F 3 "~" H 4600 4750 50  0001 C CNN
	1    4600 4750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR010
U 1 1 5F9E421B
P 4600 5000
F 0 "#PWR010" H 4600 4750 50  0001 C CNN
F 1 "GND" H 4605 4827 50  0000 C CNN
F 2 "" H 4600 5000 50  0001 C CNN
F 3 "" H 4600 5000 50  0001 C CNN
	1    4600 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	4600 4900 4600 5000
Wire Wire Line
	4600 4500 4600 4600
Wire Wire Line
	5850 1300 6150 1300
$Comp
L IP4220CZ6:IP4220CZ6 U1
U 1 1 5DF1ED71
P 2700 4300
F 0 "U1" H 3075 4715 50  0000 C CNN
F 1 "4220CZ6" H 3075 4624 50  0000 C CNN
F 2 "Package_SO:TSOP-6_1.65x3.05mm_P0.95mm" H 3050 4600 50  0001 C CNN
F 3 "" H 3050 4600 50  0001 C CNN
	1    2700 4300
	1    0    0    -1  
$EndComp
Wire Wire Line
	1850 1750 3100 1750
Wire Wire Line
	3650 1750 3650 1700
Connection ~ 1850 1750
Wire Wire Line
	3100 1750 3100 1800
Connection ~ 3100 1750
Wire Wire Line
	3100 1750 3650 1750
Wire Wire Line
	7250 750  7250 3550
Wire Wire Line
	7250 3550 7750 3550
NoConn ~ 3450 4700
Wire Wire Line
	1600 3650 2200 3650
$Comp
L power:GND #PWR03
U 1 1 5F7E2DD3
P 2550 4500
F 0 "#PWR03" H 2550 4250 50  0001 C CNN
F 1 "GND" H 2555 4327 50  0000 C CNN
F 2 "" H 2550 4500 50  0001 C CNN
F 3 "" H 2550 4500 50  0001 C CNN
	1    2550 4500
	0    1    1    0   
$EndComp
Wire Wire Line
	5500 2300 4100 2300
Wire Wire Line
	4100 2300 4100 4500
Connection ~ 5500 2300
Connection ~ 2200 3650
Wire Wire Line
	2200 3650 4500 3650
Wire Wire Line
	4750 750  7250 750 
Wire Wire Line
	5900 2950 6900 2950
Wire Wire Line
	6900 2950 6900 3650
Wire Wire Line
	6900 3650 7750 3650
Wire Wire Line
	2200 4700 2700 4700
Wire Wire Line
	2200 3650 2200 4700
NoConn ~ 2700 4300
Wire Wire Line
	2550 4500 2700 4500
$Comp
L Device:C C13
U 1 1 5F95A9E4
P 6450 1800
F 0 "C13" H 6565 1846 50  0000 L CNN
F 1 "10nF" H 6565 1755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6488 1650 50  0001 C CNN
F 3 "~" H 6450 1800 50  0001 C CNN
	1    6450 1800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0101
U 1 1 5F95AC1E
P 6450 1950
F 0 "#PWR0101" H 6450 1700 50  0001 C CNN
F 1 "GND" H 6455 1777 50  0000 C CNN
F 2 "" H 6450 1950 50  0001 C CNN
F 3 "" H 6450 1950 50  0001 C CNN
	1    6450 1950
	1    0    0    -1  
$EndComp
$Comp
L Device:C C14
U 1 1 5F95DA73
P 6900 1800
F 0 "C14" H 7015 1846 50  0000 L CNN
F 1 "1nF" H 7015 1755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6938 1650 50  0001 C CNN
F 3 "~" H 6900 1800 50  0001 C CNN
	1    6900 1800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 5F95DCCB
P 6900 1950
F 0 "#PWR0102" H 6900 1700 50  0001 C CNN
F 1 "GND" H 6905 1777 50  0000 C CNN
F 2 "" H 6900 1950 50  0001 C CNN
F 3 "" H 6900 1950 50  0001 C CNN
	1    6900 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	6900 1300 6900 1650
Wire Wire Line
	6450 1300 6450 1650
Connection ~ 6450 1300
Wire Wire Line
	6450 1300 6900 1300
Connection ~ 6450 2300
Wire Wire Line
	6450 2300 6900 2300
Wire Wire Line
	6150 2300 6450 2300
Connection ~ 6150 2300
Wire Wire Line
	6150 1300 6450 1300
Connection ~ 6150 1300
$Comp
L Connector:TestPoint TP2
U 1 1 5F984E2F
P 6900 1150
F 0 "TP2" H 6958 1268 50  0000 L CNN
F 1 "+3.3V" H 6958 1177 50  0000 L CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x01_P1.27mm_Vertical" H 7100 1150 50  0001 C CNN
F 3 "~" H 7100 1150 50  0001 C CNN
	1    6900 1150
	1    0    0    -1  
$EndComp
Wire Wire Line
	6900 1300 6900 1150
Connection ~ 6900 1300
$Comp
L Connector:TestPoint TP3
U 1 1 5F98A61F
P 7700 1150
F 0 "TP3" H 7758 1268 50  0000 L CNN
F 1 "GND" H 7758 1177 50  0000 L CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x01_P1.27mm_Vertical" H 7900 1150 50  0001 C CNN
F 3 "~" H 7900 1150 50  0001 C CNN
	1    7700 1150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR01
U 1 1 5F98A8CF
P 7700 1400
F 0 "#PWR01" H 7700 1150 50  0001 C CNN
F 1 "GND" H 7705 1227 50  0000 C CNN
F 2 "" H 7700 1400 50  0001 C CNN
F 3 "" H 7700 1400 50  0001 C CNN
	1    7700 1400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7700 1150 7700 1400
$EndSCHEMATC
