#!/usr/bin/env python3
"""
Sistema de Metricas de Escrita
Analisa todo o conteudo real do projeto e rastreia progresso automaticamente.
"""

import json
import re
import sys
from pathlib import Path
from datetime import datetime, date, timedelta
from typing import Dict, List

import os as _os

# Raiz do livro ativo: definida por scripts/lib/common.sh (BOOK_PROJECT_ROOT).
# Sem a variavel, cai no comportamento antigo (pasta acima deste arquivo).
PLATFORM_ROOT = Path(_os.environ.get("BOOK_PLATFORM_ROOT", Path(__file__).parent.parent))
PROJECT_ROOT = Path(_os.environ.get("BOOK_PROJECT_ROOT", Path(__file__).parent.parent))
CACHE_DIR = Path(_os.environ.get("BOOK_CACHE_DIR", PROJECT_ROOT / ".ai" / "cache"))
SNAPSHOTS_FILE = CACHE_DIR / "word_snapshots.json"

# Cores -- desabilita automaticamente se stdout nao for terminal
_USE_COLOR = hasattr(sys.stdout, 'isatty') and sys.stdout.isatty()

if _USE_COLOR:
    C_RESET = "\033[0m"
    C_BOLD = "\033[1m"
    C_CYAN = "\033[36m"
    C_GREEN = "\033[32m"
    C_YELLOW = "\033[33m"
    C_RED = "\033[31m"
    C_MAGENTA = "\033[35m"
    C_DIM = "\033[2m"
else:
    C_RESET = C_BOLD = C_CYAN = C_GREEN = C_YELLOW = ""
    C_RED = C_MAGENTA = C_DIM = ""


def styled(text, *codes):
    if not _USE_COLOR:
        return str(text)
    return f"{''.join(codes)}{text}{C_RESET}"


def count_words(text):
    """Conta palavras reais (ignora markdown/YAML)."""
    text = re.sub(r'^---\n.*?\n---\n', '', text, flags=re.DOTALL)
    text = re.sub(r'^#+\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'\*\*|__|\*|_|`', '', text)
    return len(re.findall(r'\b\w+\b', text))


def read_all_texts():
    """Le todo o conteudo real do projeto."""
    result = {
        "personagens": {},
        "cenas": {},
        "capitulos": {},
        "notas": {},
    }

    dirs = {
        "personagens": PROJECT_ROOT / "01_personagens",
        "cenas": PROJECT_ROOT / "02_cenas",
        "capitulos": PROJECT_ROOT / "03_capitulos",
        "notas": PROJECT_ROOT / "00_notas",
    }

    for category, d in dirs.items():
        if not d.exists():
            continue
        for f in sorted(d.iterdir()):
            if f.is_file():
                try:
                    text = f.read_text(encoding="utf-8").strip()
                    if len(text) > 20:
                        result[category][f.name] = {
                            "words": count_words(text),
                            "text": text
                        }
                except Exception:
                    pass

    return result


def analyze_composition(texts):
    """Analisa composicao do texto (dialogo, narracao, acao)."""
    all_text = ""
    for category in texts.values():
        for file_data in category.values():
            all_text += file_data["text"] + "\n"

    if not all_text.strip():
        return {"dialogo": 0, "narracao": 0, "acao": 0}

    lines = [l.strip() for l in all_text.split("\n") if l.strip()]
    total_lines = len(lines) if lines else 1

    # Dialogo: linhas com travessao ou aspas
    dialog_lines = sum(1 for l in lines if l.startswith(chr(8212)) or l.startswith(chr(8211)) or l.startswith('"'))

    # Acao: linhas com verbos de movimento
    action_pattern = re.compile(
        r'\b(correu|saltou|gritou|atacou|moveu|puxou|empurrou|lancou|'
        r'sacou|atravessou|golpeou|fugiu|caiu|levantou|ergueu|'
        r'agarrou|jogou|bateu|quebrou|cortou|abriu|fechou)\b',
        re.IGNORECASE
    )
    action_lines = sum(1 for l in lines if action_pattern.search(l))

    narration_lines = total_lines - dialog_lines - action_lines
    if narration_lines < 0:
        narration_lines = 0

    total = dialog_lines + action_lines + narration_lines
    return {
        "dialogo": round(dialog_lines / total * 100) if total else 0,
        "narracao": round(narration_lines / total * 100) if total else 0,
        "acao": round(action_lines / total * 100) if total else 0,
    }


def take_snapshot(texts):
    """Salva snapshot de contagem de palavras para tracking de progresso."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    snapshots = []
    if SNAPSHOTS_FILE.exists():
        try:
            snapshots = json.loads(SNAPSHOTS_FILE.read_text(encoding="utf-8"))
        except Exception:
            snapshots = []

    today = date.today().isoformat()

    # Calcular totais por categoria
    totals = {}
    for category, files in texts.items():
        totals[category] = sum(f["words"] for f in files.values())
    totals["total"] = sum(v for k, v in totals.items() if k != "total")

    # Detalhes por arquivo
    file_details = {}
    for category, files in texts.items():
        for fname, fdata in files.items():
            file_details[f"{category}/{fname}"] = fdata["words"]

    # Verificar se ja existe snapshot hoje
    existing_today = None
    for i, snap in enumerate(snapshots):
        if snap["date"] == today:
            existing_today = i
            break

    entry = {
        "date": today,
        "timestamp": datetime.now().isoformat(),
        "totals": totals,
        "files": file_details,
    }

    if existing_today is not None:
        snapshots[existing_today] = entry
    else:
        snapshots.append(entry)

    SNAPSHOTS_FILE.write_text(json.dumps(snapshots, indent=2, ensure_ascii=False), encoding="utf-8")
    return snapshots


def calculate_streak(snapshots):
    """Calcula dias seguidos com escrita."""
    if not snapshots:
        return 0

    dates = sorted(set(s["date"] for s in snapshots), reverse=True)
    if not dates:
        return 0

    streak = 0
    today = date.today()

    for d_str in dates:
        d = date.fromisoformat(d_str)
        expected = today - timedelta(days=streak)
        if d == expected:
            streak += 1
        elif streak == 0 and d == today - timedelta(days=1):
            streak += 1
        else:
            break

    return streak


def words_today(snapshots):
    """Palavras escritas hoje vs ontem/ultimo snapshot."""
    today_str = date.today().isoformat()
    today_total = None
    prev_total = None

    for snap in reversed(snapshots):
        if snap["date"] == today_str:
            today_total = snap["totals"].get("total", 0)
        elif today_total is not None and prev_total is None:
            prev_total = snap["totals"].get("total", 0)
            break

    if today_total is None:
        return 0
    if prev_total is None:
        return 0

    diff = today_total - prev_total
    return max(diff, 0)


def print_dashboard(texts, snapshots):
    """Imprime dashboard completo de metricas."""
    width = 60

    print()
    print(styled("=" * width, C_CYAN))
    print(styled("  >> Dashboard de Metricas de Escrita", C_BOLD, C_CYAN))
    print(styled("=" * width, C_CYAN))

    # Totais por categoria
    print(f"\n  {styled('CONTAGEM POR SECAO', C_BOLD, C_YELLOW)}")
    grand_total = 0
    for category in ["personagens", "cenas", "capitulos", "notas"]:
        files = texts[category]
        cat_total = sum(f["words"] for f in files.values())
        grand_total += cat_total
        n = len(files)
        label = category.title()
        print(f"    {styled('>', C_GREEN)} {label}: {styled(str(n), C_BOLD)} arquivo(s), {styled(str(cat_total), C_BOLD)} palavras")
        for fname, fdata in sorted(files.items(), key=lambda x: -x[1]["words"]):
            print(f"      {styled('.', C_DIM)} {fname}: {fdata['words']} palavras")

    print(f"\n    {styled('Total:', C_BOLD, C_CYAN)} {styled(str(grand_total), C_BOLD, C_CYAN)} palavras")

    # Composicao
    comp = analyze_composition(texts)
    print(f"\n  {styled('COMPOSICAO NARRATIVA', C_BOLD, C_YELLOW)}")
    bar_width = 20
    for label, pct in [("Dialogo", comp["dialogo"]), ("Narracao", comp["narracao"]), ("Acao", comp["acao"])]:
        filled = int(pct / 100 * bar_width)
        bar = styled("#" * filled, C_GREEN) + styled("." * (bar_width - filled), C_DIM)
        print(f"    {label:10s} {bar} {pct}%")

    # Progresso
    print(f"\n  {styled('PROGRESSO', C_BOLD, C_YELLOW)}")
    streak = calculate_streak(snapshots)
    today_w = words_today(snapshots)
    total_snapshots = len(snapshots)

    print(f"    {styled('>', C_GREEN)} Streak atual: {styled(f'{streak} dia(s)', C_BOLD)}")
    print(f"    {styled('>', C_GREEN)} Palavras hoje: {styled(str(today_w), C_BOLD)}")
    print(f"    {styled('>', C_GREEN)} Snapshots registrados: {total_snapshots}")

    if len(snapshots) >= 2:
        first = snapshots[0]["totals"].get("total", 0)
        last = snapshots[-1]["totals"].get("total", 0)
        growth = last - first
        days = len(set(s["date"] for s in snapshots))
        avg = growth / max(days, 1)
        print(f"    {styled('>', C_GREEN)} Media diaria: {styled(f'{avg:.0f} palavras/dia', C_BOLD)}")

    # Ultimos snapshots
    if snapshots:
        print(f"\n  {styled('HISTORICO RECENTE', C_BOLD, C_YELLOW)}")
        recent = snapshots[-7:]
        for snap in recent:
            d = snap["date"]
            t = snap["totals"].get("total", 0)
            print(f"    {styled('.', C_DIM)} {d}: {t} palavras total")

    print()
    print(styled("=" * width, C_CYAN))
    print(styled(f"  Snapshot salvo: {datetime.now().strftime('%Y-%m-%d %H:%M')}", C_DIM))
    print(styled("=" * width, C_CYAN))
    print()


def main():
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    texts = read_all_texts()
    snapshots = take_snapshot(texts)

    if len(sys.argv) > 1 and sys.argv[1] == "--json":
        # Output JSON para uso programatico
        totals = {}
        for cat, files in texts.items():
            totals[cat] = sum(f["words"] for f in files.values())
        totals["total"] = sum(v for k, v in totals.items() if k != "total")
        print(json.dumps(totals, indent=2))
    else:
        print_dashboard(texts, snapshots)


if __name__ == "__main__":
    main()
