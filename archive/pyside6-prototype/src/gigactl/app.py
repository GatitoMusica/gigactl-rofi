
"""GigaControl application entry point."""

import sys
from pathlib import Path

from PySide6.QtGui import QIcon
from PySide6.QtWidgets import (
    QApplication,
    QSystemTrayIcon,
    QMessageBox,
    QStyle,
)

from .popup import ControlPopup
from .tray import TrayController
from .theme import load_stylesheet


def load_application_icon(application: QApplication) -> QIcon:
    """Load the custom icon, using a system icon as fallback."""
    icon_path = (
        Path(__file__).parent / "assets" / "gigactl.svg"
    )

    icon = QIcon(str(icon_path))

    if icon.isNull():
        icon = QIcon.fromTheme("preferences-system-performance")

    if icon.isNull():
        icon = application.style().standardIcon(
            QStyle.StandardPixmap.SP_ComputerIcon
        )

    return icon


def main() -> int:
    application = QApplication(sys.argv)

    application.setApplicationName("GigaControl")
    application.setOrganizationName("GigaControl")

    # The application must stay alive when the popup is hidden.
    application.setQuitOnLastWindowClosed(False)

    application.setStyleSheet(load_stylesheet())

    if not QSystemTrayIcon.isSystemTrayAvailable():
        QMessageBox.critical(
            None,
            "GigaControl",
            "No compatible system tray was detected.\n\n"
            "Check that KDE Plasma's system tray is available.",
        )
        return 1

    icon = load_application_icon(application)

    popup = ControlPopup()
    tray_controller = TrayController(
        popup,
        icon,
        application,
    )

    # Keep the controller alive during the Qt event loop.
    tray_controller.show()

    return application.exec()
