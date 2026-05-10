from __future__ import annotations

import os
import random
import smtplib
import socket
from email.message import EmailMessage
from pathlib import Path

from dotenv import load_dotenv

_THIS_DIR = Path(__file__).resolve().parent
_ENV_CANDIDATES = [
    _THIS_DIR / '.env',
    _THIS_DIR.parent / '.env',
]
for env_path in _ENV_CANDIDATES:
    if env_path.exists():
        load_dotenv(dotenv_path=env_path, override=False)

SMTP_HOST = "smtp.gmail.com"
SMTP_PORT = 587
SMTP_TIMEOUT_SECONDS = int(os.getenv("SMTP_TIMEOUT_SECONDS", "15"))
OTP_LENGTH = 6


def generate_otp(length: int = OTP_LENGTH) -> str:
    """Generate a numeric OTP for password reset verification."""
    return "".join(str(random.randint(0, 9)) for _ in range(length))


def _build_otp_email(sender: str, recipient: str, otp: str, ttl_minutes: int) -> EmailMessage:
    msg = EmailMessage()
    msg["Subject"] = "Dentzy Password Reset OTP"
    msg["From"] = sender
    msg["To"] = recipient

    body = f"""
Dentzy - Dental Care Companion

Your Dentzy OTP code is:

{otp}

This OTP is valid for {ttl_minutes} minutes.

If you did not request this password reset, please ignore this email.

Stay healthy,
Dentzy Care Team
""".strip()

    msg.set_content(body)
    return msg


def send_otp_email(recipient_email: str, otp: str, ttl_minutes: int = 5) -> None:
    """Send OTP email using Gmail SMTP with TLS and app-password authentication."""
    sender_email = os.getenv("EMAIL_USER", "").strip()
    sender_password = os.getenv("EMAIL_PASSWORD", "").strip().replace(" ", "")

    print(f"[SMTP] sender configured={bool(sender_email)} password configured={bool(sender_password)}")
    print(f"[SMTP] recipient={recipient_email}")

    if not sender_email or not sender_password:
        raise RuntimeError("Email SMTP credentials are not configured in environment variables")

    message = _build_otp_email(
        sender=sender_email,
        recipient=recipient_email,
        otp=otp,
        ttl_minutes=ttl_minutes,
    )

    try:
        print(f"[SMTP] connecting host={SMTP_HOST} port={SMTP_PORT} tls=True timeout={SMTP_TIMEOUT_SECONDS}")
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=SMTP_TIMEOUT_SECONDS) as server:
            server.ehlo()
            server.starttls()
            server.ehlo()
            server.login(sender_email, sender_password)
            server.send_message(message)
        print('[SMTP] message sent successfully')
    except (smtplib.SMTPException, OSError, socket.timeout) as exc:
        print(f"[SMTP] SMTP exception: {exc}")
        raise RuntimeError("Failed to send OTP email") from exc
