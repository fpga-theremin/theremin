#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

class MainWindow : public QMainWindow
{
    Q_OBJECT

    QMenu *fileMenu;
    QMenu *deviceMenu;
    QAction * playAction;
    QAction * stopAction;

public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();
signals:
    void play();
    void stop();
public slots:
    void onPlay();
    void onPause();

};

#endif // MAINWINDOW_H
