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
L MCU_Module:TeensyLCD U1
U 1 1 5F735402
P 5650 2500
F 0 "U1" H 5878 2546 50  0000 L CNN
F 1 "TeensyLCD" H 5878 2455 50  0000 L CNN
F 2 "Module:TeensyLCD_ILI9341" H 5650 3200 50  0001 C CNN
F 3 "" H 5650 3200 50  0001 C CNN
	1    5650 2500
	1    0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_02x15_Odd_Even J1
U 1 1 5F736029
P 2400 2700
F 0 "J1" H 2450 3717 50  0000 C CNN
F 1 "Conn_02x15_Odd_Even" H 2450 3626 50  0000 C CNN
F 2 "Connector_IDC:IDC-Header_2x15_P2.54mm_Vertical" H 2400 2700 50  0001 C CNN
F 3 "~" H 2400 2700 50  0001 C CNN
	1    2400 2700
	1    0    0    -1  
$EndComp
$Comp
L Device:Rotary_Encoder_Switch SW1
U 1 1 5F76AFD7
P 4650 4800
F 0 "SW1" H 4650 5167 50  0000 C CNN
F 1 "Rotary_Encoder_Switch" H 4650 5076 50  0000 C CNN
F 2 "Rotary_Encoder:RotaryEncoder_Alps_EC11E-Switch_Vertical_H20mm" H 4500 4960 50  0001 C CNN
F 3 "~" H 4650 5060 50  0001 C CNN
	1    4650 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:Rotary_Encoder_Switch SW2
U 1 1 5F76C28A
P 5650 4800
F 0 "SW2" H 5650 5167 50  0000 C CNN
F 1 "Rotary_Encoder_Switch" H 5650 5076 50  0000 C CNN
F 2 "Rotary_Encoder:RotaryEncoder_Alps_EC11E-Switch_Vertical_H20mm" H 5500 4960 50  0001 C CNN
F 3 "~" H 5650 5060 50  0001 C CNN
	1    5650 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:Rotary_Encoder_Switch SW3
U 1 1 5F76D2CA
P 6750 4800
F 0 "SW3" H 6750 5167 50  0000 C CNN
F 1 "Rotary_Encoder_Switch" H 6750 5076 50  0000 C CNN
F 2 "Rotary_Encoder:RotaryEncoder_Alps_EC11E-Switch_Vertical_H20mm" H 6600 4960 50  0001 C CNN
F 3 "~" H 6750 5060 50  0001 C CNN
	1    6750 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:Rotary_Encoder_Switch SW4
U 1 1 5F76E86C
P 7850 4800
F 0 "SW4" H 7850 5167 50  0000 C CNN
F 1 "Rotary_Encoder_Switch" H 7850 5076 50  0000 C CNN
F 2 "Rotary_Encoder:RotaryEncoder_Alps_EC11E-Switch_Vertical_H20mm" H 7700 4960 50  0001 C CNN
F 3 "~" H 7850 5060 50  0001 C CNN
	1    7850 4800
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW5
U 1 1 5F76FAD6
P 4600 5500
F 0 "SW5" H 4600 5785 50  0000 C CNN
F 1 "SW_Push" H 4600 5694 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm_H9.5mm" H 4600 5700 50  0001 C CNN
F 3 "~" H 4600 5700 50  0001 C CNN
	1    4600 5500
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT RV1
U 1 1 5F778498
P 1800 4600
F 0 "RV1" H 1731 4646 50  0000 R CNN
F 1 "R_POT" H 1731 4555 50  0000 R CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTV09A-1_Single_Vertical" H 1800 4600 50  0001 C CNN
F 3 "~" H 1800 4600 50  0001 C CNN
	1    1800 4600
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT RV2
U 1 1 5F7793AD
P 1800 5150
F 0 "RV2" H 1731 5196 50  0000 R CNN
F 1 "R_POT" H 1731 5105 50  0000 R CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTV09A-1_Single_Vertical" H 1800 5150 50  0001 C CNN
F 3 "~" H 1800 5150 50  0001 C CNN
	1    1800 5150
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT RV3
U 1 1 5F779B63
P 1800 5700
F 0 "RV3" H 1731 5746 50  0000 R CNN
F 1 "R_POT" H 1731 5655 50  0000 R CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTV09A-1_Single_Vertical" H 1800 5700 50  0001 C CNN
F 3 "~" H 1800 5700 50  0001 C CNN
	1    1800 5700
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT RV4
U 1 1 5F77B5B6
P 1800 6350
F 0 "RV4" H 1731 6396 50  0000 R CNN
F 1 "R_POT" H 1731 6305 50  0000 R CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTV09A-1_Single_Vertical" H 1800 6350 50  0001 C CNN
F 3 "~" H 1800 6350 50  0001 C CNN
	1    1800 6350
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT RV5
U 1 1 5F77F007
P 1800 6900
F 0 "RV5" H 1731 6946 50  0000 R CNN
F 1 "R_POT" H 1731 6855 50  0000 R CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTV09A-1_Single_Vertical" H 1800 6900 50  0001 C CNN
F 3 "~" H 1800 6900 50  0001 C CNN
	1    1800 6900
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW6
U 1 1 5F782103
P 4600 6100
F 0 "SW6" H 4600 6385 50  0000 C CNN
F 1 "SW_Push" H 4600 6294 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm_H9.5mm" H 4600 6300 50  0001 C CNN
F 3 "~" H 4600 6300 50  0001 C CNN
	1    4600 6100
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW7
U 1 1 5F782516
P 4600 6650
F 0 "SW7" H 4600 6935 50  0000 C CNN
F 1 "SW_Push" H 4600 6844 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm_H9.5mm" H 4600 6850 50  0001 C CNN
F 3 "~" H 4600 6850 50  0001 C CNN
	1    4600 6650
	1    0    0    -1  
$EndComp
$EndSCHEMATC
