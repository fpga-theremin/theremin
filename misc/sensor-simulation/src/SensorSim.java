import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Random;

public class SensorSim {

	// logging support
	private static BufferedWriter logWriter;
	
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
	
	
	public static final int TIMER_COUNTER_BITS = 24; 
	public static final int TIMER_COUNTER_MASK = (1<<TIMER_COUNTER_BITS) - 1; 
	public static final double SENSOR_NOISE_LEVEL = 0.00001;

	public static final int SIMULATION_SAMPLES_TO_COLLECT = 30000; 

	
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
		
		// noise as fraction of signal period
		private double noiseLevel;
		private double noise;
		
		public Oscillator(double freq, double dutyCycle, double noiseLevel) {
			this.noiseLevel = noiseLevel;
			this.noise = 0;
			frequency = freq;
			period = 1.0 / freq;
			halfPeriod = period - period * dutyCycle;
			time = halfPeriod;
			state = false;
		}

		// returns time of new event
		public double getTime() {
			return time + noise;
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
			} else {
				// raising
				time += (period - halfPeriod);
				noise = makeNoise(period, noiseLevel, 3);
			}
			state = !state;
			return time;
		}
		
		public double stepCycle() {
			stepHalfCycle();
			return stepHalfCycle();
		}
	}
	
	
	public static int[] genSamples(double signalFreq, double timerFreq, int count) {
		Oscillator sensor = new Oscillator(signalFreq, 0.5, SENSOR_NOISE_LEVEL);
		Oscillator timer = new Oscillator(timerFreq, 0.5, 0.0);
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
		int acc = 0;
		for (int i = 0; i < width; i++) {
			// to fix timer overflows, calculate difference module timer counter width
			int delta = (samples[pos - i] - samples[pos - i - diff]) & TIMER_COUNTER_MASK;
			acc += delta;
		}
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
				+ "\texactS" //+ exactS
				//+ "\tftimer/fosc" //+ exactS
				);
	}

	public static double testMeasure(double signalFreq, double timerFreq, int diff, int width) {
		if (MAX_MEASUREMENTS_TO_DUMP > 0 || MAX_CAPTURED_VALUES_TO_DUMP > 0)
			log("Testing measure of signal freq=" + signalFreq + " timerFreq=" + timerFreq + " diff=" + diff + " width=" + width);
		int[] samples = genSamples(signalFreq, timerFreq, SIMULATION_SAMPLES_TO_COLLECT);
		dumpCapturedData(samples, MAX_CAPTURED_VALUES_TO_DUMP);
		long minPeriod = -1;
		long maxPeriod = -1;
		int maxMeasurementsToTest = 30;
		double periodSum = 0;
	    double [] periods = new double[maxMeasurementsToTest];
		Random rnd = new Random();
		int minposition = diff + width;
		for (int i = 0; i < maxMeasurementsToTest; i++) {
			int pos = rnd.nextInt(SIMULATION_SAMPLES_TO_COLLECT-minposition) + minposition;
			long period = measureAt(samples, pos, diff, width);
			if (minPeriod < 0 || minPeriod > period)
				minPeriod = period;
			if (maxPeriod < 0 || maxPeriod < period)
				maxPeriod = period;
			double periodFloat = (timerFreq/signalFreq) * (period / (double)diff / (double)width) * 2;
			double freq = 1.0 / periodFloat;
			double freqDiff = freq - signalFreq;
			if (i < MAX_MEASUREMENTS_TO_DUMP)
				log("pos\t" + pos + "\tvalue\t" + period + "\tbin\t" + Long.toBinaryString(period) + "\tfreq=\t" + freq  + "\tfreqDiff\t" + freqDiff);
			pos += 137;
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
				);
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
		int baseDiff = 1024 * 2;
		
		double sensorFreq = 990000.0;
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
		for (int i = 0; i < 30000; i++) {
			for (int j = 0; j < diffLoop; j++) {
				int diff = baseDiff >> j;
				for (int k = 0; k < widthLoop; k++) {
					int width = diff >> k;
					double S = testMeasure(sensorFreq, 240000000.0, diff, width);
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
			sensorFreq += Math.PI / 7;
		}
		log("Finished.");
		log(goodCount1 + " of " + totalCount + " (" + String.format("%.3f", goodCount1 * 100.0 / totalCount) + "%) cases with standard deviation < " + s_threshold1);
		log(goodCount2 + " of " + totalCount + " (" + String.format("%.3f", goodCount2 * 100.0 / totalCount) + "%) cases with standard deviation < " + s_threshold2);
		log(goodCount3 + " of " + totalCount + " (" + String.format("%.3f", goodCount3 * 100.0 / totalCount) + "%) cases with standard deviation < " + s_threshold3);
		log(badCount1 + " of " + totalCount + " (" + String.format("%.3f", badCount1 * 100.0 / totalCount) + "%) cases with standard deviation > " + bad_threshold1);
		log(badCount2 + " of " + totalCount + " (" + String.format("%.3f", badCount2 * 100.0 / totalCount) + "%) cases with standard deviation > " + bad_threshold2);
		log(badCount3 + " of " + totalCount + " (" + String.format("%.3f", badCount3 * 100.0 / totalCount) + "%) cases with standard deviation > " + bad_threshold3);
	}

	public static void main(String[] args) {
		setLogFile("sensor_sim", false);
		try {
			testFreqMeasures();
		} finally {
			closeLogFile();
		}
	}

}
