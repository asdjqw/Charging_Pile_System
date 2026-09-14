"""Load prediction configuration through the required PyYAML dependency."""

from pathlib import Path
import yaml

from ml.errors import ErrorCode, MLSubsystemError

__all__ = ["load_config"]

DEFAULT_CONFIG_PATH = Path(__file__).with_name("default.yaml")


def load_config(path=None):
    try:
        config_path = Path(path) if path else DEFAULT_CONFIG_PATH
        config = yaml.safe_load(config_path.read_text(encoding="utf-8"))
    except (OSError, yaml.YAMLError) as error:
        raise MLSubsystemError(ErrorCode.CONFIG_ERROR, "Cannot read prediction configuration.") from error
    if not isinstance(config, dict):
        raise MLSubsystemError(ErrorCode.CONFIG_ERROR, "Configuration must be a mapping.")

    artifacts = config.get("artifacts")
    prediction = config.get("prediction")
    if not isinstance(artifacts, dict) or not isinstance(prediction, dict):
        raise MLSubsystemError(ErrorCode.CONFIG_ERROR, "artifacts and prediction must be mappings.")
    manifest = artifacts.get("current_freeze_manifest")
    history_hours = prediction.get("history_window_hours")
    if not isinstance(manifest, str) or not manifest.strip():
        raise MLSubsystemError(ErrorCode.CONFIG_ERROR, "current_freeze_manifest must be a nonempty path.")
    if type(history_hours) is not int or history_hours < 25:
        raise MLSubsystemError(ErrorCode.CONFIG_ERROR, "history_window_hours must be an integer >= 25.")
    return config
