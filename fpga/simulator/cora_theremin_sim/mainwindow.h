#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "audioplayer.h"
#include "audiogen.h"
#include "encoder_widget.h"
#include "tact_button_widget.h"
#include "pedal_widget.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

    TactButtonWidget * tactButton;
    EncoderWidget * encoders[5];
    PedalWidget * pedals[6];

    QMenu *fileMenu;
    QMenu *deviceMenu;
    QAction * playAction;
    QAction * stopAction;
    AudioPlayer * audioPlayer;
    AudioGen * audioGen;
    QThread* audioThread;

public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();
signals:
    void play();
    void stop();
public slots:
    void onPlay();
    void onPause();

    void onThreadStarted();
    void onThreadFinished();
    void onPlaybackStarted();
    void onPlaybackStopped();
};

#endif // MAINWINDOW_H
