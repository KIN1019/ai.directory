#!/usr/bin/env python3
"""
Launcher: runs the elasticsearch-logs skill script (packed in the skill folder).
Use this from repo root: py scripts/es_logs_report.py [app1] [app2] ... [--period now-7d]
"""
import os
import sys

# Repo root: parent of scripts/
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKILL_SCRIPT = os.path.join(REPO_ROOT, ".github", "skills", "elasticsearch-logs", "scripts", "es_logs_report.py")

if not os.path.isfile(SKILL_SCRIPT):
    sys.exit(f"Skill script not found: {SKILL_SCRIPT}")

os.execv(sys.executable, [sys.executable, SKILL_SCRIPT] + sys.argv[1:])
