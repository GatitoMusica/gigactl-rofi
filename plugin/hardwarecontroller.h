#pragma once

#include <QObject>
#include <QString>
#include <QProcess>
#include <QTimer>

#include <QtQml/qqmlregistration.h>

class HardwareController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int cpuTemperature
               READ cpuTemperature
               NOTIFY dataChanged)

    Q_PROPERTY(int gpuTemperature
               READ gpuTemperature
               NOTIFY dataChanged)

    Q_PROPERTY(int cpuFanRpm
               READ cpuFanRpm
               NOTIFY dataChanged)

    Q_PROPERTY(int gpuFanRpm
               READ gpuFanRpm
               NOTIFY dataChanged)

    Q_PROPERTY(int cpuFanDuty
               READ cpuFanDuty
               NOTIFY dataChanged)

    Q_PROPERTY(int gpuFanDuty
               READ gpuFanDuty
               NOTIFY dataChanged)

    Q_PROPERTY(QString fanMode
               READ fanMode
               NOTIFY dataChanged)

    Q_PROPERTY(bool busy
               READ busy
               NOTIFY busyChanged)

    Q_PROPERTY(QString error
               READ error
               NOTIFY errorChanged)

public:
    explicit HardwareController(QObject *parent = nullptr);

    int cpuTemperature() const;
    int gpuTemperature() const;

    int cpuFanRpm() const;
    int gpuFanRpm() const;

    int cpuFanDuty() const;
    int gpuFanDuty() const;

    QString fanMode() const;

    bool busy() const;
    QString error() const;

    Q_INVOKABLE void refresh();

Q_SIGNALS:
    void dataChanged();
    void busyChanged();
    void errorChanged();

private:
    QProcess m_process;
    QTimer m_processTimeout;

    bool m_timedOut = false;

    int m_cpuTemperature = -1;
    int m_gpuTemperature = -1;

    int m_cpuFanRpm = -1;
    int m_gpuFanRpm = -1;

    int m_cpuFanDuty = -1;
    int m_gpuFanDuty = -1;

    QString m_fanMode;

    bool m_busy = false;
    QString m_error;
};
