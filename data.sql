-- 카테고리 입력
INSERT INTO categories (category_name) VALUES ('소설'), ('IT'), ('경제'), ('철학'), ('역사'), ('예술'), ('과학'), ('에세이'), ('자기계발'), ('심리');

-- 회원 입력
INSERT INTO members (name, email) VALUES ('정창석', 'js@gmail.com'), ('김철수', 'chul@naver.com'), ('이영희', 'yh@daum.net'), ('박민수', 'ms@gmail.com'), ('최지우', 'jw@naver.com'), ('강하늘', 'sky@daum.net'), ('윤서준', 'sj@gmail.com'), ('조예은', 'ye@naver.com'), ('한결', 'kg@daum.net'), ('임소윤', 'sy@gmail.com');

-- 도서 입력 (IT 카테고리는 2번, 경제는 3번 등 설정된 번호에 맞게)
INSERT INTO books (title, author, category_id) VALUES ('클린 코드', '로버트 마틴', 2), ('부자 아빠 가난한 아빠', '로버트 기요사키', 3), ('사피엔스', '유발 하라리', 5), ('미움받을 용기', '고가 후미타케', 10), ('파친코', '이민진', 1), ('자본론', '칼 마르크스', 3), ('총 균 쇠', '재레드 다이아몬드', 5), ('이기적 유전자', '리처드 도킨스', 7), ('코스모스', '칼 세이건', 7), ('데미안', '헤르만 헤세', 1);

-- 대여 기록 입력 (누가 어떤 책을 빌렸는지 연결)
INSERT INTO rentals (member_id, book_id) VALUES (1, 1), (1, 2), (2, 1), (3, 5), (4, 3), (5, 9), (6, 10), (7, 4), (8, 1), (9, 2);