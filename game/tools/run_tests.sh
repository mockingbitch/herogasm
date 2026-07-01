#!/usr/bin/env bash
# Chạy test headless (cổng Run & Test P0). Exit 0 = pass, 1 = fail.
# Override binary: GODOT=/path/to/godot ./tools/run_tests.sh
set -euo pipefail

GODOT="${GODOT:-/home/phongtq/Downloads/Godot_v4.7-stable_linux.x86_64}"
GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Import trước để đăng ký class_name mới (tránh stale global class cache).
"$GODOT" --headless --path "$GAME_DIR" --import >/dev/null 2>&1 || true
exec "$GODOT" --headless --path "$GAME_DIR" res://tests/test_runner.tscn
