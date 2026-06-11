from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

BASE_DIR = Path(__file__).resolve().parent
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))

from sqlalchemy import func, select, text

from database import session_scope
from models.admin import LearningArticle, LearningVideo


@dataclass(frozen=True)
class ArticleSeed:
    title: str
    content: str
    summary: str
    article_url: str
    language: str
    is_active: bool = True


@dataclass(frozen=True)
class VideoSeed:
    title: str
    description: str
    video_url: str
    thumbnail_url: str
    language: str
    is_active: bool = True


ARTICLE_SEEDS: list[ArticleSeed] = [
    ArticleSeed(
        title="Brushing Your Teeth",
        content="ADA brushing steps for cleaning all tooth surfaces and protecting gums.",
        summary="ADA brushing steps for cleaning all tooth surfaces and protecting gums.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/brushing-your-teeth",
        language="en",
    ),
    ArticleSeed(
        title="Flossing",
        content="Daily flossing tips and tools for cleaning between teeth.",
        summary="Daily flossing tips and tools for cleaning between teeth.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/flossing",
        language="en",
    ),
    ArticleSeed(
        title="Tooth Decay Process",
        content="How cavities form and how fluoride can help reverse early decay.",
        summary="How cavities form and how fluoride can help reverse early decay.",
        article_url="https://www.nidcr.nih.gov/health-info/tooth-decay",
        language="en",
    ),
    ArticleSeed(
        title="Periodontal Gum Disease",
        content="Causes, symptoms, and prevention of gum disease.",
        summary="Causes, symptoms, and prevention of gum disease.",
        article_url="https://www.mouthhealthy.org/all-topics-a-z/gum-disease",
        language="en",
    ),
    ArticleSeed(
        title="Keeping Kids Teeth Healthy",
        content="Brushing, flossing, fluoride, and dentist visits for children.",
        summary="Brushing, flossing, fluoride, and dentist visits for children.",
        article_url="https://www.mouthhealthy.org/en/babies-and-kids/healthy-children-and-healthy-smiles",
        language="en",
    ),
    ArticleSeed(
        title="Nutrition and Oral Health",
        content="How sugar, snacks, and drinks affect oral health.",
        summary="How sugar, snacks, and drinks affect oral health.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/nutrition-and-oral-health",
        language="en",
    ),
    ArticleSeed(
        title="Life During Treatment",
        content="Simple care tips for teeth and braces during treatment.",
        summary="Simple care tips for teeth and braces during treatment.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/orthodontics",
        language="en",
    ),
    ArticleSeed(
        title="Oral Hygiene",
        content="Brushing, flossing, and daily habits for healthy teeth and gums.",
        summary="Brushing, flossing, and daily habits for healthy teeth and gums.",
        article_url="https://www.nidcr.nih.gov/health-info/oral-hygiene",
        language="en",
    ),
    ArticleSeed(
        title="Taking Care of Teeth and Mouth",
        content="Oral care tips for teeth, gums, dry mouth, and dentures.",
        summary="Oral care tips for teeth, gums, dry mouth, and dentures.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/dry-mouth",
        language="en",
    ),
    ArticleSeed(
        title="WHO Oral Health Facts",
        content="WHO facts on oral diseases, prevention, and global oral health.",
        summary="WHO facts on oral diseases, prevention, and global oral health.",
        article_url="https://www.who.int/news-room/fact-sheets/detail/oral-health",
        language="en",
    ),
    ArticleSeed(
        title="பல் துலக்கும் வழிமுறை",
        content="பற்களின் அனைத்து பகுதிகளையும் சுத்தம் செய்யும் ADA வழிமுறை.",
        summary="பற்களின் அனைத்து பகுதிகளையும் சுத்தம் செய்யும் ADA வழிமுறை.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/brushing-your-teeth",
        language="ta",
    ),
    ArticleSeed(
        title="Flossing",
        content="பற்களுக்கு நடுவில் சுத்தம் செய்யும் தினசரி floss குறிப்புகள்.",
        summary="பற்களுக்கு நடுவில் சுத்தம் செய்யும் தினசரி floss குறிப்புகள்.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/flossing",
        language="ta",
    ),
    ArticleSeed(
        title="பல் சொத்தை செயல்முறை",
        content="சொத்தை எப்படி உருவாகிறது, fluoride எப்படி உதவுகிறது.",
        summary="சொத்தை எப்படி உருவாகிறது, fluoride எப்படி உதவுகிறது.",
        article_url="https://www.nidcr.nih.gov/health-info/tooth-decay",
        language="ta",
    ),
    ArticleSeed(
        title="ஈறு நோய்",
        content="ஈறு நோயின் காரணங்கள், அறிகுறிகள், தடுப்பு.",
        summary="ஈறு நோயின் காரணங்கள், அறிகுறிகள், தடுப்பு.",
        article_url="https://www.mouthhealthy.org/all-topics-a-z/gum-disease",
        language="ta",
    ),
    ArticleSeed(
        title="குழந்தைகளின் பல் ஆரோக்கியம்",
        content="துலக்குதல், flossing, fluoride, மற்றும் dentist visits.",
        summary="துலக்குதல், flossing, fluoride, மற்றும் dentist visits.",
        article_url="https://www.mouthhealthy.org/en/babies-and-kids/healthy-children-and-healthy-smiles",
        language="ta",
    ),
    ArticleSeed(
        title="உணவு மற்றும் வாய்நலம்",
        content="சர்க்கரை, snacks, drinks ஆகியவை வாய்நலத்தை எப்படி பாதிக்கின்றன.",
        summary="சர்க்கரை, snacks, drinks ஆகியவை வாய்நலத்தை எப்படி பாதிக்கின்றன.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/nutrition-and-oral-health",
        language="ta",
    ),
    ArticleSeed(
        title="சிகிச்சை கால பராமரிப்பு",
        content="பல் சிகிச்சை காலத்தில் teeth மற்றும் braces பராமரிப்பு.",
        summary="பல் சிகிச்சை காலத்தில் teeth மற்றும் braces பராமரிப்பு.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/orthodontics",
        language="ta",
    ),
    ArticleSeed(
        title="வாய்ச் சுகாதாரம்",
        content="தினசரி துலக்குதல், flossing, மற்றும் நல்ல பழக்கங்கள்.",
        summary="தினசரி துலக்குதல், flossing, மற்றும் நல்ல பழக்கங்கள்.",
        article_url="https://www.nidcr.nih.gov/health-info/oral-hygiene",
        language="ta",
    ),
    ArticleSeed(
        title="பற்கள் மற்றும் வாய் பராமரிப்பு",
        content="Dry mouth, dentures, gum care ஆகியவற்றுக்கான குறிப்புகள்.",
        summary="Dry mouth, dentures, gum care ஆகியவற்றுக்கான குறிப்புகள்.",
        article_url="https://www.ada.org/resources/ada-library/oral-health-topics/dry-mouth",
        language="ta",
    ),
    ArticleSeed(
        title="WHO வாய்நல உண்மைகள்",
        content="வாய்நோய்கள், தடுப்பு, மற்றும் உலகளாவிய வாய்நலம் பற்றிய தகவல்கள்.",
        summary="வாய்நோய்கள், தடுப்பு, மற்றும் உலகளாவிய வாய்நலம் பற்றிய தகவல்கள்.",
        article_url="https://www.who.int/news-room/fact-sheets/detail/oral-health",
        language="ta",
    ),
]

VIDEO_SEEDS: list[VideoSeed] = [
    VideoSeed(
        title="Proper Brushing Techniques",
        description="Proper brushing for healthy teeth",
        video_url="https://www.youtube.com/watch?v=7kGXQDwT6IA",
        thumbnail_url="https://img.youtube.com/vi/7kGXQDwT6IA/0.jpg",
        language="en",
    ),
    VideoSeed(
        title="Oral Health Care Routine",
        description="Daily oral care habits",
        video_url="https://www.youtube.com/watch?v=5J89gCDt_rk",
        thumbnail_url="https://img.youtube.com/vi/5J89gCDt_rk/0.jpg",
        language="en",
    ),
    VideoSeed(
        title="Kids Oral Care",
        description="Fun dental care for children",
        video_url="https://www.youtube.com/watch?v=aOebfGGcjVw",
        thumbnail_url="https://img.youtube.com/vi/aOebfGGcjVw/0.jpg",
        language="en",
    ),
    VideoSeed(
        title="Oral Hygiene",
        description="Complete oral hygiene basics",
        video_url="https://www.youtube.com/watch?v=9fI_hEz2oM0",
        thumbnail_url="https://img.youtube.com/vi/9fI_hEz2oM0/0.jpg",
        language="en",
    ),
    VideoSeed(
        title="Oral and General Health Animation",
        description="Connection between oral and body health",
        video_url="https://www.youtube.com/watch?v=Ge9WGTp5y3o",
        thumbnail_url="https://img.youtube.com/vi/Ge9WGTp5y3o/0.jpg",
        language="en",
    ),
    VideoSeed(
        title="How Cavities Develop From Tooth Decay",
        description="Understand cavity formation",
        video_url="https://www.youtube.com/watch?v=79VQZueHn9o",
        thumbnail_url="https://img.youtube.com/vi/79VQZueHn9o/0.jpg",
        language="en",
    ),
    VideoSeed(
        title="Flossing Technique",
        description="Correct flossing method",
        video_url="https://www.youtube.com/watch?v=m3pBA4cgdxw",
        thumbnail_url="https://img.youtube.com/vi/m3pBA4cgdxw/0.jpg",
        language="en",
    ),
    VideoSeed(
        title="Gum Disease",
        description="Learn about gum infections",
        video_url="https://www.youtube.com/watch?v=f8aqBbEtsz0",
        thumbnail_url="https://img.youtube.com/vi/f8aqBbEtsz0/0.jpg",
        language="en",
    ),
    VideoSeed(
        title="Dental Awareness",
        description="Improve dental health awareness",
        video_url="https://www.youtube.com/watch?v=9Qa2K1CC3Hw",
        thumbnail_url="https://img.youtube.com/vi/9Qa2K1CC3Hw/0.jpg",
        language="en",
    ),
    VideoSeed(
        title="பல் சுத்தம் ஏன் அவசியம்?",
        description="தினசரி பல் பராமரிப்பு",
        video_url="https://www.youtube.com/watch?v=5KxRzRJ5ibY",
        thumbnail_url="https://img.youtube.com/vi/5KxRzRJ5ibY/0.jpg",
        language="ta",
    ),
    VideoSeed(
        title="சொத்தை பல்லை சரி செய்வது எப்படி?",
        description="பல் சொத்தை தடுக்கும் வழிகள்",
        video_url="https://www.youtube.com/watch?v=cmpq37aDRxQ",
        thumbnail_url="https://img.youtube.com/vi/cmpq37aDRxQ/0.jpg",
        language="ta",
    ),
    VideoSeed(
        title="பல் இடுக்குகளை சுத்தம் செய்ய!",
        description="பற்களை சரியாக சுத்தம் செய்வது",
        video_url="https://www.youtube.com/watch?v=oZ2OEniOr7E",
        thumbnail_url="https://img.youtube.com/vi/oZ2OEniOr7E/0.jpg",
        language="ta",
    ),
    VideoSeed(
        title="மஞ்சள் படிவம் வராமல் பல் துலக்குவது எப்படி?",
        description="மஞ்சள் படிவம் வராமல் பாதுகாப்பு",
        video_url="https://www.youtube.com/watch?v=ApRfmdqQ63A",
        thumbnail_url="https://img.youtube.com/vi/ApRfmdqQ63A/0.jpg",
        language="ta",
    ),
    VideoSeed(
        title="ஈறில் இரத்தம் வருவது ஏன்? சிகிச்சை என்ன?",
        description="ஈறு நோய் பற்றிய விழிப்புணர்வு",
        video_url="https://www.youtube.com/watch?v=iziQ22xvt8o",
        thumbnail_url="https://img.youtube.com/vi/iziQ22xvt8o/0.jpg",
        language="ta",
    ),
    VideoSeed(
        title="பற்களின் பாதுகாப்பிற்கு இதை செய்யாதீர்கள்",
        description="பற்களின் பாதுகாப்பு குறிப்புகள்",
        video_url="https://www.youtube.com/watch?v=ft81iy8Xopo",
        thumbnail_url="https://img.youtube.com/vi/ft81iy8Xopo/0.jpg",
        language="ta",
    ),
    VideoSeed(
        title="பல் சொத்தை பற்றி குழந்தைகள் தெரிந்துகொள்ள வேண்டியது",
        description="குழந்தைகளுக்கான பல் பராமரிப்பு",
        video_url="https://www.youtube.com/watch?v=biD0tE-hYRE",
        thumbnail_url="https://img.youtube.com/vi/biD0tE-hYRE/0.jpg",
        language="ta",
    ),
    VideoSeed(
        title="ஈறுகளில் இரத்தக்கசிவா?",
        description="ஈறு இரத்தக்கசிவு காரணங்கள்",
        video_url="https://www.youtube.com/watch?v=iR92ycRDXXc",
        thumbnail_url="https://img.youtube.com/vi/iR92ycRDXXc/0.jpg",
        language="ta",
    ),
]


def _article_key(article: ArticleSeed) -> tuple[str, str]:
    return article.title.strip().lower(), article.language.strip().lower()


def _video_key(video: VideoSeed) -> tuple[str, str]:
    return video.video_url.strip().lower(), video.language.strip().lower()


def _count_rows(db) -> dict[str, int]:
    stats = {
        "articles_total": int(db.scalar(select(func.count()).select_from(LearningArticle)) or 0),
        "videos_total": int(db.scalar(select(func.count()).select_from(LearningVideo)) or 0),
        "articles_en": int(
            db.scalar(select(func.count()).select_from(LearningArticle).where(LearningArticle.language == "en")) or 0
        ),
        "articles_ta": int(
            db.scalar(select(func.count()).select_from(LearningArticle).where(LearningArticle.language == "ta")) or 0
        ),
        "videos_en": int(
            db.scalar(select(func.count()).select_from(LearningVideo).where(LearningVideo.language == "en")) or 0
        ),
        "videos_ta": int(
            db.scalar(select(func.count()).select_from(LearningVideo).where(LearningVideo.language == "ta")) or 0
        ),
    }
    return stats


def seed_learning_content(dry_run: bool = False) -> dict[str, int]:
    with session_scope() as db:
        existing_article_keys = {
            (row.title.strip().lower(), row.language.strip().lower())
            for row in db.scalars(select(LearningArticle)).all()
        }
        existing_video_keys = {
            (row.video_url.strip().lower(), row.language.strip().lower())
            for row in db.scalars(select(LearningVideo)).all()
        }

        new_articles: list[LearningArticle] = []
        for article in ARTICLE_SEEDS:
            if _article_key(article) in existing_article_keys:
                continue
            new_articles.append(article)

        new_videos: list[LearningVideo] = []
        for video in VIDEO_SEEDS:
            if _video_key(video) in existing_video_keys:
                continue
            new_videos.append(
                LearningVideo(
                    title=video.title,
                    description=video.description,
                    video_url=video.video_url,
                    thumbnail_url=video.thumbnail_url,
                    language=video.language,
                    is_active=video.is_active,
                )
            )

        inserted_articles = len(new_articles)
        inserted_videos = len(new_videos)

        if not dry_run:
            if new_articles:
                article_rows = [
                    {
                        "title": article.title,
                        "content": article.content,
                        "summary": article.summary,
                        "article_url": article.article_url,
                        "language": article.language,
                        "is_active": article.is_active,
                    }
                    for article in new_articles
                ]
                db.execute(
                    text(
                        """
                        INSERT INTO learning_articles_v2
                            (title, content, summary, article_url, language, is_active)
                        VALUES
                            (:title, :content, :summary, :article_url, :language, :is_active)
                        """
                    ),
                    article_rows,
                )
            if new_videos:
                db.add_all(new_videos)
            db.commit()

        stats = _count_rows(db)
        return {
            "inserted_articles": inserted_articles,
            "inserted_videos": inserted_videos,
            "inserted_total": inserted_articles + inserted_videos,
            **stats,
        }


def _print_verification(stats: dict[str, int]) -> None:
    print("Seed completed.")
    print(f"Inserted articles: {stats['inserted_articles']}")
    print(f"Inserted videos: {stats['inserted_videos']}")
    print(f"Inserted total: {stats['inserted_total']}")
    print(f"Final total articles: {stats['articles_total']}")
    print(f"Final total videos: {stats['videos_total']}")
    print(f"English articles: {stats['articles_en']}")
    print(f"Tamil articles: {stats['articles_ta']}")
    print(f"English videos: {stats['videos_en']}")
    print(f"Tamil videos: {stats['videos_ta']}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Seed Dentzy learning content into the database.")
    parser.add_argument("--dry-run", action="store_true", help="Calculate inserts without writing to the database.")
    args = parser.parse_args()

    stats = seed_learning_content(dry_run=args.dry_run)
    _print_verification(stats)


if __name__ == "__main__":
    main()
