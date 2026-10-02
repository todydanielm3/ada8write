#!/usr/bin/env python3
"""Gera assets/intro.gif - animacao de abertura do menu.

Uso:
    python3 scripts/make_intro_gif.py

Requer Pillow (pip install pillow). O GIF e opcional: o menu cai para a
animacao ASCII quando o arquivo ou um renderizador de imagem nao existem.
"""
from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:  # pragma: no cover
    sys.exit("Pillow nao encontrado. Instale com: pip3 install pillow")

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "assets" / "intro.gif"

WIDTH, HEIGHT = 640, 240
BG = (13, 17, 23)
FG = (88, 214, 212)
DIM = (110, 118, 129)
ACCENT = (247, 184, 93)
PAPER = (231, 229, 222)

TITLE = "ATELIÊ DE ESCRITA"
SUBTITLE = "projeto de livro · ambiente integrado"

FONT_CANDIDATES = [
    "/System/Library/Fonts/Menlo.ttc",
    "/System/Library/Fonts/SFNSMono.ttf",
    "/Library/Fonts/Arial.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
]


def load_font(size: int):
    for path in FONT_CANDIDATES:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    return ImageFont.load_default()


FONT_TITLE = load_font(34)
FONT_SUB = load_font(16)


def centered(draw: "ImageDraw.ImageDraw", text: str, font, y: int, fill):
    box = draw.textbbox((0, 0), text, font=font)
    draw.text(((WIDTH - (box[2] - box[0])) / 2 - box[0], y), text, font=font, fill=fill)


def draw_book(draw: "ImageDraw.ImageDraw", openness: float, y: int = 150):
    """Desenha um livro que abre: openness vai de 0 (fechado) a 1 (aberto)."""
    cx = WIDTH // 2
    half = int(18 + 76 * openness)
    height = 54
    draw.polygon(
        [(cx, y), (cx - half, y - 16), (cx - half, y + height - 16), (cx, y + height)],
        fill=PAPER,
        outline=FG,
    )
    draw.polygon(
        [(cx, y), (cx + half, y - 16), (cx + half, y + height - 16), (cx, y + height)],
        fill=PAPER,
        outline=FG,
    )
    draw.line([(cx, y), (cx, y + height)], fill=DIM, width=2)
    if openness > 0.55:
        for i in range(3):
            ly = y + 2 + i * 12
            draw.line([(cx - half + 14, ly), (cx - 10, ly - 4)], fill=DIM, width=2)
            draw.line([(cx + 10, ly - 4), (cx + half - 14, ly)], fill=DIM, width=2)


def frame(progress_chars: int, openness: float, cursor_on: bool, glow: bool):
    img = Image.new("RGB", (WIDTH, HEIGHT), BG)
    draw = ImageDraw.Draw(img)

    draw.rectangle([(0, 0), (WIDTH - 1, HEIGHT - 1)], outline=(32, 40, 51))
    draw.line([(24, 34), (WIDTH - 24, 34)], fill=(32, 40, 51))

    shown = TITLE[:progress_chars]
    if cursor_on and progress_chars < len(TITLE):
        shown += "▏"
    centered(draw, shown, FONT_TITLE, 58, ACCENT if glow else FG)

    if progress_chars >= len(TITLE):
        centered(draw, SUBTITLE, FONT_SUB, 104, DIM)

    draw_book(draw, openness)
    return img


def build_frames():
    frames, durations = [], []

    # 1. Livro abrindo
    for i in range(10):
        frames.append(frame(0, i / 9, cursor_on=(i % 2 == 0), glow=False))
        durations.append(60)

    # 2. Titulo sendo digitado
    for i in range(1, len(TITLE) + 1):
        frames.append(frame(i, 1.0, cursor_on=True, glow=False))
        durations.append(55)

    # 3. Pulso final
    for i in range(6):
        frames.append(frame(len(TITLE), 1.0, cursor_on=False, glow=(i % 2 == 0)))
        durations.append(130)

    frames.append(frame(len(TITLE), 1.0, cursor_on=False, glow=False))
    durations.append(900)
    return frames, durations


def main() -> int:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    frames, durations = build_frames()
    frames[0].save(
        OUTPUT,
        save_all=True,
        append_images=frames[1:],
        duration=durations,
        loop=0,
        optimize=True,
    )
    size_kb = OUTPUT.stat().st_size / 1024
    print(f"✓ GIF gerado: {OUTPUT} ({len(frames)} quadros, {size_kb:.0f} KB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
