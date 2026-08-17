import sqlite3
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
db_path = os.path.join(BASE_DIR, "mission12.db")
results_dir = os.path.join(BASE_DIR, "results")

os.makedirs(results_dir, exist_ok=True)

if os.path.exists(db_path):
    os.remove(db_path)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()
cursor.execute("PRAGMA foreign_keys = ON;")

# 1. Execute schema.sql
with open(os.path.join(BASE_DIR, "schema.sql"), "r", encoding="utf-8") as f:
    schema_sql = f.read()
cursor.executescript(schema_sql)

# 2. Execute data.sql
with open(os.path.join(BASE_DIR, "data.sql"), "r", encoding="utf-8") as f:
    data_sql = f.read()
cursor.executescript(data_sql)

# 3. Parse and run individual queries from queries.sql
queries = [
    ("Q01", "전체 도서 목록을 제목 순으로 정렬하여 상위 5개 조회", 
     "SELECT book_id, title, author, price FROM books ORDER BY title ASC LIMIT 5;"),
    
    ("Q02", "2026년 2월 이후 가입한 회원 목록 조회", 
     "SELECT member_id, name, email, join_date FROM members WHERE join_date >= '2026-02-01' ORDER BY join_date ASC;"),
    
    ("Q03", "저자명에 '로버트'가 포함된 도서 검색", 
     "SELECT book_id, title, author, price FROM books WHERE author LIKE '%로버트%';"),
    
    ("Q04", "Gmail 이메일을 사용하는 회원 목록 조회", 
     "SELECT member_id, name, email FROM members WHERE email LIKE '%@gmail.com' ORDER BY member_id ASC LIMIT 3;"),
    
    ("Q05", "도서 제목과 연결된 카테고리 이름 함께 조회 (INNER JOIN)", 
     "SELECT b.book_id, b.title, b.author, c.category_name FROM books b INNER JOIN categories c ON b.category_id = c.category_id ORDER BY b.book_id;"),
    
    ("Q06", "대여 상세 이력 조회 (INNER JOIN 3개 테이블)", 
     "SELECT r.rental_id, m.name AS member_name, b.title AS book_title, c.category_name, r.rental_date FROM rentals r INNER JOIN members m ON r.member_id = m.member_id INNER JOIN books b ON r.book_id = b.book_id INNER JOIN categories c ON b.category_id = c.category_id ORDER BY r.rental_date DESC;"),
    
    ("Q07", "'IT/프로그래밍' 카테고리에 속한 도서 조회 (INNER JOIN)", 
     "SELECT b.title, b.author, b.price, c.category_name FROM books b INNER JOIN categories c ON b.category_id = c.category_id WHERE c.category_name = 'IT/프로그래밍';"),
    
    ("Q08", "모든 카테고리와 해당하는 도서 목록 조회 (LEFT JOIN)", 
     "SELECT c.category_name, b.title AS book_title FROM categories c LEFT JOIN books b ON c.category_id = b.category_id ORDER BY c.category_id;"),
    
    ("Q09", "전체 회원과 대여 기록 조회 (LEFT JOIN)", 
     "SELECT m.name AS member_name, m.email, r.rental_id, r.rental_date FROM members m LEFT JOIN rentals r ON m.member_id = r.member_id ORDER BY m.member_id;"),
    
    ("Q10", "카테고리별 등록된 도서 수량 집계 (COUNT + GROUP BY)", 
     "SELECT c.category_name, COUNT(b.book_id) AS total_books FROM categories c LEFT JOIN books b ON c.category_id = b.category_id GROUP BY c.category_id, c.category_name ORDER BY total_books DESC;"),
    
    ("Q11", "회원별 대출 건수 집계 및 최다 대출 회원 TOP 3 (COUNT + GROUP BY)", 
     "SELECT m.name AS member_name, COUNT(r.rental_id) AS total_rentals FROM members m INNER JOIN rentals r ON m.member_id = r.member_id GROUP BY m.member_id, m.name ORDER BY total_rentals DESC LIMIT 3;"),
    
    ("Q12", "카테고리별 도서 평균 가격 및 총 재고 가치 금액 집계 (SUM + AVG + GROUP BY)", 
     "SELECT c.category_name, COUNT(b.book_id) AS book_count, ROUND(AVG(b.price), 0) AS avg_price, SUM(b.price) AS total_value FROM categories c INNER JOIN books b ON c.category_id = b.category_id GROUP BY c.category_id, c.category_name ORDER BY total_value DESC;"),
    
    ("Q13", "대여 이력이 한 번도 없는 미대여 도서 목록 조회 (서브쿼리 - NOT IN)", 
     "SELECT book_id, title, author, price FROM books WHERE book_id NOT IN (SELECT DISTINCT book_id FROM rentals);"),
    
    ("Q14", "'강동원' 회원의 연락처 정보 수정 (UPDATE)", 
     "UPDATE members SET phone = '010-9999-8888' WHERE name = '강동원';"),
    
    ("Q15", "대여 이력이 없는 미대여 임시 테스트 도서 삭제 (DELETE)", 
     "DELETE FROM books WHERE title = '임시 테스트 책' AND book_id NOT IN (SELECT book_id FROM rentals);"),
    
    ("Q16", "books 테이블의 category_id 컬럼 인덱스 생성 (CREATE INDEX)", 
     "CREATE INDEX IF NOT EXISTS idx_books_category_id ON books(category_id);"),

    ("Bonus_01A", "보너스 1-A: JOIN 방식으로 IT/프로그래밍 도서 조회",
     "SELECT b.title, b.author FROM books b JOIN categories c ON b.category_id = c.category_id WHERE c.category_name = 'IT/프로그래밍';"),

    ("Bonus_01B", "보너스 1-B: 서브쿼리 방식으로 IT/프로그래밍 도서 조회",
     "SELECT title, author FROM books WHERE category_id = (SELECT category_id FROM categories WHERE category_name = 'IT/프로그래밍');"),

    ("Bonus_03A", "보너스 3-1: 가장 인기 있는 도서 TOP 3 (핵심 지표 1)",
     "SELECT b.title, COUNT(r.rental_id) AS rental_count FROM books b JOIN rentals r ON b.book_id = r.book_id GROUP BY b.book_id, b.title ORDER BY rental_count DESC LIMIT 3;"),

    ("Bonus_03B", "보너스 3-2: 카테고리별 자산 가치 및 평균가 (핵심 지표 2)",
     "SELECT c.category_name, COUNT(b.book_id) AS book_count, SUM(b.price) AS total_asset_price, ROUND(AVG(b.price), 0) AS avg_book_price FROM categories c JOIN books b ON c.category_id = b.category_id GROUP BY c.category_id, c.category_name ORDER BY total_asset_price DESC;"),

    ("Bonus_03C", "보너스 3-3: 회원 대여 서비스 참여율 (핵심 지표 3)",
     "SELECT COUNT(DISTINCT r.member_id) AS active_members, (SELECT COUNT(*) FROM members) AS total_members, ROUND(CAST(COUNT(DISTINCT r.member_id) AS FLOAT) / (SELECT COUNT(*) FROM members) * 100, 1) || '%' AS participation_rate FROM rentals r;")
]

summary_lines = ["======================================================",
                 "  도서 관리 시스템 DB 쿼리 실행 결과 보고서 (SQLite)",
                 "======================================================\n"]

for q_id, desc, sql in queries:
    summary_lines.append(f"[{q_id}] {desc}")
    summary_lines.append(f"SQL: {sql}")
    
    file_content = [f"쿼리 ID: {q_id}", f"설명: {desc}", f"SQL:\n{sql}\n", "실행 결과:"]
    
    if sql.startswith("UPDATE") or sql.startswith("DELETE") or sql.startswith("CREATE INDEX"):
        cursor.execute(sql)
        conn.commit()
        res_str = f"성공적으로 실행됨 (영향을 받은 행 수: {cursor.rowcount})"
        summary_lines.append(f"결과: {res_str}\n" + "-"*50)
        file_content.append(res_str)
    else:
        cursor.execute(sql)
        cols = [description[0] for description in cursor.description]
        rows = cursor.fetchall()
        
        header = " | ".join(cols)
        sep = "-+-".join(["-" * len(col) for col in cols])
        summary_lines.append(header)
        summary_lines.append(sep)
        file_content.append(header)
        file_content.append(sep)
        
        for r in rows:
            row_str = " | ".join([str(val) if val is not None else "NULL" for val in r])
            summary_lines.append(row_str)
            file_content.append(row_str)
        summary_lines.append(f"(총 {len(rows)}개 행 조회됨)\n" + "-"*50)
        file_content.append(f"(총 {len(rows)}개 행 조회됨)")
        
    with open(os.path.join(results_dir, f"{q_id}.txt"), "w", encoding="utf-8") as f_q:
        f_q.write("\n".join(file_content) + "\n")

# Also perform Bonus 2 FK error simulation
bonus_2_log = []
bonus_2_log.append("[Bonus_02] 외래 키(FK) 제약 조건 무결성 검증 에러 시도")
bonus_2_log.append("SQL: INSERT INTO rentals (member_id, book_id, rental_date) VALUES (999, 1, '2026-08-01');")
try:
    cursor.execute("INSERT INTO rentals (member_id, book_id, rental_date) VALUES (999, 1, '2026-08-01');")
except sqlite3.IntegrityError as e:
    res_err = f"예상대로 에러 발생하여 억제됨: {e}"
    bonus_2_log.append(f"결과: {res_err}")
    bonus_2_log.append("해결 방법: members 테이블에 member_id가 999인 부모 회원을 먼저 생성하거나, 존재하는 member_id를 입력해야 참조 무결성이 보장됩니다.")

summary_lines.append("\n".join(bonus_2_log))

with open(os.path.join(results_dir, "Bonus_02.txt"), "w", encoding="utf-8") as f_b:
    f_b.write("\n".join(bonus_2_log) + "\n")

with open(os.path.join(results_dir, "query_results.txt"), "w", encoding="utf-8") as f_out:
    f_out.write("\n".join(summary_lines) + "\n")

conn.close()
print("All query results successfully generated in results/ directory!")
