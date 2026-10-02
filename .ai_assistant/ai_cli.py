#!/usr/bin/env python3
"""
CLI do Assistente de IA Narrativa
"""

import sys
import json
from pathlib import Path

# Adicionar o diretório ao path
sys.path.insert(0, str(Path(__file__).parent))

from narrative_ai import NarrativeAnalyzer


def print_analysis(title: str, data: dict):
    """Formata e exibe análise"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")
    
    if "error" in data:
        print(f"Erro: {data['error']}")
        return
    
    print(json.dumps(data, indent=2, ensure_ascii=False))


def main():
    if len(sys.argv) < 2:
        print("Uso: ai_cli.py <comando>")
        print("\nComandos disponíveis:")
        print("  consistency <texto>  - Analisa consistência")
        print("  pacing              - Analisa ritmo narrativo")
        print("  repetitions         - Detecta repetições")
        print("  themes              - Analisa coerência temática")
        print("  update_memory       - Atualiza memória narrativa")
        print("  question <contexto> - Faz pergunta criativa")
        sys.exit(1)
    
    command = sys.argv[1]
    analyzer = NarrativeAnalyzer()
    
    if command == "consistency":
        if len(sys.argv) < 3:
            print("Erro: forneça o texto para análise")
            sys.exit(1)
        text = " ".join(sys.argv[2:])
        result = analyzer.analyze_consistency(text)
        print_analysis("ANÁLISE DE CONSISTÊNCIA", result)
    
    elif command == "pacing":
        result = analyzer.analyze_pacing()
        print_analysis("ANÁLISE DE RITMO", result)
    
    elif command == "repetitions":
        result = analyzer.detect_repetitions()
        print_analysis("DETECÇÃO DE REPETIÇÕES", result)
    
    elif command == "themes":
        result = analyzer.analyze_thematic_coherence()
        print_analysis("ANÁLISE TEMÁTICA", result)
    
    elif command == "update_memory":
        print("Atualizando memória narrativa...")
        result = analyzer.update_narrative_memory()
        if "error" not in result:
            print("Memória atualizada com sucesso!")
            print(f"\nTemas: {', '.join(result.get('themes', []))}")
            print(f"Conflitos abertos: {len(result.get('open_conflicts', []))}")
            print(f"Última atualização: {result.get('last_updated', 'N/A')}")
        else:
            print(f"Erro: {result['error']}")
    
    elif command == "question":
        if len(sys.argv) < 3:
            print("Erro: forneça o contexto da cena")
            sys.exit(1)
        context = " ".join(sys.argv[2:])
        question = analyzer.ask_creative_question(context)
        print(f"\n{question}\n")
    
    else:
        print(f"Comando desconhecido: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
