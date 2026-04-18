import json
from pathlib import Path

import pandas as pd

# Resolve assets relative to the repo root so the backend can run from any CWD.
_ASSETS_DIR = Path(__file__).resolve().parents[1] / "assets"


def _asset_path(filename: str) -> Path:
    return _ASSETS_DIR / filename

# Function to load myths from JSON files
def load_myths(json_file: str) -> list[dict]:
    path = _asset_path(json_file)
    with path.open("r", encoding="utf-8") as file:
        data = json.load(file)
    myths = []
    for item in data:
        for cover in item.get("covers", []):
            myths.append({
                "text": cover,
                "explanation": item.get("explanation", ""),
                "tip": item.get("recommended_action", "")
            })
    return myths

# Function to load facts from CSV files
def load_facts(csv_file: str) -> list[dict]:
    path = _asset_path(csv_file)
    df = pd.read_csv(path)
    facts = []
    for _, row in df.iterrows():
        facts.append({
            "text": row['text'],
            "explanation": row.get("explanation", ""),
            "tip": row.get("tip", "")
        })
    return facts

# Load English and Tamil myths
english_myths = load_myths("oral_health_myth_knowledge_base.json")
tamil_myths = load_myths("knowledge_base_tamil.json")

# Load facts from CSV
facts = load_facts("oral_health_myth_fact_dataset.csv")

# Combine myths and facts
all_myths = english_myths + tamil_myths
all_facts = facts
