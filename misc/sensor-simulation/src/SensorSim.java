import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.math.BigInteger;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

public class SensorSim {

	// logging support
	private static BufferedWriter logWriter;
	
	
	public static final int TIMER_COUNTER_BITS = 30; 
	public static final int TIMER_COUNTER_MASK = (1<<TIMER_COUNTER_BITS) - 1; 
	public static final double XTAL_NOISE_LEVEL = 0; //0.000001;

	// number of captured edges to collect
	public static final int SIMULATION_SAMPLES_TO_COLLECT = 200000;
	// number of random points to measure period in collected data
	public static final int SIMULATION_RANDOM_TEST_POSITION_COUNT = 20;

	//public static final double TIMER_FREQUENCY = 1_200_000_000.0;
	public static final double TIMER_FREQUENCY = 240_000_000.0;
	//public static final double TIMER_FREQUENCY = 120_000_000.0;
	//public static final double TIMER_FREQUENCY = 150_000_000.0;
	
	public static final double SENSOR_NOISE_LEVEL = 0; //0.0001; //0.00001; //0.001; //0.00001; //0.001;
	public static final double SENSOR_DUTY_CYCLE = 0.7;
	public static final int SENSOR_DITHER_INTERVAL = 1; //512; //256; //128; //512;
	public static final double SENSOR_DITHER_AMOUNT = 0; //0.05; //0.01; //0.00001; //0.0001; //5000.1 / 2048.0 / 2048.0;

	public static final double SENSOR_ASYNC_DITHER_FREQUENCY = 44100.0 / 32; //0.01; //0.00001; //0.0001; //5000.1 / 2048.0 / 2048.0;
	public static final double SENSOR_ASYNC_DITHER_AMOUNT = 0; //0.001; //0.01; //0.00001; //0.0001; //5000.1 / 2048.0 / 2048.0;
	
//	public static final double OSCILLATOR_MIN_FREQUENCY = 878_000.0;
//	public static final double OSCILLATOR_MAX_FREQUENCY = 887_000.0;
	public static final double OSCILLATOR_MIN_FREQUENCY =   850_000.0;
	public static final double OSCILLATOR_MAX_FREQUENCY = 1_100_000.0;
	public static final int OSCILLATOR_FREQ_DIVIDER_SUBSTEPS = 8*9*5*7; //*11;
	public static final double OSCILLATOR_FREQ_SHIFT_FROM_RESONANCE_POINT = 0.05; // shift from TIMER_FREQUENCY/K as fraction of divider substep

	// number of oscilator signal periods to calculate stage 1 filter value (edge(0) - edge(0-FILTER_DISTANCE))
	// with distance 2048, first stage itself introduces 1ms latency (with 1MHz sensor frequency)
	//      distance 4096, first stage itself introduces 2ms latency (with 1MHz sensor frequency)
	//      distance 8192, first stage itself introduces 4ms latency (with 1MHz sensor frequency)
	public static final int FILTER_DISTANCE = 8192;
	public static final int FILTER_DISTANCE_OFFSET = 0; //7*2;

	public static final int[] FILTER_DISTANCE_DITHER_K = new int[] {0, 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5, -6, -7, -8, -7, -6, -5, -4, -3, -2, -1};

	public static final int FILTER_DISTANCE_AVGERAGING = 10; // for FirstStageType.DIFF_AVG

	// filter type for first stage filtering
	public static final FirstStageType FILTER_TYPE_STAGE1 = FirstStageType.DIFF; // FirstStageType.WEIGHTED_DIFF_4;
	// filter type for second stage filtering
	public static final FilterType FILTER_TYPE_STAGE2 = FilterType.IIR;
	
	// FIR filter parameter - width of window
	public static final int FILTER_WIDTH = 2048;
	
	// IIR filter parameters
	public static final double IIR_FILTER_K = 0.002; // 0.002
	public static final int IIR_FILTER_STAGES = 4; // 0.002

	public static final double LOG_2 = Math.log(2);
	
	// Range of oscillator frequency change due to hand movement. Default = 0.05 or 5%
	public static final double SENSOR_FREQUENCY_CHANGE_RATIO = 0.05;
	// Number of bits lost due to limited oscillator change range, for 5% range it's about 4.5 bits 
	public static final double SENSOR_FREQUENCY_CHANGE_RATIO_LOST_BITS = -log2(SENSOR_FREQUENCY_CHANGE_RATIO);
	
	public enum FirstStageType {
		DIFF,
		WEIGHTED_DIFF_4,
		DIFF_DITHERED,
		DIFF_AVG
	}

	public enum FilterType {
		FIR,
		IIR
	}
	
	
	private static final Random noisernd = new Random();
	
	public static double makeNoise(double base, double level, int normalizationCount) {
		if (level < 0.00000000000001)
			return 0.0;
		double sum = 0;
		for (int i = 0; i < normalizationCount; i++) {
			sum += noisernd.nextDouble() - 0.5;
		}
		sum = sum / normalizationCount;
		return sum * base * level;
	}
	
	public static class Oscillator {
		// false: getTime() returns raising edge, true: getTime() returns falling edge
		private boolean state;
		// time of next edge
		private double time;
		// oscillator frequency
		private double frequency;
		// full period
		private double period;
		// part of period from falling to raising (differs from period/2 if duty cycle != 0.5)
		private double halfPeriod;
		// cycle counter
		private int cycleCount;
		private int ditherInterval;
		private double ditherAmount;
		
		// noise as fraction of signal period
		private double noiseLevel;
		private double noise;
		private double dither;
		
		// async dither
		double asyncDitherFrequency;
		double asyncDitherAmount;
		
		public Oscillator(double freq) {
			this(freq, 0.5, 0, 1, 0, 44100, 0);
		}

		public Oscillator(double freq, double dutyCycle, double noiseLevel, int ditherInterval, double ditherAmount, double asyncDitherFrequency, double asyncDitherAmount) {
			this.noiseLevel = noiseLevel;
			this.noise = 0;
			this.ditherInterval = ditherInterval;
			this.ditherAmount = ditherAmount;
			this.dither = 0;
			this.asyncDitherAmount = asyncDitherAmount;
			this.asyncDitherFrequency = asyncDitherFrequency;
			frequency = freq;
			period = 1.0 / freq;
			halfPeriod = period - period * dutyCycle;
			time = halfPeriod;
			state = false;
		}

		// returns time of new event
		public double getTime() {
			return time + noise + dither;
		}
		
		public int getCycleCount() {
			return cycleCount;
		}
		
		private void updateDither() {
			dither = 0;
			if (asyncDitherAmount > 0.0000000001) {
				double asyncDitherPeriod = 1 / asyncDitherFrequency;
				int asyncDitherIndex = (int)(time / asyncDitherPeriod);
				double asyncDitherPhase = (time - asyncDitherPeriod * asyncDitherIndex) / asyncDitherPeriod;
				double triangle = 0;
				if (asyncDitherPhase < 0.25) {
   				    // 0..0.5
					triangle = asyncDitherPhase*2;
				} else if (asyncDitherPhase < 0.5) {
   				    // 0.5..0
					triangle = 0.5 - (asyncDitherPhase - 0.25)*2;
				} else if (asyncDitherPhase < 0.75) {
   				    // 0..-0.5
					triangle = -(asyncDitherPhase - 0.5)*2;
				} else {
   				    // 0..-0.5
					triangle = -0.5+(asyncDitherPhase - 0.75)*2;
				}
				dither = period * asyncDitherAmount * triangle;
				//log(String.format("dither=\t%.15f\ttriangle=\t%.5f", dither, triangle));
			} else if (ditherInterval > 1 && ditherAmount > 0) {
				int ditherIndex = cycleCount % ditherInterval;
				int ditherQuarterLength = (ditherInterval/4);
				int ditherQuarter = ditherIndex / ditherQuarterLength;
				int ditherQuarterPart = ditherIndex % ditherQuarterLength;
				double d = 0;
				switch (ditherQuarter) {
				default:
				case 0:
					d = ditherQuarterPart * 0.5 / ditherQuarterLength;
					break;
				case 1:
					d = 0.5 - ditherQuarterPart * 0.5 / ditherQuarterLength;
					break;
				case 2:
					d = - ditherQuarterPart * 0.5 / ditherQuarterLength;
					break;
				case 3:
					d = -0.5 + ditherQuarterPart * 0.5 / ditherQuarterLength;
					break;
				}
				//log("dither phase\t" + d);
				dither = period * ditherAmount * d;
				//log("dither =\t" + dither + "\tperiod=" + period);
			}
		}
		
		public double stepHalfCycle() {
			if (state) {
				// falling
				time += halfPeriod;
				noise = makeNoise(period, noiseLevel, 3);
				cycleCount = (cycleCount + 1) & TIMER_COUNTER_MASK;
				updateDither();
			} else {
				// raising
				time += (period - halfPeriod);
				noise = makeNoise(period, noiseLevel, 3);
			}
			state = !state;
			return time + noise + dither;
		}
		
		public double stepCycle() {
			stepHalfCycle();
			return stepHalfCycle();
		}
	}
	
	public static class GoodArea implements Comparable<GoodArea> {
		double areaStart;
		double areaEnd;
		double threshold;
		public GoodArea(double areaStart, double areaEnd, double threshold) {
			this.areaStart = areaStart;
			this.areaEnd = areaEnd;
			this.threshold = threshold;
		}
		@Override
		public String toString() {
			return "area " + String.format("\t%.5f\t%.5f\t(f_max-f_min)\t%.5f\t(f_max-f_min)/f_min\t%.5f\tthreshold\t%.2f",
					areaStart, areaEnd, (areaEnd - areaStart), (areaEnd - areaStart) / areaStart, threshold);
		}
		public double relativeSize() {
			return (areaEnd-areaStart) / areaStart;
		}
		@Override
		public int compareTo(GoodArea v) {
			double s1 = relativeSize();
			double s2 = v.relativeSize();
			// ordering desc by relative size
			if (s1 < s2)
				return 1;
			if (s1 > s2)
				return -1;
			return 0;
		}
	}
	public static class GoodAreaTracker {
		double areaStart = -1;
		double areaEnd = -1;
		double minInterval;
		double threshold;
		List<GoodArea> list = new ArrayList<>();
		public GoodAreaTracker(double minInterval, double threshold) {
			this.minInterval = minInterval;
			this.threshold = threshold;
		}
		public void tick(double freq, double bits) {
			if (bits > threshold) {
				if (areaStart < 0)
					areaStart = freq;
				areaEnd = freq;
			} else {
				areaFinished();
			}
		}
		private void areaFinished() {
			if (areaStart > 0) {
				double size = (areaEnd-areaStart) / areaStart;
				//log(String.format("area %.5f .. %.5f size %.9f   threshold %.2f", areaStart, areaEnd, size, threshold));
				if ( size > minInterval) {
					// new interval found
					GoodArea newItem = new GoodArea(areaStart, areaEnd, threshold);
					//log("adding " + newItem);
					list.add(newItem);
				}
			}
			areaStart = -1;
			areaEnd = -1;
		}
		public void dump() {
			areaFinished();
			log(String.format("Good Area detector with minInterval=%.5f threshold=%.2f areas found: %d", minInterval,
					threshold, list.size()));
			for (GoodArea item : list) {
				log("    " + item);
			}
		}
		public void sort() {
			Collections.sort(list);
		}
	}
	
	public static int[] genSamples(double signalFreq, double timerFreq, int count) {
		Oscillator sensor = new Oscillator(signalFreq, SENSOR_DUTY_CYCLE, SENSOR_NOISE_LEVEL, SENSOR_DITHER_INTERVAL,
				SENSOR_DITHER_AMOUNT, SENSOR_ASYNC_DITHER_FREQUENCY, SENSOR_ASYNC_DITHER_AMOUNT);
		Oscillator timer = new Oscillator(timerFreq);
		int[] samples = new int[count];
		for (int i = 0; i < samples.length; i++) {
			while ( sensor.getTime() > timer.getTime() ) {
				timer.stepCycle();
			}
			samples[i] = timer.getCycleCount();
			sensor.stepHalfCycle();
		}
		return samples;
	}

	public static double measureStage1(int[] samples, int pos, int diff) {
		switch (FILTER_TYPE_STAGE1) {
		default:
		case DIFF:
			// to fix timer overflows, calculate difference module timer counter width
			return ((samples[pos] - samples[pos - diff]) & TIMER_COUNTER_MASK) * 2.0 / diff;
	    case DIFF_AVG:
	        {
	            double sum = 0;
		    	for (int i = 0; i < FILTER_DISTANCE_AVGERAGING; i++) {
		    	    sum = sum + ((samples[pos - i * 2] - samples[pos - diff - i * 2]) & TIMER_COUNTER_MASK) * 2.0 / diff;
		    	}
		    	return sum / FILTER_DISTANCE_AVGERAGING;
	        }
		case WEIGHTED_DIFF_4:
			{
				int offset1 = diff;
				int offset2 = diff*2;
				int offset3 = diff*3;
				int offset4 = diff*4;
				final double k1 = 4;
				final double k2 = 3;
				final double k3 = 2;
				final double k4 = 1;
				// to fix timer overflows, calculate difference module timer counter width
				final double d1 = ((samples[pos] - samples[pos - offset1]) & TIMER_COUNTER_MASK) * 2.0 / offset1;
				final double d2 = ((samples[pos] - samples[pos - offset2]) & TIMER_COUNTER_MASK) * 2.0 / offset2;
				final double d3 = ((samples[pos] - samples[pos - offset3]) & TIMER_COUNTER_MASK) * 2.0 / offset3;
				final double d4 = ((samples[pos] - samples[pos - offset4]) & TIMER_COUNTER_MASK) * 2.0 / offset4;
				final double combined = (d1 * k1 + d2 * k2 + d3 * k3 + d4 * k4);
				return  combined / (k1 + k2 + k3 + k4);
			}
		case DIFF_DITHERED:
		    {
		    	int phase = pos % FILTER_DISTANCE_DITHER_K.length;
		    	int d1 = 0;
		    	int d2 = 0;
		    	int posBit0 = pos & 1;
		    	int amp = FILTER_DISTANCE_DITHER_K[phase] * 10;
		    	int count = 1;
		    	if (amp > 0) {
		    	    d1 = 1 ^ posBit0;
		    	    d2 = 0 ^ posBit0;
		    	    count = amp;
		    	} else if (amp < 0) {
		    	    d1 = 0 ^ posBit0;
		    	    d2 = 1 ^ posBit0;
		    	    count = -amp;
		    	}
		    	double sum = 0;
		    	for (int i = 0; i < count; i++) {
			    	int pos1 = pos - d1- 2*i;
			    	int pos2 = pos - diff - d2 - 2*i;
			    	int length = pos1 - pos2;
					sum = sum + ((samples[pos1] - samples[pos2]) & TIMER_COUNTER_MASK) * 2.0 / length;
		    	}
				return sum / count;
		    }
		}
	}

	public static double measureIIR(int[] samples, int pos, int diff, int width) {
		int startOffset = diff * 4;
		double[] filterStages = new double[16];
		double initValue = measureStage1(samples, pos - startOffset, diff);
		for (int k = 0; k < 16; k++) {
			filterStages[k] = initValue;
		}
		for (int i = startOffset; i >= 0; i--) {
			double inValue = measureStage1(samples, pos - i, diff);
			for (int k = 0; k < IIR_FILTER_STAGES; k++) {
				filterStages[k] = filterStages[k] + (inValue - filterStages[k]) * IIR_FILTER_K;
				inValue = filterStages[k];
			}
			//log(String.format("    %d:\t%.11f\t%.11f\t%.11f\t%.11f\t%.11f\t%.11f\t%.11f\t%.11f\t value=\t%.11f", i, filterStages[0], filterStages[1], filterStages[2], filterStages[3], filterStages[4], filterStages[5], filterStages[6], filterStages[6], inValue));
		}
		return filterStages[IIR_FILTER_STAGES-1];
	}

	/**
	 * Measure signal period using averaging.
	 * @param samples is array of timer counter values captured on each oscillator signal edge
	 * @param pos is index of origin point (averaging done to the past from this point)
	 * @param diff is difference in captured items to the past (step)
	 * @param width is number of pairs to average
	 * @return measured period value * diff * width
	 */
	public static double measureFIR(int[] samples, int pos, int diff, int width) {
		double acc = 0;
		for (int i = 0; i < width; i++) {
			double period = measureStage1(samples, pos - i, diff);
			acc += period;
		}
		return acc / width;
	}


	public static long dumpDiffPatternAt(int[] samples, int pos, int diff, int width) {
		long acc = 0;
		StringBuilder buf = new StringBuilder();
		buf.append("    ");
		for (int i = 0; i < width; i++) {
			// to fix timer overflows, calculate difference module timer counter width
			int delta = (samples[pos - i] - samples[pos - i - diff]) & TIMER_COUNTER_MASK;
			if (i == 0) {
				buf.append("period*" + diff + "~=" + delta + " pattern=");
			}
			buf.append((delta & 1) != 0 ? '1' : '0');
			acc += delta;
		}
		log(buf.toString());
		return acc;
	}

	public static void dumpCapturedData(int[] samples, int length) {
		if (length < 1)
			return;
		log("Captured data:");
		for (int i = 2; i < 30; i++) {
			log("[" + i + "]\t" + samples[i] + "\tdiff\t" + (samples[i] - samples[i-1]));
		}
	}

	public final static int MAX_CAPTURED_VALUES_TO_DUMP = 0;
	public final static int MAX_MEASUREMENTS_TO_DUMP = 0;
	
	public static void testMeasureHeader() {
		log(
				"freq" //+ signalFreq 
				//+ "\ttimerFreq=\t" + timerFreq 
				+ "\tdiff"// + diff 
				+ "\twidth"// + width
				+ "\tperiod min"// + minPeriod 
				//+ "\t max=\t" + maxPeriod 
				+ "\tmax-min" //+ (maxPeriod-minPeriod) 
				+ "\tavg" //+ periodAvg 
				//+ "\t S=\t" + S 
				+ "\tS" //+ exactS
				//+ "\tftimer/fosc" //+ exactS
				+ "\tavgp error"
				+ "\tminp error"
				+ "\tmaxp error"
				+ "\tgood bits"
				);
	}

	public static double[] measure(double signalFreq, double timerFreq, int diff, int width, int testPointStep) {
		int[] samples = genSamples(signalFreq, timerFreq, SIMULATION_SAMPLES_TO_COLLECT);
		dumpCapturedData(samples, MAX_CAPTURED_VALUES_TO_DUMP);
		int minposition = diff*8 + width * 8 + 2;
		int numberOfTestPoints = (SIMULATION_SAMPLES_TO_COLLECT - minposition) / testPointStep;
		double[] res = new double[numberOfTestPoints]; 
		for (int i = 0; i < numberOfTestPoints; i++) {
			int pos = minposition + i * testPointStep;
			//double period = measureIIR(samples, pos, diff, width);
			double period = 0;
			switch (FILTER_TYPE_STAGE2) {
			case FIR:
				period = measureFIR(samples, pos, diff, width);
				break;
			case IIR:
				period = measureIIR(samples, pos, diff, width);
				break;
			}
			
			
			res[i] = period; //2 * period / diff;
		}
		return res;
	}

	public static double testMeasure(double signalFreq, double timerFreq, int diff, int width) {
		if (MAX_MEASUREMENTS_TO_DUMP > 0 || MAX_CAPTURED_VALUES_TO_DUMP > 0)
			log("Testing measure of signal freq=" + signalFreq + " timerFreq=" + timerFreq + " diff=" + diff + " width=" + width);
		int minposition = diff*2 + width * 8 + 2;
		int testPointStep = (SIMULATION_SAMPLES_TO_COLLECT - minposition) / SIMULATION_RANDOM_TEST_POSITION_COUNT;
		double[] measuredPeriods = measure(signalFreq, timerFreq, diff, width, testPointStep);
		double minPeriod = -1;
		double maxPeriod = -1;
		double periodSum = 0;
		for (int i = 0; i < measuredPeriods.length; i++) {
			double period = measuredPeriods[i];
			long periodLong = (long)(period * diff * width + 0.5);
			if (minPeriod < 0 || minPeriod > period) {
				minPeriod = period;
			}
			if (maxPeriod < 0 || maxPeriod < period) {
				maxPeriod = period;
			}
			double freq = 1.0 / period;
			double freqDiff = freq - signalFreq;
			if (i < MAX_MEASUREMENTS_TO_DUMP)
				log("pos\t" + i + "\tvalue\t" + period + "\tbin\t" + Long.toBinaryString(periodLong) + "\tfreq=\t" + freq  + "\tfreqDiff\t" + freqDiff);
			periodSum += period;
		}
		double exactPeriod = (timerFreq / signalFreq);
		double periodAvg = periodSum / measuredPeriods.length;
		double squareDiffSum = 0;
		double squareExactDiffSum = 0;
		for (int i = 0; i < measuredPeriods.length; i++) {
			squareDiffSum += (measuredPeriods[i]-periodAvg) * (measuredPeriods[i]-periodAvg);
			squareExactDiffSum += (measuredPeriods[i]-exactPeriod) * (measuredPeriods[i]-exactPeriod);
		}
		// standard deviation
		double S = Math.sqrt(squareDiffSum / (measuredPeriods.length - 0));
		double exactS = Math.sqrt(squareExactDiffSum / (measuredPeriods.length - 0));

		double scaling = diff * width;
		
		double maxError = Math.max(Math.max(Math.abs(minPeriod - exactPeriod), Math.abs(maxPeriod - exactPeriod)) * scaling, 1); 
		double goodPart = exactPeriod*scaling / maxError;
		// 4.5 bits lost due to 5% oscillator frequency deviation due to hand distance
		double goodBits = log2(goodPart) - SENSOR_FREQUENCY_CHANGE_RATIO_LOST_BITS;
		
		//System.out.println("exact period:\t" + exactPeriod);
		log(
				"" + String.format("%.4f", signalFreq) 
				//+ "\ttimerFreq=\t" + timerFreq 
				+ "\t" + diff 
				+ "\t" + width
				+ "\t" + String.format("%.2f", minPeriod*scaling) 
				+ "\t" + String.format("%.2f", (maxPeriod-minPeriod)*scaling) 
				+ "\t" + String.format("%.2f", periodAvg*scaling)
				//+ "\t S=\t" + S 
				+ "\t" + String.format("%.3f", exactS*scaling)
				//+ "\t" + String.format("%.6f", diff * timerFreq / signalFreq)
				+ "\t" + String.format("%.3f", (periodAvg - exactPeriod)*scaling)
				+ "\t" + String.format("%.3f", (minPeriod - exactPeriod)*scaling)
				+ "\t" + String.format("%.3f", (maxPeriod - exactPeriod)*scaling)
				+ "\t" + String.format("%.3f", goodBits)
				);
		
//		if (exactS > 10000) {
//			int p = 10000;
//			log("    near diff " + (diff) + " pos " + p);
//			for (int i = -10; i <= 10; i += 2 ) {
//				dumpDiffPatternAt(samples, p, diff + i, 128);
//			}
//			p+=12345;
//			log("    near diff " + (diff) + " pos " + p);
//			for (int i = -10; i <= 10; i += 2 ) {
//				dumpDiffPatternAt(samples, p, diff + i, 128);
//			}
//		}
		return goodBits;
 	}

	public static void dumpMeasurementsNear(double signalFreq, double timerFreq, int diff, int width, double freqStep, int freqCount) {
		int testPointStep = 100;
		double[][] measurements = new double[freqCount][];
		StringBuilder header = new StringBuilder();
		header.append("cycle");
		for (int i = 0; i < freqCount; i++) {
			double freq = signalFreq - freqStep * freqCount / 2 + i * freqStep;
			measurements[i] = measure(freq, timerFreq, diff, width, testPointStep);
			header.append("\t");
			header.append(String.format("f%.3f", freq));
		}
		log(String.format("Dumping measurements for frequencies near %.4f  freqStep=%.5f", signalFreq, freqStep));
		log(header.toString());
		int scaling = width * diff / 2;
		for (int i = 0; i < measurements[0].length; i++) {
			StringBuilder line = new StringBuilder();
			line.append(i * testPointStep);
			for (int j = 0; j < freqCount; j++) {
				double freq = signalFreq - freqStep * freqCount / 2 + j * freqStep;
				double exactPeriod = timerFreq/freq * scaling;
				line.append("\t");
				double measuredPeriod = measurements[j][i] * scaling; // / diff / width;
				double k = measuredPeriod - exactPeriod;
				line.append(String.format("%.3f", k));
			}
			log(line.toString());
		}
	}

	public static void testFreqMeasures() {

		
		
		testMeasureHeader();

		
//		testMeasure(1000567.890123456, 240000000.0, 2048, 2048);
//		testMeasure(1234567.890123456, 240000000.0, 2048, 2048);
//		testMeasure(1065444.123465456, 240000000.0, 2048, 2048);
//		testMeasure(987654.321456775456, 240000000.0, 2048, 2048);
//		testMeasure(987654.321456775456, 240000000.0, 2048, 1024);
//		testMeasure(987654.321456775456, 240000000.0, 2048, 3000);
//		testMeasure(1345654.321456775456, 240000000.0, 2048, 2048);
//		testMeasure(1001234.9876554, 240000000.0, 2048, 2048);
//		testMeasure(1001234.9876554, 240000000.0, 2048, 1024);
//		
//		testMeasure(993153.321456775456, 240000000.0, 2048, 2048);
//
//		testMeasure(993153.321456775456, 240000000.0, 2048-2, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 2048-4, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 2048-6, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 2048, 1024);
//		testMeasure(993153.321456775456, 240000000.0, 2048, 512);
//		testMeasure(993153.321456775456, 240000000.0, 2048, 256);
//		testMeasure(993153.321456775456, 240000000.0, 2048, 128);
//		testMeasure(993153.321456775456, 240000000.0, 2048, 64);
//		testMeasure(993153.321456775456, 240000000.0, 2048, 32);
//		testMeasure(993153.321456775456, 240000000.0, 2048, 16);
//
//		testMeasure(993153.321456775456, 240000000.0, 2048, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 1024, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 512, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 256, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 128, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 64, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 32, 2048);
//		testMeasure(993153.321456775456, 240000000.0, 16, 2048);

		int diffLoop = 1;
		int widthLoop = 1;
		//int baseDiff = 1031 * 2;
		int baseDiff = FILTER_DISTANCE * 2;
		
		//990098.8173689365	2048	2048	508349644	382	508349770.97	143.882
		double sensorFreq = OSCILLATOR_MIN_FREQUENCY;

		
		//double sensorFreq = 990098.8173689365;
		//double sensorFreq = 999996;
		int totalCount = 0;
		int goodCount0 = 0;
		int goodCount1 = 0;
		int goodCount2 = 0;
		int goodCount3 = 0;
		int goodCount4 = 0;
		int badCount1 = 0;
		int badCount2 = 0;
		int badCount3 = 0;
		double s_threshold0 = 22;
		double s_threshold1 = 23;
		double s_threshold2 = 24;
		double s_threshold3 = 25;
		double s_threshold4 = 26;
//		double bad_threshold1 = 30;
//		double bad_threshold2 = 100;
//		double bad_threshold3 = 200;
		GoodAreaTracker [] trackers = new GoodAreaTracker[25];
		for (int i = 0; i < trackers.length; i++) {
			trackers[i] = new GoodAreaTracker(0.0005, 27 - 0.5*i);
		}
		double worstBits = 1000;
		double worstBitsFrequency = 0;
		int subSteps = OSCILLATOR_FREQ_DIVIDER_SUBSTEPS;
		int minDividerK = (int)(subSteps * TIMER_FREQUENCY / OSCILLATOR_MAX_FREQUENCY - 0.5);
		int maxDividerK = (int)(subSteps * TIMER_FREQUENCY / OSCILLATOR_MIN_FREQUENCY + 0.5);
		for (int i = maxDividerK; i >= minDividerK; i--) {
			double sensorFreq1 = TIMER_FREQUENCY / i * subSteps;
			double sensorFreq2 = TIMER_FREQUENCY / (i + 1) * subSteps;
			sensorFreq = sensorFreq1 + (sensorFreq2 - sensorFreq1) * OSCILLATOR_FREQ_SHIFT_FROM_RESONANCE_POINT;
			if (sensorFreq < OSCILLATOR_MIN_FREQUENCY || sensorFreq > OSCILLATOR_MAX_FREQUENCY) 
				continue;
			//if (sensorFreq < SENSOR_
			for (int j = 0; j < diffLoop; j++) {
				int diff = baseDiff - j; // >> j;
				for (int k = 0; k < widthLoop; k++) {
					int width = FILTER_WIDTH >> k;
					double bits = testMeasure(sensorFreq, TIMER_FREQUENCY, diff + FILTER_DISTANCE_OFFSET, width);
					if (bits < worstBits) {
						worstBits = bits;
						worstBitsFrequency = sensorFreq;
					}
					for (GoodAreaTracker tracker : trackers)
						tracker.tick(sensorFreq, bits);
					if (bits > s_threshold0)
						goodCount0++;
					if (bits > s_threshold1)
						goodCount1++;
					if (bits > s_threshold2)
						goodCount2++;
					if (bits > s_threshold3)
						goodCount3++;
					if (bits > s_threshold4)
						goodCount4++;
//					if (S > bad_threshold1)
//						badCount1++;
//					if (S > bad_threshold2)
//						badCount2++;
//					if (S > bad_threshold3)
//						badCount3++;
					totalCount++;
				}
			}
			//sensorFreq += OSCILLATOR_FREQ_TEST_STEP;
		}
		log("Finished.");
		log(goodCount0 + " of " + totalCount + " (" + String.format("%.3f", goodCount0 * 100.0 / totalCount) + "%) cases with exact bits > " + s_threshold0);
		log(goodCount1 + " of " + totalCount + " (" + String.format("%.3f", goodCount1 * 100.0 / totalCount) + "%) cases with exact bits > " + s_threshold1);
		log(goodCount2 + " of " + totalCount + " (" + String.format("%.3f", goodCount2 * 100.0 / totalCount) + "%) cases with exact bits > " + s_threshold2);
		log(goodCount3 + " of " + totalCount + " (" + String.format("%.3f", goodCount3 * 100.0 / totalCount) + "%) cases with exact bits > " + s_threshold3);
		log(goodCount4 + " of " + totalCount + " (" + String.format("%.3f", goodCount4 * 100.0 / totalCount) + "%) cases with exact bits > " + s_threshold4);
//		log(badCount1 + " of " + totalCount + " (" + String.format("%.3f", badCount1 * 100.0 / totalCount) + "%) cases with standard deviation > " + bad_threshold1);
//		log(badCount2 + " of " + totalCount + " (" + String.format("%.3f", badCount2 * 100.0 / totalCount) + "%) cases with standard deviation > " + bad_threshold2);
//		log(badCount3 + " of " + totalCount + " (" + String.format("%.3f", badCount3 * 100.0 / totalCount) + "%) cases with standard deviation > " + bad_threshold3);

		log("Found good areas in sorted by frequency:");
		for (GoodAreaTracker tracker : trackers)
			tracker.dump();

		for (GoodAreaTracker tracker : trackers)
			tracker.sort();
		
		log("Found good areas in sorted by size:");
		for (GoodAreaTracker tracker : trackers)
			tracker.dump();

		dumpMeasurementsNear(worstBitsFrequency, TIMER_FREQUENCY, FILTER_DISTANCE * 2 + FILTER_DISTANCE_OFFSET, FILTER_WIDTH, 1.2, 9);
		dumpMeasurementsNear(worstBitsFrequency, TIMER_FREQUENCY, FILTER_DISTANCE * 2 + FILTER_DISTANCE_OFFSET, FILTER_WIDTH, 0.3, 9);
		dumpMeasurementsNear(worstBitsFrequency, TIMER_FREQUENCY, FILTER_DISTANCE * 2 + FILTER_DISTANCE_OFFSET, FILTER_WIDTH, 0.1, 9);
		
	}

	public static void main(String[] args) {
		setLogFile("sensor_sim", false);
		try {
			testFreqMeasures();
		} finally {
			closeLogFile();
		}
	}

	public static final boolean LOG_TIMESTAMPS = false;
	public static void setLogFile(String fname, boolean appendTimestamp) {
		String ts = "_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(
		        Calendar.getInstance().getTime());
		String timeLog = appendTimestamp ? ts : "";
		BufferedWriter writer;
		try {
			File logFile = new File(fname + timeLog + ".log");
			writer = new BufferedWriter(new FileWriter(logFile));
			logWriter = writer;
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void closeLogFile() {
		if (logWriter != null) {
			try {
				logWriter.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
			logWriter = null;
		}
	}
	
	public static void log(String msg) {
		if (logWriter != null) {
			String timeLog = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss ").format(
			        Calendar.getInstance().getTime());
			if (!LOG_TIMESTAMPS)
				timeLog = "";
			try {
				logWriter.write(timeLog + msg + "\n");
				logWriter.flush();
			} catch (IOException e) {
				// ignore
				e.printStackTrace();
				closeLogFile();
			}
		}
		System.out.println(msg);
	}
	

	// logarithm base 2
	public static double log2(double n) {
		if (n <= 1)
			return 0;
		return (Math.log(n) / LOG_2);
	}
	
	// exponent base 2
	public static double exp2(double e) {
		return (Math.exp(LOG_2 * e));
	}

}
