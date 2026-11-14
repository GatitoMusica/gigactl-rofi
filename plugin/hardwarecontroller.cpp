#include "hardwarecontroller.h"

#include <QRegularExpression>
#include <QStandardPaths>
#include <QStringList>

namespace {

constexpr int processTimeoutMs = 10'000;

// Temporary structure for the values reported by gfan.
struct FanStatus {
    int cpuTemperature = -1;
    int gpuTemperature = -1;

    int cpuFanRpm = -1;
    int gpuFanRpm = -1;

    int cpuFanDuty = -1;
    int gpuFanDuty = -1;

    QString fanMode;
};

// Parse the output returned by gfan.
bool parseFanStatus(const QString &output, FanStatus &status)
{
    const QRegularExpression temperaturePattern(
        QStringLiteral(
            R"(CPU:\s*(\d+)\s*°C\s+GPU:\s*(\d+)\s*°C)"
        )
    );

    const QRegularExpression cpuFanPattern(
        QStringLiteral(
            R"(Fan1\s*\(CPU\):\s*duty\s*(\d+)%\s*~\s*(\d+)\s*RPM)"
        )
    );

    const QRegularExpression gpuFanPattern(
        QStringLiteral(
            R"(Fan2\s*\(GPU\):\s*duty\s*(\d+)%\s*~\s*(\d+)\s*RPM)"
        )
    );

    const QRegularExpression modePattern(
        QStringLiteral(R"(^Mode:\s*(.+)$)"),
        QRegularExpression::MultilineOption
    );

    const auto temperatureMatch = temperaturePattern.match(output);
    const auto cpuFanMatch = cpuFanPattern.match(output);
    const auto gpuFanMatch = gpuFanPattern.match(output);
    const auto modeMatch = modePattern.match(output);

    // Require all expected fields before accepting a reading.
    if (!temperatureMatch.hasMatch()
        || !cpuFanMatch.hasMatch()
        || !gpuFanMatch.hasMatch()
        || !modeMatch.hasMatch()) {
        return false;
    }

    status.cpuTemperature = temperatureMatch.captured(1).toInt();
    status.gpuTemperature = temperatureMatch.captured(2).toInt();

    status.cpuFanDuty = cpuFanMatch.captured(1).toInt();
    status.cpuFanRpm = cpuFanMatch.captured(2).toInt();

    status.gpuFanDuty = gpuFanMatch.captured(1).toInt();
    status.gpuFanRpm = gpuFanMatch.captured(2).toInt();

    status.fanMode = modeMatch.captured(1).trimmed();

    return true;
}

} // namespace

HardwareController::HardwareController(QObject *parent)
    : QObject(parent)
{
    // Configure a one-shot timeout for each gfan invocation.
    m_processTimeout.setSingleShot(true);

    // Start counting only after the process has actually started.
    connect(
        &m_process,
        &QProcess::started,
        this,
        [this]() {
            m_processTimeout.start(processTimeoutMs);
        }
    );

    // Kill gfan if it does not finish within the allowed time.
    connect(
        &m_processTimeout,
        &QTimer::timeout,
        this,
        [this]() {
            if (m_process.state() == QProcess::NotRunning) {
                return;
            }

            m_timedOut = true;
            m_process.kill();
        }
    );

    // Handle the result when gfan finishes.
    connect(
        &m_process,
        &QProcess::finished,
        this,
        [this](int exitCode, QProcess::ExitStatus exitStatus) {
            m_processTimeout.stop();

            if (m_busy) {
                m_busy = false;
                Q_EMIT busyChanged();
            }

            const QString standardOutput =
                QString::fromLocal8Bit(m_process.readAllStandardOutput());

            const QString standardError =
                QString::fromLocal8Bit(m_process.readAllStandardError()).trimmed();

            const auto setError = [this](const QString &message) {
                if (m_error != message) {
                    m_error = message;
                    Q_EMIT errorChanged();
                }
            };

            // Report a timeout separately from other process failures.
            if (m_timedOut) {
                m_timedOut = false;
                setError(
                    QStringLiteral("gfan superó el tiempo máximo de ejecución de 10 segundos.")
                );
                return;
            }

            // Check that the process exited normally and successfully.
            if (exitStatus != QProcess::NormalExit || exitCode != 0) {
                setError(
                    !standardError.isEmpty()
                        ? standardError
                        : QStringLiteral("gfan terminó con código %1.").arg(exitCode)
                );
                return;
            }

            // Parse the returned hardware readings.
            FanStatus status;

            if (!parseFanStatus(standardOutput, status)) {
                setError(
                    QStringLiteral(
                        "La salida de gfan tiene un formato inesperado."
                    )
                );
                return;
            }

            // Publish the new values to QML.
            m_cpuTemperature = status.cpuTemperature;
            m_gpuTemperature = status.gpuTemperature;

            m_cpuFanRpm = status.cpuFanRpm;
            m_gpuFanRpm = status.gpuFanRpm;

            m_cpuFanDuty = status.cpuFanDuty;
            m_gpuFanDuty = status.gpuFanDuty;

            m_fanMode = status.fanMode;

            Q_EMIT dataChanged();
            setError(QString());
        }
    );

    // Handle errors that prevent the process from starting.
    connect(
        &m_process,
        &QProcess::errorOccurred,
        this,
        [this](QProcess::ProcessError processError) {
            if (processError != QProcess::FailedToStart) {
                return;
            }

            m_processTimeout.stop();
            m_timedOut = false;

            if (m_busy) {
                m_busy = false;
                Q_EMIT busyChanged();
            }

            const QString message = m_process.errorString();

            if (m_error != message) {
                m_error = message;
                Q_EMIT errorChanged();
            }
        }
    );
}

// Getters used by QML.
int HardwareController::cpuTemperature() const
{
    return m_cpuTemperature;
}

int HardwareController::gpuTemperature() const
{
    return m_gpuTemperature;
}

int HardwareController::cpuFanRpm() const
{
    return m_cpuFanRpm;
}

int HardwareController::gpuFanRpm() const
{
    return m_gpuFanRpm;
}

int HardwareController::cpuFanDuty() const
{
    return m_cpuFanDuty;
}

int HardwareController::gpuFanDuty() const
{
    return m_gpuFanDuty;
}

QString HardwareController::fanMode() const
{
    return m_fanMode;
}

bool HardwareController::busy() const
{
    return m_busy;
}

QString HardwareController::error() const
{
    return m_error;
}

// Run gfan to obtain an updated hardware reading.
void HardwareController::refresh()
{
    // Avoid starting another query while one is already running.
    if (m_process.state() != QProcess::NotRunning) {
        return;
    }

    // Locate gfan using the current system PATH.
    const QString program =
        QStandardPaths::findExecutable(QStringLiteral("gfan"));

    if (program.isEmpty()) {
        const QString message =
            QStringLiteral("No se ha encontrado el ejecutable gfan.");

        if (m_error != message) {
            m_error = message;
            Q_EMIT errorChanged();
        }

        return;
    }

    // Reset timeout state and clear any previous error.
    m_timedOut = false;

    if (!m_error.isEmpty()) {
        m_error.clear();
        Q_EMIT errorChanged();
    }

    m_busy = true;
    Q_EMIT busyChanged();

    // Run gfan asynchronously without blocking the UI.
    m_process.start(program, QStringList(), QIODevice::ReadOnly);
}
