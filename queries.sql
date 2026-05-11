-- [조인 쿼리] 누가 어떤 책을 빌렸는지 이름과 제목으로 보기
SELECT m.name AS 회원명, b.title AS 도서명, r.rental_date AS 대여일
FROM rentals r
JOIN members m ON r.member_id = m.member_id      -- 대여 기록과 회원 테이블 합치기
JOIN books b ON r.book_id = b.book_id;         -- 대여 기록과 도서 테이블 합치기

-- [집계 쿼리] 카테고리별로 책이 몇 권씩 있는지 세어보기
SELECT c.category_name, COUNT(b.book_id) AS 도서수
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id -- 책이 없는 카테고리도 나오게 LEFT JOIN
GROUP BY c.category_name; -- 카테고리 이름별로 묶어서 숫자를 셈

-- [서브쿼리] 대여 기록이 한 번이라도 있는 도서의 제목만 가져오기
SELECT title 
FROM books 
WHERE book_id IN (SELECT DISTINCT book_id FROM rentals); -- rentals에 있는 번호만 골라냄