import json
import pandas as pd

# Function to load myths from JSON files
def load_myths(json_file):
    with open(json_file, 'r', encoding='utf-8') as file:
        data = json.load(file)
    myths = []
    for item in data:
        for cover in item['covers']:
            myths.append({
                "text": cover,
                "explanation": item.get("explanation", ""),
                "tip": item.get("recommended_action", "")
            })
    return myths

# Function to load facts from CSV files
def load_facts(csv_file):
    df = pd.read_csv(csv_file)
    facts = []
    for _, row in df.iterrows():
        facts.append({
            "text": row['text'],
            "explanation": row.get("explanation", ""),
            "tip": row.get("tip", "")
        })
    return facts

# Load English and Tamil myths
english_myths = load_myths('assets/oral_health_myth_knowledge_base.json')
tamil_myths = load_myths('assets/knowledge_base_tamil.json')

# Load facts from CSV
facts = load_facts('assets/oral_health_myth_fact_dataset.csv')

# Combine myths and facts
all_myths = english_myths + tamil_myths
all_facts = facts
