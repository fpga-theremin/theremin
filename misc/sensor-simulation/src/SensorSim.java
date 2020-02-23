
public class SensorSim {

	public static class Oscillator {
		private boolean state;
		private double time;
		private double frequency;
		private double period;
		// from falling to raising
		private double halfPeriod;
		private long cycleCount;
		public Oscillator(double freq, double dutyCycle) {
			frequency = freq;
			period = 1.0 / freq;
			halfPeriod = period - period * dutyCycle;
			time = halfPeriod;
			state = false;
		}

		// returns time of new event
		public double getTime() {
			return time;
		}
		
		public long getCycleCount() {
			return cycleCount;
		}
		
		public double stepHalfCycle() {
			if (state) {
				// falling
				time += halfPeriod;
				cycleCount++;
			} else {
				// raising
				time += (period - halfPeriod);
			}
			state = !state;
			return time;
		}
		
		public double stepCycle() {
			stepHalfCycle();
			return stepHalfCycle();
		}
	}
	
	public static long[] genSamples(double signalFreq, double timerFreq, int count) {
		Oscillator sensor = new Oscillator(signalFreq, 0.5);
		Oscillator timer = new Oscillator(timerFreq, 0.5);
		long[] samples = new long[count];
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
	public static long measureAt(long[] samples, int pos, int diff, int width) {
		long sum1 = 0;
		long sum2 = 0;
		for (int i = 0; i < width; i++) {
			// older part
			sum1 += samples[pos - diff - i];
			// recent part
			sum2 += samples[pos - i];
		}
		long measuredValue = sum2 - sum1;
		return measuredValue;
	}
	
	public static void testMeasure(double signalFreq, double timerFreq, int diff, int width) {
		System.out.println("Testing measure of signal freq=" + signalFreq + " timerFreq=" + timerFreq + " diff=" + diff + " width=" + width);
		long[] samples = genSamples(signalFreq, timerFreq, 100000);
		System.out.println("Captured data:");
		for (int i = 2; i < 30; i++) {
			System.out.println("[" + i + "]\t" + samples[i] + "\tdiff\t" + (samples[i] - samples[i-1]));
		}
		
		int pos = 10000;
		long minPeriod = -1;
		long maxPeriod = -1;
		for (int i = 0; i < 50; i++) {
			long period = measureAt(samples, pos, diff, width);
			if (minPeriod < 0 || minPeriod > period)
				minPeriod = period;
			if (maxPeriod < 0 || maxPeriod < period)
				maxPeriod = period;
			double periodFloat = (1/timerFreq) * (period / (double)diff / (double)width) * 2;
			double freq = 1.0 / periodFloat;
			double freqDiff = freq - signalFreq;
			System.out.println("pos\t" + pos + "\tvalue\t" + period + "\tbin\t" + Long.toBinaryString(period) + "\tfreq=\t" + freq  + "\tfreqDiff\t" + freqDiff);
			pos += 137;
		}
		System.out.println("period min=" + minPeriod + " max=" + maxPeriod + " diff=" + (maxPeriod-minPeriod));
 	}
	
	public static void main(String[] args) {
		testMeasure(1000567.890123456, 240000000.0, 2048, 2048);
		testMeasure(1234567.890123456, 240000000.0, 2048, 2048);
		testMeasure(1065444.123465456, 240000000.0, 2048, 2048);
		testMeasure(987654.321456775456, 240000000.0, 2048, 2048);
		testMeasure(987654.321456775456, 240000000.0, 2048, 1024);
		testMeasure(987654.321456775456, 240000000.0, 2048, 3000);
		testMeasure(1345654.321456775456, 240000000.0, 2048, 2048);
		testMeasure(1001234.9876554, 240000000.0, 2048, 2048);
		testMeasure(1001234.9876554, 240000000.0, 2048, 1024);
	}

}
