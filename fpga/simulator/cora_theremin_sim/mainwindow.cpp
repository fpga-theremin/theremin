#include "mainwindow.h"

#include "simulator_impl.h"
#include "lcd_simulator.h"
#include "theremin_sensor_simulator.h"
#include "reg_value_widget.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QSurfaceFormat>
#include <QKeyEvent>
#include <QAction>
#include <QMenu>
#include <QMenuBar>
#include <QToolBar>
#include <QSpacerItem>
#include <QAudioOutput>
#include <QThread>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setMouseTracking(false);

    setFocusPolicy(Qt::FocusPolicy::StrongFocus);
    setFocus();

    setWindowTitle(tr("Cora Z7 FPGA Theremin Emulator"));
    setWindowIcon(QIcon(":/images/theremin.png"));


    fileMenu = menuBar()->addMenu(tr("&File"));
    playAction = new QAction(tr("Play"), this);
    playAction->setEnabled(true);
    const QIcon playIcon = QIcon::fromTheme("media-playback-start", QIcon(":/images/play.png"));
    playAction->setIcon(playIcon);
    connect(playAction, SIGNAL (triggered()), this, SLOT (onPlay()));

    stopAction = new QAction(tr("Stop"), this);
    const QIcon stopIcon = QIcon::fromTheme("media-playback-stop", QIcon(":/images/stop.png"));
    stopAction->setIcon(stopIcon);
    stopAction->setEnabled(false);
    connect(stopAction, SIGNAL (triggered()), this, SLOT (onPause()));
    fileMenu->addAction(playAction);
    fileMenu->addAction(stopAction);

    deviceMenu = fileMenu->addMenu(tr("Playback &Device"));
    QAction * defaultDevice = new QAction(tr("Default"), this);
    deviceMenu->addAction(defaultDevice);
    QActionGroup * deviceActionGroup = new QActionGroup(this);
    deviceActionGroup->addAction(defaultDevice);
    defaultDevice->setCheckable(true);
    defaultDevice->setChecked(true);
    QList<QAudioDeviceInfo> devices = QAudioDeviceInfo::availableDevices(QAudio::Mode::AudioOutput);
    for (int i = 0; i < devices.length(); i++) {
        QAction * devAction = new QAction(devices[i].deviceName(), this);
        devAction->setCheckable(true);
        deviceActionGroup->addAction(devAction);
        deviceMenu->addAction(devAction);
    }


    QToolBar *toolBar = addToolBar(tr("Play"));
    toolBar->addAction(playAction);
    toolBar->addAction(stopAction);


    QVBoxLayout * mainLayout = new QVBoxLayout;
    QVBoxLayout * rightLayout = new QVBoxLayout;

    LCDSimulator * lcdWidget = new LCDSimulator(this);
    mainLayout->addWidget(lcdWidget);

    QHBoxLayout * encodersLayout = new QHBoxLayout;
    tactButton = new TactButtonWidget(this);
    encodersLayout->addStretch(1);
    encodersLayout->addWidget(tactButton);
    encodersLayout->addStretch(2);
    for (int i = 0; i < 5; i++) {
        encoders[i] = new EncoderWidget(i, this);
        encoders[i] -> rotate(i);
        encoders[i] -> setPressed((i & 1) ? true : false);
        encodersLayout->addWidget(encoders[i]);
        encodersLayout->addStretch(3);
    }
    mainLayout->addLayout(encodersLayout);

    QLabel * lblPedals = new QLabel(QString("Pedals"), this);
    rightLayout->addWidget(lblPedals, 0, Qt::AlignCenter);
    for (int i = 0; i < 6; i++) {
        pedals[i] = new PedalWidget(i, this);
        pedals[i] -> setPressed((i & 1) ? true : false);
        pedals[i]->setValue(i * 0.15f);
        rightLayout->addWidget(pedals[i]);
    }
    rightLayout->addStretch(1);
    regWidgets[0] = new RegValueWidget(QString("ENC0"), THEREMIN_RD_REG_ENCODER_0, this);
    regWidgets[1] = new RegValueWidget(QString("ENC1"), THEREMIN_RD_REG_ENCODER_1, this);
    regWidgets[2] = new RegValueWidget(QString("ENC2"), THEREMIN_RD_REG_ENCODER_2, this);
    rightLayout->addWidget(regWidgets[0], 0, Qt::AlignRight);
    rightLayout->addWidget(regWidgets[1], 0, Qt::AlignRight);
    rightLayout->addWidget(regWidgets[2], 0, Qt::AlignRight);
    rightLayout->addStretch(5);


    ThereminSensorSimulator * sensorWidget = new ThereminSensorSimulator(this);
    mainLayout->addWidget(sensorWidget);
    mainLayout->addStretch();


    QHBoxLayout * centralLayout = new QHBoxLayout;
    centralLayout->addLayout(mainLayout);
    centralLayout->addLayout(rightLayout);

    QWidget * centralWidget = new QWidget(this);
    centralWidget->setLayout(centralLayout);
    setCentralWidget(centralWidget);


    audioGen = new AudioGen(this);




    audioThread = new QThread(this);
    audioPlayer = new AudioPlayer(audioGen);
    audioPlayer->moveToThread(audioThread);
    //connect(thread, SIGNAL (started()), thread, SLOT (exec()));
    connect(audioThread, SIGNAL (started()), this, SLOT (onThreadStarted()));
    connect(audioThread, SIGNAL (finished()), this, SLOT (onThreadFinished()));
    connect(audioThread, SIGNAL (finished()), audioPlayer, SLOT (deleteLater()));
    connect(audioThread, SIGNAL (finished()), audioThread, SLOT (deleteLater()));

    connect(this, SIGNAL (play()), audioPlayer, SLOT (start()));
    connect(this, SIGNAL (stop()), audioPlayer, SLOT (stop()));
    connect(audioPlayer, SIGNAL (started()), this, SLOT (onPlaybackStarted()));
    connect(audioPlayer, SIGNAL (stopped()), this, SLOT (onPlaybackStopped()));
    audioThread->start(QThread::Priority::TimeCriticalPriority);

    connect(&periodicTimer, SIGNAL (timeout()), this, SLOT (onPeriodicTimer()));
    periodicTimer.setInterval(500);
    periodicTimer.start();
}

MainWindow::~MainWindow()
{
    qDebug("MainWindow::~MainWindow() enter");
    audioThread->quit();
    audioThread->wait();
    qDebug("MainWindow::~MainWindow() exit");
}

void MainWindow::onPeriodicTimer() {
    regWidgets[0]->updateValue();
    regWidgets[1]->updateValue();
    regWidgets[2]->updateValue();
}

void MainWindow::onPlay() {
    emit play();
}

void MainWindow::onPause() {
    emit stop();
}

void MainWindow::onThreadStarted() {
    qDebug("Thread started");
}

void MainWindow::onThreadFinished() {
    qDebug("Thread stopped");
}

void MainWindow::onPlaybackStarted() {
    qDebug("MainWindow::onPlayStarted");
    playAction->setEnabled(false);
    stopAction->setEnabled(true);
}

void MainWindow::onPlaybackStopped() {
    qDebug("MainWindow::onPlayStopped");
    playAction->setEnabled(true);
    stopAction->setEnabled(false);
}
