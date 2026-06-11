from __future__ import annotations

from sqlalchemy import select

from auth.security import hash_password
from database import SessionLocal, init_db
from models.admin import AdminUser


def create_default_admin() -> None:
    init_db()

    db = SessionLocal()
    try:
        existing_admin = db.scalar(select(AdminUser).where(AdminUser.email == "admin@dentzy.com"))
        if existing_admin is not None:
            print("Admin bootstrap skipped: admin@dentzy.com already exists.")
            return

        total_admins = db.query(AdminUser).count()
        if total_admins > 0:
            print(f"Admin bootstrap skipped: {total_admins} admin user(s) already exist.")
            return

        admin = AdminUser(
            username="admin",
            email="admin@dentzy.com",
            password_hash=hash_password("Admin@123"),
            role="admin",
            is_active=True,
        )
        db.add(admin)
        db.commit()
        db.refresh(admin)
        print(f"Admin bootstrap success: created admin user id={admin.id}, email={admin.email}")
    except Exception as exc:
        db.rollback()
        print(f"Admin bootstrap failed: {exc}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    create_default_admin()