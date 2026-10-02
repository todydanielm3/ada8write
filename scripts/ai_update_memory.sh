#!/usr/bin/env bash
# ai_update_memory.sh - atalho para: ./scripts/ai.sh memory
exec bash "$(dirname "$0")/ai.sh" memory "$@"
