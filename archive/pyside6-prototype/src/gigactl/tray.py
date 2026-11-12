
"""System tray controller."""

from PySide6.QtCore import QTimer
from PySide6.QtWidgets import (
    QSystemTrayIcon,
    QMenu,
    QApplication,
)


class TrayController:
    """Manage the system tray icon and its actions."""

    def __init__(self, popup, icon, application):
        self._popup = popup
        self._application = application

        self._tray = QSystemTrayIcon(icon, application)
        self._tray.setToolTip(
            "GigaControl - Fan and RGB controls"
        )

        self._build_context_menu()

        self._tray.activated.connect(self._on_activated)

    def _build_context_menu(self):
        self._menu = QMenu()

        open_action = self._menu.addAction("Open GigaControl")
        open_action.triggered.connect(self._open_popup)

        settings_action = self._menu.addAction("Settings")
        settings_action.triggered.connect(
            lambda: QTimer.singleShot(
                0,
                lambda: self._open_popup("settings"),
            )
        )

        self._menu.addSeparator()

        exit_action = self._menu.addAction("Exit")
        exit_action.triggered.connect(self.quit)

        self._tray.setContextMenu(self._menu)

    def show(self):
        """Make the tray icon visible."""
        self._tray.show()

    def _on_activated(self, reason):
        if reason == QSystemTrayIcon.ActivationReason.Trigger:
            if self._popup.isVisible():
                self._popup.hide()
            else:
                self._open_popup()

    def _open_popup(self, section=None):
        if section is not None:
            self._popup.show_section(section)

        self._popup.show_near(self._tray.geometry())

    def quit(self):
        """Exit the application completely."""
        self._popup.hide()
        self._tray.hide()
        self._application.quit()
