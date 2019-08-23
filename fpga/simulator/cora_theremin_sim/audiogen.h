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

    uint32_t _phase;
    uint32_t _phaseIncrement;
    int _volume;

    int _newVolume;
    float _newFrequency;
    uint32_t _newPhaseIncrement;
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

    void setVolume(int volume);
    void setFrequency(float freq);

    AudioGen(QObject *parent);
    virtual ~AudioGen();
};

#endif // AUDIOGEN_H
