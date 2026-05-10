from __future__ import annotations

import re
from typing import Dict, Tuple

import numpy as np
from sentence_transformers import SentenceTransformer

from data import all_facts, all_myths

_MODEL = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2")

_FACT_TEXTS = [item["text"] for item in all_facts]
_MYTH_TEXTS = [item["text"] for item in all_myths]

_FACT_EMBEDDINGS = _MODEL.encode(_FACT_TEXTS, convert_to_numpy=True, normalize_embeddings=True)
_MYTH_EMBEDDINGS = _MODEL.encode(_MYTH_TEXTS, convert_to_numpy=True, normalize_embeddings=True)

_DENTAL_CONCEPTS = [
    "tooth health and care",
    "gum disease and treatment",
    "oral hygiene practices",
    "dental procedures and cleaning",
    "tooth decay and cavities",
    "brushing and flossing techniques",
    "dental prevention and maintenance",
    "mouth and tooth health",
    "enamel and dental sensitivity",
    "plaque and tartar buildup",
    "dental infections and root canals",
    "teeth whitening and cosmetic dentistry",
    "orthodontics and teeth alignment",
    "dental implants and bridges",
    "tooth extraction and replacement",
    "பல் ஆரோக்கியம் மற்றும் பராமரிப்பு",
    "ஈறு நோய் மற்றும் சிகிச்சை",
    "வாய் சுகாதாரம் நடைமுறைகள்",
    "பல் துலக்குதல் நுட்பம்",
    "பல் அழுக்கு மற்றும் குழி",
    "பல் சுளுவு மற்றும் சிதைவு",
    "வாய் உடம்பு ஆரோக்கியம்",
    "பல் வெள்ளை செய்தல்",
    "ஈறுகளை பாதுகாக்க",
    "வாயில் சொத்த",
]

_DENTAL_EMBEDDINGS = _MODEL.encode(_DENTAL_CONCEPTS, convert_to_numpy=True, normalize_embeddings=True)

_DENTAL_RELEVANCE_THRESHOLD = 0.35
_HIGH_THRESHOLD = 0.6
_MEDIUM_THRESHOLD = 0.4

_MYTH_OVERRIDE_RULES = [
    {
        "pattern": re.compile(
            r"(morning\s+brushing\s+is\s+enough|brush(?:ing)?\s+once\s+(?:a\s+day|daily)|once\s+(?:a\s+day|daily)\s+brushing\s+is\s+enough)",
            flags=re.I,
        ),
        "explanation": "Brushing only once a day is not enough. Most dental guidelines recommend brushing twice daily.",
        "tip": "Brush twice daily with fluoride toothpaste, especially before bedtime.",
        "confidence": 0.95,
    },
]


def _match_override_rule(sentence: str) -> Dict[str, object] | None:
    text = (sentence or "").strip()
    for rule in _MYTH_OVERRIDE_RULES:
        if rule["pattern"].search(text):
            return {
                "type": "myth",
                "explanation": rule["explanation"] or "This statement is a dental myth.",
                "tip": rule["tip"] or "Check the advice with a dentist.",
                "confidence": float(rule["confidence"]),
            }
    return None


def _best_match(scores: np.ndarray) -> tuple[int, float]:
    index = int(np.argmax(scores))
    return index, float(scores[index])


def is_dental(sentence: str) -> Tuple[bool, float]:
    if not sentence or not sentence.strip():
        return False, 0.0

    query_embedding = _MODEL.encode(sentence, convert_to_numpy=True, normalize_embeddings=True)
    concept_scores = np.dot(_DENTAL_EMBEDDINGS, query_embedding)
    _, best_concept_score = _best_match(concept_scores)
    return best_concept_score > _DENTAL_RELEVANCE_THRESHOLD, float(best_concept_score)


def classify(sentence: str) -> Dict[str, object]:
    if not sentence or not sentence.strip():
        raise ValueError("Input text is empty.")

    override = _match_override_rule(sentence)
    if override is not None:
        return override

    is_dental_related, dental_confidence = is_dental(sentence)
    if not is_dental_related:
        return {
            "type": "not_dental",
            "explanation": "This statement is not clearly related to dental health.",
            "tip": "Try asking about oral hygiene, dental care, or common myths.",
            "confidence": float(dental_confidence),
        }

    query_embedding = _MODEL.encode(sentence, convert_to_numpy=True, normalize_embeddings=True)
    fact_scores = np.dot(_FACT_EMBEDDINGS, query_embedding)
    myth_scores = np.dot(_MYTH_EMBEDDINGS, query_embedding)

    best_fact_index, best_fact_score = _best_match(fact_scores)
    best_myth_index, best_myth_score = _best_match(myth_scores)

    if best_fact_score > best_myth_score and best_fact_score > _HIGH_THRESHOLD:
        best_fact = all_facts[best_fact_index]
        return {
            "type": "fact",
            "explanation": best_fact.get("explanation") or "This statement is consistent with common dental knowledge.",
            "tip": best_fact.get("tip") or "Keep following a regular oral hygiene routine.",
            "confidence": float(best_fact_score),
        }

    if best_myth_score > best_fact_score and best_myth_score > _HIGH_THRESHOLD:
        best_myth = all_myths[best_myth_index]
        return {
            "type": "myth",
            "explanation": best_myth.get("explanation") or "This statement is a dental myth.",
            "tip": best_myth.get("tip") or "Use trusted dental guidance instead.",
            "confidence": float(best_myth_score),
        }

    if max(best_fact_score, best_myth_score) > _MEDIUM_THRESHOLD:
        is_fact = best_fact_score >= best_myth_score
        best_item = all_facts[best_fact_index] if is_fact else all_myths[best_myth_index]
        return {
            "type": "fact" if is_fact else "myth",
            "explanation": best_item.get("explanation") or "This statement is related to dental care but not found clearly in the knowledge base.",
            "tip": best_item.get("tip") or "Please check the wording with a dental professional.",
            "confidence": float(max(best_fact_score, best_myth_score)),
        }

    best_score = float(max(best_fact_score, best_myth_score, dental_confidence))
    return {
        "type": "not_dental",
        "explanation": "Low-confidence local match for a dental statement; trying AI fallback is recommended.",
        "tip": "Please rephrase with more detail for better classification.",
        "confidence": best_score,
    }
