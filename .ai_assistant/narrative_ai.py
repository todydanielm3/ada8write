#!/usr/bin/env python3
"""
Assistente de IA para Escrita Criativa
Um observador silencioso que conhece profundamente sua história.

Lê TODO o conteúdo real do projeto: personagens, cenas, capítulos e notas.
Nunca inventa dados — só analisa o que realmente existe.
"""

import os
import json
import sys
import textwrap
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
from openai import OpenAI
from dotenv import load_dotenv

# Paths
# A plataforma guarda a chave da API; cada livro guarda sua propria memoria.
# scripts/lib/common.sh exporta BOOK_PROJECT_ROOT / BOOK_CACHE_DIR / BOOK_PLATFORM_ROOT.
PLATFORM_ROOT = Path(os.environ.get("BOOK_PLATFORM_ROOT", Path(__file__).parent.parent))
PROJECT_ROOT = Path(os.environ.get("BOOK_PROJECT_ROOT", Path(__file__).parent.parent))
ENV_PATH = PLATFORM_ROOT / ".ai_assistant" / ".env"
CACHE_DIR = Path(os.environ.get("BOOK_CACHE_DIR", PROJECT_ROOT / ".ai" / "cache"))

load_dotenv(ENV_PATH)

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

# Cores para output — desativa automaticamente se nao for terminal
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
    C_RESET = C_BOLD = C_CYAN = C_GREEN = C_YELLOW = C_RED = C_MAGENTA = C_DIM = ""

WIDTH = 62


def styled(text, *codes):
    if not _USE_COLOR:
        return str(text)
    return f"{''.join(codes)}{text}{C_RESET}"


# ─── Leitores de conteúdo ────────────────────────────────────────────

def read_all_content() -> Dict:
    """Lê TODO o conteúdo real do projeto, sem filtros."""
    content = {
        "personagens": [],
        "cenas": [],
        "capitulos": [],
        "notas": [],
    }

    # Personagens
    chars_dir = PROJECT_ROOT / "01_personagens"
    if chars_dir.exists():
        for f in sorted(chars_dir.iterdir()):
            if not f.is_file():
                continue
            try:
                text = f.read_text(encoding="utf-8").strip()
                if len(text) > 20:
                    content["personagens"].append({
                        "arquivo": f.name,
                        "nome": f.stem,
                        "texto": text
                    })
            except Exception:
                pass

    # Cenas (incluir arquivos sem extensão também)
    cenas_dir = PROJECT_ROOT / "02_cenas"
    if cenas_dir.exists():
        for f in sorted(cenas_dir.iterdir()):
            if f.is_file():
                try:
                    text = f.read_text(encoding="utf-8").strip()
                    if len(text) > 20:
                        content["cenas"].append({
                            "arquivo": f.name,
                            "nome": f.stem,
                            "texto": text
                        })
                except Exception:
                    pass

    # Capítulos (incluir TUDO, inclusive exemplos)
    caps_dir = PROJECT_ROOT / "03_capitulos"
    if caps_dir.exists():
        for f in sorted(caps_dir.iterdir()):
            if f.is_file():
                try:
                    text = f.read_text(encoding="utf-8").strip()
                    if len(text) > 20:
                        content["capitulos"].append({
                            "arquivo": f.name,
                            "nome": f.stem,
                            "texto": text
                        })
                except Exception:
                    pass

    # Notas
    notas_dir = PROJECT_ROOT / "00_notas"
    if notas_dir.exists():
        for f in sorted(notas_dir.iterdir()):
            if f.is_file():
                try:
                    text = f.read_text(encoding="utf-8").strip()
                    if len(text) > 20:
                        content["notas"].append({
                            "arquivo": f.name,
                            "nome": f.stem,
                            "texto": text
                        })
                except Exception:
                    pass

    return content


def build_context_prompt(content: Dict) -> str:
    """Monta o contexto completo da história para enviar à IA."""
    parts = []

    if content["personagens"]:
        parts.append("=== PERSONAGENS ===")
        for p in content["personagens"]:
            parts.append(f"\n> {p['nome']} ({p['arquivo']})\n{p['texto']}")

    if content["cenas"]:
        parts.append("\n=== CENAS ===")
        for c in content["cenas"]:
            parts.append(f"\n> {c['nome']} ({c['arquivo']})\n{c['texto']}")

    if content["capitulos"]:
        parts.append("\n=== CAPITULOS ===")
        for ch in content["capitulos"]:
            parts.append(f"\n> {ch['nome']} ({ch['arquivo']})\n{ch['texto']}")

    if content["notas"]:
        parts.append("\n=== NOTAS DO AUTOR ===")
        for n in content["notas"]:
            parts.append(f"\n> {n['nome']} ({n['arquivo']})\n{n['texto']}")

    return "\n".join(parts)


SYSTEM_PROMPT = """Voce eh um assistente de escrita literaria que atua como um "leitor tecnico silencioso".

REGRAS INVIOLAVEIS:
1. Analise APENAS o conteudo que foi fornecido. NUNCA invente capitulos, cenas ou personagens que nao existem.
2. Se nao houver conteudo suficiente para uma analise, diga isso honestamente.
3. Seja CONCISO — maximo 1-2 linhas por item.
4. Nunca reescreva ou sugira texto pronto. Identifique problemas, nao os resolva.
5. Responda sempre em portugues brasileiro.
6. Voce nao eh um co-autor. Voce eh um observador atento.

SOBRE O PROJETO:
- Eh um livro de fantasia com forte carga filosofica
- Esta em estagio inicial de escrita
- O autor escreve em NeoVim usando um workflow tecnico/engenharia"""


def call_ai(user_prompt: str, json_mode: bool = True) -> Dict:
    """Chama a API OpenAI com o contexto do projeto."""
    try:
        kwargs = {
            "model": MODEL,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_prompt}
            ],
            "temperature": 0.3,
        }
        if json_mode:
            kwargs["response_format"] = {"type": "json_object"}

        response = client.chat.completions.create(**kwargs)
        text = response.choices[0].message.content.strip()

        if json_mode:
            return json.loads(text)
        else:
            return {"text": text}

    except Exception as e:
        return {"error": str(e)}


# ─── Funções de análise ──────────────────────────────────────────────

def analyze_consistency(content: Dict, extra_text: str = "") -> Dict:
    """Analisa inconsistências reais no conteúdo existente."""
    ctx = build_context_prompt(content)
    if not ctx.strip():
        return {"error": "Nenhum conteudo encontrado para analisar."}

    extra = ""
    if extra_text:
        extra = f"\n\nTEXTO ADICIONAL PARA VERIFICAR:\n{extra_text}"

    prompt = f"""Analise o conteudo abaixo e identifique inconsistencias REAIS.

{ctx}{extra}

Procure especificamente por:
1. Nomes de lugares que mudam de grafia (ex: mesma cidade com nomes diferentes)
2. Tracos de personalidade que se contradizem entre arquivos
3. Eventos que se contradizem entre cenas
4. Detalhes fisicos ou contextuais inconsistentes
5. Arcos narrativos iniciados mas sem evolucao

Responda em JSON:
{{
    "inconsistencies": [
        {{"tipo": "tipo", "detalhe": "descricao precisa com referencia ao arquivo", "severidade": "alta|media|baixa"}}
    ],
    "narrative_gaps": [
        {{"gap": "descricao", "sugestao": "pergunta para o autor refletir"}}
    ],
    "character_coherence": [
        {{"personagem": "nome", "observacao": "o que esta coerente ou nao"}}
    ]
}}

Se algo nao se aplica, retorne lista vazia. NAO invente problemas."""

    return call_ai(prompt)


def analyze_pacing(content: Dict) -> Dict:
    """Analisa ritmo narrativo do conteúdo existente."""
    ctx = build_context_prompt(content)
    if not ctx.strip():
        return {"error": "Nenhum conteudo encontrado para analisar."}

    prompt = f"""Analise o ritmo narrativo do conteudo abaixo.

{ctx}

Identifique:
1. Cenas/trechos mais lentos (muita exposicao, pouca acao)
2. Cenas/trechos mais rapidos (acao intensa, dialogo vivo)
3. Proporcao de dialogo vs. narracao vs. acao
4. Onde o ritmo poderia melhorar

Responda em JSON:
{{
    "ritmo_geral": "descricao em 1-2 linhas",
    "secoes_lentas": [{{"local": "arquivo/trecho", "motivo": "razao"}}],
    "secoes_rapidas": [{{"local": "arquivo/trecho", "motivo": "razao"}}],
    "proporcao": {{"dialogo": "X%", "narracao": "X%", "acao": "X%"}},
    "sugestoes": ["pergunta reflexiva para o autor"]
}}

Analise APENAS o que existe. Se ha pouco conteudo, diga isso."""

    return call_ai(prompt)


def detect_repetitions(content: Dict) -> Dict:
    """Detecta padrões repetitivos reais na narrativa."""
    ctx = build_context_prompt(content)
    if not ctx.strip():
        return {"error": "Nenhum conteudo encontrado para analisar."}

    prompt = f"""Identifique repeticoes narrativas no conteudo abaixo.

{ctx}

Detecte:
1. Palavras ou expressoes usadas demais
2. Estruturas de cena similares
3. Mesma dinamica de personagem sendo repetida
4. Mesma funcao dramatica em dialogos diferentes

Responda em JSON:
{{
    "palavras_repetidas": [{{"palavra": "X", "ocorrencias": "onde aparece"}}],
    "estruturas_similares": [{{"padrao": "descricao", "onde": "arquivos"}}],
    "dinamicas_repetidas": [{{"dinamica": "descricao", "personagens": "quais"}}]
}}

Se ha pouco conteudo para detectar repeticoes, diga isso honestamente."""

    return call_ai(prompt)


def analyze_themes(content: Dict) -> Dict:
    """Analisa coerência temática da obra."""
    ctx = build_context_prompt(content)
    if not ctx.strip():
        return {"error": "Nenhum conteudo encontrado para analisar."}

    prompt = f"""Identifique os temas centrais presentes no conteudo abaixo.

{ctx}

Analise:
1. Quais temas emergem naturalmente do texto
2. Quao fortemente cada tema esta presente
3. Se alguma cena foge do tom geral
4. Onde temas poderiam ser reforcados

Responda em JSON:
{{
    "temas_centrais": [
        {{"tema": "nome", "forca": "forte|emergente|sugerido", "evidencia": "onde aparece"}}
    ],
    "tom_geral": "descricao em 1 linha",
    "desvios_de_tom": [{{"local": "arquivo", "detalhe": "como foge do tom"}}],
    "oportunidades": ["pergunta reflexiva sobre tema que poderia crescer"]
}}"""

    return call_ai(prompt)


def update_memory(content: Dict) -> Dict:
    """Atualiza memória narrativa com base em TODO o conteúdo real."""
    ctx = build_context_prompt(content)
    if not ctx.strip():
        return {"error": "Nenhum conteudo encontrado para analisar."}

    prompt = f"""Crie um resumo estruturado do estado atual desta historia.

{ctx}

Responda em JSON:
{{
    "resumo_geral": "1-2 linhas sobre o que existe ate agora",
    "timeline": [
        {{"evento": "o que acontece", "local": "arquivo/cena", "impacto": "alto|medio|baixo"}}
    ],
    "personagens": [
        {{"nome": "X", "estado_atual": "descricao", "arco": "onde esta no arco", "ultima_aparicao": "arquivo"}}
    ],
    "temas": ["tema identificado"],
    "conflitos_abertos": [{{"conflito": "descricao", "envolvidos": "quem"}}],
    "mundo": {{
        "locais_mencionados": ["lugar (grafia usada)"],
        "regras_do_mundo": ["o que sabemos sobre o universo"]
    }},
    "alertas": ["inconsistencia ou risco identificado"]
}}

Inclua APENAS fatos extraidos do texto. Nao invente nada."""

    result = call_ai(prompt)
    if "error" not in result:
        result["last_updated"] = datetime.now().isoformat()
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        with open(CACHE_DIR / "narrative_memory.json", "w", encoding="utf-8") as f:
            json.dump(result, f, indent=2, ensure_ascii=False)

    return result


def ask_creative_question(content: Dict, scene_text: str = "") -> str:
    """Faz uma pergunta criativa para estimular reflexão."""
    ctx = build_context_prompt(content)

    prompt = f"""Voce eh um mentor de escrita que faz perguntas profundas, nao da respostas.

CONTEXTO DA HISTORIA:
{ctx[:4000]}

CENA ATUAL:
{scene_text if scene_text else "(nenhuma cena especifica)"}

Faca UMA pergunta criativa e provocadora que ajude o autor a pensar mais profundamente.
A pergunta deve ser sobre:
- O que um personagem teme perder neste momento
- Como esta cena muda alguem emocionalmente
- Qual decisao aproxima/afasta do arco final
- O que esta em jogo de verdade

Responda APENAS a pergunta, nada mais. Em portugues."""

    result = call_ai(prompt, json_mode=False)
    return result.get("text", result.get("error", "Erro desconhecido"))


def analyze_scene(scene_path: str) -> Dict:
    """Analisa uma cena específica no contexto geral da história."""
    content = read_all_content()
    ctx = build_context_prompt(content)

    scene_file = Path(scene_path)
    if not scene_file.exists():
        # Tentar encontrar o arquivo
        cenas = PROJECT_ROOT / "02_cenas"
        matches = list(cenas.glob(f"*{scene_path}*"))
        if matches:
            scene_file = matches[0]
        else:
            return {"error": f"Cena '{scene_path}' nao encontrada."}

    scene_text = scene_file.read_text(encoding="utf-8").strip()
    scene_name = scene_file.name

    prompt = f"""Analise esta cena especifica no contexto geral da historia.

CONTEXTO GERAL:
{ctx}

CENA SENDO ANALISADA ({scene_name}):
{scene_text}

Avalie:
1. A cena eh consistente com o que sabemos dos personagens?
2. O tom combina com o restante da narrativa?
3. Ha algo que precisa ser melhor conectado?
4. Qual eh a funcao dramatica desta cena?

Responda em JSON:
{{
    "cena": "{scene_name}",
    "funcao_dramatica": "o que esta cena faz pela historia",
    "consistencia": {{"status": "ok|alerta|problema", "detalhe": "explicacao"}},
    "tom": {{"status": "coerente|divergente", "detalhe": "explicacao"}},
    "conexoes_faltantes": ["o que poderia estar melhor ligado"],
    "pontos_fortes": ["o que funciona bem"],
    "pergunta": "uma pergunta para o autor sobre esta cena"
}}"""

    return call_ai(prompt)


def get_character_quick(name: str) -> str:
    """Busca rápida de personagem pelo nome — para uso durante escrita."""
    chars_dir = PROJECT_ROOT / "01_personagens"
    name_lower = name.lower()

    for f in chars_dir.iterdir():
        if not f.is_file():
            continue
        if name_lower in f.stem.lower():
            text = f.read_text(encoding="utf-8").strip()
            return f">>> {f.stem}\n{'=' * 40}\n{text}"

    # Busca no conteúdo das cenas também
    results = []
    cenas_dir = PROJECT_ROOT / "02_cenas"
    if cenas_dir.exists():
        for f in cenas_dir.iterdir():
            if f.is_file():
                try:
                    text = f.read_text(encoding="utf-8")
                    if name_lower in text.lower():
                        lines = text.split("\n")
                        relevant = [l.strip() for l in lines if name_lower in l.lower()]
                        results.append(f"Em {f.name}: {' | '.join(relevant[:3])}")
                except Exception:
                    pass

    if results:
        return f"'{name}' encontrado em cenas:\n" + "\n".join(results)

    return f"Personagem '{name}' nao encontrado."


# ─── Formatação de output ────────────────────────────────────────────

def _wrap(text: str, indent: int = 6, width: int = WIDTH) -> str:
    """Quebra texto longo em várias linhas com indentação."""
    prefix = " " * indent
    return textwrap.fill(str(text), width=width,
                         initial_indent="", subsequent_indent=prefix)


def _severity_label(sev: str) -> str:
    """Retorna label colorido para severidade."""
    s = sev.lower().strip()
    if s == "alta":
        return styled(" ALTA ", C_BOLD, C_RED)
    elif s in ("media", "média"):
        return styled(" MED  ", C_BOLD, C_YELLOW)
    else:
        return styled(" BAIXA", C_DIM)


def _status_label(status: str) -> str:
    """Retorna label colorido para status."""
    s = status.lower().strip()
    if s in ("ok", "coerente"):
        return styled("OK", C_GREEN, C_BOLD)
    elif s in ("alerta", "divergente"):
        return styled("ALERTA", C_YELLOW, C_BOLD)
    else:
        return styled("PROBLEMA", C_RED, C_BOLD)


def print_header(title: str):
    line = styled("─" * WIDTH, C_CYAN)
    print(f"\n{line}")
    print(styled(f"  {title}", C_BOLD, C_CYAN))
    print(f"{line}\n")


def print_section(title: str):
    print(f"  {styled(title, C_BOLD, C_YELLOW)}")
    print(f"  {styled('─' * (len(title) + 2), C_DIM)}")


def print_error(data: Dict):
    if "error" in data:
        print(f"  {styled('ERRO:', C_RED, C_BOLD)} {data['error']}\n")
        return True
    return False


def print_item(label: str, value: str, indent: int = 4):
    pad = " " * indent
    wrapped = _wrap(str(value), indent=indent + len(label) + 2)
    print(f"{pad}{styled(label, C_BOLD)} {wrapped}")


def print_bullet(text: str, indent: int = 6):
    pad = " " * indent
    wrapped = _wrap(str(text), indent=indent + 2)
    print(f"{pad}{styled('•', C_GREEN)} {wrapped}")


# ─── Formatadores específicos ────────────────────────────────────────

def format_consistency(data: Dict):
    """Formata resultado de análise de consistência."""
    if print_error(data):
        return

    # Inconsistências
    items = data.get("inconsistencies", [])
    print_section("INCONSISTÊNCIAS ENCONTRADAS")
    if not items:
        print(f"      {styled('Nenhuma inconsistência detectada.', C_DIM)}\n")
    else:
        for i, item in enumerate(items, 1):
            sev = _severity_label(item.get("severidade", "baixa"))
            tipo = item.get("tipo", "geral")
            detalhe = item.get("detalhe", "")
            print(f"\n    {sev}  {styled(tipo.upper(), C_BOLD)}")
            print(f"          {_wrap(detalhe, indent=10)}")
        print()

    # Gaps narrativos
    gaps = data.get("narrative_gaps", [])
    if gaps:
        print_section("LACUNAS NARRATIVAS")
        for g in gaps:
            gap = g.get("gap", "")
            sug = g.get("sugestao", "")
            print(f"    {styled('Gap:', C_BOLD)} {_wrap(gap, indent=10)}")
            if sug:
                print(f"         {styled('?', C_YELLOW)} {_wrap(sug, indent=11)}")
            print()

    # Coerência de personagens
    chars = data.get("character_coherence", [])
    if chars:
        print_section("COERÊNCIA DE PERSONAGENS")
        for c in chars:
            nome = c.get("personagem", "?")
            obs = c.get("observacao", "")
            print(f"    {styled(nome + ':', C_BOLD, C_MAGENTA)} {_wrap(obs, indent=4+len(nome)+2)}")
        print()


def format_pacing(data: Dict):
    """Formata resultado de análise de ritmo."""
    if print_error(data):
        return

    # Ritmo geral
    ritmo = data.get("ritmo_geral", "")
    if ritmo:
        print_item("Ritmo geral:", ritmo)
        print()

    # Proporção
    prop = data.get("proporcao", {})
    if prop:
        print_section("PROPORÇÃO")
        bar_w = 20
        for label, key in [("Diálogo", "dialogo"), ("Narração", "narracao"), ("Ação", "acao")]:
            val = prop.get(key, "0%")
            try:
                pct = int(str(val).replace("%", "").strip())
            except ValueError:
                pct = 0
            filled = int(pct / 100 * bar_w)
            bar = styled("█" * filled, C_GREEN) + styled("░" * (bar_w - filled), C_DIM)
            print(f"      {label:10s} {bar} {pct}%")
        print()

    # Seções lentas
    lentas = data.get("secoes_lentas", [])
    if lentas:
        print_section("SEÇÕES LENTAS")
        for s in lentas:
            local = s.get("local", "")
            motivo = s.get("motivo", "")
            print(f"    {styled('→', C_YELLOW)} {styled(local, C_BOLD)}")
            print(f"      {_wrap(motivo, indent=6)}")
        print()

    # Seções rápidas
    rapidas = data.get("secoes_rapidas", [])
    if rapidas:
        print_section("SEÇÕES RÁPIDAS")
        for s in rapidas:
            local = s.get("local", "")
            motivo = s.get("motivo", "")
            print(f"    {styled('→', C_GREEN)} {styled(local, C_BOLD)}")
            print(f"      {_wrap(motivo, indent=6)}")
        print()

    # Sugestões
    sugs = data.get("sugestoes", [])
    if sugs:
        print_section("REFLEXÕES")
        for s in sugs:
            print_bullet(s)
        print()


def format_repetitions(data: Dict):
    """Formata resultado de detecção de repetições."""
    if print_error(data):
        return

    # Palavras repetidas
    palavras = data.get("palavras_repetidas", [])
    print_section("PALAVRAS/EXPRESSÕES REPETIDAS")
    if not palavras:
        print(f"      {styled('Nenhuma repetição significativa.', C_DIM)}\n")
    else:
        for p in palavras:
            palavra = p.get("palavra", "")
            onde = p.get("ocorrencias", "")
            quoted = '\u201c' + palavra + '\u201d'
            print(f"    {styled(quoted, C_BOLD, C_YELLOW)}")
            print(f"      {_wrap(onde, indent=6)}")
        print()

    # Estruturas similares
    estruturas = data.get("estruturas_similares", [])
    if estruturas:
        print_section("ESTRUTURAS SIMILARES")
        for e in estruturas:
            padrao = e.get("padrao", "")
            onde = e.get("onde", "")
            print(f"    {styled('Padrão:', C_BOLD)} {_wrap(padrao, indent=12)}")
            print(f"      {styled('Onde:', C_DIM)} {onde}")
        print()

    # Dinâmicas repetidas
    dinamicas = data.get("dinamicas_repetidas", [])
    if dinamicas:
        print_section("DINÂMICAS REPETIDAS")
        for d in dinamicas:
            din = d.get("dinamica", "")
            pers = d.get("personagens", "")
            print(f"    {styled('•', C_GREEN)} {_wrap(din, indent=6)}")
            print(f"      {styled('Personagens:', C_DIM)} {pers}")
        print()


def format_themes(data: Dict):
    """Formata resultado de análise temática."""
    if print_error(data):
        return

    # Tom geral
    tom = data.get("tom_geral", "")
    if tom:
        print_item("Tom geral:", tom)
        print()

    # Temas centrais
    temas = data.get("temas_centrais", [])
    if temas:
        print_section("TEMAS IDENTIFICADOS")
        for t in temas:
            tema = t.get("tema", "")
            forca = t.get("forca", "").lower()
            evidencia = t.get("evidencia", "")
            if forca == "forte":
                badge = styled(" FORTE ", C_BOLD, C_GREEN)
            elif forca == "emergente":
                badge = styled(" EMERG.", C_BOLD, C_YELLOW)
            else:
                badge = styled(" SUTIL ", C_DIM)
            print(f"    {badge}  {styled(tema, C_BOLD)}")
            if evidencia:
                print(f"           {_wrap(evidencia, indent=11)}")
        print()

    # Desvios de tom
    desvios = data.get("desvios_de_tom", [])
    if desvios:
        print_section("DESVIOS DE TOM")
        for d in desvios:
            local = d.get("local", "")
            detalhe = d.get("detalhe", "")
            print(f"    {styled('!', C_RED)} {styled(local, C_BOLD)}: {_wrap(detalhe, indent=6)}")
        print()

    # Oportunidades
    ops = data.get("oportunidades", [])
    if ops:
        print_section("OPORTUNIDADES")
        for o in ops:
            print_bullet(o)
        print()


def format_memory(data: Dict):
    """Formata resultado da memória narrativa."""
    if print_error(data):
        return

    # Resumo geral
    resumo = data.get("resumo_geral", "")
    if resumo:
        print_item("Resumo:", resumo)
        print()

    # Timeline
    timeline = data.get("timeline", [])
    if timeline:
        print_section("TIMELINE")
        for ev in timeline:
            evento = ev.get("evento", "")
            local = ev.get("local", "")
            impacto = ev.get("impacto", "")
            imp_color = C_RED if impacto == "alto" else (C_YELLOW if impacto in ("medio", "médio") else C_DIM)
            print(f"    {styled('→', imp_color)} {_wrap(evento, indent=6)}")
            print(f"      {styled('Local:', C_DIM)} {local}  {styled('Impacto:', C_DIM)} {impacto}")
        print()

    # Personagens
    personagens = data.get("personagens", [])
    if personagens:
        print_section("PERSONAGENS")
        for p in personagens:
            nome = p.get("nome", "?")
            estado = p.get("estado_atual", "")
            arco = p.get("arco", "")
            aparicao = p.get("ultima_aparicao", "")
            print(f"    {styled(nome, C_BOLD, C_MAGENTA)}")
            if estado:
                print(f"      Estado: {_wrap(estado, indent=14)}")
            if arco:
                print(f"      Arco:   {_wrap(arco, indent=14)}")
            if aparicao:
                print(f"      Última: {styled(aparicao, C_DIM)}")
            print()

    # Temas
    temas = data.get("temas", [])
    if temas:
        print_section("TEMAS")
        for t in temas:
            print_bullet(t)
        print()

    # Conflitos abertos
    conflitos = data.get("conflitos_abertos", [])
    if conflitos:
        print_section("CONFLITOS ABERTOS")
        for c in conflitos:
            conf = c.get("conflito", "")
            envolvidos = c.get("envolvidos", "")
            print(f"    {styled('*', C_YELLOW)} {_wrap(conf, indent=6)}")
            if envolvidos:
                print(f"      {styled('Envolvidos:', C_DIM)} {envolvidos}")
        print()

    # Mundo
    mundo = data.get("mundo", {})
    if mundo:
        print_section("MUNDO")
        locais = mundo.get("locais_mencionados", [])
        if locais:
            print(f"    {styled('Locais:', C_BOLD)}")
            for l in locais:
                print_bullet(l)
        regras = mundo.get("regras_do_mundo", [])
        if regras:
            print(f"    {styled('Regras:', C_BOLD)}")
            for r in regras:
                print_bullet(r)
        print()

    # Alertas
    alertas = data.get("alertas", [])
    if alertas:
        print_section("ALERTAS")
        for a in alertas:
            print(f"    {styled('!', C_RED, C_BOLD)} {_wrap(a, indent=6)}")
        print()


def format_scene(data: Dict):
    """Formata resultado de análise de cena."""
    if print_error(data):
        return

    cena = data.get("cena", "")
    if cena:
        print(f"  {styled('Arquivo:', C_BOLD)} {cena}\n")

    funcao = data.get("funcao_dramatica", "")
    if funcao:
        print_item("Função dramática:", funcao)

    # Consistência
    cons = data.get("consistencia", {})
    if cons:
        status = _status_label(cons.get("status", ""))
        detalhe = cons.get("detalhe", "")
        print(f"    {styled('Consistência:', C_BOLD)} [{status}] {_wrap(detalhe, indent=20)}")

    # Tom
    tom = data.get("tom", {})
    if tom:
        status = _status_label(tom.get("status", ""))
        detalhe = tom.get("detalhe", "")
        print(f"    {styled('Tom:', C_BOLD)}           [{status}] {_wrap(detalhe, indent=20)}")

    print()

    # Conexões faltantes
    conexoes = data.get("conexoes_faltantes", [])
    if conexoes:
        print_section("CONEXÕES FALTANTES")
        for c in conexoes:
            print_bullet(c)
        print()

    # Pontos fortes
    fortes = data.get("pontos_fortes", [])
    if fortes:
        print_section("PONTOS FORTES")
        for f in fortes:
            print_bullet(f)
        print()

    # Pergunta
    pergunta = data.get("pergunta", "")
    if pergunta:
        print(f"  {styled('Pergunta:', C_BOLD, C_YELLOW)} {_wrap(pergunta, indent=12)}")
        print()


def format_generic(data: Dict, indent: int = 0):
    """Formatador genérico para dados não mapeados."""
    prefix = "  " * (indent + 1)

    if print_error(data):
        return

    for key, value in data.items():
        if key in ("last_updated",):
            continue

        label = key.replace("_", " ").title()

        if isinstance(value, str):
            print(f"{prefix}{styled(label + ':', C_BOLD)} {_wrap(value, indent=len(prefix)+len(label)+2)}")

        elif isinstance(value, list):
            print(f"\n{prefix}{styled(label + ':', C_BOLD, C_YELLOW)}")
            if not value:
                print(f"{prefix}  {styled('(nenhum)', C_DIM)}")
            for item in value:
                if isinstance(item, dict):
                    for k, v in item.items():
                        k_label = k.replace('_', ' ').title()
                        print(f"{prefix}  {styled(k_label + ':', C_DIM)} {v}")
                    print()
                else:
                    print(f"{prefix}  {styled('•', C_GREEN)} {_wrap(str(item), indent=len(prefix)+4)}")

        elif isinstance(value, dict):
            print(f"\n{prefix}{styled(label + ':', C_BOLD, C_MAGENTA)}")
            format_generic(value, indent + 1)


# ─── CLI ─────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print_header("Assistente de IA Narrativa")
        print("  Uso: narrative_ai.py <comando>\n")
        cmds = [
            ("consistency", "[texto]", "Analisa inconsistencias"),
            ("pacing", "", "Analisa ritmo narrativo"),
            ("repetitions", "", "Detecta repeticoes"),
            ("themes", "", "Analisa temas"),
            ("memory", "", "Atualiza memoria narrativa"),
            ("question", "[cena]", "Pergunta criativa"),
            ("character", "<nome>", "Busca rapida de personagem"),
            ("scene", "<arquivo>", "Analisa cena especifica"),
            ("status", "", "Status do conteudo"),
        ]
        print(f"  {styled('Comandos:', C_BOLD)}")
        for cmd, args, desc in cmds:
            arg_str = f" {args}" if args else ""
            print(f"    {styled(cmd, C_YELLOW)}{styled(arg_str, C_DIM):14s}  {desc}")
        print()
        sys.exit(0)

    cmd = sys.argv[1]
    content = read_all_content()

    if cmd == "status":
        print_header("Status do Projeto")
        n_p = len(content["personagens"])
        n_c = len(content["cenas"])
        n_ch = len(content["capitulos"])
        n_n = len(content["notas"])

        total_words = 0
        for category in content.values():
            for item in category:
                total_words += len(item["texto"].split())

        print_section("PERSONAGENS")
        print(f"    {n_p} arquivo(s) com conteudo real")
        for p in content["personagens"]:
            wc = len(p["texto"].split())
            print(f"    {styled('*', C_GREEN)} {p['nome']} ({wc} palavras)")

        print()
        print_section("CENAS")
        print(f"    {n_c} arquivo(s) com conteudo real")
        for c in content["cenas"]:
            wc = len(c["texto"].split())
            print(f"    {styled('*', C_GREEN)} {c['nome']} ({wc} palavras)")

        print()
        print_section("CAPITULOS")
        print(f"    {n_ch} arquivo(s) com conteudo")
        for ch in content["capitulos"]:
            wc = len(ch["texto"].split())
            print(f"    {styled('*', C_GREEN)} {ch['nome']} ({wc} palavras)")

        print()
        print_section("NOTAS")
        print(f"    {n_n} arquivo(s)")

        print(f"\n  {styled('Total de palavras:', C_BOLD, C_CYAN)} {total_words}")

        mem_file = CACHE_DIR / "narrative_memory.json"
        if mem_file.exists():
            mem = json.loads(mem_file.read_text(encoding="utf-8"))
            last = mem.get("last_updated", "nunca")
            print(f"  {styled('Ultima analise:', C_BOLD)} {last[:19].replace('T', ' ')}")
        else:
            print(f"  {styled('Memoria:', C_BOLD)} nao inicializada -- rode: ai-memoria")
        print()

    elif cmd == "consistency":
        print_header("Analise de Consistencia")
        extra = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else ""
        result = analyze_consistency(content, extra)
        format_consistency(result)

    elif cmd == "pacing":
        print_header("Analise de Ritmo")
        result = analyze_pacing(content)
        format_pacing(result)

    elif cmd == "repetitions":
        print_header("Deteccao de Repeticoes")
        result = detect_repetitions(content)
        format_repetitions(result)

    elif cmd == "themes":
        print_header("Analise Tematica")
        result = analyze_themes(content)
        format_themes(result)

    elif cmd == "memory":
        print_header("Atualizando Memoria Narrativa")
        print(f"  {styled('Lendo conteudo...', C_DIM)}")
        result = update_memory(content)
        if "error" not in result:
            print(f"  {styled('Memoria atualizada!', C_GREEN)}\n")
            format_memory(result)
        else:
            print(f"  {styled('ERRO:', C_RED, C_BOLD)} {result['error']}")

    elif cmd == "question":
        scene = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else ""
        print_header("Pergunta Criativa")
        q = ask_creative_question(content, scene)
        print(f"  {styled(q, C_BOLD, C_YELLOW)}")
        print()

    elif cmd == "character":
        if len(sys.argv) < 3:
            print("Uso: narrative_ai.py character <nome>")
            sys.exit(1)
        name = " ".join(sys.argv[2:])
        print(get_character_quick(name))

    elif cmd == "scene":
        if len(sys.argv) < 3:
            print("Uso: narrative_ai.py scene <arquivo>")
            sys.exit(1)
        scene_path = " ".join(sys.argv[2:])
        print_header(f"Analise de Cena: {scene_path}")
        result = analyze_scene(scene_path)
        format_scene(result)

    else:
        print(f"Comando desconhecido: {cmd}")
        print("Use sem argumentos para ver a ajuda.")
        sys.exit(1)


if __name__ == "__main__":
    main()
