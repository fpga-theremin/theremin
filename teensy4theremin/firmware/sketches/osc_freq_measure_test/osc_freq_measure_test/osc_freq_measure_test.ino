#include <FreqMeasureMulti.h>

//#include <core_cm7.h>

#include "src/FreqMeasureDMA/FreqMeasureDMA.h"

//FreqMeasureDMA freqdma;
#define MAX_MOVING_AVERAGE_WINDOW_SIZE_BITS 12
#define MAX_IIR_FILTER_STAGES 8
#define MOVING_AVERAGE_WINDOW_SIZE_BITS 12
#define IIR_FILTER_STAGES 4
#define IIR_FILTER_SHIFT  10
#define SCALING_SHIFT 9
FreqMeasureDMAWithFilter<MAX_MOVING_AVERAGE_WINDOW_SIZE_BITS, MAX_IIR_FILTER_STAGES> freqdma;

//FreqMeasureMulti freq1;

//#define MEASURE_PIN 5
//#define MEASURE_TYPE FREQMEASUREMULTI_RAISING

//#define MEASURE_PIN 0
//#define MEASURE_TYPE FREQMEASUREMULTI_ALTERNATE

//#define MEASURE_PIN 2
#define MEASURE_PIN 33
//#define MEASURE_PIN 36
//#define MEASURE_TYPE FREQMEASUREMULTI_ALTERNATE //FREQMEASUREMULTI_INTERLEAVE
#define MEASURE_TYPE FREQMEASUREMULTI_RAISING

#define PWM_OUT_PIN 10   // not a flexPWM pin 
  
#define DMA_BUF_SIZE 16384
DMAMEM volatile uint16_t dma_buf[DMA_BUF_SIZE*2] __attribute__((aligned(DMA_BUF_SIZE)));

#define TEST_FREQ_MAX  750000.0f
#define TEST_FREQ_MIN   650000.0f
#define TEST_FREQ_STEP 0.001f

static float testFreq = (TEST_FREQ_MAX + TEST_FREQ_MIN) / 2;
static float testFreqMul = 1.0 + TEST_FREQ_STEP; //0.9999;
static float testFreqDuty = 470;

static void updateTestFreq() {
    testFreq = testFreq * testFreqMul;
    if (testFreqMul < 1.0 && testFreq < TEST_FREQ_MIN) {
        testFreqMul = 1.0 + TEST_FREQ_STEP;
    } else if (testFreqMul > 1.0 && testFreq > TEST_FREQ_MAX) {
        testFreqMul = 1.0 - TEST_FREQ_STEP;
    }
  //__disable_irq();
    analogWriteFrequency(PWM_OUT_PIN, testFreq);
    analogWrite(PWM_OUT_PIN, testFreqDuty);
  //__enable_irq();
}

#define COLLECT_BUF_SIZE 15000
uint32_t collect_buf[COLLECT_BUF_SIZE];
//uint16_t collect_buf_samples[COLLECT_BUF_SIZE];
//float collect_buf_freq[COLLECT_BUF_SIZE];

#define COLLECT_STEP_MICROS 1000

void testCollect() {

  Serial.println("Collecting measured data");
  uint32_t v;
  for (int i = 0; i < 100; i++) {
      delay(1);
      v = freqdma.read();
      updateTestFreq();
  }  
  uint64_t sumMicros = 0;
  for (int i = 0; i < COLLECT_BUF_SIZE; i++) {
      uint32_t start = micros();
      //delay(1);
      //collect_buf_samples[i] = freqdma.dmaAvailable();
      v = freqdma.read();
      uint16_t avail = freqdma.dmaAvailable();
      if (avail > 1) {
        v = freqdma.read();
        //collect_buf_samples[i]++;
      }
      avail = freqdma.dmaAvailable();
      if (avail > 1) {
        v = freqdma.read();
        //collect_buf_samples[i]++;
      }
      uint32_t end = micros();
      sumMicros += end - start;
      //updateTestFreq();
      while (end - start < COLLECT_STEP_MICROS)
        end = micros();
      collect_buf[i] = v;
      //collect_buf_freq[i] = testFreq;
  }
  for (int i = 0; i < COLLECT_BUF_SIZE; i++) {
    //float freq = freqdma.periodToFrequency(collect_buf[i]);
    //Serial.printf("%d\t%08x\t%d\t%.3f\t%.3f\n", i, collect_buf[i], collect_buf_samples[i], collect_buf_freq[i], freq);
    Serial.printf("%d\t%d\n", i, collect_buf[i]);
  }

  uint32_t avgMicros = sumMicros / COLLECT_BUF_SIZE;
  Serial.printf("avg %d micros to process data for one %dus interval\n", avgMicros, COLLECT_STEP_MICROS);
  
    
  delay(15000);
}


void iirFilterTest() {
    Serial.println("IIR filter test:");
    SimpleShiftIIRFilter<8> _iirFilter;
    _iirFilter.begin(6, 2, 0);
    uint32_t inputValue = 0x010000;
    for (int i = 0; i < 200; i++) {
       if (i == 1)
          inputValue = 0x80000000;
       if (i == 100)
          inputValue = 0x10000000;
      Serial.printf("%d\t%08x\n", i, _iirFilter.filter(inputValue));
    }
    delay(20000);
}



void setup() {
  Serial.begin(57600);
  while (!Serial) ; // wait for Arduino Serial Monitor

  Serial.println("Theremin sensor test");

  //iirFilterTest();

  analogWriteResolution(10);
  updateTestFreq();

  // put your setup code here, to run once:
  delay(10);
  //freq1.begin(MEASURE_PIN, MEASURE_TYPE);
  //delay(10);
//  for (int i = 0; i < DMA_BUF_SIZE * 2; i++)
//    dma_buf[i] = i + 1;
  Serial.printf("Buffer ptr=%x\n", dma_buf);
  freqdma.begin(MEASURE_PIN, dma_buf, DMA_BUF_SIZE, MOVING_AVERAGE_WINDOW_SIZE_BITS, SCALING_SHIFT, IIR_FILTER_STAGES, IIR_FILTER_SHIFT);


  testCollect();
}



void loop() {


  

  uint64_t sum = 0;
  uint32_t minv = 0;
  uint32_t maxv = 0;
  int avgcount = 200;
  uint32_t dmaAvailSum = 0;
  uint32_t v = 0;
  for (int i = 0; i < avgcount; i++) {
    delay(1);
    dmaAvailSum += freqdma.dmaAvailable();
    v = freqdma.read();
    if (minv == 0 || minv > v)
        minv = v;
    if (maxv == 0 || maxv < v)
        maxv = v;
    sum += v;


    updateTestFreq();
  
  }
  uint32_t avgv = (uint32_t)(sum / avgcount);
  float freq = freqdma.periodToFrequency(avgv);
  uint32_t avgavail = (uint32_t)(dmaAvailSum / avgcount); 
  Serial.printf("%08d\t%08d\t%08d\t%08d\t%d\tfreq:%.3f\n",  //wr:%04x\terr:%d\tcompl:%d\t
      minv, avgv, maxv, v, avgavail, freq); //freqdma.dmaWritePos(), freqdma.dmaError(), freqdma.dmaComplete(), 

  
  //dumpBuf(12); //DMA_BUF_SIZE
 
  //collect(10); //SAMPLE_COUNT);
  //Serial.print("captured value = ");
  //Serial.println(freqdma.peek());
  //delay(7000);

  
}
