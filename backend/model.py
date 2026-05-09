from __future__ import annotations

import re
from typing import Dict, Tuple

import numpy as np
from sentence_transformers import SentenceTransformer

try:
    from backend.data import all_facts, all_myths
except Exception:
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

# Define general dental concepts for semantic relevance detection
_DENTAL_CONCEPTS = [
    # English concepts
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
    
    # Tamil concepts (உதாரணம் - Examples)
    "பல் ஆரோக்கியம் மற்றும் பராமரிப்பு",  # tooth health and care
    "ஈறு நோய் மற்றும் சிகிச்சை",  # gum disease and treatment
    "வாய் சுகாதாரம் நடைமுறைகள்",  # oral hygiene practices
    "பல் துலக்குதல் நுட்பம்",  # tooth brushing technique
    "பல் அழுக்கு மற்றும் குழி",  # plaque and cavities
    "பல் சுளுவு மற்றும் சிதைவு",  # tooth decay and cavities
    "வாய் உடம்பு ஆரோக்கியம்",  # oral health
    "பல் வெள்ளை செய்தல்",  # teeth whitening
    "ஈறுகளை பாதுகாக்க",  # protect gums
    "வாயில் சொத்த",  # cleaning in mouth
]

# Precompute embeddings for dental concepts at startup
_DENTAL_EMBEDDINGS = _MODEL.encode(
    _DENTAL_CONCEPTS,
    convert_to_numpy=True,
    normalize_embeddings=True,
)

# Thresholds for multi-level classification
_DENTAL_RELEVANCE_THRESHOLD = 0.35
_HIGH_THRESHOLD = 0.6
_MEDIUM_THRESHOLD = 0.4

_MYTH_OVERRIDE_RULES = [
    {
        "pattern": re.compile(
            r"(morning\s+brushing\s+is\s+enough|brush(?:ing)?\s+once\s+(?:a\s+day|daily)|once\s+(?:a\s+day|daily)\s+brushing\s+is\s+enough)",
            flags=re.I,
        ),
        "explanation": "Brushing only once a day is not enough. Most dental guidelines recommend brushing twice daily (morning and before bed) for 2 minutes.",
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
    """
    STAGE 1: Detect whether a sentence is related to dental/oral health using semantic similarity.
    
    Uses semantic embeddings of general dental concepts to determine relevance,
    independent of dataset sentence matching.
    
    Args:
        sentence: Input sentence to classify
        
    Returns:
        Tuple[bool, float]: (is_dental, confidence_score)
    """
    if not sentence or not sentence.strip():
        return False, 0.0
    
    query_embedding = _MODEL.encode(
        sentence,
        convert_to_numpy=True,
        normalize_embeddings=True,
    )
    
    # Compute semantic similarity with dental concepts
    concept_scores = np.dot(_DENTAL_EMBEDDINGS, query_embedding)
    best_concept_index, best_concept_score = _best_match(concept_scores)
    
    # Determine if sentence is dental-related based on threshold
    is_dental_related = best_concept_score > _DENTAL_RELEVANCE_THRESHOLD
    
    return is_dental_related, float(best_concept_score)


def classify(sentence: str) -> Dict[str, object]:
    """
    Two-stage classification pipeline:
    
    STAGE 1: Detect if sentence is dental-related using semantic similarity with dental concepts
    STAGE 2: Classify as fact or myth using dataset embeddings (only if Stage 1 is positive)
    
    Args:
        sentence: Input sentence to classify
        
    Returns:
        Dict with type ("fact", "myth", or "not_dental"), explanation, tip, and confidence
    """
    if not sentence or not sentence.strip():
        raise ValueError("Input text is empty.")

    override = _match_override_rule(sentence)
    if override is not None:
        return override
    
    # STAGE 1: Dental Relevance Detection
    is_dental_related, dental_confidence = is_dental(sentence)
    
    if not is_dental_related:
        return {
            "type": "not_dental",
            "explanation": "This statement is not clearly related to dental health.",
            "tip": "Try asking about oral hygiene, dental care, or common myths.",
            "confidence": float(dental_confidence),
        }
    
    # STAGE 2: Fact vs Myth Classification
    query_embedding = _MODEL.encode(
        sentence,
        convert_to_numpy=True,
        normalize_embeddings=True,
    )
    
    fact_scores = np.dot(_FACT_EMBEDDINGS, query_embedding)
    myth_scores = np.dot(_MYTH_EMBEDDINGS, query_embedding)
    
    best_fact_index, best_fact_score = _best_match(fact_scores)
    best_myth_index, best_myth_score = _best_match(myth_scores)
    
    # High confidence match for fact
    if best_fact_score > best_myth_score and best_fact_score > _HIGH_THRESHOLD:
        best_fact = all_facts[best_fact_index]
        return {
            "type": "fact",
            "explanation": best_fact.get("explanation") or "This statement is consistent with common dental knowledge.",
            "tip": best_fact.get("tip") or "Keep following a regular oral hygiene routine.",
            "confidence": float(best_fact_score),
        }
    
    # High confidence match for myth
    if best_myth_score > best_fact_score and best_myth_score > _HIGH_THRESHOLD:
        best_myth = all_myths[best_myth_index]
        return {
            "type": "myth",
            "explanation": best_myth.get("explanation") or "This statement is a dental myth.",
            "tip": best_myth.get("tip") or "Use trusted dental guidance instead.",
            "confidence": float(best_myth_score),
        }
    
    # Medium confidence match - use top score type instead of always returning fact
    if max(best_fact_score, best_myth_score) > _MEDIUM_THRESHOLD:
        is_fact = best_fact_score >= best_myth_score
        best_item = all_facts[best_fact_index] if is_fact else all_myths[best_myth_index]
        return {
            "type": "fact" if is_fact else "myth",
            "explanation": best_item.get("explanation") or "This statement is related to dental care but not found clearly in the knowledge base.",
            "tip": best_item.get("tip") or "Please check the wording with a dental professional.",
            "confidence": float(max(best_fact_score, best_myth_score)),
        }
    
    # Low confidence but still dental-related - return unknown-style not_dental to force LLM fallback in API layer
    best_score = float(max(best_fact_score, best_myth_score, dental_confidence))
    return {
        "type": "not_dental",
        "explanation": "Low-confidence local match for a dental statement; trying AI fallback is recommended.",
        "tip": "Please rephrase with more detail for better classification.",
        "confidence": best_score,
    }
