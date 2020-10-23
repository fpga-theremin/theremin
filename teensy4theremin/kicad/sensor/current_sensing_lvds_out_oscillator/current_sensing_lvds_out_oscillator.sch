EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Theremin Oscillator"
Date "2020-10-23"
Rev "v1.0"
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
Theremin oscillator\ndigital output square 3.3V 700..2000KHz\nsingle ended LVTTL or differential LVDS\nPower input: +3.6 .. 6V, 50mA\n
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
L Connector:Conn_01x04_Male J6
U 1 1 5E5208E1
P 10250 3650
F 0 "J6" H 10223 3580 50  0000 R CNN
F 1 "OSC" H 10223 3671 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x04_P2.54mm_Horizontal" H 10250 3650 50  0001 C CNN
F 3 "~" H 10250 3650 50  0001 C CNN
	1    10250 3650
	-1   0    0    1   
$EndComp
Wire Wire Line
	10050 3750 9450 3750
Connection ~ 4100 4500
Text Label 9700 3750 0    50   ~ 0
GND
Text Label 9700 3550 0    50   ~ 0
5V
Text Label 9700 3650 0    50   ~ 0
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
	7250 1400 7200 1400
Wire Wire Line
	7200 1400 7200 1300
$Comp
L Device:C C13
U 1 1 5F77DF33
P 7200 1800
F 0 "C13" H 7315 1846 50  0000 L CNN
F 1 "1uF" H 7315 1755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 7238 1650 50  0001 C CNN
F 3 "~" H 7200 1800 50  0001 C CNN
	1    7200 1800
	1    0    0    -1  
$EndComp
$Comp
L Device:C C14
U 1 1 5F77DF3D
P 7900 1800
F 0 "C14" H 8015 1846 50  0000 L CNN
F 1 "10nF" H 8015 1755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 7938 1650 50  0001 C CNN
F 3 "~" H 7900 1800 50  0001 C CNN
	1    7900 1800
	-1   0    0    -1  
$EndComp
$Comp
L Device:C C15
U 1 1 5F77DF47
P 8150 1800
F 0 "C15" H 8265 1846 50  0000 L CNN
F 1 "1uF" H 8265 1755 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8188 1650 50  0001 C CNN
F 3 "~" H 8150 1800 50  0001 C CNN
	1    8150 1800
	1    0    0    -1  
$EndComp
Wire Wire Line
	7200 1400 7200 1650
Connection ~ 7200 1400
Wire Wire Line
	7850 1300 8150 1300
Wire Wire Line
	8150 1300 8150 1650
Wire Wire Line
	8150 1950 8150 2000
Wire Wire Line
	8150 2000 7900 2000
Wire Wire Line
	7200 2000 7200 1950
Wire Wire Line
	7550 1700 7550 2000
Connection ~ 7550 2000
Wire Wire Line
	7550 2000 7200 2000
Wire Wire Line
	7900 1950 7900 2000
Connection ~ 7900 2000
Wire Wire Line
	7900 2000 7550 2000
$Comp
L power:GND #PWR011
U 1 1 5F77DF5E
P 7550 2000
F 0 "#PWR011" H 7550 1750 50  0001 C CNN
F 1 "GND" H 7555 1827 50  0000 C CNN
F 2 "" H 7550 2000 50  0001 C CNN
F 3 "" H 7550 2000 50  0001 C CNN
	1    7550 2000
	1    0    0    -1  
$EndComp
Connection ~ 8150 1300
$Comp
L Regulator_Linear:LD3985M33R_SOT23 U4
U 1 1 5F77DF78
P 7550 1400
F 0 "U4" H 7550 1742 50  0000 C CNN
F 1 "LD3985M33R_SOT23" H 7550 1651 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 7550 1725 50  0001 C CIN
F 3 "http://www.st.com/internet/com/TECHNICAL_RESOURCES/TECHNICAL_LITERATURE/DATASHEET/CD00003395.pdf" H 7550 1400 50  0001 C CNN
	1    7550 1400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7850 1400 7900 1400
Wire Wire Line
	7900 1400 7900 1650
Wire Wire Line
	9450 750  7000 750 
Wire Wire Line
	4750 750  4750 1300
Wire Wire Line
	4750 1300 4900 1300
Wire Wire Line
	7000 750  7000 1300
Wire Wire Line
	7000 1300 7200 1300
Connection ~ 7000 750 
Wire Wire Line
	7000 750  4750 750 
$Comp
L power:GND #PWR015
U 1 1 5F7D2E8E
P 9450 3850
F 0 "#PWR015" H 9450 3600 50  0001 C CNN
F 1 "GND" H 9455 3677 50  0000 C CNN
F 2 "" H 9450 3850 50  0001 C CNN
F 3 "" H 9450 3850 50  0001 C CNN
	1    9450 3850
	1    0    0    -1  
$EndComp
Wire Wire Line
	9450 3750 9450 3850
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
Text Notes 7300 950  0    50   ~ 0
Digital part LDO
Text Notes 9750 3300 0    50   ~ 0
To MCU or FPGA
Wire Wire Line
	4900 1300 4950 1300
Connection ~ 4900 1300
NoConn ~ 3450 4300
Text Label 6450 1300 0    50   ~ 0
3V3_A
Text Label 8700 1300 0    50   ~ 0
3V3_D
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
	5500 2300 6200 2300
Wire Wire Line
	6650 2300 6650 1300
Wire Wire Line
	8300 3650 8750 3650
Wire Wire Line
	8400 3850 8300 3850
$Comp
L power:GND #PWR012
U 1 1 5F98AD24
P 7800 4150
F 0 "#PWR012" H 7800 3900 50  0001 C CNN
F 1 "GND" H 7805 3977 50  0000 C CNN
F 2 "" H 7800 4150 50  0001 C CNN
F 3 "" H 7800 4150 50  0001 C CNN
	1    7800 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	5900 2950 6450 2950
Wire Wire Line
	6450 3750 7200 3750
Wire Wire Line
	8950 2300 8950 1300
$Comp
L Device:C C9
U 1 1 5F99A62F
P 6200 2500
F 0 "C9" H 6315 2546 50  0000 L CNN
F 1 "0.1uF" H 6315 2455 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6238 2350 50  0001 C CNN
F 3 "~" H 6200 2500 50  0001 C CNN
	1    6200 2500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR07
U 1 1 5F99B51E
P 6200 2650
F 0 "#PWR07" H 6200 2400 50  0001 C CNN
F 1 "GND" H 6205 2477 50  0000 C CNN
F 2 "" H 6200 2650 50  0001 C CNN
F 3 "" H 6200 2650 50  0001 C CNN
	1    6200 2650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR09
U 1 1 5F99B92A
P 6650 2650
F 0 "#PWR09" H 6650 2400 50  0001 C CNN
F 1 "GND" H 6655 2477 50  0000 C CNN
F 2 "" H 6650 2650 50  0001 C CNN
F 3 "" H 6650 2650 50  0001 C CNN
	1    6650 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	6650 2350 6650 2300
Connection ~ 6650 2300
Wire Wire Line
	6200 2300 6200 2350
$Comp
L Device:CP C11
U 1 1 5F9AC08F
P 6650 2500
F 0 "C11" H 6768 2546 50  0000 L CNN
F 1 "4.7uF" H 6768 2455 50  0000 L CNN
F 2 "Capacitor_Tantalum_SMD:CP_EIA-3528-21_Kemet-B_Pad1.50x2.35mm_HandSolder" H 6688 2350 50  0001 C CNN
F 3 "~" H 6650 2500 50  0001 C CNN
	1    6650 2500
	1    0    0    -1  
$EndComp
$Comp
L Device:C C16
U 1 1 5F9AC76C
P 8500 2500
F 0 "C16" H 8615 2546 50  0000 L CNN
F 1 "0.1uF" H 8615 2455 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8538 2350 50  0001 C CNN
F 3 "~" H 8500 2500 50  0001 C CNN
	1    8500 2500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR013
U 1 1 5F9ACA76
P 8500 2650
F 0 "#PWR013" H 8500 2400 50  0001 C CNN
F 1 "GND" H 8505 2477 50  0000 C CNN
F 2 "" H 8500 2650 50  0001 C CNN
F 3 "" H 8500 2650 50  0001 C CNN
	1    8500 2650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR014
U 1 1 5F9ACA80
P 8950 2650
F 0 "#PWR014" H 8950 2400 50  0001 C CNN
F 1 "GND" H 8955 2477 50  0000 C CNN
F 2 "" H 8950 2650 50  0001 C CNN
F 3 "" H 8950 2650 50  0001 C CNN
	1    8950 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	8950 2350 8950 2300
Wire Wire Line
	8500 2300 8500 2350
$Comp
L Device:CP C17
U 1 1 5F9ACA8C
P 8950 2500
F 0 "C17" H 9068 2546 50  0000 L CNN
F 1 "4.7uF" H 9068 2455 50  0000 L CNN
F 2 "Capacitor_Tantalum_SMD:CP_EIA-3528-21_Kemet-B_Pad1.50x2.35mm_HandSolder" H 8988 2350 50  0001 C CNN
F 3 "~" H 8950 2500 50  0001 C CNN
	1    8950 2500
	1    0    0    -1  
$EndComp
Connection ~ 8950 2300
Text Label 9700 3450 0    50   ~ 0
OUT_N
$Comp
L Connector:Conn_01x02_Male J5
U 1 1 5F9B4A83
P 9100 4500
F 0 "J5" H 9072 4382 50  0000 R CNN
F 1 "Single Ended" H 9072 4473 50  0000 R CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x02_P1.27mm_Vertical" H 9100 4500 50  0001 C CNN
F 3 "~" H 9100 4500 50  0001 C CNN
	1    9100 4500
	-1   0    0    1   
$EndComp
Wire Wire Line
	8900 4400 8750 4400
Wire Wire Line
	8750 4400 8750 3650
Connection ~ 8750 3650
Wire Wire Line
	8750 3650 10050 3650
Text Notes 8600 4800 0    50   ~ 0
For single ended output only,\nshorten J5 and don't solder\nU4 and U5.
$Comp
L Connector:Conn_01x02_Male J4
U 1 1 5F9CCAB3
P 7250 2600
F 0 "J4" V 7200 2600 50  0000 R CNN
F 1 "Single VReg" V 7100 2750 50  0000 R CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x02_P1.27mm_Vertical" H 7250 2600 50  0001 C CNN
F 3 "~" H 7250 2600 50  0001 C CNN
	1    7250 2600
	0    -1   -1   0   
$EndComp
Wire Wire Line
	7350 2400 7350 2300
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
Connection ~ 7800 2300
Wire Wire Line
	7350 2300 7800 2300
Wire Wire Line
	7800 2300 8500 2300
Wire Wire Line
	7250 2400 7250 2300
Wire Wire Line
	7800 3350 7800 2300
$Comp
L Interface:SN65LVDS1DBV U5
U 1 1 5F9817F9
P 7800 3750
F 0 "U5" H 7800 4331 50  0000 C CNN
F 1 "SN65LVDS1DBV" H 7800 4240 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 7800 3300 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn65lvds1.pdf" H 7800 3850 50  0001 C CNN
	1    7800 3750
	1    0    0    -1  
$EndComp
Connection ~ 6200 2300
Wire Wire Line
	6200 2300 6650 2300
Connection ~ 8500 2300
Wire Wire Line
	8500 2300 8950 2300
Wire Wire Line
	7250 1300 7200 1300
Connection ~ 7200 1300
Text Notes 7050 3050 0    50   ~ 0
For single VReg,\nshorten J4 and\ndon't solder U4.
Wire Wire Line
	5850 1300 6650 1300
Wire Wire Line
	8150 1300 8950 1300
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
	7200 3750 7200 4500
Wire Wire Line
	7200 4500 8900 4500
Connection ~ 7200 3750
Wire Wire Line
	7200 3750 7300 3750
$Comp
L Device:R R2
U 1 1 5FACAC9F
P 6450 3400
F 0 "R2" H 6380 3354 50  0000 R CNN
F 1 "0" H 6380 3445 50  0000 R CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" V 6380 3400 50  0001 C CNN
F 3 "~" H 6450 3400 50  0001 C CNN
	1    6450 3400
	-1   0    0    1   
$EndComp
$Comp
L Device:R R3
U 1 1 5FACB1B3
P 6450 4000
F 0 "R3" H 6380 3954 50  0000 R CNN
F 1 "1M" H 6380 4045 50  0000 R CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" V 6380 4000 50  0001 C CNN
F 3 "~" H 6450 4000 50  0001 C CNN
	1    6450 4000
	-1   0    0    1   
$EndComp
$Comp
L power:GND #PWR01
U 1 1 5FACBA48
P 6450 4200
F 0 "#PWR01" H 6450 3950 50  0001 C CNN
F 1 "GND" H 6455 4027 50  0000 C CNN
F 2 "" H 6450 4200 50  0001 C CNN
F 3 "" H 6450 4200 50  0001 C CNN
	1    6450 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	6450 4150 6450 4200
Wire Wire Line
	6450 2950 6450 3250
Wire Wire Line
	6450 3550 6450 3750
Wire Wire Line
	6450 3750 6450 3850
Connection ~ 6450 3750
Text Notes 6050 4700 0    50   ~ 0
Optional voltage divider\nFor cases when Vcc \nof osciller > 3.3V
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
	9450 750  9450 3550
Wire Wire Line
	9450 3550 10050 3550
Wire Wire Line
	10050 3450 8400 3450
Wire Wire Line
	8400 3450 8400 3850
NoConn ~ 2700 4700
NoConn ~ 3450 4700
Wire Wire Line
	1600 3650 2450 3650
Wire Wire Line
	6650 2300 7250 2300
Wire Wire Line
	2450 4500 2450 4550
$Comp
L power:GND #PWR03
U 1 1 5F7E2DD3
P 2450 4550
F 0 "#PWR03" H 2450 4300 50  0001 C CNN
F 1 "GND" H 2455 4377 50  0000 C CNN
F 2 "" H 2450 4550 50  0001 C CNN
F 3 "" H 2450 4550 50  0001 C CNN
	1    2450 4550
	1    0    0    -1  
$EndComp
Wire Wire Line
	2450 4500 2700 4500
Wire Wire Line
	5500 2300 4100 2300
Wire Wire Line
	4100 2300 4100 4500
Connection ~ 5500 2300
Wire Wire Line
	2700 4300 2450 4300
Wire Wire Line
	2450 4300 2450 3650
Connection ~ 2450 3650
Wire Wire Line
	2450 3650 4500 3650
$EndSCHEMATC
