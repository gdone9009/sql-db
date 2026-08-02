-- ======================================================
-- 도서 관리 시스템 (Book Management System) 핵심 SQL 쿼리 16선 + 보너스 과제
-- DB 종류: SQLite
-- ======================================================

PRAGMA foreign_keys = ON;

-- ======================================================
-- 1. 기본 조회 4개 (WHERE, ORDER BY, LIMIT 포함)
-- ======================================================

-- [Q01] 전체 도서 목록을 제목 순으로 정렬하여 상위 5개 조회 (ORDER BY, LIMIT)
SELECT book_id, title, author, price 
FROM books 
ORDER BY title ASC 
LIMIT 5;

-- [Q02] 2026년 2월 이후 가입한 회원 목록 조회 (WHERE, ORDER BY)
SELECT member_id, name, email, join_date 
FROM members 
WHERE join_date >= '2026-02-01' 
ORDER BY join_date ASC;

-- [Q03] 저자명에 '로버트'가 포함된 도서 검색 (WHERE LIKE)
SELECT book_id, title, author, price 
FROM books 
WHERE author LIKE '%로버트%';

-- [Q04] Gmail 이메일을 사용하는 회원 목록 조회 (WHERE LIKE, ORDER BY, LIMIT)
SELECT member_id, name, email 
FROM members 
WHERE email LIKE '%@gmail.com' 
ORDER BY member_id ASC 
LIMIT 3;


-- ======================================================
-- 2. 조인 5개 (INNER JOIN 3개, LEFT JOIN 2개)
-- ======================================================

-- [Q05] [INNER JOIN] 도서 제목과 연결된 카테고리 이름 함께 조회
SELECT b.book_id, b.title, b.author, c.category_name
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
ORDER BY b.book_id;

-- [Q06] [INNER JOIN] 대여 상세 이력 조회 (누가, 어떤 책을, 어떤 카테고리에서, 언제 빌렸는가?)
SELECT r.rental_id, m.name AS member_name, b.title AS book_title, c.category_name, r.rental_date
FROM rentals r
INNER JOIN members m ON r.member_id = m.member_id
INNER JOIN books b ON r.book_id = b.book_id
INNER JOIN categories c ON b.category_id = c.category_id
ORDER BY r.rental_date DESC;

-- [Q07] [INNER JOIN] 'IT/프로그래밍' 카테고리에 속한 도서와 저자, 가격 조회
SELECT b.title, b.author, b.price, c.category_name
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
WHERE c.category_name = 'IT/프로그래밍';

-- [Q08] [LEFT JOIN] 모든 카테고리와 해당하는 도서 목록 조회 (도서가 없는 카테고리도 표시)
SELECT c.category_name, b.title AS book_title
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
ORDER BY c.category_id;

-- [Q09] [LEFT JOIN] 전체 회원과 대여 기록 조회 (대여 이력이 없는 회원도 포함)
SELECT m.name AS member_name, m.email, r.rental_id, r.rental_date
FROM members m
LEFT JOIN rentals r ON m.member_id = r.member_id
ORDER BY m.member_id;


-- ======================================================
-- 3. 집계 및 통계 3개 (COUNT, SUM, AVG 중 2개 이상 + GROUP BY)
-- ======================================================

-- [Q10] [COUNT + GROUP BY] 카테고리별 등록된 도서 수량 집계
SELECT c.category_name, COUNT(b.book_id) AS total_books
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_books DESC;

-- [Q11] [COUNT + GROUP BY + ORDER BY + LIMIT] 회원별 총 대출 횟수 집계 및 대출 왕 TOP 3
SELECT m.name AS member_name, COUNT(r.rental_id) AS total_rentals
FROM members m
INNER JOIN rentals r ON m.member_id = r.member_id
GROUP BY m.member_id, m.name
ORDER BY total_rentals DESC
LIMIT 3;

-- [Q12] [SUM, AVG, COUNT + GROUP BY] 카테고리별 도서 평균 가격(AVG) 및 총 재고 가치 금액(SUM) 집계
SELECT c.category_name, 
       COUNT(b.book_id) AS book_count,
       ROUND(AVG(b.price), 0) AS avg_price,
       SUM(b.price) AS total_value
FROM categories c
INNER JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_value DESC;


-- ======================================================
-- 4. 서브쿼리 1개
-- ======================================================

-- [Q13] [서브쿼리 - NOT IN] 대여 이력이 한 번도 없는 미대여 도서 목록 조회
SELECT book_id, title, author, price
FROM books
WHERE book_id NOT IN (SELECT DISTINCT book_id FROM rentals);


-- ======================================================
-- 5. 데이터 수정 및 삭제 2개 (UPDATE, DELETE)
-- ======================================================

-- [Q14] [UPDATE] '정창석' 회원의 연락처 정보 수정
UPDATE members 
SET phone = '010-9999-8888' 
WHERE name = '정창석';

-- [Q15] [DELETE] 대여 이력이 없는 미대여 임시 테스트 도서 삭제
-- (테스트를 위해 미대여 도서를 조건으로 삭제 조치)
DELETE FROM books 
WHERE title = '임시 테스트 책' AND book_id NOT IN (SELECT book_id FROM rentals);


-- ======================================================
-- 6. 인덱스 생성 1개 (CREATE INDEX + 적용 이유)
-- ======================================================

-- [Q16] [CREATE INDEX] books 테이블의 category_id 외래키 컬럼에 인덱스 생성
-- 적용 이유: books 테이블의 category_id 컬럼에 인덱스를 생성하여 카테고리별 도서 조회 및 categories 테이블과의 JOIN 연산 실행 속도를 최적화합니다.
CREATE INDEX IF NOT EXISTS idx_books_category_id ON books(category_id);


-- ======================================================
-- 7. 보너스 과제 (Bonus Tasks)
-- ======================================================

-- [보너스 1] 조인과 서브쿼리로 동일한 요구사항 풀기 및 비교
-- 요구사항: 'IT/프로그래밍' 카테고리에 속한 도서 목록 조회

-- 방식 A (JOIN 방식):
SELECT b.title, b.author 
FROM books b 
JOIN categories c ON b.category_id = c.category_id 
WHERE c.category_name = 'IT/프로그래밍';

-- 방식 B (서브쿼리 방식):
SELECT title, author 
FROM books 
WHERE category_id = (SELECT category_id FROM categories WHERE category_name = 'IT/프로그래밍');

-- 비교 분석:
-- 1. Readability (가독성): 서브쿼리는 직관적으로 단일 카테고리 ID를 조건절에 대입하므로 비교적 단순하지만, JOIN 방식은 관계형 데이터의 결합을 명시적으로 표현합니다.
-- 2. Performance (성능): 복잡한 대용량 테이블 환경에서는 RDBMS의 쿼리 최적화기(Optimizer)가 JOIN을 인덱스 스캔과 함께 처리하여 실행 계획(Execution Plan)에서 우수한 성능을 나타내는 경우가 많습니다.

-- [보너스 2] 데이터 정합성 깨뜨리기 시도 (FK 에러 테스트)
-- 실행 의도: 존재하지 않는 회원(member_id = 999)으로 대여 기록을 삽입하려는 시도
-- 주석 해제 후 실행 시 'FOREIGN KEY constraint failed' 에러 발생
-- INSERT INTO rentals (member_id, book_id, rental_date) VALUES (999, 1, '2026-08-01');
-- 해결 방법: 부모 테이블인 members에 member_id가 999인 회원을 먼저 INSERT 하거나, 존재하는 member_id (예: 1~10)를 사용해야 참조 무결성이 유지됩니다.

-- [보너스 3] 미니 리포트 - 도서관 DB 핵심 지표 3선
-- 지표 1: 가장 인기 있는 도서 TOP 3 (대여 빈도 기준)
SELECT b.title, COUNT(r.rental_id) AS rental_count
FROM books b
JOIN rentals r ON b.book_id = r.book_id
GROUP BY b.book_id, b.title
ORDER BY rental_count DESC
LIMIT 3;

-- 지표 2: 카테고리별 보유 자산 금액 및 평균 도서 가격
SELECT c.category_name, COUNT(b.book_id) AS book_count, SUM(b.price) AS total_asset_price, ROUND(AVG(b.price), 0) AS avg_book_price
FROM categories c
JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_asset_price DESC;

-- 지표 3: 회원 대여 서비스 참여율 (전체 회원 중 최소 1회 이상 대여한 회원의 비율)
SELECT 
    COUNT(DISTINCT r.member_id) AS active_members,
    (SELECT COUNT(*) FROM members) AS total_members,
    ROUND(CAST(COUNT(DISTINCT r.member_id) AS FLOAT) / (SELECT COUNT(*) FROM members) * 100, 1) || '%' AS participation_rate
FROM rentals r;