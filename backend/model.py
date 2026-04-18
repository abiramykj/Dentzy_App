from __future__ import annotations

from typing import Dict

import numpy as np
from sentence_transformers import SentenceTransformer

from data import all_facts, all_myths

_MODEL = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2")

# Precompute embeddings dynamically
_FACT_TEXTS = [item["text"] for item in all_facts]
_MYTH_TEXTS = [item["text"] for item in all_myths]

_FACT_EMBEDDINGS = _MODEL.encode(
    _FACT_TEXTS,
    convert_to_numpy=True,
    normalize_embeddings=True,
)
_MYTH_EMBEDDINGS = _MODEL.encode(
    _MYTH_TEXTS,
    convert_to_numpy=True,
    normalize_embeddings=True,
)

_THRESHOLD = 0.45


def _best_match(scores: np.ndarray) -> tuple[int, float]:
    index = int(np.argmax(scores))
    return index, float(scores[index])


def is_dental(sentence: str) -> bool:
    dental_keywords = [
        "tooth", "teeth", "gum", "brush", "floss", "dentist", "oral", "mouth", "cavity", "toothbrush", "cleaning", "hygiene", "neem", "stick",
        "பல்", "பற்கள்", "ஈறு", "துலக்கு", "பற்பசை", "மவுத்", "வாய்", "பிளாக்", "நீம்", "குச்சி"
    ]
    return any(keyword in sentence.lower() for keyword in dental_keywords)


def classify(sentence: str) -> Dict[str, object]:
    if not sentence or not sentence.strip():
        raise ValueError("Input text is empty.")

    query_embedding = _MODEL.encode(
        sentence,
        convert_to_numpy=True,
        normalize_embeddings=True,
    )

    fact_scores = np.dot(_FACT_EMBEDDINGS, query_embedding)
    myth_scores = np.dot(_MYTH_EMBEDDINGS, query_embedding)

    best_fact_index, best_fact_score = _best_match(fact_scores)
    best_myth_index, best_myth_score = _best_match(myth_scores)

    HIGH_THRESHOLD = 0.6
    MEDIUM_THRESHOLD = 0.4

    if best_fact_score > best_myth_score and best_fact_score > HIGH_THRESHOLD:
        best_fact = all_facts[best_fact_index]
        return {
            "type": "fact",
            "explanation": best_fact["explanation"],
            "tip": best_fact["tip"],
            "confidence": float(best_fact_score),
        }

    if best_myth_score > best_fact_score and best_myth_score > HIGH_THRESHOLD:
        best_myth = all_myths[best_myth_index]
        return {
            "type": "myth",
            "explanation": best_myth["explanation"],
            "tip": best_myth["tip"],
            "confidence": float(best_myth_score),
        }

    if max(best_fact_score, best_myth_score) > MEDIUM_THRESHOLD:
        best_fact = all_facts[best_fact_index]
        return {
            "type": "fact",
            "explanation": "This statement is related to dental care but not found in the knowledge base.",
            "confidence": float(max(best_fact_score, best_myth_score)),
        }

    if is_dental(sentence):
        return {
            "type": "fact",
            "explanation": "This statement is related to dental care but not found in the knowledge base.",
            "confidence": 0.4,
        }

    if "neem" in sentence.lower():
        return {
            "type": "fact",
            "explanation": "Neem sticks have antibacterial properties and support oral hygiene.",
            "tip": "Use gently and maintain proper brushing habits.",
            "confidence": 0.5,
        }

    best_score = float(max(best_fact_score, best_myth_score))
    return {
        "type": "not_dental",
        "explanation": "This statement is not clearly related to dental health.",
        "tip": "Try asking about oral hygiene, dental care, or common myths.",
        "confidence": best_score,
    }
