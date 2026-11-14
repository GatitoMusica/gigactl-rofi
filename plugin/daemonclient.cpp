#include "daemonclient.h"

#include <QDBusArgument>
#include <QDBusMessage>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QDBusServiceWatcher>
#include <QDBusVariant>
#include <QMetaType>
#include <QVariant>

namespace {

const QString SERVICE_NAME =
    QStringLiteral("io.github.smairio.gigactl");

const QString OBJECT_PATH =
    QStringLiteral("/io/github/smairio/gigactl");

const QString INTERFACE_NAME =
    QStringLiteral("io.github.smairio.gigactl.Control");

const QString PROPERTIES_INTERFACE =
    QStringLiteral("org.freedesktop.DBus.Properties");

const QString DBUS_SERVICE =
    QStringLiteral("org.freedesktop.DBus");

const QString DBUS_PATH =
    QStringLiteral("/org/freedesktop/DBus");

const QString DBUS_INTERFACE =
    QStringLiteral("org.freedesktop.DBus");

constexpr int DBUS_CHECK_TIMEOUT_MS = 5000;
constexpr int DBUS_CALL_TIMEOUT_MS = 30000;

QString dbusVariantToString(const QVariant &value)
{
    if (value.metaType().id() == qMetaTypeId<QDBusVariant>()) {
        return qvariant_cast<QDBusVariant>(value).variant().toString();
    }

    return value.toString();
}

bool dbusVariantToBool(const QVariant &wireValue, bool &result)
{
    QVariant value = wireValue;

    if (value.metaType().id() == qMetaTypeId<QDBusVariant>()) {
        value = qvariant_cast<QDBusVariant>(value).variant();
    }

    if (value.metaType().id() != QMetaType::Bool) {
        return false;
    }

    result = value.toBool();
    return true;
}

bool dbusVariantToKeyboardState(
    const QVariant &wireValue,
    bool &enabled,
    int &red,
    int &green,
    int &blue,
    int &brightness
)
{
    QVariant value = wireValue;

    if (value.metaType().id() == qMetaTypeId<QDBusVariant>()) {
        value = qvariant_cast<QDBusVariant>(value).variant();
    }

    bool enabledValue = false;
    quint32 redValue = 0;
    quint32 greenValue = 0;
    quint32 blueValue = 0;
    quint32 brightnessValue = 0;

    if (value.metaType().id() == qMetaTypeId<QDBusArgument>()) {
        const QDBusArgument argument = qvariant_cast<QDBusArgument>(value);
        argument.beginStructure();
        argument >> enabledValue >> redValue >> greenValue >> blueValue
                 >> brightnessValue;
        argument.endStructure();
    } else {
        const QVariantList fields = value.toList();
        if (fields.size() != 5) {
            return false;
        }

        enabledValue = fields.at(0).toBool();
        redValue = fields.at(1).toUInt();
        greenValue = fields.at(2).toUInt();
        blueValue = fields.at(3).toUInt();
        brightnessValue = fields.at(4).toUInt();
    }

    if (redValue > 255 || greenValue > 255 || blueValue > 255
        || brightnessValue > 100) {
        return false;
    }

    enabled = enabledValue;
    red = static_cast<int>(redValue);
    green = static_cast<int>(greenValue);
    blue = static_cast<int>(blueValue);
    brightness = static_cast<int>(brightnessValue);
    return true;
}

} // namespace

GigactlDaemonClient::GigactlDaemonClient(QObject *parent)
    : QObject(parent),
      m_bus(QDBusConnection::systemBus())
{
    // Check whether the system D-Bus is available.
    if (!m_bus.isConnected()) {
        const QString reason = m_bus.lastError().message();

        setError(
            reason.isEmpty()
                ? tr("The system D-Bus is unavailable.")
                : tr("Cannot connect to system D-Bus: %1").arg(reason)
        );

        return;
    }

    // Watch for daemon registration and unregistration.
    m_serviceWatcher = new QDBusServiceWatcher(
        SERVICE_NAME,
        m_bus,
        QDBusServiceWatcher::WatchForOwnerChange,
        this
    );

    connect(
        m_serviceWatcher,
        &QDBusServiceWatcher::serviceOwnerChanged,
        this,
        [this](
            const QString &,
            const QString &,
            const QString &newOwner
        ) {
            setAvailable(!newOwner.isEmpty());
        }
    );

    // Subscribe to daemon property changes.
    const bool signalConnected = m_bus.connect(
        SERVICE_NAME,
        OBJECT_PATH,
        PROPERTIES_INTERFACE,
        QStringLiteral("PropertiesChanged"),
        QStringLiteral("sa{sv}as"),
        this,
        SLOT(onPropertiesChanged(QString,QVariantMap,QStringList))
    );

    if (!signalConnected) {
        setError(
            tr("Could not subscribe to daemon state changes.")
        );
    }

    // Check whether the daemon is already running.
    QDBusMessage message = QDBusMessage::createMethodCall(
        DBUS_SERVICE,
        DBUS_PATH,
        DBUS_INTERFACE,
        QStringLiteral("NameHasOwner")
    );

    message.setArguments({
        QVariant::fromValue(SERVICE_NAME)
    });

    auto *watcher = new QDBusPendingCallWatcher(
        m_bus.asyncCall(message, DBUS_CHECK_TIMEOUT_MS),
        this
    );

    connect(
        watcher,
        &QDBusPendingCallWatcher::finished,
        this,
        [this, watcher]() {
            QDBusPendingReply<bool> reply = *watcher;

            if (reply.isError()) {
                if (!m_available) {
                    setError(
                        tr("Could not check daemon availability: %1")
                            .arg(reply.error().message())
                    );
                }
            } else {
                setAvailable(reply.value());
            }

            watcher->deleteLater();
        }
    );
}

// -----------------------------------------------------------------------------
// Property getters
// -----------------------------------------------------------------------------

bool GigactlDaemonClient::available() const
{
    return m_available;
}

QString GigactlDaemonClient::activeProfile() const
{
    return m_activeProfile;
}

QString GigactlDaemonClient::ecStatus() const
{
    return m_ecStatus;
}

QString GigactlDaemonClient::daemonVersion() const
{
    return m_daemonVersion;
}

bool GigactlDaemonClient::turboAvailable() const
{
    return m_turboAvailable;
}

bool GigactlDaemonClient::turboBoost() const
{
    return m_turboBoost;
}

bool GigactlDaemonClient::keyboardEnabled() const
{
    return m_keyboardEnabled;
}

int GigactlDaemonClient::keyboardRed() const
{
    return m_keyboardRed;
}

int GigactlDaemonClient::keyboardGreen() const
{
    return m_keyboardGreen;
}

int GigactlDaemonClient::keyboardBlue() const
{
    return m_keyboardBlue;
}

int GigactlDaemonClient::keyboardBrightness() const
{
    return m_keyboardBrightness;
}

QString GigactlDaemonClient::error() const
{
    return m_error;
}

// -----------------------------------------------------------------------------
// Internal state management
// -----------------------------------------------------------------------------

void GigactlDaemonClient::setAvailable(bool available)
{
    if (m_available == available) {
        return;
    }

    m_available = available;

    Q_EMIT availabilityChanged();

    if (available) {
        setError(QString());
        readState();
        return;
    }

    // Clear stale daemon information after disconnection.
    const bool hadState =
        !m_activeProfile.isEmpty() || !m_ecStatus.isEmpty()
        || !m_daemonVersion.isEmpty();
    const bool hadTurboState = m_turboAvailable || m_turboBoost;

    m_activeProfile.clear();
    m_ecStatus.clear();
    m_daemonVersion.clear();
    m_turboAvailable = false;
    m_turboBoost = false;

    if (hadState) {
        Q_EMIT stateChanged();
    }
    if (hadTurboState) {
        Q_EMIT turboStateChanged();
    }
}

void GigactlDaemonClient::setError(const QString &message)
{
    if (m_error == message) {
        return;
    }

    m_error = message;

    Q_EMIT errorChanged();
}

// -----------------------------------------------------------------------------
// Read daemon properties asynchronously
// -----------------------------------------------------------------------------

void GigactlDaemonClient::readState()
{
    if (!m_available) {
        return;
    }

    const QStringList properties = {
        QStringLiteral("ActiveProfile"),
        QStringLiteral("EcStatus"),
        QStringLiteral("DaemonVersion"),
        QStringLiteral("KeyboardState"),
        QStringLiteral("TurboAvailable"),
        QStringLiteral("TurboBoost")
    };

    for (const QString &propertyName : properties) {
        quint64 turboRevision = 0;
        quint64 turboReadSerial = 0;

        if (propertyName == QStringLiteral("TurboAvailable")) {
            turboRevision = m_turboAvailableRevision;
            turboReadSerial = ++m_turboAvailableReadSerial;
        } else if (propertyName == QStringLiteral("TurboBoost")) {
            turboRevision = m_turboBoostRevision;
            turboReadSerial = ++m_turboBoostReadSerial;
        }

        QDBusMessage message = QDBusMessage::createMethodCall(
            SERVICE_NAME,
            OBJECT_PATH,
            PROPERTIES_INTERFACE,
            QStringLiteral("Get")
        );

        message.setArguments({
            QVariant::fromValue(INTERFACE_NAME),
            QVariant::fromValue(propertyName)
        });

        auto *watcher = new QDBusPendingCallWatcher(
            m_bus.asyncCall(message, DBUS_CALL_TIMEOUT_MS),
            this
        );

        connect(
            watcher,
            &QDBusPendingCallWatcher::finished,
            this,
            [this, watcher, propertyName, turboRevision, turboReadSerial]() {
                const bool isTurboAvailable =
                    propertyName == QStringLiteral("TurboAvailable");
                const bool isTurboBoost =
                    propertyName == QStringLiteral("TurboBoost");

                if ((isTurboAvailable
                     && (turboRevision != m_turboAvailableRevision
                         || turboReadSerial != m_turboAvailableReadSerial))
                    || (isTurboBoost
                        && (turboRevision != m_turboBoostRevision
                            || turboReadSerial != m_turboBoostReadSerial))) {
                    watcher->deleteLater();
                    return;
                }

                QDBusPendingReply<QDBusVariant> reply = *watcher;

                if (reply.isError()) {
                    // EcStatus is optional for older daemon versions.
                    if (propertyName == QStringLiteral("ActiveProfile")) {
                        setError(
                            tr("Could not read the active fan profile: %1")
                                .arg(reply.error().message())
                        );
                    } else if (propertyName == QStringLiteral("KeyboardState")) {
                        setError(
                            tr("Could not read keyboard state: %1")
                                .arg(reply.error().message())
                        );
                    }

                    watcher->deleteLater();
                    return;
                }

                const QString value = reply.value().variant().toString();
                bool changed = false;

                if (propertyName == QStringLiteral("ActiveProfile")) {
                    if (m_activeProfile != value) {
                        m_activeProfile = value;
                        changed = true;
                    }

                    setError(QString());
                } else if (propertyName == QStringLiteral("EcStatus")) {
                    if (m_ecStatus != value) {
                        m_ecStatus = value;
                        changed = true;
                    }
                } else if (propertyName == QStringLiteral("DaemonVersion")) {
                    if (m_daemonVersion != value) {
                        m_daemonVersion = value;
                        changed = true;
                    }
                } else if (propertyName == QStringLiteral("KeyboardState")) {
                    bool enabled = false;
                    int red = 0;
                    int green = 0;
                    int blue = 0;
                    int brightness = 0;

                    if (!dbusVariantToKeyboardState(
                            reply.value().variant(),
                            enabled,
                            red,
                            green,
                            blue,
                            brightness)) {
                        setError(tr("The daemon returned an invalid keyboard state."));
                        watcher->deleteLater();
                        return;
                    }

                    const bool keyboardChanged =
                        m_keyboardEnabled != enabled ||
                        m_keyboardRed != red ||
                        m_keyboardGreen != green ||
                        m_keyboardBlue != blue ||
                        m_keyboardBrightness != brightness;

                    m_keyboardEnabled = enabled;
                    m_keyboardRed = red;
                    m_keyboardGreen = green;
                    m_keyboardBlue = blue;
                    m_keyboardBrightness = brightness;

                    if (keyboardChanged) {
                        Q_EMIT keyboardStateChanged();
                    }
                } else if (propertyName == QStringLiteral("TurboAvailable")
                           || propertyName == QStringLiteral("TurboBoost")) {
                    bool booleanValue = false;
                    if (!dbusVariantToBool(reply.value().variant(), booleanValue)) {
                        setError(tr("The daemon returned an invalid Turbo Boost state."));
                        watcher->deleteLater();
                        return;
                    }

                    bool &cached = propertyName == QStringLiteral("TurboAvailable")
                        ? m_turboAvailable
                        : m_turboBoost;
                    if (cached != booleanValue) {
                        cached = booleanValue;
                        Q_EMIT turboStateChanged();
                    }
                }

                if (changed) {
                    Q_EMIT stateChanged();
                }

                watcher->deleteLater();
            }
        );
    }
}

// -----------------------------------------------------------------------------
// Public operations
// -----------------------------------------------------------------------------

void GigactlDaemonClient::refreshState()
{
    if (!m_available) {
        setError(tr("The gigactl daemon is not available."));
        return;
    }

    readState();
}

void GigactlDaemonClient::setProfile(const QString &name)
{
    if (!m_available) {
        setError(tr("The gigactl daemon is not available."));
        return;
    }

    QDBusMessage message = QDBusMessage::createMethodCall(
        SERVICE_NAME,
        OBJECT_PATH,
        INTERFACE_NAME,
        QStringLiteral("SetProfile")
    );

    message.setArguments({
        QVariant::fromValue(name)
    });

    auto *watcher = new QDBusPendingCallWatcher(
        m_bus.asyncCall(message, DBUS_CALL_TIMEOUT_MS),
        this
    );

    connect(
        watcher,
        &QDBusPendingCallWatcher::finished,
        this,
        [this, watcher]() {
            QDBusPendingReply<> reply = *watcher;

            if (reply.isError()) {
                setError(
                    tr("Could not change fan profile: %1")
                        .arg(reply.error().message())
                );
                Q_EMIT stateChanged();
            } else {
                setError(QString());
            }

            readState();

            watcher->deleteLater();
        }
    );
}

void GigactlDaemonClient::restoreFirmware()
{
    if (!m_available) {
        setError(tr("The gigactl daemon is not available."));
        return;
    }

    QDBusMessage message = QDBusMessage::createMethodCall(
        SERVICE_NAME,
        OBJECT_PATH,
        INTERFACE_NAME,
        QStringLiteral("RestoreFirmware")
    );

    auto *watcher = new QDBusPendingCallWatcher(
        m_bus.asyncCall(message, DBUS_CALL_TIMEOUT_MS),
        this
    );

    connect(
        watcher,
        &QDBusPendingCallWatcher::finished,
        this,
        [this, watcher]() {
            QDBusPendingReply<> reply = *watcher;

            if (reply.isError()) {
                setError(
                    tr("Could not restore firmware fan control: %1")
                        .arg(reply.error().message())
                );
            } else {
                setError(QString());
                readState();
            }

            watcher->deleteLater();
        }
    );
}

void GigactlDaemonClient::setTurboBoost(bool enabled)
{
    if (!m_available) {
        setError(tr("The gigactl daemon is not available."));
        Q_EMIT turboStateChanged();
        return;
    }

    // A pending property read must not overwrite this newer user request.
    ++m_turboBoostRevision;

    QDBusMessage message = QDBusMessage::createMethodCall(
        SERVICE_NAME,
        OBJECT_PATH,
        INTERFACE_NAME,
        QStringLiteral("SetTurboBoost")
    );
    message.setArguments({QVariant::fromValue(enabled)});

    auto *watcher = new QDBusPendingCallWatcher(
        m_bus.asyncCall(message, DBUS_CALL_TIMEOUT_MS),
        this
    );

    connect(
        watcher,
        &QDBusPendingCallWatcher::finished,
        this,
        [this, watcher]() {
            QDBusPendingReply<> reply = *watcher;

            if (reply.isError()) {
                setError(
                    tr("Could not change CPU Turbo Boost: %1")
                        .arg(reply.error().message())
                );
                Q_EMIT turboStateChanged();
            } else {
                setError(QString());
                readState();
            }

            watcher->deleteLater();
        }
    );
}

void GigactlDaemonClient::setKeyboardColor(int red, int green, int blue)
{
    if (red < 0 || red > 255 || green < 0 || green > 255
        || blue < 0 || blue > 255) {
        setError(tr("Keyboard color components must be between 0 and 255."));
        Q_EMIT keyboardStateChanged();
        return;
    }

    callKeyboardMethod(
        QStringLiteral("SetKeyboardColor"),
        {
            QVariant::fromValue(static_cast<uint>(red)),
            QVariant::fromValue(static_cast<uint>(green)),
            QVariant::fromValue(static_cast<uint>(blue))
        },
        tr("Could not change keyboard color")
    );
}

void GigactlDaemonClient::setKeyboardBrightness(int percent)
{
    if (percent < 0 || percent > 100) {
        setError(tr("Keyboard brightness must be between 0 and 100 percent."));
        Q_EMIT keyboardStateChanged();
        return;
    }

    callKeyboardMethod(
        QStringLiteral("SetKeyboardBrightness"),
        {QVariant::fromValue(static_cast<uint>(percent))},
        tr("Could not change keyboard brightness")
    );
}

void GigactlDaemonClient::setKeyboardEnabled(bool enabled)
{
    callKeyboardMethod(
        QStringLiteral("SetKeyboardEnabled"),
        {QVariant::fromValue(enabled)},
        tr("Could not change keyboard power")
    );
}

void GigactlDaemonClient::callKeyboardMethod(
    const QString &method,
    const QVariantList &arguments,
    const QString &errorPrefix
)
{
    if (!m_available) {
        setError(tr("The gigactl daemon is not available."));
        Q_EMIT keyboardStateChanged();
        return;
    }

    QDBusMessage message = QDBusMessage::createMethodCall(
        SERVICE_NAME,
        OBJECT_PATH,
        INTERFACE_NAME,
        method
    );
    message.setArguments(arguments);

    auto *watcher = new QDBusPendingCallWatcher(
        m_bus.asyncCall(message, DBUS_CALL_TIMEOUT_MS),
        this
    );

    connect(
        watcher,
        &QDBusPendingCallWatcher::finished,
        this,
        [this, watcher, errorPrefix]() {
            QDBusPendingReply<> reply = *watcher;

            if (reply.isError()) {
                setError(
                    QStringLiteral("%1: %2")
                        .arg(errorPrefix, reply.error().message())
                );
                Q_EMIT keyboardStateChanged();
            } else {
                setError(QString());
                readState();
            }

            watcher->deleteLater();
        }
    );
}

// -----------------------------------------------------------------------------
// D-Bus property change notifications
// -----------------------------------------------------------------------------

void GigactlDaemonClient::onPropertiesChanged(
    const QString &interfaceName,
    const QVariantMap &changedProperties,
    const QStringList &invalidatedProperties
)
{
    // Ignore notifications from unrelated interfaces or unavailable daemon.
    if (!m_available || interfaceName != INTERFACE_NAME) {
        return;
    }

    bool changed = false;
    bool keyboardChanged = false;
    bool turboChanged = false;

    // Active fan profile.
    const auto profileIt =
        changedProperties.constFind(QStringLiteral("ActiveProfile"));

    if (profileIt != changedProperties.cend()) {
        const QString value = dbusVariantToString(profileIt.value());

        if (m_activeProfile != value) {
            m_activeProfile = value;
            changed = true;
        }
    }

    // Embedded Controller status.
    const auto statusIt =
        changedProperties.constFind(QStringLiteral("EcStatus"));

    if (statusIt != changedProperties.cend()) {
        const QString value = dbusVariantToString(statusIt.value());

        if (m_ecStatus != value) {
            m_ecStatus = value;
            changed = true;
        }
    }

    const auto versionIt =
        changedProperties.constFind(QStringLiteral("DaemonVersion"));

    if (versionIt != changedProperties.cend()) {
        const QString value = dbusVariantToString(versionIt.value());

        if (m_daemonVersion != value) {
            m_daemonVersion = value;
            changed = true;
        }
    }

    const auto turboAvailableIt =
        changedProperties.constFind(QStringLiteral("TurboAvailable"));

    if (turboAvailableIt != changedProperties.cend()) {
        ++m_turboAvailableRevision;
        bool value = false;

        if (dbusVariantToBool(turboAvailableIt.value(), value)) {
            if (m_turboAvailable != value) {
                m_turboAvailable = value;
                turboChanged = true;
            }
        } else {
            setError(tr("The daemon returned an invalid Turbo Boost availability."));
        }
    }

    const auto turboBoostIt =
        changedProperties.constFind(QStringLiteral("TurboBoost"));

    if (turboBoostIt != changedProperties.cend()) {
        ++m_turboBoostRevision;
        bool value = false;

        if (dbusVariantToBool(turboBoostIt.value(), value)) {
            if (m_turboBoost != value) {
                m_turboBoost = value;
                turboChanged = true;
            }
        } else {
            setError(tr("The daemon returned an invalid Turbo Boost state."));
        }
    }

    const auto keyboardIt =
        changedProperties.constFind(QStringLiteral("KeyboardState"));

    if (keyboardIt != changedProperties.cend()) {
        bool enabled = false;
        int red = 0;
        int green = 0;
        int blue = 0;
        int brightness = 0;

        if (dbusVariantToKeyboardState(
                keyboardIt.value(), enabled, red, green, blue, brightness)) {
            keyboardChanged =
                m_keyboardEnabled != enabled ||
                m_keyboardRed != red ||
                m_keyboardGreen != green ||
                m_keyboardBlue != blue ||
                m_keyboardBrightness != brightness;

            m_keyboardEnabled = enabled;
            m_keyboardRed = red;
            m_keyboardGreen = green;
            m_keyboardBlue = blue;
            m_keyboardBrightness = brightness;
        } else {
            setError(tr("The daemon returned an invalid keyboard state."));
        }
    }

    // Invalidated properties are no longer authoritative until re-read.
    if (invalidatedProperties.contains(QStringLiteral("ActiveProfile"))) {
        if (!m_activeProfile.isEmpty()) {
            m_activeProfile.clear();
            changed = true;
        }
    }

    if (invalidatedProperties.contains(QStringLiteral("EcStatus"))) {
        if (!m_ecStatus.isEmpty()) {
            m_ecStatus.clear();
            changed = true;
        }
    }

    if (invalidatedProperties.contains(QStringLiteral("DaemonVersion"))) {
        if (!m_daemonVersion.isEmpty()) {
            m_daemonVersion.clear();
            changed = true;
        }
    }

    if (invalidatedProperties.contains(QStringLiteral("TurboAvailable"))) {
        ++m_turboAvailableRevision;
        if (m_turboAvailable) {
            m_turboAvailable = false;
            turboChanged = true;
        }
    }

    if (invalidatedProperties.contains(QStringLiteral("TurboBoost"))) {
        ++m_turboBoostRevision;
        if (m_turboBoost) {
            m_turboBoost = false;
            turboChanged = true;
        }
    }

    // Notify QML once when the locally cached state changed.
    if (changed) {
        Q_EMIT stateChanged();
    }

    // Re-read invalidated values asynchronously.
    if (invalidatedProperties.contains(QStringLiteral("ActiveProfile"))
        || invalidatedProperties.contains(QStringLiteral("EcStatus"))
        || invalidatedProperties.contains(QStringLiteral("DaemonVersion"))
        || invalidatedProperties.contains(QStringLiteral("KeyboardState"))
        || invalidatedProperties.contains(QStringLiteral("TurboAvailable"))
        || invalidatedProperties.contains(QStringLiteral("TurboBoost"))) {
        readState();
    }

    if (turboChanged) {
        Q_EMIT turboStateChanged();
    }

    if (keyboardChanged) {
        Q_EMIT keyboardStateChanged();
    }
}
