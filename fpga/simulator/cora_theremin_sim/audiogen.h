#ifndef AUDIOGEN_H
#define AUDIOGEN_H

#include <QObject>
#include <QIODevice>
#include <QAudioFormat>

class AudioGen : public QObject //QIODevice
{
    Q_OBJECT

    QAudioFormat _format;
    int _sampleRate;
    bool _started;
#if 0
    float _prevPitchLinear;
    float _prevVolumeLinear;
#endif
    uint32_t _prevPitchPeriod;
    uint32_t _prevVolumePeriod;
public:

    void start();
    void stop();

    void setFormat(QAudioFormat format);

    //virtual bool isSequential() const;
    //virtual bool atEnd() const;
    //virtual qint64 read(char *data, qint64 maxlen);
    //virtual qint64 readData(char *data, qint64 maxlen);
    //virtual qint64 writeData(const char *data, qint64 len);
    //virtual qint64 bytesAvailable() const;

    virtual int generate(int * data, int maxlen);

    //void setVolume(int volume);
    //void setFrequency(float freq);

    AudioGen(QObject *parent);
    virtual ~AudioGen();
};

#endif // AUDIOGEN_H
