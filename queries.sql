-- ======================================================
-- 1. 기초 조회 및 필터링 (기초 단계)
-- ======================================================

-- 1) 모든 도서의 목록을 제목 순으로 조회
SELECT * FROM books ORDER BY title ASC;

-- 2) 2026년에 가입한 회원만 조회 (날짜 함수 활용)
SELECT * FROM members WHERE join_date LIKE '2026%';

-- 3) 특정 저자(로버트 마틴)의 책만 골라보기
SELECT title, author FROM books WHERE author = '로버트 마틴';

-- 4) 이메일이 'gmail.com'으로 끝나는 회원 찾기 (패턴 매칭)
SELECT name, email FROM members WHERE email LIKE '%gmail.com';

-- 5) 아직 한 번도 대출되지 않은 도서 조회 (서브쿼리 활용)
SELECT title FROM books 
WHERE book_id NOT IN (SELECT DISTINCT book_id FROM rentals);


-- ======================================================
-- 2. 관계 연결 및 조인 (중급 단계: Alias 활용)
-- ======================================================

-- 6) 도서명과 해당 도서의 카테고리명을 합쳐서 보기
SELECT b.title, c.category_name
FROM books b
JOIN categories c ON b.category_id = c.category_id;

-- 7) 대출 기록 상세: 누가, 어떤 책을, 언제 빌렸는가?
SELECT m.name AS 회원명, b.title AS 도서명, r.rental_date AS 대여일
FROM rentals r
JOIN members m ON r.member_id = m.member_id
JOIN books b ON r.book_id = b.book_id;

-- 8) 'IT' 카테고리에 속한 도서들만 조인해서 보기
SELECT b.title, c.category_name
FROM books b
JOIN categories c ON b.category_id = c.category_id
WHERE c.category_name = 'IT';


-- ======================================================
-- 3. 집계 및 통계 (고급 단계: 비즈니스 지표)
-- ======================================================

-- 9) 카테고리별 도서 보유 수량 (통계)
SELECT c.category_name, COUNT(b.book_id) AS 도서수
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_name;

-- 10) 회원별 총 대출 횟수 (우수 회원 파악)
SELECT m.name, COUNT(r.rental_id) AS 대출건수
FROM members m
JOIN rentals r ON m.member_id = r.member_id
GROUP BY m.member_id
ORDER BY 대출건수 DESC;

-- 11) 가장 인기 있는 도서 TOP 3 (보너스 과제 1번)
SELECT b.title, COUNT(r.rental_id) AS total_rentals
FROM books b
JOIN rentals r ON b.book_id = r.book_id
GROUP BY b.book_id
ORDER BY total_rentals DESC
LIMIT 3;

-- 12) 한 번이라도 대출을 한 적이 있는 회원의 수 (집계 함수)
SELECT COUNT(DISTINCT member_id) AS '대출 경험 회원수' FROM rentals;


-- ======================================================
-- 4. 데이터 수정 및 유지보수 (관리 단계)
-- ======================================================

-- 13) 특정 회원의 연락처 업데이트 (데이터 수정)
UPDATE members SET phone = '010-9999-9999' WHERE name = '정창석';

-- 14) 대출 기록이 없는 도서 중 특정 도서 삭제 (데이터 관리)
DELETE FROM books WHERE title = '삭제예정도서' AND book_id NOT IN (SELECT book_id FROM rentals);

-- 15) [종합] 장르별 평균 대출 빈도 (복합 쿼리)
-- 어떤 장르의 책들이 도서관에서 활발히 소비되는지 파악
SELECT c.category_name, COUNT(r.rental_id) AS total_rentals
FROM categories c
JOIN books b ON c.category_id = b.category_id
JOIN rentals r ON b.book_id = r.book_id
GROUP BY c.category_name
ORDER BY total_rentals DESC;