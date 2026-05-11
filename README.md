# 📊 SQL-DB: 관계형 데이터베이스 설계 및 분석 리포트

이 저장소는 **Codyssey AI All-in-One** 과정의 미션 12(SQL 데이터베이스)를 수행한 기록입니다. 단순한 데이터 저장을 넘어, 데이터 간의 관계 설계와 쿼리 최적화, 그리고 관리 자동화를 실습했습니다.

## 🛠 1. 개발 및 실행 환경

* **OS**: macOS (iMac 내장 SQLite 3.43.2 활용)
* **DB 엔진**: SQLite3
* **관리 도구**: Terminal (CLI), VS Code, DB Browser for SQLite (GUI)

---

## 🏗 2. 데이터 모델링 (Schema)

총 4개의 테이블을 설계하여 도서 대여 시스템의 핵심 비즈니스 로직을 구현했습니다.

### 테이블 간 관계 (1:N)

1. **categories → books**: 한 카테고리에 여러 권의 책이 속함
2. **members → rentals**: 한 회원이 여러 번의 대여 기록을 가짐
3. **books → rentals**: 한 권의 책이 여러 번 대여될 수 있음

### 주요 제약 조건

* `PRIMARY KEY AUTOINCREMENT`: 고유 번호 자동 생성
* `FOREIGN KEY`: 참조 무결성을 유지하여 존재하지 않는 ID 참조 방지
* `UNIQUE / NOT NULL`: 데이터의 중복 방지 및 필수값 보장

---

## ⚡ 3. 효율적인 쿼리 작성 (Alias & Join)

복잡한 조인 문을 작성할 때 가독성을 높이기 위해 테이블 별칭(Alias)을 적극 활용했습니다.

* **`m`**: members (회원)
* **`b`**: books (도서)
* **`r`**: rentals (대여)
* **`c`**: categories (카테고리)

---

## 🔍 4. 주요 분석 쿼리 (미니 리포트)

### ① 대여 현황 상세 조회 (JOIN)

어떤 회원이 어떤 책을 언제 빌렸는지 세 테이블을 결합하여 출력합니다.

```sql
SELECT m.name AS 회원명, b.title AS 도서명, r.rental_date AS 대여일
FROM rentals r
JOIN members m ON r.member_id = m.member_id
JOIN books b ON r.book_id = b.book_id;

```

### ② 장르별 보유 도서 통계 (GROUP BY & LEFT JOIN)

도서가 없는 카테고리도 포함하여 전체 통계를 산출합니다.

```sql
SELECT c.category_name, COUNT(b.book_id) AS 도서수
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_name;

```

---

## 🤖 5. 관리 자동화 및 확장 (Automation & View)

### 자동화 스크립트 (`init.sql`)

스키마 생성, 데이터 입력, 쿼리 실행을 한 번에 처리하기 위해 통합 실행 파일을 운용합니다.

```sql
-- 실행: sqlite3 mission12.db ".read init.sql"
.read schema.sql
.read data.sql
.read queries.sql

```

### 가상 테이블 (VIEW) 생성

자주 사용되는 복잡한 조인 결과를 `VIEW`로 저장하여 재사용성을 높였습니다.

```sql
CREATE VIEW v_rental_status AS
SELECT m.name, b.title, r.rental_date
FROM rentals r
JOIN members m ON r.member_id = m.member_id
JOIN books b ON r.book_id = b.book_id;

```

---

## 🛡 6. 보너스 과제: 정합성 검증

* **FK 제약조건 테스트**: 존재하지 않는 `member_id(999)`를 `rentals` 테이블에 삽입 시도 시, SQLite 엔진이 참조 무결성 위반 에러를 발생시키며 데이터 오염을 방지하는 것을 확인했습니다.
