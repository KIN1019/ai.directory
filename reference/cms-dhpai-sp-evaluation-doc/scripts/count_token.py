"""
count_token.py

This script recursively counts the number of tokens in all `.sql` files within one or more specified directories,
using the tiktoken library (with GPT-4o encoding). It outputs a CSV file with the token counts per file and
generates a histogram PNG visualizing the distribution of token counts.

Usage:
    uv run -m scripts/count_token <directory1> [<directory2> ...] [--csv <output_csv>] [--hist <output_png>]

Arguments:
    directories         One or more input directories to search for .sql files (searched recursively).

Options:
    --csv <output_csv>  Output CSV file path (default: output/token_count.csv).
    --hist <output_png> Output histogram PNG file path (default: output/token_count.png).

Requirements:
    - tiktoken
    - matplotlib

Example:
    uv run -m scripts/count_token sp/postgresql
"""

import argparse
from math import inf
import tiktoken
import glob
import csv
import os
import matplotlib.pyplot as plt
from typing import List, Tuple

def count_token(filepath: str) -> int:
    with open(filepath, 'r') as f:
        content = f.read()
    encoding = tiktoken.encoding_for_model("gpt-4o")
    tokens = encoding.encode(content)
    return len(tokens)

def collect_token_counts(directories: List[str]) -> List[Tuple[str, int]]:
    buffer: List[Tuple[str, int]] = []
    for directory in directories:
        pattern = os.path.join(directory, "**", "*.sql")
        for f in glob.glob(pattern, recursive=True):
            buffer.append((f, count_token(f)))
    return buffer

def ensure_parent_dir_exists(filepath: str) -> None:
    parent_dir = os.path.dirname(os.path.abspath(filepath))
    if parent_dir and not os.path.exists(parent_dir):
        os.makedirs(parent_dir, exist_ok=True)

def write_csv(data: List[Tuple[str, int]], output: str) -> None:
    ensure_parent_dir_exists(output)
    with open(output, "w", newline='') as f:
        writer = csv.writer(f)
        writer.writerows(data)

def plot_histogram(data: List[Tuple[str, int]], output: str, clipped: int = inf) -> None:
    ensure_parent_dir_exists(output)
    clipped = [min(clipped, x[1]) for x in data]
    plt.figure(figsize=(10, 6))
    plt.hist(clipped, bins=100)
    plt.xlabel("Token Count (clipped at 10,000)")
    plt.ylabel("Number of Files")
    plt.title("Token Count Distribution")
    plt.tight_layout()
    plt.savefig(output)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Count tokens in all *.sql files in one or more directories (recursively), output CSV and histogram."
    )
    parser.add_argument(
        "directories",
        nargs="+",
        help="Input directories containing .sql files (searched recursively)"
    )
    parser.add_argument(
        "--csv",
        default="output/token_count.csv",
        help="Output CSV file (default: output/token_count.csv)"
    )
    parser.add_argument(
        "--hist",
        default="output/token_count.png",
        help="Output histogram PNG file (default: output/token_count.png)"
    )
    args = parser.parse_args()

    buffer = collect_token_counts(args.directories)
    sorted_buffer = sorted(buffer, key=lambda x: x[1], reverse=True)
    write_csv(sorted_buffer, args.csv)
    plot_histogram(sorted_buffer, args.hist)

if __name__ == "__main__":
    main()
