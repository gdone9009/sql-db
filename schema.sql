-- ======================================================
-- 도서 관리 시스템 (Book Management System) DB 스키마 생성
-- DB 종류: SQLite (표준 SQL 지원)
-- ======================================================

-- SQLite 외래 키(FK) 제약 조건 활성화
PRAGMA foreign_keys = ON;

-- 기존 테이블이 존재할 경우 참조 관계 역순으로 삭제 (안전한 재생성)
DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS members;

-- 1. 회원 (members) 테이블: 도서관 회원 정보 관리
CREATE TABLE members (
    member_id INTEGER PRIMARY KEY AUTOINCREMENT, -- 회원 PK (자동 증가)
    name TEXT NOT NULL,                         -- 회원 이름 (필수입력)
    email TEXT UNIQUE NOT NULL,                  -- 이메일 (중복 불가, 필수입력)
    phone TEXT,                                  -- 연락처
    join_date DATE DEFAULT (date('now'))         -- 가입일자 (기본값: 오늘)
);

-- 2. 카테고리 (categories) 테이블: 도서 장르/분류 관리
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT, -- 카테고리 PK (자동 증가)
    category_name TEXT NOT NULL UNIQUE            -- 카테고리명 (중복 불가, 필수입력)
);

-- 3. 도서 (books) 테이블: 보유 도서 정보 관리
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,   -- 도서 PK (자동 증가)
    title TEXT NOT NULL,                         -- 도서 제목 (필수입력)
    author TEXT NOT NULL,                        -- 저자명 (필수입력)
    price INTEGER NOT NULL DEFAULT 15000,        -- 정가 (기본값: 15,000원, 집계함수 SUM/AVG 실습용)
    category_id INTEGER NOT NULL,                -- 카테고리 FK (categories 참조)
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 4. 대여 (rentals) 테이블: 회원과 도서 간 대여 이력 관리 (N:M 연결 테이블)
CREATE TABLE rentals (
    rental_id INTEGER PRIMARY KEY AUTOINCREMENT, -- 대여 기록 PK (자동 증가)
    member_id INTEGER NOT NULL,                  -- 대여 회원 FK (members 참조)
    book_id INTEGER NOT NULL,                    -- 대여 도서 FK (books 참조)
    rental_date DATE DEFAULT (date('now')),      -- 대여일자 (기본값: 오늘)
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);