EESchema Schematic File Version 4
LIBS:sp721
LIBS:phase_shift_sensor_smd_3v3-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Theremin Phase Shift Sensor"
Date "2019-12-09"
Rev "v0.3"
Comp ""
Comment1 "Teensy 4 Theremin Project"
Comment2 "(c) Vadim Lopatin 2019"
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Device:C C1
U 1 1 5D9DEE40
P 8250 3700
F 0 "C1" H 8365 3746 50  0000 L CNN
F 1 "3.3pF" H 8365 3655 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8288 3550 50  0001 C CNN
F 3 "~" H 8250 3700 50  0001 C CNN
	1    8250 3700
	0    1    1    0   
$EndComp
Wire Wire Line
	1450 2100 1450 2300
$Comp
L power:GND #PWR05
U 1 1 5D9E3311
P 1450 2300
F 0 "#PWR05" H 1450 2050 50  0001 C CNN
F 1 "GND" H 1455 2127 50  0000 C CNN
F 2 "" H 1450 2300 50  0001 C CNN
F 3 "" H 1450 2300 50  0001 C CNN
	1    1450 2300
	1    0    0    -1  
$EndComp
Text Label 1050 1800 0    50   ~ 0
VCC_5V
Text Label 1050 1700 0    50   ~ 0
REF_CLK
Text Label 1050 2000 0    50   ~ 0
OUT
Text Label 1050 2100 0    50   ~ 0
GND
$Comp
L Connector:Conn_01x01_Male J2
U 1 1 5D9FD8BA
P 9900 1700
F 0 "J2" H 9872 1580 50  0000 R CNN
F 1 "INDUCTOR_IN" H 9872 1671 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Vertical" H 9900 1700 50  0001 C CNN
F 3 "~" H 9900 1700 50  0001 C CNN
	1    9900 1700
	-1   0    0    1   
$EndComp
$Comp
L Connector:Conn_01x01_Male J3
U 1 1 5D9FD952
P 9900 3200
F 0 "J3" H 9872 3080 50  0000 R CNN
F 1 "INDUCTOR_OUT" H 9872 3171 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Vertical" H 9900 3200 50  0001 C CNN
F 3 "~" H 9900 3200 50  0001 C CNN
	1    9900 3200
	-1   0    0    1   
$EndComp
$Comp
L Connector:Conn_01x01_Male J4
U 1 1 5D9FD990
P 9900 3700
F 0 "J4" H 9872 3580 50  0000 R CNN
F 1 "ANTENNA" H 9872 3671 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Vertical" H 9900 3700 50  0001 C CNN
F 3 "~" H 9900 3700 50  0001 C CNN
	1    9900 3700
	-1   0    0    1   
$EndComp
Wire Wire Line
	9500 3200 9700 3200
Wire Wire Line
	9500 3700 9700 3700
Connection ~ 9500 3700
$Comp
L power:GND #PWR010
U 1 1 5DA2AF11
P 8750 6200
F 0 "#PWR010" H 8750 5950 50  0001 C CNN
F 1 "GND" H 8755 6027 50  0000 C CNN
F 2 "" H 8750 6200 50  0001 C CNN
F 3 "" H 8750 6200 50  0001 C CNN
	1    8750 6200
	1    0    0    -1  
$EndComp
Text Notes 9800 3900 0    79   ~ 0
To theremin antenna
Text Notes 850  750  0    79   ~ 0
Theremin phase shift sensor
$Comp
L Device:C C12
U 1 1 5DD2E1A1
P 10050 5850
F 0 "C12" H 10165 5896 50  0000 L CNN
F 1 "1uF" H 10165 5805 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 10088 5700 50  0001 C CNN
F 3 "~" H 10050 5850 50  0001 C CNN
	1    10050 5850
	1    0    0    -1  
$EndComp
Wire Wire Line
	10050 6000 10050 6200
$Comp
L Device:C C11
U 1 1 5DD314D9
P 8750 5850
F 0 "C11" H 8865 5896 50  0000 L CNN
F 1 "1uF" H 8865 5805 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8788 5700 50  0001 C CNN
F 3 "~" H 8750 5850 50  0001 C CNN
	1    8750 5850
	1    0    0    -1  
$EndComp
Wire Wire Line
	8750 6000 8750 6100
Wire Wire Line
	9750 5400 10050 5400
Wire Wire Line
	10050 5400 10050 5700
Wire Wire Line
	8750 5400 8750 5700
$Comp
L power:GND #PWR011
U 1 1 5DD39AFC
P 9450 6200
F 0 "#PWR011" H 9450 5950 50  0001 C CNN
F 1 "GND" H 9455 6027 50  0000 C CNN
F 2 "" H 9450 6200 50  0001 C CNN
F 3 "" H 9450 6200 50  0001 C CNN
	1    9450 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	9450 5700 9450 6200
$Comp
L power:GND #PWR012
U 1 1 5DD3B6B2
P 10050 6200
F 0 "#PWR012" H 10050 5950 50  0001 C CNN
F 1 "GND" H 10055 6027 50  0000 C CNN
F 2 "" H 10050 6200 50  0001 C CNN
F 3 "" H 10050 6200 50  0001 C CNN
	1    10050 6200
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR09
U 1 1 5DDEB314
P 10750 5400
F 0 "#PWR09" H 10750 5250 50  0001 C CNN
F 1 "+3.3V" H 10765 5573 50  0000 C CNN
F 2 "" H 10750 5400 50  0001 C CNN
F 3 "" H 10750 5400 50  0001 C CNN
	1    10750 5400
	0    1    1    0   
$EndComp
Wire Wire Line
	10050 5400 10500 5400
Connection ~ 10050 5400
$Comp
L power:+5V #PWR03
U 1 1 5DDFCFD3
P 1800 1350
F 0 "#PWR03" H 1800 1200 50  0001 C CNN
F 1 "+5V" H 1815 1523 50  0000 C CNN
F 2 "" H 1800 1350 50  0001 C CNN
F 3 "" H 1800 1350 50  0001 C CNN
	1    1800 1350
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR08
U 1 1 5DDFD021
P 8500 5400
F 0 "#PWR08" H 8500 5250 50  0001 C CNN
F 1 "+5V" V 8515 5528 50  0000 L CNN
F 2 "" H 8500 5400 50  0001 C CNN
F 3 "" H 8500 5400 50  0001 C CNN
	1    8500 5400
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8500 5400 8750 5400
Connection ~ 8750 5400
$Comp
L Device:R R2
U 1 1 5DDC4F30
P 1900 4250
F 0 "R2" V 1693 4250 50  0000 C CNN
F 1 "100K" V 1784 4250 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" V 1830 4250 50  0001 C CNN
F 3 "~" H 1900 4250 50  0001 C CNN
	1    1900 4250
	1    0    0    -1  
$EndComp
$Comp
L Device:R R3
U 1 1 5DDC4FB9
P 1900 4750
F 0 "R3" V 1693 4750 50  0000 C CNN
F 1 "100K" V 1784 4750 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" V 1830 4750 50  0001 C CNN
F 3 "~" H 1900 4750 50  0001 C CNN
	1    1900 4750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR02
U 1 1 5DDC50A6
P 1900 5000
F 0 "#PWR02" H 1900 4750 50  0001 C CNN
F 1 "GND" H 1905 4827 50  0000 C CNN
F 2 "" H 1900 5000 50  0001 C CNN
F 3 "" H 1900 5000 50  0001 C CNN
	1    1900 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 4000 1900 4100
Wire Wire Line
	1900 4400 1900 4500
Connection ~ 1900 4500
Wire Wire Line
	1900 4500 1900 4600
Wire Wire Line
	1900 4900 1900 5000
$Comp
L Device:C C2
U 1 1 5DDCCEBE
P 7750 3700
F 0 "C2" H 7865 3746 50  0000 L CNN
F 1 "3.3pF" H 7865 3655 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 7788 3550 50  0001 C CNN
F 3 "~" H 7750 3700 50  0001 C CNN
	1    7750 3700
	0    1    1    0   
$EndComp
Wire Wire Line
	7900 3700 8100 3700
Text Notes 6650 1550 0    50   ~ 0
(optional: C 1..100nF or R0..100 Ohm)
$Comp
L Connector:TestPoint TP1
U 1 1 5DDD0440
P 850 4500
F 0 "TP1" V 1045 4574 50  0000 C CNN
F 1 "OUT_NOBUF" V 954 4574 50  0000 C CNN
F 2 "TestPoint:TestPoint_THTPad_1.0x1.0mm_Drill0.5mm" H 1050 4500 50  0001 C CNN
F 3 "~" H 1050 4500 50  0001 C CNN
	1    850  4500
	0    -1   -1   0   
$EndComp
$Comp
L Connector:TestPoint TP5
U 1 1 5DDD895C
P 10050 5250
F 0 "TP5" H 10108 5370 50  0000 L CNN
F 1 "+3.3V" H 10108 5279 50  0000 L CNN
F 2 "TestPoint:TestPoint_THTPad_1.0x1.0mm_Drill0.5mm" H 10250 5250 50  0001 C CNN
F 3 "~" H 10250 5250 50  0001 C CNN
	1    10050 5250
	1    0    0    -1  
$EndComp
Wire Wire Line
	10050 5250 10050 5400
$Comp
L Connector:TestPoint TP6
U 1 1 5DDE0887
P 8350 6100
F 0 "TP6" V 8545 6174 50  0000 C CNN
F 1 "GND" V 8454 6174 50  0000 C CNN
F 2 "TestPoint:TestPoint_THTPad_1.0x1.0mm_Drill0.5mm" H 8550 6100 50  0001 C CNN
F 3 "~" H 8550 6100 50  0001 C CNN
	1    8350 6100
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8350 6100 8750 6100
Connection ~ 8750 6100
Wire Wire Line
	8750 6100 8750 6200
Wire Wire Line
	8400 3700 9500 3700
$Comp
L Device:C C3
U 1 1 5DDF2A40
P 7250 3700
F 0 "C3" H 7365 3746 50  0000 L CNN
F 1 "3.3pF" H 7365 3655 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 7288 3550 50  0001 C CNN
F 3 "~" H 7250 3700 50  0001 C CNN
	1    7250 3700
	0    1    1    0   
$EndComp
Wire Wire Line
	7400 3700 7600 3700
Text Notes 7050 3500 0    50   ~ 0
1pF..3.3pF, 3 caps in series - to increase voltage
$Comp
L Connector:Conn_01x06_Male J1
U 1 1 5DE043CD
P 800 1900
F 0 "J1" H 900 1550 50  0000 R CNN
F 1 "SENSOR" V 700 2050 50  0000 R CNN
F 2 "Connector_PinHeader_1.27mm:PinHeader_1x06_P1.27mm_Vertical" H 800 1900 50  0001 C CNN
F 3 "~" H 800 1900 50  0001 C CNN
	1    800  1900
	1    0    0    1   
$EndComp
Text Label 1050 1900 0    50   ~ 0
GND
Wire Wire Line
	7500 1700 9700 1700
Text Notes 7600 2500 0    79   ~ 0
INDUCTOR_IN, INDUCTOR_OUT: air core coil, 2-3mH\n0.1mm/0.125mm copper wire, 32mm frame diameter, \n40..55mm winding length
Wire Wire Line
	9500 3200 9500 3700
$Comp
L 74LVC2G04:74LVC2G04 U4
U 1 1 5DEA3604
P 3800 1700
F 0 "U4" H 3775 1967 50  0000 C CNN
F 1 "LVC2G04" H 3775 1876 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-6" H 3800 1700 50  0001 C CNN
F 3 "http://www.ti.com/lit/sg/scyt129e/scyt129e.pdf" H 3800 1700 50  0001 C CNN
	1    3800 1700
	1    0    0    -1  
$EndComp
$Comp
L 74LVC2G04:74LVC2G04 U4
U 2 1 5DEA372E
P 3800 2400
F 0 "U4" H 3775 2667 50  0000 C CNN
F 1 "LVC2G04" H 3775 2576 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-6" H 3800 2400 50  0001 C CNN
F 3 "http://www.ti.com/lit/sg/scyt129e/scyt129e.pdf" H 3800 2400 50  0001 C CNN
	2    3800 2400
	1    0    0    -1  
$EndComp
$Comp
L Device:C C9
U 1 1 5DEAAC89
P 3000 2350
F 0 "C9" H 3115 2396 50  0000 L CNN
F 1 "0.1uF" H 3115 2305 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3038 2200 50  0001 C CNN
F 3 "~" H 3000 2350 50  0001 C CNN
	1    3000 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	3500 2400 3400 2400
Wire Wire Line
	3000 2200 3000 2100
Wire Wire Line
	3000 2100 3800 2100
Wire Wire Line
	3800 2100 3800 2300
Wire Wire Line
	3800 2500 3800 2700
Wire Wire Line
	3000 2700 3000 2500
$Comp
L power:GND #PWR0101
U 1 1 5DEB4381
P 3000 2800
F 0 "#PWR0101" H 3000 2550 50  0001 C CNN
F 1 "GND" H 3005 2627 50  0000 C CNN
F 2 "" H 3000 2800 50  0001 C CNN
F 3 "" H 3000 2800 50  0001 C CNN
	1    3000 2800
	1    0    0    -1  
$EndComp
$Comp
L power:+3V3 #PWR0102
U 1 1 5DEB43BC
P 3000 1250
F 0 "#PWR0102" H 3000 1100 50  0001 C CNN
F 1 "+3V3" V 3015 1378 50  0000 L CNN
F 2 "" H 3000 1250 50  0001 C CNN
F 3 "" H 3000 1250 50  0001 C CNN
	1    3000 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 1250 3000 1350
Connection ~ 3000 2100
Wire Wire Line
	3000 2700 3000 2800
Connection ~ 3000 2700
$Comp
L Device:C C10
U 1 1 5DEC729F
P 6400 2750
F 0 "C10" H 6515 2796 50  0000 L CNN
F 1 "0.22uF" H 6515 2705 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6438 2600 50  0001 C CNN
F 3 "~" H 6400 2750 50  0001 C CNN
	1    6400 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	6400 2900 6400 3000
Wire Wire Line
	6400 3000 6200 3000
Connection ~ 6200 3000
Wire Wire Line
	6200 3000 6200 3200
Wire Wire Line
	6200 2300 6200 2500
Wire Wire Line
	6400 2600 6400 2500
Wire Wire Line
	6400 2500 6200 2500
Connection ~ 6200 2500
$Comp
L power:GND #PWR0103
U 1 1 5DEC72AD
P 6200 3200
F 0 "#PWR0103" H 6200 2950 50  0001 C CNN
F 1 "GND" H 6205 3027 50  0000 C CNN
F 2 "" H 6200 3200 50  0001 C CNN
F 3 "" H 6200 3200 50  0001 C CNN
	1    6200 3200
	1    0    0    -1  
$EndComp
Text Notes 4350 3200 0    50   ~ 0
IP4220CZ6 ESD protection is mandatory!\nThere is 200V voltage swing on antenna!!!
$Comp
L IP4220CZ6:IP4220CZ6 U5
U 1 1 5DEC72BB
P 4900 2300
F 0 "U5" H 5275 2715 50  0000 C CNN
F 1 "4220CZ6" H 5275 2624 50  0000 C CNN
F 2 "Package_SO:TSOP-6_1.65x3.05mm_P0.95mm" H 5250 2600 50  0001 C CNN
F 3 "" H 5250 2600 50  0001 C CNN
	1    4900 2300
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 2500 6200 2500
Wire Wire Line
	4700 3000 6200 3000
Wire Wire Line
	4700 3000 4700 2500
Wire Wire Line
	4700 2500 4900 2500
NoConn ~ 4900 2700
NoConn ~ 4900 2300
$Comp
L 74LVC2G04:74LVC2G04 U1
U 2 1 5DEE13DE
P 3750 4500
F 0 "U1" H 3725 4767 50  0000 C CNN
F 1 "LVC2G04" H 3725 4676 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-6" H 3750 4500 50  0001 C CNN
F 3 "http://www.ti.com/lit/sg/scyt129e/scyt129e.pdf" H 3750 4500 50  0001 C CNN
	2    3750 4500
	1    0    0    -1  
$EndComp
$Comp
L 74LVC2G04:74LVC2G04 U1
U 1 1 5DEE13E4
P 3750 5200
F 0 "U1" H 3725 5467 50  0000 C CNN
F 1 "LVC2G04" H 3725 5376 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-6" H 3750 5200 50  0001 C CNN
F 3 "http://www.ti.com/lit/sg/scyt129e/scyt129e.pdf" H 3750 5200 50  0001 C CNN
	1    3750 5200
	1    0    0    -1  
$EndComp
$Comp
L Device:C C7
U 1 1 5DEE13EA
P 2950 5150
F 0 "C7" H 3065 5196 50  0000 L CNN
F 1 "0.1uF" H 3065 5105 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2988 5000 50  0001 C CNN
F 3 "~" H 2950 5150 50  0001 C CNN
	1    2950 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	3450 5200 3350 5200
Wire Wire Line
	2950 5000 2950 4900
Wire Wire Line
	2950 4900 3750 4900
Wire Wire Line
	3750 4900 3750 5100
Wire Wire Line
	3750 5300 3750 5500
Wire Wire Line
	3750 5500 3350 5500
Wire Wire Line
	2950 5500 2950 5300
$Comp
L power:GND #PWR0104
U 1 1 5DEE13FC
P 2950 5600
F 0 "#PWR0104" H 2950 5350 50  0001 C CNN
F 1 "GND" H 2955 5427 50  0000 C CNN
F 2 "" H 2950 5600 50  0001 C CNN
F 3 "" H 2950 5600 50  0001 C CNN
	1    2950 5600
	1    0    0    -1  
$EndComp
Connection ~ 2950 4900
Wire Wire Line
	2950 5500 2950 5600
Connection ~ 2950 5500
Wire Wire Line
	1900 4500 2500 4500
Wire Wire Line
	3350 5200 3350 5500
Connection ~ 3350 5500
Wire Wire Line
	3350 5500 2950 5500
NoConn ~ 4000 5200
$Comp
L Device:C C8
U 1 1 5DF1ED56
P 4400 6750
F 0 "C8" H 4515 6796 50  0000 L CNN
F 1 "0.22uF" H 4515 6705 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4438 6600 50  0001 C CNN
F 3 "~" H 4400 6750 50  0001 C CNN
	1    4400 6750
	1    0    0    -1  
$EndComp
Wire Wire Line
	4400 6900 4400 7000
Connection ~ 4400 7000
Wire Wire Line
	4400 7000 4400 7350
Wire Wire Line
	4400 6600 4400 6500
Connection ~ 4400 6500
$Comp
L power:GND #PWR0105
U 1 1 5DF1ED64
P 4400 7350
F 0 "#PWR0105" H 4400 7100 50  0001 C CNN
F 1 "GND" H 4405 7177 50  0000 C CNN
F 2 "" H 4400 7350 50  0001 C CNN
F 3 "" H 4400 7350 50  0001 C CNN
	1    4400 7350
	1    0    0    -1  
$EndComp
Text Notes 2650 7250 0    50   ~ 0
IP4220CZ6 ESD protection is mandatory!\nThere is 200V voltage swing on antenna!!!
$Comp
L IP4220CZ6:IP4220CZ6 U2
U 1 1 5DF1ED71
P 3400 6300
F 0 "U2" H 3775 6715 50  0000 C CNN
F 1 "4220CZ6" H 3775 6624 50  0000 C CNN
F 2 "Package_SO:TSOP-6_1.65x3.05mm_P0.95mm" H 3750 6600 50  0001 C CNN
F 3 "" H 3750 6600 50  0001 C CNN
	1    3400 6300
	1    0    0    -1  
$EndComp
Wire Wire Line
	4150 6500 4400 6500
Wire Wire Line
	3200 7000 4400 7000
Wire Wire Line
	3200 7000 3200 6500
Wire Wire Line
	3200 6500 3400 6500
NoConn ~ 3400 6700
NoConn ~ 4150 6700
$Comp
L power:+3V3 #PWR0107
U 1 1 5DF22E04
P 6200 2300
F 0 "#PWR0107" H 6200 2150 50  0001 C CNN
F 1 "+3V3" V 6215 2428 50  0000 L CNN
F 2 "" H 6200 2300 50  0001 C CNN
F 3 "" H 6200 2300 50  0001 C CNN
	1    6200 2300
	1    0    0    -1  
$EndComp
Wire Wire Line
	850  4500 1150 4500
Wire Wire Line
	1800 2000 1800 3100
Wire Wire Line
	1800 3100 4200 3100
Wire Wire Line
	4200 3100 4200 4500
Wire Wire Line
	4200 4500 4000 4500
NoConn ~ 5650 2300
Wire Wire Line
	1000 2100 1450 2100
Wire Wire Line
	1000 2000 1800 2000
$Comp
L Device:C C4
U 1 1 5DF6FB14
P 8700 2900
F 0 "C4" H 8815 2946 50  0000 L CNN
F 1 "10pF" H 8815 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8738 2750 50  0001 C CNN
F 3 "~" H 8700 2900 50  0001 C CNN
	1    8700 2900
	0    1    1    0   
$EndComp
$Comp
L Device:C C5
U 1 1 5DF6FB1A
P 8200 2900
F 0 "C5" H 8315 2946 50  0000 L CNN
F 1 "10pF" H 8315 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8238 2750 50  0001 C CNN
F 3 "~" H 8200 2900 50  0001 C CNN
	1    8200 2900
	0    1    1    0   
$EndComp
Wire Wire Line
	8350 2900 8550 2900
Wire Wire Line
	8850 2900 9500 2900
$Comp
L Device:C C6
U 1 1 5DF6FB22
P 7700 2900
F 0 "C6" H 7815 2946 50  0000 L CNN
F 1 "10pF" H 7815 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 7738 2750 50  0001 C CNN
F 3 "~" H 7700 2900 50  0001 C CNN
	1    7700 2900
	0    1    1    0   
$EndComp
Wire Wire Line
	7850 2900 8050 2900
Wire Wire Line
	2500 3700 2500 4500
Wire Wire Line
	2500 3700 7100 3700
Connection ~ 2500 4500
Wire Wire Line
	2500 4500 3450 4500
Wire Wire Line
	7550 2900 7250 2900
Wire Wire Line
	7250 2900 7250 3100
$Comp
L power:GND #PWR0108
U 1 1 5DF81AA2
P 7250 3100
F 0 "#PWR0108" H 7250 2850 50  0001 C CNN
F 1 "GND" H 7255 2927 50  0000 C CNN
F 2 "" H 7250 3100 50  0001 C CNN
F 3 "" H 7250 3100 50  0001 C CNN
	1    7250 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	9500 2900 9500 3200
$Comp
L Device:C C13
U 1 1 5DF84774
P 7350 1700
F 0 "C13" H 7465 1746 50  0000 L CNN
F 1 "220pF" H 7465 1655 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 7388 1550 50  0001 C CNN
F 3 "~" H 7350 1700 50  0001 C CNN
	1    7350 1700
	0    1    1    0   
$EndComp
NoConn ~ 4150 6300
Wire Wire Line
	3400 6300 2500 6300
Wire Wire Line
	2500 6300 2500 4500
Text Notes 2900 900  0    50   ~ 0
Two gates in parallel to increase output current
Wire Wire Line
	3750 4600 3750 4750
Wire Wire Line
	3750 4750 4200 4750
Wire Wire Line
	4200 4750 4200 5500
Wire Wire Line
	4200 5500 3750 5500
Connection ~ 3750 5500
Wire Wire Line
	3750 4400 3750 4250
Wire Wire Line
	3750 4250 2950 4250
Connection ~ 2950 4250
Wire Wire Line
	2950 4250 2950 4900
Wire Wire Line
	3000 1350 3800 1350
Wire Wire Line
	3800 1350 3800 1600
Connection ~ 3000 1350
Wire Wire Line
	3000 1350 3000 2100
Wire Wire Line
	3800 1800 3800 2000
Wire Wire Line
	3800 2000 4100 2000
Wire Wire Line
	4100 2000 4100 2700
Wire Wire Line
	4100 2700 3800 2700
Connection ~ 3800 2700
Wire Wire Line
	5650 2700 5800 2700
Wire Wire Line
	5800 2700 5800 1700
Connection ~ 5800 1700
Wire Wire Line
	5800 1700 7200 1700
Wire Wire Line
	4050 1700 4250 1700
$Comp
L Regulator_Linear:MCP1700-3302E_SOT23 U3
U 1 1 5DEFB48C
P 9450 5400
F 0 "U3" H 9450 5642 50  0000 C CNN
F 1 "MCP1700-3302E" H 9450 5551 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 9450 5625 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/20001826C.pdf" H 9450 5400 50  0001 C CNN
	1    9450 5400
	1    0    0    -1  
$EndComp
$Comp
L Device:C C14
U 1 1 5E45C684
P 6200 5850
F 0 "C14" H 6315 5896 50  0000 L CNN
F 1 "1uF" H 6315 5805 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6238 5700 50  0001 C CNN
F 3 "~" H 6200 5850 50  0001 C CNN
	1    6200 5850
	1    0    0    -1  
$EndComp
Wire Wire Line
	6200 6000 6200 6200
Wire Wire Line
	5900 5400 6200 5400
Wire Wire Line
	6200 5400 6200 5700
$Comp
L power:GND #PWR04
U 1 1 5E45C696
P 5600 6200
F 0 "#PWR04" H 5600 5950 50  0001 C CNN
F 1 "GND" H 5605 6027 50  0000 C CNN
F 2 "" H 5600 6200 50  0001 C CNN
F 3 "" H 5600 6200 50  0001 C CNN
	1    5600 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5600 5700 5600 6200
$Comp
L power:GND #PWR06
U 1 1 5E45C69D
P 6200 6200
F 0 "#PWR06" H 6200 5950 50  0001 C CNN
F 1 "GND" H 6205 6027 50  0000 C CNN
F 2 "" H 6200 6200 50  0001 C CNN
F 3 "" H 6200 6200 50  0001 C CNN
	1    6200 6200
	1    0    0    -1  
$EndComp
Connection ~ 6200 5400
$Comp
L power:+5V #PWR01
U 1 1 5E45C6AB
P 4850 5400
F 0 "#PWR01" H 4850 5250 50  0001 C CNN
F 1 "+5V" V 4865 5528 50  0000 L CNN
F 2 "" H 4850 5400 50  0001 C CNN
F 3 "" H 4850 5400 50  0001 C CNN
	1    4850 5400
	0    -1   -1   0   
$EndComp
$Comp
L Connector:TestPoint TP2
U 1 1 5E45C6B3
P 6200 5250
F 0 "TP2" H 6258 5370 50  0000 L CNN
F 1 "+3.3V" H 6258 5279 50  0000 L CNN
F 2 "TestPoint:TestPoint_THTPad_1.0x1.0mm_Drill0.5mm" H 6400 5250 50  0001 C CNN
F 3 "~" H 6400 5250 50  0001 C CNN
	1    6200 5250
	1    0    0    -1  
$EndComp
Wire Wire Line
	6200 5250 6200 5400
$Comp
L Regulator_Linear:MCP1700-3302E_SOT23 U6
U 1 1 5E45C6C3
P 5600 5400
F 0 "U6" H 5600 5642 50  0000 C CNN
F 1 "MCP1700-3302E" H 5600 5551 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 5600 5625 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/20001826C.pdf" H 5600 5400 50  0001 C CNN
	1    5600 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 2700 3800 2700
Wire Wire Line
	3400 2400 3400 1700
Wire Wire Line
	3400 1700 3500 1700
Wire Wire Line
	4050 2400 4250 2400
Wire Wire Line
	4250 2400 4250 1700
Connection ~ 4250 1700
Wire Wire Line
	4250 1700 5800 1700
Wire Wire Line
	6500 5400 6500 4400
Wire Wire Line
	6500 4400 4400 4400
Wire Wire Line
	6200 5400 6500 5400
Wire Wire Line
	2950 4000 2950 4250
Connection ~ 2950 4000
Wire Wire Line
	2950 4000 1900 4000
Wire Wire Line
	4400 4000 4400 4400
Wire Wire Line
	4400 4000 2950 4000
Connection ~ 1450 2100
Wire Wire Line
	1000 1900 1450 1900
Wire Wire Line
	1450 1900 1450 2100
Text Label 1050 1600 0    50   ~ 0
GND
Wire Wire Line
	1000 1700 3400 1700
Connection ~ 3400 1700
Wire Wire Line
	1000 1800 1800 1800
Wire Wire Line
	1800 1350 1800 1800
Wire Wire Line
	1000 1600 1450 1600
Wire Wire Line
	1450 1600 1450 1900
Connection ~ 1450 1900
Wire Wire Line
	10500 5400 10500 5000
Wire Wire Line
	10500 4400 9800 4400
Connection ~ 10500 5400
Wire Wire Line
	10500 5400 10750 5400
$Comp
L Device:Jumper JP1
U 1 1 5E51304C
P 9500 4400
F 0 "JP1" H 9500 4664 50  0000 C CNN
F 1 "01REG" H 9500 4573 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 9500 4400 50  0001 C CNN
F 3 "~" H 9500 4400 50  0001 C CNN
	1    9500 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	9200 4400 6500 4400
Connection ~ 6500 4400
Text Notes 7400 4300 0    59   ~ 0
Short JP1 if only one regulator is soldered\nor no on board regulators at all
$Comp
L Device:Jumper JP2
U 1 1 5E51875F
P 9500 5000
F 0 "JP2" H 9500 5264 50  0000 C CNN
F 1 "00REG" H 9500 5173 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 9500 5000 50  0001 C CNN
F 3 "~" H 9500 5000 50  0001 C CNN
	1    9500 5000
	1    0    0    -1  
$EndComp
Text Notes 8100 4850 0    59   ~ 0
Short both JP1 and JP2 \nif no regulators used\nand 3.3V provided from J1
Wire Wire Line
	4850 5400 5300 5400
Connection ~ 9500 3200
Wire Wire Line
	8750 5400 9150 5400
Wire Wire Line
	9800 5000 10500 5000
Connection ~ 10500 5000
Wire Wire Line
	10500 5000 10500 4400
Wire Wire Line
	9200 5000 8750 5000
Wire Wire Line
	8750 5000 8750 5400
$Comp
L Device:C C15
U 1 1 5E58EBF3
P 1150 4750
F 0 "C15" H 1265 4796 50  0000 L CNN
F 1 "3.3pF" H 1265 4705 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 1188 4600 50  0001 C CNN
F 3 "~" H 1150 4750 50  0001 C CNN
	1    1150 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	1150 4900 1150 5000
Wire Wire Line
	1150 4500 1150 4600
$Comp
L power:GND #PWR07
U 1 1 5E58EBFB
P 1150 5000
F 0 "#PWR07" H 1150 4750 50  0001 C CNN
F 1 "GND" H 1155 4827 50  0000 C CNN
F 2 "" H 1150 5000 50  0001 C CNN
F 3 "" H 1150 5000 50  0001 C CNN
	1    1150 5000
	1    0    0    -1  
$EndComp
Connection ~ 1150 4500
Wire Wire Line
	1150 4500 1900 4500
Connection ~ 4400 4400
Wire Wire Line
	4400 4400 4400 6500
Text Notes 550  5800 0    50   ~ 0
Optional C - additional\nvoltage divider on buffer input
Text Notes 1500 5350 0    50   ~ 0
Input centering resistors
Text Notes 7550 2750 0    50   ~ 0
Optional: to decrease sensitivity if needed
$Comp
L Device:C C16
U 1 1 5E5BC251
P 1150 4200
F 0 "C16" H 1265 4246 50  0000 L CNN
F 1 "3.3pF" H 1265 4155 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 1188 4050 50  0001 C CNN
F 3 "~" H 1150 4200 50  0001 C CNN
	1    1150 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	1150 4050 1150 4000
Wire Wire Line
	1150 4000 1900 4000
Connection ~ 1900 4000
Wire Wire Line
	1150 4350 1150 4500
$EndSCHEMATC