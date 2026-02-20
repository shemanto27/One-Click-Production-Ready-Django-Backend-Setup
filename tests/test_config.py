"""Tests for config module"""

from one_click_drf.config import load_config, save_config


def test_save_and_load_config(tmp_path, monkeypatch):
    """Test saving and loading configuration"""
    config_file = tmp_path / "config.toml"
    monkeypatch.setattr("one_click_drf.config.CONFIG_FILE", config_file)
    monkeypatch.setattr("one_click_drf.config.CONFIG_DIR", tmp_path)

    save_config("testuser", "dockeruser")

    config = load_config()
    assert config["user"]["github_username"] == "testuser"
    assert config["user"]["dockerhub_username"] == "dockeruser"


def test_load_config_missing_file(tmp_path, monkeypatch):
    """Test loading config when file doesn't exist"""
    config_file = tmp_path / "nonexistent.toml"
    monkeypatch.setattr("one_click_drf.config.CONFIG_FILE", config_file)

    config = load_config()
    assert config == {}
