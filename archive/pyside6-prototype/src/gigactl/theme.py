
"""Theme loading utilities."""

from pathlib import Path


def load_stylesheet() -> str:
    """Load the application QSS stylesheet."""
    theme_path = Path(__file__).parent / "themes" / "tokyo-midnight.qss"

    try:
        return theme_path.read_text(encoding="utf-8")
    except OSError as exc:
        print(f"Warning: could not load application theme: {exc}")
        return ""
