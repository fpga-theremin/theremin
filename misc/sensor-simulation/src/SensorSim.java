import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
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
	
	
	public static final int TIMER_COUNTER_BITS = 24; 
	public static final int TIMER_COUNTER_MASK = (1<<TIMER_COUNTER_BITS) - 1; 
	public static final double XTAL_NOISE_LEVEL = 0; //0.000001;

	// number of captured edges to collect
	public static final int SIMULATION_SAMPLES_TO_COLLECT = 15000;
	// number of random points to measure period in collected data
	public static final int SIMULATION_RANDOM_TEST_POSITION_COUNT = 3;

	//public static final double TIMER_FREQUENCY = 1_200_000_000.0;
	//public static final double TIMER_FREQUENCY = 240_000_000.0;
	public static final double TIMER_FREQUENCY = 120_000_000.0;
	//public static final double TIMER_FREQUENCY = 150_000_000.0;
	
	public static final double SENSOR_NOISE_LEVEL = 0.0001; //0.001; //0.00001; //0.001;
	public static final double SENSOR_DUTY_CYCLE = 0.5;
	public static final int SENSOR_DITHER_INTERVAL = 1; //512;
	public static final double SENSOR_DITHER_AMOUNT = 0; //0.0001; //5000.1 / 2048.0 / 2048.0;
	
	public static final double OSCILLATOR_START_FREQUENCY = 870_000.0;
	public static final double SENSOR_MAX_TEST_FREQ = 915_000.0;
	//public static final double SENSOR_MAX_TEST_FREQ = 1_050_000.0;
	public final static double OSCILLATOR_FREQ_TEST_STEP = Math.PI / 5; //11; // / 7;
	public static final int FILTER_DISTANCE = 1024;
	public static final int FILTER_DISTANCE_OFFSET = 0; //7*2;
	
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
		
		public Oscillator(double freq, double dutyCycle, double noiseLevel, int ditherInterval, double ditherAmount) {
			this.noiseLevel = noiseLevel;
			this.noise = 0;
			this.ditherInterval = ditherInterval;
			this.ditherAmount = ditherAmount;
			this.dither = 0;
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
		
		public double stepHalfCycle() {
			if (state) {
				// falling
				time += halfPeriod;
				noise = makeNoise(period, noiseLevel, 3);
				cycleCount = (cycleCount + 1) & TIMER_COUNTER_MASK;
				if (ditherInterval > 1 && ditherAmount > 0) {
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
		public void tick(double freq, double errorRate) {
			if (errorRate < threshold) {
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
		Oscillator sensor = new Oscillator(signalFreq, SENSOR_DUTY_CYCLE, SENSOR_NOISE_LEVEL, SENSOR_DITHER_INTERVAL, SENSOR_DITHER_AMOUNT);
		Oscillator timer = new Oscillator(timerFreq, 0.5, XTAL_NOISE_LEVEL, 1, 0);
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

	/**
	 * Measure signal period using averaging.
	 * @param samples is array of timer counter values captured on each oscillator signal edge
	 * @param pos is index of origin point (averaging done to the past from this point)
	 * @param diff is difference in captured items to the past (step)
	 * @param width is number of pairs to average
	 * @return measured period value * diff * width
	 */
	public static long measureAt(int[] samples, int pos, int diff, int width) {
		long acc = 0;
		for (int i = 0; i < width; i++) {
			// to fix timer overflows, calculate difference module timer counter width
			int delta = (samples[pos - i] - samples[pos - i - diff]) & TIMER_COUNTER_MASK;
			acc += delta;
		}
		return acc;
	}

	/**
	 * Measure signal period using averaging.
	 * @param samples is array of timer counter values captured on each oscillator signal edge
	 * @param pos is index of origin point (averaging done to the past from this point)
	 * @param diff is difference in captured items to the past (step)
	 * @param width is number of pairs to average
	 * @return measured period value * diff * width
	 */
	public static long measureAt2(int[] samples, int pos, int diff, int width) {
		long acc = 0;
		for (int i = 0; i < width; i++) {
			// to fix timer overflows, calculate difference module timer counter width
			int delta1 = (samples[pos - i] - samples[pos - i - diff - 2]) & TIMER_COUNTER_MASK;
			int delta2 = (samples[pos - i] - samples[pos - i - diff + 2]) & TIMER_COUNTER_MASK;
			int delta3 = (samples[pos - i] - samples[pos - i - diff - 1]) & TIMER_COUNTER_MASK;
			int delta4 = (samples[pos - i] - samples[pos - i - diff + 1]) & TIMER_COUNTER_MASK;
			acc += delta1 + delta2 + delta3 + delta4;
		}
		return acc / 4;
	}


	public static long dumpDiffPatternAt(int[] samples, int pos, int diff, int width) {
		long acc = 0;
		StringBuilder buf = new StringBuilder();
		buf.append("    ");
		for (int i = 0; i < width; i++) {
			// to fix timer overflows, calculate difference module timer counter width
			int delta = (samples[pos - i] - samples[pos - i - diff]) & TIMER_COUNTER_MASK;
			if (i == 0)
				buf.append("period*" + diff + "~=" + delta + " pattern=");
			buf.append((delta & 1) != 0 ? '1' : '0');
			acc += delta;
		}
		log(buf.toString());
		return acc;
	}

	private static Map<Integer, double[]> windowMap = new HashMap<>();
	public static double[] makeLinearWindow(int width) {
		double[] window = new double[width];
		double sum = 0;
		for (int i = 0; i < width; i++) {
			window[i] = (1.0 - (width-i-1) / width);
			sum += window[i];
		}
		log("window sum=" + sum);
		return window;
	}
	public static double[] getWindow(int width) {
		double[] window = windowMap.get(width);
		if (window == null) {
			window = makeLinearWindow(width);
			windowMap.put(width, window);
		}
		return window;
	}

	/**
	 * Measure signal period using averaging.
	 * @param samples is array of timer counter values captured on each oscillator signal edge
	 * @param pos is index of origin point (averaging done to the past from this point)
	 * @param diff is difference in captured items to the past (step)
	 * @param width is number of pairs to average
	 * @return measured period value * diff * width
	 */
	public static long measureWithFIRFilter(int[] samples, int pos, int diff, int width) {
		double[] window = getWindow(width);
		double acc = 0;
		for (int i = 0; i < width; i++) {
			// to fix timer overflows, calculate difference module timer counter width
			int delta = (samples[pos - i] - samples[pos - i - diff]) & TIMER_COUNTER_MASK;
			acc += delta * window[i];
			//log("delta=" + delta + " acc=" + (int)acc);
		}
		int res = (int)acc;
		//log("acc/width=" + (res/width));
		return res;
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
				+ "\tavgp error" //+ exactS
				+ "\tminp error" //+ exactS
				+ "\tmaxp error" //+ exactS
				);
	}

	public static double testMeasure(double signalFreq, double timerFreq, int diff, int width) {
		if (MAX_MEASUREMENTS_TO_DUMP > 0 || MAX_CAPTURED_VALUES_TO_DUMP > 0)
			log("Testing measure of signal freq=" + signalFreq + " timerFreq=" + timerFreq + " diff=" + diff + " width=" + width);
		int[] samples = genSamples(signalFreq, timerFreq, SIMULATION_SAMPLES_TO_COLLECT);
		dumpCapturedData(samples, MAX_CAPTURED_VALUES_TO_DUMP);
		long minPeriod = -1;
		long maxPeriod = -1;
		int maxMeasurementsToTest = SIMULATION_RANDOM_TEST_POSITION_COUNT;
		double periodSum = 0;
	    double [] periods = new double[maxMeasurementsToTest];
		Random rnd = new Random();
		int minposition = diff + width + 2;
		for (int i = 0; i < maxMeasurementsToTest; i++) {
			int pos = rnd.nextInt(SIMULATION_SAMPLES_TO_COLLECT-minposition) + minposition;
			long period = measureAt(samples, pos, diff, width);
			//long period = measureAt2(samples, pos, diff, width);
			//long period = measureAt2(samples, pos, diff, width);
			//long period = measureWithFIRFilter(samples, pos, diff, width);
			if (minPeriod < 0 || minPeriod > period) {
				minPeriod = period;
			}
			if (maxPeriod < 0 || maxPeriod < period) {
				maxPeriod = period;
			}
			double periodFloat = (timerFreq/signalFreq) * (period / (double)diff / (double)width) * 2;
			double freq = 1.0 / periodFloat;
			double freqDiff = freq - signalFreq;
			if (i < MAX_MEASUREMENTS_TO_DUMP)
				log("pos\t" + pos + "\tvalue\t" + period + "\tbin\t" + Long.toBinaryString(period) + "\tfreq=\t" + freq  + "\tfreqDiff\t" + freqDiff);
			periodSum += period;
			periods[i] = period;
		}
		double exactPeriod = (timerFreq/signalFreq) * width * diff / 2;
		double periodAvg = periodSum / maxMeasurementsToTest;
		double squareDiffSum = 0;
		double squareExactDiffSum = 0;
		for (int i = 0; i < maxMeasurementsToTest; i++) {
			squareDiffSum += (periods[i]-periodAvg)*(periods[i]-periodAvg);
			squareExactDiffSum += (periods[i]-exactPeriod)*(periods[i]-exactPeriod);
		}
		// standard deviation
		double S = Math.sqrt(squareDiffSum / (maxMeasurementsToTest - 0));
		double exactS = Math.sqrt(squareExactDiffSum / (maxMeasurementsToTest - 0));

		//System.out.println("exact period:\t" + exactPeriod);
		log(
				"" + signalFreq 
				//+ "\ttimerFreq=\t" + timerFreq 
				+ "\t" + diff 
				+ "\t" + width
				+ "\t" + minPeriod 
				//+ "\t max=\t" + maxPeriod 
				+ "\t" + (maxPeriod-minPeriod) 
				+ "\t" + String.format("%.2f", periodAvg)
				//+ "\t S=\t" + S 
				+ "\t" + String.format("%.3f", exactS)
				//+ "\t" + String.format("%.6f", diff * timerFreq / signalFreq)
				+ "\t" + String.format("%.3f", periodAvg - exactPeriod)
				+ "\t" + String.format("%.3f", minPeriod - exactPeriod)
				+ "\t" + String.format("%.3f", maxPeriod - exactPeriod)
				);
		
		if (exactS > 10000) {
			int p = 10000;
			log("    near diff " + (diff) + " pos " + p);
			for (int i = -10; i <= 10; i += 2 ) {
				dumpDiffPatternAt(samples, p, diff + i, 128);
			}
			p+=12345;
			log("    near diff " + (diff) + " pos " + p);
			for (int i = -10; i <= 10; i += 2 ) {
				dumpDiffPatternAt(samples, p, diff + i, 128);
			}
		}
		return exactS;
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
		double sensorFreq = OSCILLATOR_START_FREQUENCY;
		//double sensorFreq = 990098.8173689365;
		//double sensorFreq = 999996;
		int totalCount = 0;
		int goodCount1 = 0;
		int goodCount2 = 0;
		int goodCount3 = 0;
		int badCount1 = 0;
		int badCount2 = 0;
		int badCount3 = 0;
		double s_threshold1 = 8;
		double s_threshold2 = 4;
		double s_threshold3 = 2;
		double bad_threshold1 = 30;
		double bad_threshold2 = 100;
		double bad_threshold3 = 200;
		GoodAreaTracker [] trackers = new GoodAreaTracker[25];
		for (int i = 0; i < trackers.length; i++) {
			trackers[i] = new GoodAreaTracker(0.0005, 20 + 5*i);
		}
		for (int i = 0; i < 1_000_000 && sensorFreq < SENSOR_MAX_TEST_FREQ; i++) {
			for (int j = 0; j < diffLoop; j++) {
				int diff = baseDiff - j; // >> j;
				for (int k = 0; k < widthLoop; k++) {
					int width = diff >> k;
					double S = testMeasure(sensorFreq, TIMER_FREQUENCY, diff + FILTER_DISTANCE_OFFSET, width);
					for (GoodAreaTracker tracker : trackers)
						tracker.tick(sensorFreq, S);
					if (S < s_threshold1)
						goodCount1++;
					if (S < s_threshold2)
						goodCount2++;
					if (S < s_threshold3)
						goodCount3++;
					if (S > bad_threshold1)
						badCount1++;
					if (S > bad_threshold2)
						badCount2++;
					if (S > bad_threshold3)
						badCount3++;
					totalCount++;
				}
			}
			sensorFreq += OSCILLATOR_FREQ_TEST_STEP;
		}
		log("Finished.");
		log(goodCount1 + " of " + totalCount + " (" + String.format("%.3f", goodCount1 * 100.0 / totalCount) + "%) cases with standard deviation < " + s_threshold1);
		log(goodCount2 + " of " + totalCount + " (" + String.format("%.3f", goodCount2 * 100.0 / totalCount) + "%) cases with standard deviation < " + s_threshold2);
		log(goodCount3 + " of " + totalCount + " (" + String.format("%.3f", goodCount3 * 100.0 / totalCount) + "%) cases with standard deviation < " + s_threshold3);
		log(badCount1 + " of " + totalCount + " (" + String.format("%.3f", badCount1 * 100.0 / totalCount) + "%) cases with standard deviation > " + bad_threshold1);
		log(badCount2 + " of " + totalCount + " (" + String.format("%.3f", badCount2 * 100.0 / totalCount) + "%) cases with standard deviation > " + bad_threshold2);
		log(badCount3 + " of " + totalCount + " (" + String.format("%.3f", badCount3 * 100.0 / totalCount) + "%) cases with standard deviation > " + bad_threshold3);

		log("Found good areas in sorted by frequency:");
		for (GoodAreaTracker tracker : trackers)
			tracker.dump();

		for (GoodAreaTracker tracker : trackers)
			tracker.sort();
		
		log("Found good areas in sorted by size:");
		for (GoodAreaTracker tracker : trackers)
			tracker.dump();

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
	

}
