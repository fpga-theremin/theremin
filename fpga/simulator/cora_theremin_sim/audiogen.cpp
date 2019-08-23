#include "audiogen.h"

static int sine_wave[1024];
static bool sine_wave_initialized = false;
#define M_PI 3.141592653589793238462643383

int interpolatedSin(uint32_t phase, int vol) {
    uint32_t index = (phase >> 22);
    int s1 = sine_wave[index & 0x3ff];
    int s2 = sine_wave[(index + 1) & 0x3ff];
    int64_t delta = (phase >> 6) & 0xffff;
    int64_t noscale = (s1 + (((s2-s1)*delta) >> 16));
    int scaled = static_cast<int>((noscale * vol) >> 24);
    //qDebug("            vol: %d   noscale: %lld   scaled: %d", vol, noscale, scaled);
    return scaled;
}

AudioGen::AudioGen(QObject *parent)
    : QObject(parent), _sampleRate(48000), _started(false)
{
    _phase = 0;

    _newVolume = 0x700000;
    _newFrequency = 440.0f;
    _newPhaseIncrement = static_cast<uint32_t>(_newFrequency * ((static_cast<uint64_t>(1)) << 32) / _sampleRate);
    _volume = _newVolume;
    _phaseIncrement = _newPhaseIncrement;

    qDebug("volume: 0x%x  freq:%f  phaseInc: 0x%x", _volume, _newFrequency, _phaseIncrement);


    //open(QIODevice::ReadOnly);
    if (!sine_wave_initialized) {
        for (int i = 0; i < 1024; i++) {
            sine_wave[i] = static_cast<int>(0x400000 * sin(i * M_PI * 2 / 1024));
        }
    }

//    uint32_t phase = 0;
//    for (int i = 0; i < 1000; i++) {
//        //qDebug("sin(%x)=%d", phase, interpolatedSin(phase, _volume));
//        phase += _phaseIncrement;
//    }
}

void AudioGen::start()
{
    if (!_started) {
        qDebug("Starting AudioGen");
        _started = true;
    }
}

void AudioGen::stop()
{
    if (_started) {
        qDebug("Stopping AudioGen");
        _started = false;
        //close();
    }
}

void AudioGen::setVolume(int volume)
{
    _newVolume = volume;
    qDebug("volume: 0x%x  freq:%f  phaseInc: 0x%x", _volume, _newFrequency, _phaseIncrement);
}

void AudioGen::setFrequency(float freq)
{
    _newFrequency = freq;
    _newPhaseIncrement = static_cast<uint32_t>(freq * ((static_cast<uint64_t>(1)) << 32) / _sampleRate);
    qDebug("volume: 0x%x  freq:%f  phaseInc: 0x%x", _volume, _newFrequency, _phaseIncrement);
}

void AudioGen::setFormat(QAudioFormat format) {
    qDebug("AudioGen::setFormat rate=%d sampleSize=%d sampleType=%d channels=%d", format.sampleRate(), format.sampleSize(), format.sampleType(), format.channelCount());
    _format = format;
    _sampleRate = format.sampleRate();
}

int AudioGen::generate(int * data, int maxlen) {

    if (_volume == 0 || _phaseIncrement == 0) {
        _phase = 0;
    }
    uint32_t phaseIncStart = _phaseIncrement;
    uint32_t phaseIncEnd = _newPhaseIncrement;
    int volumeStart = _volume;
    int volumeEnd = _newVolume;

    if (!_started) {
        return 0;
    }

    for (int i = 0; i < maxlen; i++) {
        uint32_t increment = phaseIncStart + (phaseIncEnd - phaseIncStart) * i / maxlen;
        int vol = volumeStart + (volumeEnd - volumeStart) * i / maxlen;
        int value = interpolatedSin(_phase, vol);
        data[i] = value;
        _phase += increment;
    }

    _phaseIncrement = phaseIncEnd;
    _volume = volumeEnd;

    return maxlen;
}

AudioGen::~AudioGen() {
    //close();
}
