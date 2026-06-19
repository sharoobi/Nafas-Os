from __future__ import annotations

import argparse
import csv
import random
from pathlib import Path

import numpy as np
import tensorflow as tf


LABELS = [
    "warming_up",
    "lighter_like_pattern",
    "restless_window",
    "steady_breathing",
    "cough_stress",
    "high_arousal_audio",
    "ambient_or_unclear",
]


def clamp(value: float) -> float:
    return float(max(0.0, min(1.0, value)))


def sample_for_label(index: int) -> list[float]:
    if index == 0:
        return [
            random.uniform(0.0, 0.18),
            random.uniform(0.0, 0.08),
            random.uniform(0.0, 0.08),
            random.uniform(0.0, 0.12),
            random.uniform(0.0, 0.10),
            random.uniform(0.02, 0.16),
            random.uniform(0.04, 0.22),
            random.uniform(0.02, 0.12),
        ]
    if index == 1:
        return [
            random.uniform(0.45, 0.92),
            random.uniform(0.36, 1.00),
            random.uniform(0.00, 0.24),
            random.uniform(0.00, 0.18),
            random.uniform(0.08, 0.44),
            random.uniform(0.20, 0.68),
            random.uniform(0.58, 1.00),
            random.uniform(0.20, 1.00),
        ]
    if index == 2:
        return [
            random.uniform(0.28, 0.72),
            random.uniform(0.00, 0.18),
            random.uniform(0.00, 0.18),
            random.uniform(0.00, 0.18),
            random.uniform(0.34, 0.96),
            random.uniform(0.16, 0.54),
            random.uniform(0.40, 0.84),
            random.uniform(0.25, 1.00),
        ]
    if index == 3:
        return [
            random.uniform(0.00, 0.35),
            random.uniform(0.00, 0.10),
            random.uniform(0.00, 0.14),
            random.uniform(0.42, 1.00),
            random.uniform(0.00, 0.20),
            random.uniform(0.08, 0.30),
            random.uniform(0.14, 0.40),
            random.uniform(0.18, 0.90),
        ]
    if index == 4:
        return [
            random.uniform(0.18, 0.62),
            random.uniform(0.00, 0.16),
            random.uniform(0.30, 1.00),
            random.uniform(0.00, 0.28),
            random.uniform(0.05, 0.36),
            random.uniform(0.16, 0.52),
            random.uniform(0.34, 0.88),
            random.uniform(0.18, 0.92),
        ]
    if index == 5:
        return [
            random.uniform(0.55, 1.00),
            random.uniform(0.00, 0.28),
            random.uniform(0.00, 0.28),
            random.uniform(0.00, 0.24),
            random.uniform(0.16, 0.84),
            random.uniform(0.24, 0.70),
            random.uniform(0.50, 1.00),
            random.uniform(0.28, 1.00),
        ]
    return [
        random.uniform(0.10, 0.44),
        random.uniform(0.00, 0.24),
        random.uniform(0.00, 0.20),
        random.uniform(0.00, 0.30),
        random.uniform(0.00, 0.28),
        random.uniform(0.06, 0.36),
        random.uniform(0.16, 0.56),
        random.uniform(0.18, 0.95),
    ]


def build_dataset(samples_per_label: int = 700) -> tuple[np.ndarray, np.ndarray]:
    features: list[list[float]] = []
    labels: list[int] = []
    for label_index in range(len(LABELS)):
        for _ in range(samples_per_label):
            row = sample_for_label(label_index)
            noisy = [clamp(value + random.uniform(-0.035, 0.035)) for value in row]
            features.append(noisy)
            labels.append(label_index)
    x = np.array(features, dtype=np.float32)
    y = tf.keras.utils.to_categorical(labels, num_classes=len(LABELS))
    permutation = np.random.permutation(len(x))
    x = x[permutation]
    y = y[permutation]
    return x, y


def load_real_dataset(path: Path) -> tuple[np.ndarray, np.ndarray]:
    features: list[list[float]] = []
    labels: list[int] = []
    with path.open("r", encoding="utf-8", newline="") as handle:
      reader = csv.DictReader(handle)
      for row in reader:
          label = (row.get("confirmed_label") or "").strip()
          if not label or label not in LABELS:
              continue
          feature_row = [
              clamp(float(row.get("audio_risk_score", 0) or 0) / 100.0),
              clamp(float(row.get("lighter_like_spikes", 0) or 0) / 6.0),
              clamp(float(row.get("cough_like_bursts", 0) or 0) / 6.0),
              clamp(float(row.get("steady_breath_cycles", 0) or 0) / 8.0),
              clamp(float(row.get("restlessness_bursts", 0) or 0) / 8.0),
              clamp(float(row.get("average_amplitude", 0) or 0) / 32768.0),
              clamp(float(row.get("peak_amplitude", 0) or 0) / 32768.0),
              clamp(float(row.get("sample_count", 0) or 0) / 32.0),
          ]
          features.append(feature_row)
          labels.append(LABELS.index(label))

    if not features:
        return (
            np.zeros((0, 8), dtype=np.float32),
            np.zeros((0, len(LABELS)), dtype=np.float32),
        )
    x = np.array(features, dtype=np.float32)
    y = tf.keras.utils.to_categorical(labels, num_classes=len(LABELS))
    return x, y


def merge_datasets(
    synthetic_x: np.ndarray,
    synthetic_y: np.ndarray,
    real_x: np.ndarray,
    real_y: np.ndarray,
    real_weight: int,
) -> tuple[np.ndarray, np.ndarray]:
    if real_x.size == 0:
        return synthetic_x, synthetic_y
    repeated_x = np.repeat(real_x, real_weight, axis=0)
    repeated_y = np.repeat(real_y, real_weight, axis=0)
    x = np.concatenate([synthetic_x, repeated_x], axis=0)
    y = np.concatenate([synthetic_y, repeated_y], axis=0)
    permutation = np.random.permutation(len(x))
    return x[permutation], y[permutation]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--real-data",
        type=Path,
        default=None,
        help="CSV exported from Nafas OS with confirmed audio labels.",
    )
    parser.add_argument(
        "--real-weight",
        type=int,
        default=6,
        help="How strongly to oversample real labeled sessions.",
    )
    args = parser.parse_args()

    random.seed(42)
    np.random.seed(42)
    tf.random.set_seed(42)

    root = Path(__file__).resolve().parents[1]
    output_dir = root / "assets" / "models"
    output_dir.mkdir(parents=True, exist_ok=True)

    x, y = build_dataset()
    if args.real_data is not None and args.real_data.exists():
        real_x, real_y = load_real_dataset(args.real_data)
        x, y = merge_datasets(x, y, real_x, real_y, max(args.real_weight, 1))
    model = tf.keras.Sequential(
        [
            tf.keras.layers.Input(shape=(8,), name="engineered_audio_features"),
            tf.keras.layers.Dense(24, activation="relu"),
            tf.keras.layers.Dense(24, activation="relu"),
            tf.keras.layers.Dense(len(LABELS), activation="softmax"),
        ]
    )
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.003),
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )
    model.fit(
        x,
        y,
        epochs=18,
        batch_size=64,
        validation_split=0.15,
        verbose=2,
    )

    @tf.function(input_signature=[tf.TensorSpec(shape=[None, 8], dtype=tf.float32)])
    def infer(inputs: tf.Tensor) -> tf.Tensor:
        return model(inputs, training=False)

    concrete_func = infer.get_concrete_function()
    converter = tf.lite.TFLiteConverter.from_concrete_functions([concrete_func])
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()

    (output_dir / "guarded_audio_classifier.tflite").write_bytes(tflite_model)
    (output_dir / "guarded_audio_classifier_labels.txt").write_text(
        "\n".join(LABELS),
        encoding="utf-8",
    )
    print(f"Wrote model to {output_dir / 'guarded_audio_classifier.tflite'}")


if __name__ == "__main__":
    main()
