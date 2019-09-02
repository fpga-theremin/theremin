#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTimer>
#include "audioplayer.h"
#include "audiogen.h"
#include "encoder_widget.h"
#include "tact_button_widget.h"
#include "pedal_widget.h"
#include "reg_value_widget.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

    TactButtonWidget * tactButton;
    EncoderWidget * encoders[5];
    PedalWidget * pedals[6];
    RegValueWidget * regWidgets[3];

    QMenu *fileMenu;
    QMenu *deviceMenu;
    QAction * playAction;
    QAction * stopAction;
    AudioPlayer * audioPlayer;
    AudioGen * audioGen;
    QThread* audioThread;

    QTimer periodicTimer;
public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();
signals:
    void play();
    void stop();
public slots:
    void onPlay();
    void onPause();

    void onPeriodicTimer();

    void onThreadStarted();
    void onThreadFinished();
    void onPlaybackStarted();
    void onPlaybackStopped();
};

#endif // MAINWINDOW_H
