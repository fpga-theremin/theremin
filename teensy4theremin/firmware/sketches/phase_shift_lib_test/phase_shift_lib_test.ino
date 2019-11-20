#include "src/PhaseShift/PhaseShift.h"
//#include <PhaseShift.h>

//Pins 2,3:
//  {1, M(4, 2), 1, 1},  // FlexPWM4_2_A   2  // EMC_04
//  {1, M(4, 2), 2, 1},  // FlexPWM4_2_B   3  // EMC_05

#define PITCH_SENSOR_FREF_PIN        2
#define PITCH_SENSOR_PHASE_SHIFT_PIN 3
#define PITCH_SENSOR_FREQUENCY 690000.0f
#define PITCH_SENSOR_AVERAGING 1024
PhaseShift pitchSensor(PITCH_SENSOR_FREF_PIN, PITCH_SENSOR_PHASE_SHIFT_PIN);

void setup() {
  //Serial.begin(9600);
  Serial.begin(115200);
  Serial.println("Phase shift sensor test. Use pin 2 as reference frequency, connect shifted signal to pin 3");
  Serial.println("Initializing of phase shift detector");

//  pinMode(2, OUTPUT);
//  pinMode(3, INPUT);
//  Serial.println("Testing digitalWrite/digitalRead on pins 2,3");
//  digitalWrite(2, 0);
//  Serial.print("Must be 0: ");
//  Serial.println(digitalRead(3));
//  digitalWrite(2, 1);
//  Serial.print("Must be 1: ");
//  Serial.println(digitalRead(3));
//
//  analogWriteFrequency(2, 650000.0f);
//  analogWrite(2, 128);
//  Serial.println("reading pwm");
//  for (int i = 0; i < 20; i++) {
//     delay(100);
//     Serial.print(digitalRead(3));
//  }
//  Serial.println("done");
//  
//  Serial.println("Init sensor");
  uint16_t pitchPeriod = PhaseShift::frequencyToPeriod(PITCH_SENSOR_FREQUENCY);
  pitchSensor.begin(pitchPeriod, 50, PITCH_SENSOR_AVERAGING);
  //analogWriteFrequency(2, PITCH_SENSOR_FREQUENCY);
  //analogWrite(2, 128);
  Serial.print("Pitch sensor reference freq period, F_BUS cycles: ");
  Serial.println(pitchPeriod);
}

void loop() {
  delay(1000);
  Serial.print("Status: ");
  Serial.print(pitchSensor.readStatusReg());
  Serial.print(" digitalRead: ");
  Serial.println(digitalRead(3));
  for (int i = 0; i < 70; i++) {
     delay(30);
     Serial.print(digitalRead(3));
  }
  Serial.println("...");
}
