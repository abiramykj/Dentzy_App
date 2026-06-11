from __future__ import annotations

from services.myth_classifier_service import _classify_with_groq, _detect_language, _has_dental_keywords, classify_statement

classify = classify_statement
from __future__ import annotations

import asyncio

from services.myth_classifier_service import classify_statement


def _run_sync(sentence: str) -> dict[str, object]:
    return asyncio.run(classify_statement(sentence))


def classify(sentence: str) -> dict[str, object]:
    sentence = (sentence or "").strip()
    if not sentence:
        raise ValueError("Input text is empty.")
    return _run_sync(sentence)


def is_dental(sentence: str) -> tuple[bool, float]:
    result = classify(sentence)
    return result.get("type") != "NOT_DENTAL", float(result.get("confidence", 0))
