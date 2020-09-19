#ifndef AUDIOPLAYER_H
#define AUDIOPLAYER_H

#include <QObject>
#include <QIODevice>
#include <QAudioFormat>
#include <QAudioOutput>
#include "audiogen.h"

#define MAX_BUFFER_SAMPLES 16384

class AudioPlayer : public QObject
{
    Q_OBJECT

    QAudioFormat _format;
    AudioGen * _device;
    QAudioOutput * _audioOutput;
    QIODevice* _audioIO;

    int * _sample_buffer;
    uint8_t * _byte_buffer;
    bool _start_reported;

private:
    int generate(int bytes);
public:
    explicit AudioPlayer(AudioGen * device, QObject *parent = nullptr);
    virtual ~AudioPlayer();
signals:
    void started();
    void playbackPosition(uint64_t position);
    void stopped();
public slots:
    void start();
    void stop();
private slots:
    void handleStateChanged(QAudio::State newState);
    void handleNotify();
};

#endif // AUDIOPLAYER_H
