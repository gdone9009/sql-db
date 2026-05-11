-- 기존에 테이블이 혹시 있다면 삭제하고 새로 만듭니다. (초기화 스크립트의 안전성 확보)
DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS members;

-- 1. 회원(members) 테이블: 도서관 서비스를 이용하는 사용자 정보
CREATE TABLE members (
    -- AUTOINCREMENT를 통해 회원 번호가 1번부터 자동으로 생성됩니다.
    member_id INTEGER PRIMARY KEY AUTOINCREMENT, 
    
    -- NOT NULL: 이름은 반드시 입력해야 합니다.
    name TEXT NOT NULL, 
    
    -- UNIQUE: 같은 이메일로 중복 가입을 할 수 없습니다.
    email TEXT UNIQUE NOT NULL, 
    
    -- 연락처 정보 (선택 입력)
    phone TEXT, 
    
    -- DEFAULT: 날짜를 생략하고 입력(INSERT)하면 '현재 날짜'가 자동으로 들어갑니다.
    join_date DATE DEFAULT (date('now')) 
);

-- 2. 카테고리(categories) 테이블: 도서의 장르(소설, IT 등)를 관리
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- UNIQUE: 동일한 장르 이름이 중복 생성되는 것을 방지합니다.
    category_name TEXT NOT NULL UNIQUE 
);

-- 3. 도서(books) 테이블: 보유하고 있는 도서의 상세 정보
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- 책 제목은 필수값입니다.
    title TEXT NOT NULL, 
    
    -- 저자 정보
    author TEXT, 
    
    -- 해당 도서가 속한 카테고리 번호 (categories 테이블의 category_id를 저장)
    category_id INTEGER, 
    
    -- [외래 키 제약 조건]
    -- 만약 categories 테이블에 존재하지 않는 category_id를 넣으려고 하면 에러를 발생시켜
    -- 데이터의 정합성(부모 없는 자식 데이터 방지)을 지킵니다.
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 4. 대여(rentals) 테이블: '누가', '어떤 책'을 빌렸는지 기록하는 핵심 테이블
CREATE TABLE rentals (
    rental_id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- 대여한 회원 번호 (members 테이블 참조)
    member_id INTEGER NOT NULL, 
    
    -- 대여한 도서 번호 (books 테이블 참조)
    book_id INTEGER NOT NULL, 
    
    -- 대여일 (기본값 오늘)
    rental_date DATE DEFAULT (date('now')), 
    
    -- [외래 키 제약 조건 1] 회원이 먼저 존재해야 대여 기록을 만들 수 있습니다.
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    
    -- [외래 키 제약 조건 2] 도서가 먼저 존재해야 대여 기록을 만들 수 있습니다.
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);