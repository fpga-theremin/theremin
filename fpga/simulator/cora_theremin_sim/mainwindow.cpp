#include "mainwindow.h"

#include "simulator_impl.h"
#include "lcd_simulator.h"
#include "theremin_sensor_simulator.h"

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

    LCDSimulator * lcdWidget = new LCDSimulator(this);
    mainLayout->addWidget(lcdWidget);
    ThereminSensorSimulator * sensorWidget = new ThereminSensorSimulator(this);
    mainLayout->addWidget(sensorWidget);
    mainLayout->addStretch();

    QWidget * centralWidget = new QWidget(this);
    centralWidget->setLayout(mainLayout);
    setCentralWidget(centralWidget);
}

MainWindow::~MainWindow()
{

}

void MainWindow::onPlay() {
    emit play();
}

void MainWindow::onPause() {
    emit stop();
}

