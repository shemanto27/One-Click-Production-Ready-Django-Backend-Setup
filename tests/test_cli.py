"""Tests for CLI commands"""

from typer.testing import CliRunner

from one_click_drf.cli import app

runner = CliRunner()


def test_version_command():
    """Test version command"""
    result = runner.invoke(app, ["version"])
    assert result.exit_code == 0
    assert "one-click-drf" in result.stdout


def test_version_flag():
    """Test --version flag"""
    result = runner.invoke(app, ["--version"])
    assert result.exit_code == 0
    assert "one-click-drf" in result.stdout


def test_help_command():
    """Test help command"""
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0
    assert "Initialize a Production Ready Django REST Framework project" in result.stdout
