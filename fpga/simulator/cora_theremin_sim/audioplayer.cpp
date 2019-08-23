#include "audioplayer.h"



AudioPlayer::AudioPlayer(AudioGen * device, QObject *parent)
    : QObject(parent), _device(device), _audioOutput(nullptr), _audioIO(nullptr), _start_reported(false)
{
    _sample_buffer = new int[MAX_BUFFER_SAMPLES * 2];
    _byte_buffer = new uint8_t[MAX_BUFFER_SAMPLES * 8];

}

AudioPlayer::~AudioPlayer() {
    qDebug("AudioPlayer::~AudioPlayer enter");
    if (_audioOutput) {
        qDebug("Stopping audio output");
        if (_audioOutput->state() == QAudio::State::ActiveState || _audioOutput->state() == QAudio::State::IdleState) {
            _audioOutput->stop();
        }
        delete _audioOutput;
    }
    delete[] _sample_buffer;
    delete[] _byte_buffer;
    qDebug("AudioPlayer::~AudioPlayer exit");
}

void AudioPlayer::start() {
    qDebug("AudioPlayer::start()");
    if (_audioOutput) {
        qDebug("already playing");
        return;
    }
    QAudioFormat format;
    // Set up the format
    int sampleRate = 48000;
    int notifyInterval = 10;
    format.setSampleRate(sampleRate);
    format.setChannelCount(1);
    format.setSampleSize(16);
    format.setCodec("audio/pcm");
    format.setByteOrder(QAudioFormat::LittleEndian);
    format.setSampleType(QAudioFormat::SignedInt);

    QAudioDeviceInfo info(QAudioDeviceInfo::defaultOutputDevice());
    if (!info.isFormatSupported(format)) {
        format = info.nearestFormat(format);
    }
    _format = format;
    _device->setFormat(_format);
    _audioOutput = new QAudioOutput(format, this);
    _device->start();
    connect(_audioOutput, SIGNAL(stateChanged(QAudio::State)), this, SLOT(handleStateChanged(QAudio::State)));
    connect(_audioOutput, SIGNAL(notify()), this, SLOT(handleNotify()));
    qDebug("current buffer size: %d  notify interval: %d   period size: %d", _audioOutput->bufferSize(), _audioOutput->notifyInterval(), _audioOutput->periodSize());
    // 48 samples per ms
    _audioOutput->setNotifyInterval(notifyInterval);
    _audioOutput->setBufferSize(sampleRate*notifyInterval/1000*2*6);
    _audioIO = _audioOutput->start();
    qDebug("current buffer size: %d  notify interval: %d   period size: %d", _audioOutput->bufferSize(), _audioOutput->notifyInterval(), _audioOutput->periodSize());
    generate(2000);
}

static uint32_t pos = 0;
int AudioPlayer::generate(int bytes) {
    const int channelBytes = _format.sampleSize() / 8;
    //if (channelBytes == 3)
    //    channelBytes = 4;
    const int sampleBytes = _format.channelCount() * channelBytes;
    int samples = bytes / sampleBytes;
    if (samples > MAX_BUFFER_SAMPLES)
        samples = MAX_BUFFER_SAMPLES;
    if (samples > 0) {
        _device->generate(_sample_buffer, samples);
        int p = 0;
        for (int i = 0; i < samples; i++) {
            int sample = _sample_buffer[i];
            pos++;
//            if (pos & 0x100)
//                sample = 0x800000;
//            else
//                sample = 0x7fffff;
            //_byte_buffer[p++] = static_cast<uint8_t>(sample >> 0);
            _byte_buffer[p++] = static_cast<uint8_t>(sample >> 8);
            _byte_buffer[p++] = static_cast<uint8_t>(sample >> 16);
            //_byte_buffer[p++] = sample >= 0 ? 0 : 0xff;
        }

    }
    return samples * sampleBytes;
}

void AudioPlayer::handleNotify()
{
    if (_audioOutput->state() != QAudio::State::ActiveState && _audioOutput->state() != QAudio::State::IdleState) {
        qDebug("notify: not in active/idle state");
        return;
    }
    int bytesFree = _audioOutput->bytesFree();
    if (bytesFree == 0)
        return;
    int periodSize = _audioOutput->periodSize();
    int sz = bytesFree >= periodSize*6 ? periodSize*6 : bytesFree;
    int byteCount = generate(sz);
    //qDebug("QAudioOutput:notify bytesFree=%d periodSize=%d sz=%d generated=%d", bytesFree, periodSize, sz, byteCount);
    _audioIO->write(reinterpret_cast<char*>(_byte_buffer), byteCount);
}


void AudioPlayer::handleStateChanged(QAudio::State newState) {
    qDebug("AudioPlayer::handleStateChanged %d", newState);
    switch (newState) {
        case QAudio::IdleState:
            qDebug("QAudio::IdleState");

//            {
//                int bytesFree = _audioOutput->bytesFree();
//                if (bytesFree) {
//                    int bytesGenerated = generate(bytesFree);

//                } else {
//                    _audioOutput->stop();
//                }
//            }
            // Finished playing (no more data)
            //_audioOutput->stop();
            //_device->stop();
            //delete _audioOutput;
            //_audioOutput = nullptr;
            //emit stopped();
            //handleNotify();
            break;

        case QAudio::ActiveState:
            qDebug("QAudio::ActiveState");
            if (!_start_reported) {
                emit started();
                _start_reported = true;
            }
            break;
        case QAudio::SuspendedState:
            qDebug("QAudio::SuspendedState");
            _audioOutput->stop();
            break;
        case QAudio::StoppedState:
            qDebug("QAudio::StoppedState");
            // Stopped for other reasons
            if (_audioOutput->error() != QAudio::NoError) {
                // Error handling
                qDebug("QAudio::StoppedState error=%d", _audioOutput->error());
            }
            //_audioOutput->stop();
            //_device->stop();
            delete _audioOutput;
            _audioOutput = nullptr;
            emit stopped();
            _start_reported = false;
            break;

        default:
            // ... other cases as appropriate
            break;
    }
}

void AudioPlayer::stop() {
    if (!_audioOutput) {
        qDebug("already stopped");
        return;
    }
    qDebug("AudioPlayer::stop()");
    _audioOutput->stop();
    //_audioOutput->suspend();
}
