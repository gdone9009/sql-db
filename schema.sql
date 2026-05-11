-- 1. 회원(members) 테이블: 서비스를 이용하는 사람들의 정보
CREATE TABLE members (
    member_id INTEGER PRIMARY KEY AUTOINCREMENT, -- 고유 번호 (자동으로 1, 2, 3... 증가)
    name VARCHAR(50) NOT NULL,                    -- 이름 (비어있으면 안 됨)
    email VARCHAR(100) UNIQUE NOT NULL,           -- 이메일 (중복 안 됨, 필수 입력)
    join_date DATE DEFAULT (date('now'))          -- 가입일 (입력 안 하면 오늘 날짜 자동 입력)
);

-- 2. 카테고리(categories) 테이블: 책의 장르 분류
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT, -- 카테고리 고유 번호
    category_name VARCHAR(50) NOT NULL UNIQUE       -- 장르 이름 (중복 안 됨)
);

-- 3. 도서(books) 테이블: 도서관이 보유한 책 정보
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,     -- 도서 고유 번호
    title VARCHAR(100) NOT NULL,                    -- 책 제목
    author VARCHAR(50),                             -- 저자
    category_id INTEGER,                            -- 어떤 장르인지 (카테고리 번호)
    -- [외래키] category_id는 categories 테이블의 id를 반드시 참조해야 함
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 4. 대여(rentals) 테이블: 누가, 어떤 책을, 언제 빌렸는가?
CREATE TABLE rentals (
    rental_id INTEGER PRIMARY KEY AUTOINCREMENT,    -- 대여 기록 고유 번호
    member_id INTEGER NOT NULL,                     -- 빌린 회원 번호
    book_id INTEGER NOT NULL,                       -- 빌린 책 번호
    rental_date DATE DEFAULT (date('now')),         -- 빌린 날짜
    -- [외래키] 회원이 존재해야 빌릴 수 있음
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    -- [외래키] 책이 존재해야 빌릴 수 있음
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);