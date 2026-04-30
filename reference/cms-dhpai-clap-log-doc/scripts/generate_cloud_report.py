#!/usr/bin/env python3
"""
Launcher: runs the elasticsearch-logs skill report generator (packed in the skill folder).
Use from repo root: py scripts/generate_cloud_report.py [path_to_json]
"""
import os
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKILL_SCRIPT = os.path.join(REPO_ROOT, ".github", "skills", "elasticsearch-logs", "scripts", "generate_cloud_report.py")

if not os.path.isfile(SKILL_SCRIPT):
    sys.exit(f"Skill script not found: {SKILL_SCRIPT}")

os.execv(sys.executable, [sys.executable, SKILL_SCRIPT] + sys.argv[1:])
