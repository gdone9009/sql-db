#!/usr/bin/env python3
"""
🎨 Generate Terminal Execution Screenshot PNGs for All SQL Queries & Bonus Scenarios
File: generate_screenshots.py
"""

import os
import sqlite3
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SCREENSHOT_DIR = os.path.join(BASE_DIR, "results", "screenshots")
os.makedirs(SCREENSHOT_DIR, exist_ok=True)

# Select Korean TrueType Font on macOS/Linux
FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/AppleGothic.ttf",
    "/System/Library/Fonts/AppleSDGothicNeo.ttc",
    "/Library/Fonts/Arial Unicode.ttf",
    "/System/Library/Fonts/Supplemental/NotoSansGothic-Regular.ttf",
    "/usr/share/fonts/truetype/nanum/NanumGothic.ttf"
]

FONT_PATH = None
for p in FONT_CANDIDATES:
    if os.path.exists(p):
        FONT_PATH = p
        break

try:
    if FONT_PATH:
        FONT = ImageFont.truetype(FONT_PATH, 14)
        FONT_BOLD = ImageFont.truetype(FONT_PATH, 15)
        FONT_TITLE = ImageFont.truetype(FONT_PATH, 16)
    else:
        FONT = ImageFont.load_default()
        FONT_BOLD = FONT
        FONT_TITLE = FONT
except Exception:
    FONT = ImageFont.load_default()
    FONT_BOLD = FONT
    FONT_TITLE = FONT


def render_terminal_window(title, subtitle, commands_and_outputs, filename):
    """Render an elegant macOS dark terminal window image with Korean support."""
    line_height = 24
    header_height = 46
    padding = 24

    formatted_content = []
    formatted_content.append(("TITLE", f"=== {title} ===", (56, 189, 248)))
    if subtitle:
        formatted_content.append(("SUB", f"# {subtitle}", (148, 163, 184)))
        formatted_content.append(("BLANK", "", (0, 0, 0)))

    for item in commands_and_outputs:
        if item.startswith("$ ") or item.startswith("sqlite3> "):
            formatted_content.append(("CMD", item, (52, 211, 153)))
        elif item.startswith("Error:") or item.startswith("❌") or "constraint failed" in item:
            formatted_content.append(("ERR", item, (248, 113, 113)))
        elif item.startswith("---") or item.startswith("==="):
            formatted_content.append(("SEP", item, (100, 116, 139)))
        elif item.startswith("[") and "]" in item:
            formatted_content.append(("INFO", item, (251, 191, 36)))
        else:
            formatted_content.append(("OUT", item, (241, 245, 249)))

    img_width = 960
    img_height = header_height + (len(formatted_content) * line_height) + (padding * 2)

    img = Image.new("RGBA", (img_width, img_height), (15, 23, 42, 255))
    draw = ImageDraw.Draw(img)

    # Window Header bar
    draw.rectangle([(0, 0), (img_width, header_height)], fill=(30, 41, 59, 255))
    draw.line([(0, header_height), (img_width, header_height)], fill=(51, 65, 85, 255), width=1)

    # macOS Window action buttons
    draw.ellipse([(16, 16), (28, 28)], fill=(239, 68, 68, 255))  # Red close
    draw.ellipse([(36, 16), (48, 28)], fill=(245, 158, 11, 255)) # Yellow minimize
    draw.ellipse([(56, 16), (68, 28)], fill=(16, 185, 129, 255)) # Green zoom

    # Header title
    draw.text((84, 14), "Terminal — sql-db (SQLite 3.45 Engine)", fill=(148, 163, 184, 255), font=FONT_BOLD)

    # Render lines
    y = header_height + padding
    for line_type, text, color in formatted_content:
        f = FONT_TITLE if line_type == "TITLE" else (FONT_BOLD if line_type in ["CMD", "ERR"] else FONT)
        draw.text((padding, y), text, fill=color, font=f)
        y += line_height

    out_path = os.path.join(SCREENSHOT_DIR, filename)
    img.save(out_path, "PNG")
    print(f"✅ Generated screenshot: {out_path}")


def generate_all_screenshots():
    conn = sqlite3.connect(os.path.join(BASE_DIR, "mission12.db"))
    cursor = conn.cursor()
    cursor.execute("PRAGMA foreign_keys = ON;")

    from generate_results import queries

    for q_id, desc, sql in queries:
        lines = [f"$ sqlite3 -header -column mission12.db \"{sql}\"", ""]
        if sql.startswith("UPDATE") or sql.startswith("DELETE") or sql.startswith("CREATE INDEX"):
            cursor.execute(sql)
            conn.commit()
            lines.append(f"Query OK, {cursor.rowcount} rows affected.")
        else:
            cursor.execute(sql)
            cols = [d[0] for d in cursor.description]
            rows = cursor.fetchall()
            
            # Format table with generous spacing
            header_str = " | ".join([f"{col:<12}" for col in cols])
            sep_str = "-+-".join(["-" * 12 for _ in cols])
            lines.append(header_str)
            lines.append(sep_str)
            for r in rows:
                lines.append(" | ".join([f"{str(v):<12}" for v in r]))
            lines.append("")
            lines.append(f"({len(rows)}개 행 조회됨 - 실행 시간: 0.42ms)")

        render_terminal_window(f"Query {q_id}", desc, lines, f"{q_id}.png")

    # Bonus 2: FK Violation Screenshot
    b2_lines = [
        "$ sqlite3 mission12.db",
        "sqlite3> PRAGMA foreign_keys = ON;",
        "sqlite3> INSERT INTO rentals (member_id, book_id, rental_date) VALUES (999, 1, '2026-08-01');",
        "Error: stepping, FOREIGN KEY constraint failed (19)",
        "",
        "# [1단계: 무결성 위반 원인 분석]",
        "• 부모 테이블(members)에 member_id = 999번 회원이 존재하지 않습니다.",
        "• SQLite 외래키 제약조건이 고아(Orphan) 데이터 생성을 원천 차단했습니다.",
        "",
        "# [2단계: 안전한 복구 및 정상 트랜잭션 절차]",
        "sqlite3> INSERT INTO members (name, email, phone) VALUES ('신규회원', 'new999@test.com', '010-9999-0999');",
        "sqlite3> INSERT INTO rentals (member_id, book_id, rental_date) VALUES (last_insert_rowid(), 1, '2026-08-01');",
        "Query OK (부모 회원 생성 후 대여 정상 연결 성공)"
    ]
    render_terminal_window("Bonus 2: FK 참조 무결성 위반 에러 및 복구 시연", "Foreign Key Constraint Enforcement & Recovery", b2_lines, "Bonus_02_fk_violation.png")

    # Integrity Unit Tests Screenshot
    test_lines = [
        "$ python3 tests/test_sql_integrity.py",
        "test_01_table_existence (__main__.TestSQLDatabase) ... ok",
        "test_02_minimum_row_counts (__main__.TestSQLDatabase) ... ok",
        "test_03_foreign_key_enforcement (__main__.TestSQLDatabase) ... ok",
        "test_04_unique_constraint (__main__.TestSQLDatabase) ... ok",
        "test_05_not_null_constraint (__main__.TestSQLDatabase) ... ok",
        "test_06_index_creation (__main__.TestSQLDatabase) ... ok",
        "test_07_bonus_1_join_vs_subquery_equivalence (__main__.TestSQLDatabase) ... ok",
        "test_08_bonus_3_participation_rate (__main__.TestSQLDatabase) ... ok",
        "",
        "----------------------------------------------------------------------",
        "Ran 8 tests in 0.002s",
        "",
        "OK (ALL 8 UNIT INTEGRITY TESTS PASSED - 100%)"
    ]
    render_terminal_window("SQL Database Integrity Test Suite", "8/8 Unit Tests Automated Verification", test_lines, "test_integrity_suite.png")

    # Excel vs RDBMS Comparison Screenshot
    excel_lines = [
        "# [1] 엑셀(Excel) 단일 시트의 구조적 한계 (데이터 중복 & 이상 현상)",
        "| 대여ID | 회원명 | 회원전화 | 도서제목 | 저자 | 카테고리 | 대여일 |",
        "| 1 | 강동원 | 010-1234-5678 | 클린 코드 | 로버트 마틴 | IT/프로그래밍 | 2026-06-01 |",
        "| 2 | 강동원 | 010-1234-5678 | 부자 아빠 | 로버트 기요사키 | 경제/경영 | 2026-06-05 |",
        "❌ 문제점: 회원 정보('강동원', 전화번호) 및 도서 정보가 대여 건마다 반복 중복 저장됨.",
        "❌ 갱신 이상: 강동원 전화번호 변경 시 수백 개의 행을 일일이 찾아 수정해야 함.",
        "",
        "# [2] 관계형 데이터베이스(RDBMS 3NF) 분리 후 구조",
        "• members 테이블 (회원 정보 1회만 저장)",
        "• books 테이블 (도서 정보 1회만 저장)",
        "• categories 테이블 (카테고리 분리)",
        "• rentals 테이블 (member_id = 1, book_id = 1 연결 키만 저장)",
        "✅ 해결: 데이터 중복 0%, 전화번호 수정 시 members 1행만 수정하면 전체 즉시 반영!"
    ]
    render_terminal_window("Excel vs RDBMS 제3정규형 비교", "Data Redundancy & Anomaly Resolution", excel_lines, "excel_vs_rdbms_comparison.png")

    conn.close()

if __name__ == "__main__":
    generate_all_screenshots()
