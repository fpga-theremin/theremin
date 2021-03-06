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
P 3300 3650
F 0 "J3" H 3272 3530 50  0000 R CNN
F 1 "INDUCTOR_IN" H 3272 3621 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Horizontal" H 3300 3650 50  0001 C CNN
F 3 "~" H 3300 3650 50  0001 C CNN
	1    3300 3650
	1    0    0    1   
$EndComp
$Comp
L Connector:Conn_01x02_Male J1
U 1 1 5D9FD990
P 5300 1750
F 0 "J1" H 5350 1850 50  0000 R CNN
F 1 "ANTENNA" H 5200 1650 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Horizontal" H 5300 1750 50  0001 C CNN
F 3 "~" H 5300 1750 50  0001 C CNN
	1    5300 1750
	1    0    0    1   
$EndComp
Text Notes 4850 1500 0    79   ~ 0
To theremin antenna
Text Notes 2850 1300 0    79   ~ 0
Theremin oscillator\ndigital output square 3.3V 500..1500KHz\nPower input: +4.5V 50mA\n
Text Notes 2800 3300 0    79   ~ 0
L: Air core coil, 1.5-3 mH\n0.1mm/0.125mm copper wire, \n32mm frame diameter, \n40..70mm winding length
$Comp
L Connector:Conn_01x03_Male J6
U 1 1 5E5208E1
P 9800 4600
F 0 "J6" H 9773 4530 50  0000 R CNN
F 1 "OSC" H 9773 4621 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Horizontal" H 9800 4600 50  0001 C CNN
F 3 "~" H 9800 4600 50  0001 C CNN
	1    9800 4600
	-1   0    0    1   
$EndComp
Wire Wire Line
	9600 4700 9000 4700
Text Label 9250 4700 0    50   ~ 0
GND
Text Label 9250 4500 0    50   ~ 0
4.5V
Text Label 9250 4600 0    50   ~ 0
OUT
$Comp
L power:GND #PWR015
U 1 1 5F7D2E8E
P 9000 4800
F 0 "#PWR015" H 9000 4550 50  0001 C CNN
F 1 "GND" H 9005 4627 50  0000 C CNN
F 2 "" H 9000 4800 50  0001 C CNN
F 3 "" H 9000 4800 50  0001 C CNN
	1    9000 4800
	1    0    0    -1  
$EndComp
Wire Wire Line
	9000 4700 9000 4800
Wire Wire Line
	5500 1750 5700 1750
Wire Wire Line
	5500 1650 5700 1650
Wire Wire Line
	5700 1650 5700 1750
Text Notes 9300 4250 0    50   ~ 0
To MCU or FPGA
$Comp
L Device:C C1
U 1 1 5F95F4DD
P 6300 1650
F 0 "C1" H 6415 1696 50  0000 L CNN
F 1 "1pF" H 6415 1605 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.4mm_W2.1mm_P2.50mm" H 6338 1500 50  0001 C CNN
F 3 "~" H 6300 1650 50  0001 C CNN
	1    6300 1650
	0    1    1    0   
$EndComp
$Comp
L Connector:TestPoint TP1
U 1 1 5F95FFE3
P 7300 1550
F 0 "TP1" H 7358 1668 50  0000 L CNN
F 1 "Antenna Voltage Swing" H 7358 1577 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x01_P2.54mm_Vertical" H 7500 1550 50  0001 C CNN
F 3 "~" H 7500 1550 50  0001 C CNN
	1    7300 1550
	1    0    0    -1  
$EndComp
Text Notes 7050 1350 0    50   ~ 0
Test point for checking of\nantenna voltage swing.\nDivider 1:940
$Comp
L Transistor_BJT:BC549 Q2
U 1 1 5FDA1422
P 5350 3850
F 0 "Q2" H 5541 3896 50  0000 L CNN
F 1 "BC549" H 5541 3805 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline_Wide" H 5550 3775 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC550-D.pdf" H 5350 3850 50  0001 L CNN
	1    5350 3850
	1    0    0    -1  
$EndComp
$Comp
L Transistor_BJT:BC549 Q4
U 1 1 5FDA1AEA
P 6350 3850
F 0 "Q4" H 6541 3896 50  0000 L CNN
F 1 "BC549" H 6541 3805 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline_Wide" H 6550 3775 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC550-D.pdf" H 6350 3850 50  0001 L CNN
	1    6350 3850
	-1   0    0    -1  
$EndComp
$Comp
L Transistor_BJT:BC549 Q3
U 1 1 5FDA29CC
P 5350 4600
F 0 "Q3" H 5541 4646 50  0000 L CNN
F 1 "BC549" H 5541 4555 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline_Wide" H 5550 4525 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC550-D.pdf" H 5350 4600 50  0001 L CNN
	1    5350 4600
	1    0    0    -1  
$EndComp
$Comp
L Transistor_BJT:BC549 Q1
U 1 1 5FDA34C1
P 4750 4600
F 0 "Q1" H 4941 4646 50  0000 L CNN
F 1 "BC549" H 4941 4555 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline_Wide" H 4950 4525 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC550-D.pdf" H 4750 4600 50  0001 L CNN
	1    4750 4600
	-1   0    0    -1  
$EndComp
Wire Wire Line
	4950 4600 5050 4600
Wire Wire Line
	5050 4600 5050 4350
Wire Wire Line
	5050 4350 4650 4350
Wire Wire Line
	4650 4350 4650 4400
Connection ~ 5050 4600
Wire Wire Line
	5050 4600 5150 4600
Wire Wire Line
	5450 4050 5450 4150
Wire Wire Line
	6250 4050 6250 4150
Wire Wire Line
	6250 4150 5450 4150
Connection ~ 5450 4150
Wire Wire Line
	5450 4150 5450 4400
$Comp
L power:GND #PWR05
U 1 1 5FDA82AF
P 4650 4900
F 0 "#PWR05" H 4650 4650 50  0001 C CNN
F 1 "GND" H 4655 4727 50  0000 C CNN
F 2 "" H 4650 4900 50  0001 C CNN
F 3 "" H 4650 4900 50  0001 C CNN
	1    4650 4900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR07
U 1 1 5FDA8AE7
P 5450 4900
F 0 "#PWR07" H 5450 4650 50  0001 C CNN
F 1 "GND" H 5455 4727 50  0000 C CNN
F 2 "" H 5450 4900 50  0001 C CNN
F 3 "" H 5450 4900 50  0001 C CNN
	1    5450 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	4650 4800 4650 4900
Wire Wire Line
	5450 4800 5450 4900
$Comp
L Device:R R1
U 1 1 5FDA9758
P 4650 4150
F 0 "R1" H 4720 4196 50  0000 L CNN
F 1 "4.7K" H 4720 4105 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 4580 4150 50  0001 C CNN
F 3 "~" H 4650 4150 50  0001 C CNN
	1    4650 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4650 4300 4650 4350
Connection ~ 4650 4350
$Comp
L power:VCC #PWR04
U 1 1 5FDB4966
P 4650 3900
F 0 "#PWR04" H 4650 3750 50  0001 C CNN
F 1 "VCC" H 4665 4073 50  0000 C CNN
F 2 "" H 4650 3900 50  0001 C CNN
F 3 "" H 4650 3900 50  0001 C CNN
	1    4650 3900
	1    0    0    -1  
$EndComp
$Comp
L Device:R R2
U 1 1 5FDB4B72
P 5450 3300
F 0 "R2" H 5520 3346 50  0000 L CNN
F 1 "4.7K" H 5520 3255 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 5380 3300 50  0001 C CNN
F 3 "~" H 5450 3300 50  0001 C CNN
	1    5450 3300
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR06
U 1 1 5FDB5375
P 5450 2900
F 0 "#PWR06" H 5450 2750 50  0001 C CNN
F 1 "VCC" H 5465 3073 50  0000 C CNN
F 2 "" H 5450 2900 50  0001 C CNN
F 3 "" H 5450 2900 50  0001 C CNN
	1    5450 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 2900 5450 2950
$Comp
L power:VCC #PWR09
U 1 1 5FDB7532
P 6250 2900
F 0 "#PWR09" H 6250 2750 50  0001 C CNN
F 1 "VCC" H 6265 3073 50  0000 C CNN
F 2 "" H 6250 2900 50  0001 C CNN
F 3 "" H 6250 2900 50  0001 C CNN
	1    6250 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 3450 5450 3550
Wire Wire Line
	6250 2900 6250 2950
$Comp
L Transistor_BJT:BC549 Q7
U 1 1 5FDB795D
P 7450 5000
F 0 "Q7" H 7641 5046 50  0000 L CNN
F 1 "BC549" H 7641 4955 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline_Wide" H 7650 4925 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC550-D.pdf" H 7450 5000 50  0001 L CNN
	1    7450 5000
	1    0    0    -1  
$EndComp
$Comp
L Transistor_BJT:BC549 Q5
U 1 1 5FDB7B65
P 6850 5000
F 0 "Q5" H 7041 5046 50  0000 L CNN
F 1 "BC549" H 7041 4955 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline_Wide" H 7050 4925 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC550-D.pdf" H 6850 5000 50  0001 L CNN
	1    6850 5000
	-1   0    0    -1  
$EndComp
Wire Wire Line
	7050 5000 7150 5000
Wire Wire Line
	7150 5000 7150 4750
Wire Wire Line
	7150 4750 6750 4750
Wire Wire Line
	6750 4750 6750 4800
Connection ~ 7150 5000
Wire Wire Line
	7150 5000 7250 5000
$Comp
L power:GND #PWR011
U 1 1 5FDB7B76
P 6750 5300
F 0 "#PWR011" H 6750 5050 50  0001 C CNN
F 1 "GND" H 6755 5127 50  0000 C CNN
F 2 "" H 6750 5300 50  0001 C CNN
F 3 "" H 6750 5300 50  0001 C CNN
	1    6750 5300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR013
U 1 1 5FDB7B80
P 7550 5300
F 0 "#PWR013" H 7550 5050 50  0001 C CNN
F 1 "GND" H 7555 5127 50  0000 C CNN
F 2 "" H 7550 5300 50  0001 C CNN
F 3 "" H 7550 5300 50  0001 C CNN
	1    7550 5300
	1    0    0    -1  
$EndComp
Wire Wire Line
	6750 5200 6750 5300
Wire Wire Line
	7550 5200 7550 5300
$Comp
L Device:R R4
U 1 1 5FDB7B8C
P 6750 4550
F 0 "R4" H 6820 4596 50  0000 L CNN
F 1 "680" H 6820 4505 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 6680 4550 50  0001 C CNN
F 3 "~" H 6750 4550 50  0001 C CNN
	1    6750 4550
	1    0    0    -1  
$EndComp
Wire Wire Line
	6750 4700 6750 4750
Connection ~ 6750 4750
$Comp
L power:VCC #PWR010
U 1 1 5FDC0C29
P 6750 4300
F 0 "#PWR010" H 6750 4150 50  0001 C CNN
F 1 "VCC" H 6765 4473 50  0000 C CNN
F 2 "" H 6750 4300 50  0001 C CNN
F 3 "" H 6750 4300 50  0001 C CNN
	1    6750 4300
	1    0    0    -1  
$EndComp
Wire Wire Line
	6750 4300 6750 4350
$Comp
L Transistor_BJT:BC549 Q6
U 1 1 5FDC1BAA
P 7450 3550
F 0 "Q6" H 7641 3596 50  0000 L CNN
F 1 "BC549" H 7641 3505 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline_Wide" H 7650 3475 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC550-D.pdf" H 7450 3550 50  0001 L CNN
	1    7450 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	7250 3550 5450 3550
Connection ~ 5450 3550
Wire Wire Line
	5450 3550 5450 3650
Wire Wire Line
	7550 3750 7550 3850
$Comp
L power:VCC #PWR012
U 1 1 5FDC438A
P 7550 2800
F 0 "#PWR012" H 7550 2650 50  0001 C CNN
F 1 "VCC" H 7565 2973 50  0000 C CNN
F 2 "" H 7550 2800 50  0001 C CNN
F 3 "" H 7550 2800 50  0001 C CNN
	1    7550 2800
	1    0    0    -1  
$EndComp
$Comp
L Transistor_BJT:BC549 Q8
U 1 1 5FDC5495
P 8050 4350
F 0 "Q8" H 8241 4396 50  0000 L CNN
F 1 "BC549" H 8241 4305 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline_Wide" H 8250 4275 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC550-D.pdf" H 8050 4350 50  0001 L CNN
	1    8050 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	7850 4350 7550 4350
Connection ~ 7550 4350
Wire Wire Line
	7550 4350 7550 4800
$Comp
L power:VCC #PWR016
U 1 1 5FDCA083
P 8150 2800
F 0 "#PWR016" H 8150 2650 50  0001 C CNN
F 1 "VCC" H 8165 2973 50  0000 C CNN
F 2 "" H 8150 2800 50  0001 C CNN
F 3 "" H 8150 2800 50  0001 C CNN
	1    8150 2800
	1    0    0    -1  
$EndComp
Wire Wire Line
	8150 2800 8150 2850
Wire Wire Line
	6550 3850 6650 3850
Connection ~ 7550 3850
Wire Wire Line
	7550 3850 7550 4350
$Comp
L Device:R R3
U 1 1 5FDCC472
P 5800 2450
F 0 "R3" V 5593 2450 50  0000 C CNN
F 1 "47" V 5684 2450 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 5730 2450 50  0001 C CNN
F 3 "~" H 5800 2450 50  0001 C CNN
	1    5800 2450
	0    1    1    0   
$EndComp
Wire Wire Line
	5150 3850 5000 3850
Wire Wire Line
	5000 3850 5000 3650
Wire Wire Line
	5650 2450 5000 2450
Wire Wire Line
	5950 2450 6650 2450
Wire Wire Line
	6650 2450 6650 3850
Connection ~ 6650 3850
Wire Wire Line
	6650 3850 7550 3850
$Comp
L power:VCC #PWR020
U 1 1 5FDD017B
P 9000 3500
F 0 "#PWR020" H 9000 3350 50  0001 C CNN
F 1 "VCC" H 9015 3673 50  0000 C CNN
F 2 "" H 9000 3500 50  0001 C CNN
F 3 "" H 9000 3500 50  0001 C CNN
	1    9000 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	9000 3500 9000 3600
Wire Wire Line
	9000 4500 9600 4500
Wire Wire Line
	8650 3700 8650 3600
Wire Wire Line
	8650 3600 9000 3600
Connection ~ 9000 3600
Wire Wire Line
	9000 3600 9000 4500
$Comp
L power:GND #PWR019
U 1 1 5FDD4946
P 8650 4100
F 0 "#PWR019" H 8650 3850 50  0001 C CNN
F 1 "GND" H 8655 3927 50  0000 C CNN
F 2 "" H 8650 4100 50  0001 C CNN
F 3 "" H 8650 4100 50  0001 C CNN
	1    8650 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	8650 4000 8650 4100
$Comp
L Device:C C11
U 1 1 5FDD651E
P 8350 3100
F 0 "C11" H 8465 3146 50  0000 L CNN
F 1 "0.1uF" H 8465 3055 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.4mm_W2.1mm_P2.50mm" H 8388 2950 50  0001 C CNN
F 3 "~" H 8350 3100 50  0001 C CNN
	1    8350 3100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR018
U 1 1 5FDDAC7C
P 8350 3250
F 0 "#PWR018" H 8350 3000 50  0001 C CNN
F 1 "GND" H 8355 3077 50  0000 C CNN
F 2 "" H 8350 3250 50  0001 C CNN
F 3 "" H 8350 3250 50  0001 C CNN
	1    8350 3250
	1    0    0    -1  
$EndComp
Wire Wire Line
	8350 2950 8350 2850
Wire Wire Line
	8350 2850 8150 2850
Connection ~ 8150 2850
Wire Wire Line
	8150 2850 8150 4150
$Comp
L Device:C C9
U 1 1 5FDDE4F4
P 5850 3150
F 0 "C9" H 5965 3196 50  0000 L CNN
F 1 "0.1uF" H 5965 3105 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.4mm_W2.1mm_P2.50mm" H 5888 3000 50  0001 C CNN
F 3 "~" H 5850 3150 50  0001 C CNN
	1    5850 3150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR08
U 1 1 5FDDEBFE
P 5850 3300
F 0 "#PWR08" H 5850 3050 50  0001 C CNN
F 1 "GND" H 5855 3127 50  0000 C CNN
F 2 "" H 5850 3300 50  0001 C CNN
F 3 "" H 5850 3300 50  0001 C CNN
	1    5850 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	5850 3000 5850 2950
Wire Wire Line
	5850 2950 5450 2950
Connection ~ 5450 2950
Wire Wire Line
	5450 2950 5450 3150
Wire Wire Line
	5850 2950 6250 2950
Connection ~ 5850 2950
Connection ~ 6250 2950
Wire Wire Line
	6250 2950 6250 3650
$Comp
L Device:CP C12
U 1 1 5FDE7183
P 8650 3850
F 0 "C12" H 8768 3896 50  0000 L CNN
F 1 "22uF" H 8768 3805 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D4.7mm_W2.5mm_P5.00mm" H 8688 3700 50  0001 C CNN
F 3 "~" H 8650 3850 50  0001 C CNN
	1    8650 3850
	1    0    0    -1  
$EndComp
$Comp
L Device:C C7
U 1 1 5FDF044D
P 7300 1850
F 0 "C7" H 7415 1896 50  0000 L CNN
F 1 "470pF" H 7415 1805 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.4mm_W2.1mm_P2.50mm" H 7338 1700 50  0001 C CNN
F 3 "~" H 7300 1850 50  0001 C CNN
	1    7300 1850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR01
U 1 1 5FDF0993
P 7300 2000
F 0 "#PWR01" H 7300 1750 50  0001 C CNN
F 1 "GND" H 7305 1827 50  0000 C CNN
F 2 "" H 7300 2000 50  0001 C CNN
F 3 "" H 7300 2000 50  0001 C CNN
	1    7300 2000
	1    0    0    -1  
$EndComp
Wire Wire Line
	3500 3650 5000 3650
Connection ~ 5000 3650
Wire Wire Line
	5000 3650 5000 2450
Wire Wire Line
	5700 1650 6150 1650
Connection ~ 5700 1650
$Comp
L Device:C C13
U 1 1 5FE57956
P 6150 4600
F 0 "C13" H 6265 4646 50  0000 L CNN
F 1 "0.1uF" H 6265 4555 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.4mm_W2.1mm_P2.50mm" H 6188 4450 50  0001 C CNN
F 3 "~" H 6150 4600 50  0001 C CNN
	1    6150 4600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR021
U 1 1 5FE57D46
P 6150 4750
F 0 "#PWR021" H 6150 4500 50  0001 C CNN
F 1 "GND" H 6155 4577 50  0000 C CNN
F 2 "" H 6150 4750 50  0001 C CNN
F 3 "" H 6150 4750 50  0001 C CNN
	1    6150 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	6150 4350 6750 4350
Wire Wire Line
	6150 4350 6150 4450
Connection ~ 6750 4350
Wire Wire Line
	6750 4350 6750 4400
$Comp
L Device:C C2
U 1 1 5FEC8B4B
P 6800 1650
F 0 "C2" H 6915 1696 50  0000 L CNN
F 1 "1pF" H 6915 1605 50  0000 L CNN
F 2 "Capacitor_THT:C_Disc_D3.4mm_W2.1mm_P2.50mm" H 6838 1500 50  0001 C CNN
F 3 "~" H 6800 1650 50  0001 C CNN
	1    6800 1650
	0    1    1    0   
$EndComp
Wire Wire Line
	7300 1550 7300 1650
Wire Wire Line
	6950 1650 7300 1650
Connection ~ 7300 1650
Wire Wire Line
	7300 1650 7300 1700
Wire Wire Line
	6650 1650 6450 1650
Wire Wire Line
	4650 3900 4650 4000
Wire Wire Line
	7550 2800 7550 3350
Wire Wire Line
	8150 4550 8150 4600
$Comp
L Device:R R5
U 1 1 5FEF7FE1
P 8600 4600
F 0 "R5" V 8393 4600 50  0000 C CNN
F 1 "100" V 8484 4600 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0204_L3.6mm_D1.6mm_P2.54mm_Vertical" V 8530 4600 50  0001 C CNN
F 3 "~" H 8600 4600 50  0001 C CNN
	1    8600 4600
	0    1    1    0   
$EndComp
Wire Wire Line
	8750 4600 9600 4600
Wire Wire Line
	8450 4600 8150 4600
Connection ~ 8150 4600
$Comp
L Transistor_BJT:BC549 Q9
U 1 1 5FEFD61F
P 8050 5650
F 0 "Q9" H 8241 5696 50  0000 L CNN
F 1 "BC549" H 8241 5605 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline_Wide" H 8250 5575 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC550-D.pdf" H 8050 5650 50  0001 L CNN
	1    8050 5650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR02
U 1 1 5FEFE317
P 8150 5950
F 0 "#PWR02" H 8150 5700 50  0001 C CNN
F 1 "GND" H 8155 5777 50  0000 C CNN
F 2 "" H 8150 5950 50  0001 C CNN
F 3 "" H 8150 5950 50  0001 C CNN
	1    8150 5950
	1    0    0    -1  
$EndComp
Wire Wire Line
	8150 5850 8150 5950
Wire Wire Line
	7850 5650 7150 5650
Wire Wire Line
	7150 5650 7150 5000
Wire Wire Line
	8150 4600 8150 5450
$EndSCHEMATC
