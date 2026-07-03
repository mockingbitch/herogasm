#!/usr/bin/env python3
"""Slice rock-tileset.png into individual sprites for Godot import.

Usage:
  python3 game/tools/slice_rock_tileset.py
  python3 game/tools/slice_rock_tileset.py --input path/to/rock-tileset.png --out game/assets/tilesets/rocks
"""

from __future__ import annotations

import argparse
import json
import shutil
from collections import deque
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image


@dataclass(frozen=True)
class Band:
    key: str
    y0: int
    y1: int
    min_area: int


@dataclass(frozen=True)
class Column:
    key: str
    x0: int
    x1: int


BANDS: list[Band] = [
    Band("pebble", 100, 220, 200),
    Band("stone", 228, 372, 400),
    Band("big-rock", 379, 530, 500),
    Band("crystal-rock", 537, 688, 450),
    Band("moss-rock", 695, 847, 450),
]

COLUMNS: list[Column] = [
    Column("icon", 120, 210),
    Column("small", 210, 430),
    Column("medium", 430, 720),
    Column("large", 720, 980),
    Column("cluster", 980, 1180),
    Column("scatter", 1180, 1520),
]

GROUND_TILES: list[tuple[str, int, int, int, int]] = [
    ("grass", 500, 865, 565, 940),
    ("dirt", 565, 865, 650, 940),
    ("sand", 650, 865, 705, 940),
    ("snow", 705, 865, 875, 940),
    ("swamp", 875, 865, 915, 940),
    ("stone-floor", 915, 865, 1015, 940),
    ("cliff-edge", 1015, 865, 1505, 940),
]

COLOR_TILES: list[tuple[str, int, int, int, int]] = [
    ("gray", 60, 945, 150, 985),
    ("tan", 152, 945, 285, 985),
    ("brown", 288, 945, 423, 985),
    ("basalt", 426, 945, 560, 985),
    ("mossy", 564, 945, 698, 985),
    ("purple", 703, 945, 760, 985),
]


def is_bg(r: int, g: int, b: int, a: int = 255) -> bool:
    if a < 8:
        return True
    if r < 40 and g < 40 and b < 45:
        return True
    # Gold label text in the sheet header.
    if r > 150 and g > 120 and b < 80:
        return True
    return False


def find_components(
    image: Image.Image,
    x0: int,
    y0: int,
    x1: int,
    y1: int,
    min_area: int,
) -> list[dict]:
    px = image.load()
    w = x1 - x0 + 1
    h = y1 - y0 + 1
    visited = [[False] * w for _ in range(h)]
    comps: list[dict] = []

    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            lx = x - x0
            ly = y - y0
            if visited[ly][lx] or is_bg(*px[x, y]):
                continue

            q: deque[tuple[int, int]] = deque([(x, y)])
            visited[ly][lx] = True
            minx = maxx = x
            miny = maxy = y
            area = 0

            while q:
                cx, cy = q.popleft()
                area += 1
                minx = min(minx, cx)
                maxx = max(maxx, cx)
                miny = min(miny, cy)
                maxy = max(maxy, cy)
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = cx + dx, cy + dy
                    if x0 <= nx <= x1 and y0 <= ny <= y1:
                        nlx, nly = nx - x0, ny - y0
                        if not visited[nly][nlx] and not is_bg(*px[nx, ny]):
                            visited[nly][nlx] = True
                            q.append((nx, ny))

            bw = maxx - minx + 1
            bh = maxy - miny + 1
            if area >= min_area and bw >= 8 and bh >= 8:
                comps.append(
                    {
                        "x0": minx,
                        "y0": miny,
                        "x1": maxx,
                        "y1": maxy,
                        "area": area,
                        "cx": (minx + maxx) * 0.5,
                        "cy": (miny + maxy) * 0.5,
                    }
                )

    comps.sort(key=lambda c: (c["y0"], c["x0"]))
    return comps


def column_for(cx: float) -> str | None:
    for col in COLUMNS:
        if col.x0 <= cx <= col.x1:
            return col.key
    return None


def split_by_x_gaps(image: Image.Image, comp: dict, min_run: int = 6, min_width: int = 14) -> list[dict]:
    """Split a wide component into individual sprites using vertical empty columns."""
    x0, y0, x1, y1 = comp["x0"], comp["y0"], comp["x1"], comp["y1"]
    if x1 - x0 < 90:
        return [comp]

    px = image.load()
    width = x1 - x0 + 1
    col_fill = []
    for x in range(x0, x1 + 1):
        filled = 0
        for y in range(y0, y1 + 1):
            if not is_bg(*px[x, y]):
                filled += 1
        col_fill.append(filled)

    segments: list[tuple[int, int]] = []
    start: int | None = None
    empty = 0
    for i, filled in enumerate(col_fill):
        x = x0 + i
        if filled >= 2:
            if start is None:
                start = x
            empty = 0
        else:
            empty += 1
            if start is not None and empty >= min_run:
                end = x - empty
                if end - start + 1 >= min_width:
                    segments.append((start, end))
                start = None
                empty = 0
    if start is not None and x1 - start + 1 >= min_width:
        segments.append((start, x1))

    if len(segments) <= 1:
        return [comp]

    out: list[dict] = []
    for sx0, sx1 in segments:
        out.append(
            {
                "x0": sx0,
                "y0": y0,
                "x1": sx1,
                "y1": y1,
                "area": comp["area"],
                "cx": (sx0 + sx1) * 0.5,
                "cy": comp["cy"],
            }
        )
    return out


def merge_nearby(comps: Iterable[dict], gap: int = 36) -> list[dict]:
    items = list(comps)
    if not items:
        return []

    merged: list[dict] = []
    used = [False] * len(items)

    for i, a in enumerate(items):
        if used[i]:
            continue
        group = [a]
        used[i] = True
        changed = True
        while changed:
            changed = False
            for j, b in enumerate(items):
                if used[j]:
                    continue
                for g in group:
                    hx_gap = max(0, max(g["x0"], b["x0"]) - min(g["x1"], b["x1"]) - 1)
                    vy_overlap = min(g["y1"], b["y1"]) - max(g["y0"], b["y0"])
                    if hx_gap <= gap and vy_overlap > -8:
                        group.append(b)
                        used[j] = True
                        changed = True
                        break

        x0 = min(g["x0"] for g in group)
        y0 = min(g["y0"] for g in group)
        x1 = max(g["x1"] for g in group)
        y1 = max(g["y1"] for g in group)
        merged.append(
            {
                "x0": x0,
                "y0": y0,
                "x1": x1,
                "y1": y1,
                "area": sum(g["area"] for g in group),
                "cx": (x0 + x1) * 0.5,
                "cy": (y0 + y1) * 0.5,
            }
        )

    merged.sort(key=lambda c: (c["y0"], c["x0"]))
    return merged


def crop_sprite(image: Image.Image, box: tuple[int, int, int, int], pad: int = 1) -> Image.Image:
    x0, y0, x1, y1 = box
    x0 = max(0, x0 - pad)
    y0 = max(0, y0 - pad)
    x1 = min(image.width - 1, x1 + pad)
    y1 = min(image.height - 1, y1 + pad)
    return image.crop((x0, y0, x1 + 1, y1 + 1))


def save_sprite(
    image: Image.Image,
    out_dir: Path,
    rel_path: str,
    box: tuple[int, int, int, int],
    manifest: list[dict],
    meta: dict,
) -> None:
    sprite = crop_sprite(image, box)
    target = out_dir / rel_path
    target.parent.mkdir(parents=True, exist_ok=True)
    sprite.save(target)

    entry = {
        "id": rel_path.replace("/", "_").replace(".png", ""),
        "path": f"res://assets/tilesets/rocks/{rel_path}",
        "source_box": [box[0], box[1], box[2], box[3]],
        "size": [sprite.width, sprite.height],
        **meta,
    }
    manifest.append(entry)


def slice_main_rows(image: Image.Image, out_dir: Path, manifest: list[dict]) -> None:
    for band in BANDS:
        comps = find_components(image, 120, band.y0, 1500, band.y1, band.min_area)
        by_col: dict[str, list[dict]] = {c.key: [] for c in COLUMNS}

        for comp in comps:
            col = column_for(comp["cx"])
            if col is None:
                continue
            by_col[col].append(comp)

        for col in COLUMNS:
            merged = merge_nearby(by_col[col.key])
            if not merged:
                continue

            if col.key in {"cluster", "scatter"}:
                best = max(merged, key=lambda c: c["area"])
                save_sprite(
                    image,
                    out_dir,
                    f"{band.key}/{col.key}.png",
                    (best["x0"], best["y0"], best["x1"], best["y1"]),
                    manifest,
                    {"category": band.key, "variant": col.key, "type": "rock"},
                )
                continue

            split: list[dict] = []
            for comp in merged:
                split.extend(split_by_x_gaps(image, comp))

            for idx, comp in enumerate(split, start=1):
                save_sprite(
                    image,
                    out_dir,
                    f"{band.key}/{col.key}-{idx:02d}.png",
                    (comp["x0"], comp["y0"], comp["x1"], comp["y1"]),
                    manifest,
                    {"category": band.key, "variant": col.key, "index": idx, "type": "rock"},
                )


def slice_fixed_tiles(
    image: Image.Image,
    out_dir: Path,
    manifest: list[dict],
    tiles: list[tuple[str, int, int, int, int]],
    folder: str,
    tile_type: str,
) -> None:
    for name, x0, y0, x1, y1 in tiles:
        save_sprite(
            image,
            out_dir,
            f"{folder}/{name}.png",
            (x0, y0, x1, y1),
            manifest,
            {"category": folder, "variant": name, "type": tile_type},
        )


def write_godot_loader(out_dir: Path, manifest: list[dict]) -> None:
    lines = [
        "extends RefCounted",
        "class_name RockTilesetCatalog",
        "## Auto-generated by game/tools/slice_rock_tileset.py — do not edit by hand.",
        "",
        "const MANIFEST_PATH := \"res://assets/tilesets/rocks/manifest.json\"",
        "",
        "static func all_paths() -> Array[String]:",
        "\tvar out: Array[String] = []",
        "\tfor e in load_manifest():",
        "\t\tout.append(str(e.get(\"path\", \"\")))",
        "\treturn out",
        "",
        "static func by_category(category: String) -> Array[Dictionary]:",
        "\tvar out: Array[Dictionary] = []",
        "\tfor e in load_manifest():",
        "\t\tif str(e.get(\"category\", \"\")) == category:",
        "\t\t\tout.append(e)",
        "\treturn out",
        "",
        "static func load_manifest() -> Array:",
        "\tvar f := FileAccess.open(MANIFEST_PATH, FileAccess.READ)",
        "\tif f == null:",
        "\t\treturn []",
        "\tvar parsed: Variant = JSON.parse_string(f.get_as_text())",
        "\tif typeof(parsed) != TYPE_DICTIONARY:",
        "\t\treturn []",
        "\tvar sprites = parsed.get(\"sprites\", [])",
        "\treturn sprites if typeof(sprites) == TYPE_ARRAY else []",
        "",
    ]
    (out_dir / "rock_tileset_catalog.gd").write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Slice rock tileset into Godot-ready sprites.")
    parser.add_argument(
        "--input",
        default="images/water-tileset/rock-tileset.png",
        help="Source tileset image",
    )
    parser.add_argument(
        "--out",
        default="game/assets/tilesets/rocks",
        help="Output directory inside game assets",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[2]
    src = (repo_root / args.input).resolve()
    out_dir = (repo_root / args.out).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    image = Image.open(src).convert("RGBA")
    manifest: list[dict] = []

    slice_main_rows(image, out_dir, manifest)
    slice_fixed_tiles(image, out_dir, manifest, GROUND_TILES, "ground-integration", "ground")
    slice_fixed_tiles(image, out_dir, manifest, COLOR_TILES, "color-variations", "palette")

    shutil.copy2(src, out_dir / "rock-tileset-source.png")

    manifest_doc = {
        "source": str(src.relative_to(repo_root)),
        "source_size": [image.width, image.height],
        "sprite_count": len(manifest),
        "categories": sorted({m["category"] for m in manifest}),
        "sprites": manifest,
    }
    (out_dir / "manifest.json").write_text(
        json.dumps(manifest_doc, indent=2),
        encoding="utf-8",
    )
    write_godot_loader(out_dir, manifest)

    print(f"Sliced {len(manifest)} sprites -> {out_dir}")


if __name__ == "__main__":
    main()
