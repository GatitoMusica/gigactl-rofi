
"""Main GigaControl popup window."""

from PySide6.QtCore import Qt, QSize
from PySide6.QtGui import QCursor, QGuiApplication
from PySide6.QtWidgets import (
    QWidget,
    QLabel,
    QPushButton,
    QVBoxLayout,
    QHBoxLayout,
    QGridLayout,
    QFrame,
    QStackedWidget,
    QButtonGroup,
)


class ControlPopup(QWidget):
    """Compact popup displayed from the system tray."""

    SECTIONS = {
        "cooling": 0,
        "keyboard": 1,
        "settings": 2,
    }

    def __init__(self):
        super().__init__(
            None,
            Qt.WindowType.Popup | Qt.WindowType.FramelessWindowHint,
        )

        self.setObjectName("ControlPopup")
        self.setWindowTitle("GigaControl")
        self.setFixedSize(QSize(390, 490))

        self._nav_group = QButtonGroup(self)
        self._nav_group.setExclusive(True)

        self._build_interface()
        self.show_section("cooling")

    def _build_interface(self):
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(18, 18, 18, 16)
        main_layout.setSpacing(14)

        # Header
        header = QHBoxLayout()

        brand_layout = QVBoxLayout()
        brand_layout.setSpacing(2)

        brand = QLabel("GigaControl")
        brand.setObjectName("BrandTitle")

        subtitle = QLabel("SYSTEM CONTROL")
        subtitle.setObjectName("MutedText")

        brand_layout.addWidget(brand)
        brand_layout.addWidget(subtitle)

        header.addLayout(brand_layout)
        header.addStretch()

        main_layout.addLayout(header)

        # Navigation
        navigation = QHBoxLayout()
        navigation.setSpacing(6)

        self.nav_buttons = {}

        sections = [
            ("cooling", "Cooling"),
            ("keyboard", "RGB Keyboard"),
            ("settings", "Settings"),
        ]

        for index, (key, label) in enumerate(sections):
            button = QPushButton(label)
            button.setObjectName("NavButton")
            button.setCheckable(True)
            button.setCursor(Qt.CursorShape.PointingHandCursor)

            self._nav_group.addButton(button, index)
            self.nav_buttons[key] = button

            navigation.addWidget(button)

        self._nav_group.idClicked.connect(
            self._on_navigation_changed
        )

        main_layout.addLayout(navigation)

        # Section pages
        self.pages = QStackedWidget()

        self.pages.addWidget(self._create_cooling_page())
        self.pages.addWidget(self._create_keyboard_page())
        self.pages.addWidget(self._create_settings_page())

        main_layout.addWidget(self.pages, 1)

        # Footer
        footer = QLabel("GIGACONTROL  ·  DEVELOPMENT BUILD")
        footer.setObjectName("FooterText")
        footer.setAlignment(Qt.AlignmentFlag.AlignCenter)

        main_layout.addWidget(footer)

    def _create_metric_card(self, title: str, value: str, detail: str):
        card = QFrame()
        card.setObjectName("MetricCard")

        layout = QVBoxLayout(card)
        layout.setContentsMargins(14, 12, 14, 12)
        layout.setSpacing(5)

        title_label = QLabel(title)
        title_label.setObjectName("CardTitle")

        value_label = QLabel(value)
        value_label.setObjectName("MetricValue")

        detail_label = QLabel(detail)
        detail_label.setObjectName("MutedText")
        detail_label.setWordWrap(True)

        layout.addWidget(title_label)
        layout.addWidget(value_label)
        layout.addWidget(detail_label)

        return card

    def _create_cooling_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(0, 8, 0, 0)
        layout.setSpacing(12)

        title = QLabel("Cooling")
        title.setObjectName("SectionTitle")

        description = QLabel(
            "Monitor and manage your laptop cooling system."
        )
        description.setObjectName("MutedText")
        description.setWordWrap(True)

        layout.addWidget(title)
        layout.addWidget(description)

        grid = QGridLayout()
        grid.setSpacing(10)

        grid.addWidget(
            self._create_metric_card(
                "CPU TEMPERATURE",
                "— °C",
                "Waiting for gfan integration",
            ),
            0, 0,
        )

        grid.addWidget(
            self._create_metric_card(
                "GPU TEMPERATURE",
                "— °C",
                "Waiting for gfan integration",
            ),
            0, 1,
        )

        grid.addWidget(
            self._create_metric_card(
                "CPU FAN",
                "— RPM",
                "Fan speed unavailable",
            ),
            1, 0,
        )

        grid.addWidget(
            self._create_metric_card(
                "GPU FAN",
                "— RPM",
                "Fan speed unavailable",
            ),
            1, 1,
        )

        layout.addLayout(grid)

        notice = QLabel(
            "Hardware monitoring is not connected yet."
        )
        notice.setObjectName("InfoBanner")
        notice.setWordWrap(True)

        layout.addWidget(notice)
        layout.addStretch()

        return page

    def _create_keyboard_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(0, 8, 0, 0)
        layout.setSpacing(12)

        title = QLabel("RGB Keyboard")
        title.setObjectName("SectionTitle")

        description = QLabel(
            "Manage your keyboard backlight."
        )
        description.setObjectName("MutedText")

        notice = QLabel(
            "Keyboard controls will appear here.\n\n"
            "The existing gkbd utility will provide the "
            "hardware integration."
        )
        notice.setObjectName("InfoBanner")
        notice.setWordWrap(True)

        layout.addWidget(title)
        layout.addWidget(description)
        layout.addWidget(notice)
        layout.addStretch()

        return page

    def _create_settings_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(0, 8, 0, 0)
        layout.setSpacing(12)

        title = QLabel("Settings")
        title.setObjectName("SectionTitle")

        description = QLabel(
            "Application preferences and behavior."
        )
        description.setObjectName("MutedText")

        defaults = [
            "Start with KDE Plasma — ON by default",
            "Keep running in background — ON by default",
            "Show system tray icon — ON by default",
        ]

        layout.addWidget(title)
        layout.addWidget(description)

        for item in defaults:
            label = QLabel(item)
            label.setObjectName("InfoBanner")
            label.setWordWrap(True)
            layout.addWidget(label)

        note = QLabel(
            "These preferences are planned and are not "
            "configurable yet."
        )
        note.setObjectName("MutedText")
        note.setWordWrap(True)

        layout.addWidget(note)
        layout.addStretch()

        return page

    def show_section(self, section: str):
        """Display the requested section."""
        if section not in self.SECTIONS:
            return

        index = self.SECTIONS[section]

        self.pages.setCurrentIndex(index)
        self.nav_buttons[section].setChecked(True)

    def _on_navigation_changed(self, index: int):
        self.pages.setCurrentIndex(index)

    def show_near(self, tray_geometry):
        """Position the popup near its tray icon."""
        if tray_geometry.isValid() and not tray_geometry.isNull():
            anchor = tray_geometry.center()
            screen = QGuiApplication.screenAt(anchor)
        else:
            screen = QGuiApplication.screenAt(QCursor.pos())

        if screen is None:
            screen = QGuiApplication.primaryScreen()

        if screen is None:
            self.show()
            return

        available = screen.availableGeometry()

        if tray_geometry.isValid() and not tray_geometry.isNull():
            x = tray_geometry.center().x() - self.width() // 2

            space_below = available.bottom() - tray_geometry.bottom()

            if space_below >= self.height() + 16:
                y = tray_geometry.bottom() + 8
            else:
                y = tray_geometry.top() - self.height() - 8
        else:
            cursor = QCursor.pos()
            x = cursor.x() - self.width() // 2
            y = cursor.y() - self.height() // 2

        # Keep the popup inside the available screen area.
        x = max(
            available.left() + 8,
            min(x, available.right() - self.width() - 7),
        )

        y = max(
            available.top() + 8,
            min(y, available.bottom() - self.height() - 7),
        )

        self.move(x, y)
        self.show()
        self.raise_()
        self.activateWindow()
