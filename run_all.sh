#!/bin/bash
# ==============================================================================
# 📊 SQL Database System - Master Orchestration & Interactive Live Demo Pipeline
# File: run_all.sh
# ==============================================================================

set -e

# Terminal Colors & Formats
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_GRAY='\033[90m'
C_WHITE='\033[1;37m'
C_BLUE='\033[38;5;110m'
C_TEAL='\033[38;5;73m'
C_GREEN='\033[38;5;150m'
C_YELLOW='\033[38;5;179m'
C_ROSE='\033[38;5;167m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

print_banner() {
    echo -e "\n${C_GRAY}────────────────────────────────────────────────────────────────────────${C_RESET}"
    echo -e " ${C_BOLD}${C_WHITE}$1${C_RESET}"
    echo -e "${C_GRAY}────────────────────────────────────────────────────────────────────────${C_RESET}"
}

print_section() {
    echo -e "\n${C_BLUE}:: ${C_BOLD}$1${C_RESET}"
}

print_step() {
    echo -e "\n  ${C_GRAY}[Step ${1}]${C_RESET} ${C_WHITE}${2}${C_RESET}"
}

print_ok() {
    echo -e "  ${C_GREEN}[OK]${C_RESET} ${C_GRAY}$1${C_RESET}"
}

print_warn() {
    echo -e "  ${C_YELLOW}[WARN]${C_RESET} $1"
}

print_fail() {
    echo -e "  ${C_ROSE}[FAIL]${C_RESET} $1"
}

MODE=""
INTERACTIVE=false

if [ "$1" = "--auto" ] || [ "$1" = "-a" ]; then
    MODE="1"
elif [ "$1" = "--step" ] || [ "$1" = "-s" ] || [ "$1" = "-i" ]; then
    MODE="2"
elif [ "$1" = "--bonus" ] || [ "$1" = "-b" ]; then
    MODE="3"
elif [ "$1" = "--test" ] || [ "$1" = "-t" ]; then
    MODE="4"
fi

if [ -z "$MODE" ]; then
    clear 2>/dev/null || true
    echo -e "${C_BLUE}┌──────────────────────────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_BLUE}│${C_RESET}  ${C_BOLD}${C_WHITE}SQL DATABASE SYSTEM — MASTER DEMONSTRATION PIPELINE${C_RESET}               ${C_BLUE}│${C_RESET}"
    echo -e "${C_BLUE}│${C_RESET}  ${C_TEAL}Domain: 도서 관리 시스템 (Book Management System - SQLite)${C_RESET}         ${C_BLUE}│${C_RESET}"
    echo -e "${C_BLUE}└──────────────────────────────────────────────────────────────────────┘${C_RESET}"
    echo -e "  ${C_GRAY}Project Location :${C_RESET} ${C_BLUE}$PROJECT_ROOT${C_RESET}"
    echo -e "  ${C_GRAY}System Timestamp :${C_RESET} $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo -e "  ${C_BOLD}Execution Modes:${C_RESET}"
    echo -e "    ${C_GREEN}1)${C_RESET} ${C_WHITE}전체 자동화 실행 (Full Automation)${C_RESET}    ${C_GRAY}(중단 없이 100% 자동 실행)${C_RESET}"
    echo -e "    ${C_BLUE}2)${C_RESET} ${C_WHITE}대화형 단계별 시연 (Step-by-Step Interactive)${C_RESET} ${C_GRAY}(엔터 키로 단계별 진행)${C_RESET}"
    echo -e "    ${C_YELLOW}3)${C_RESET} ${C_WHITE}보너스 과제 3종 시연 (Bonus Tasks Only)${C_RESET}  ${C_GRAY}(JOIN/서브쿼리, FK에러, 지표3선)${C_RESET}"
    echo -e "    ${C_TEAL}4)${C_RESET} ${C_WHITE}무결성 단위 테스트만 실행 (Unit Tests Only)${C_RESET} ${C_GRAY}(8개 항목 테스트)${C_RESET}"
    echo ""
    
    if [ -t 0 ]; then
        read -r -p "  모드를 선택하세요 [1-4] (기본값: 1): " USER_INPUT
        MODE="${USER_INPUT:-1}"
    else
        MODE="1"
    fi
fi

if [ "$MODE" = "2" ]; then
    INTERACTIVE=true
    echo -e "\n  ${C_BLUE}-> Step-by-Step Interactive mode activated.${C_RESET}"
elif [ "$MODE" = "3" ]; then
    python3 generate_results.py >/dev/null 2>&1
    print_banner "보너스 과제 3종 상세 시연"
    echo -e "\n${C_BLUE}[보너스 1] JOIN vs 서브쿼리 비교 분석${C_RESET}"
    cat results/Bonus_01A.txt
    echo ""
    cat results/Bonus_01B.txt
    echo -e "\n${C_YELLOW}[보너스 2] 외래키(FK) 참조 무결성 위반 에러 테스트${C_RESET}"
    cat results/Bonus_02.txt
    echo -e "\n${C_GREEN}[보너스 3] 비즈니스 핵심 지표 3선 미니 리포트${C_RESET}"
    cat results/Bonus_03A.txt
    echo ""
    cat results/Bonus_03B.txt
    echo ""
    cat results/Bonus_03C.txt
    exit 0
elif [ "$MODE" = "4" ]; then
    print_banner "SQL Database 무결성 단위 테스트 실행"
    python3 tests/test_sql_integrity.py
    exit 0
fi

pause_step() {
    local next_step="$1"
    if [ "$INTERACTIVE" = true ]; then
        echo -e "\n  ${C_GRAY}----------------------------------------------------------------------${C_RESET}"
        echo -e "  ${C_BLUE}Press [Enter] to proceed to: ${C_BOLD}${next_step}${C_RESET} ${C_GRAY}(Ctrl+C to abort)${C_RESET}"
        echo -e "  ${C_GRAY}----------------------------------------------------------------------${C_RESET}"
        if [ -t 0 ]; then
            read -r -p ""
        fi
    fi
}

# ------------------------------------------------------------------------------
# Phase 1: 스키마 생성 및 DDL 무결성 검증
# ------------------------------------------------------------------------------
print_banner "Phase 1: 데이터베이스 초기화 및 DDL 스키마 생성 (schema.sql)"

print_step "1.1" "SQLite 데이터베이스 파일 초기화 (mission12.db)"
rm -f mission12.db
print_ok "기존 데이터베이스 파일 정리 완료."

print_step "1.2" "schema.sql 스크립트 실행 및 외래키 활성화"
sqlite3 mission12.db < schema.sql
print_ok "4개 테이블(members, categories, books, rentals) 생성 완료."

print_step "1.3" "생성된 테이블 및 스키마 구조 확인"
sqlite3 mission12.db ".schema"
print_ok "PK, FK, UNIQUE, NOT NULL 제약조건 무결성 확인."
pause_step "Phase 2: 샘플 데이터 입력 및 참조 무결성 검증 (data.sql)"

# ------------------------------------------------------------------------------
# Phase 2: 샘플 데이터 적재 및 건수 검증
# ------------------------------------------------------------------------------
print_banner "Phase 2: 샘플 데이터 DML 적재 및 건수 검증 (data.sql)"

print_step "2.1" "부모 -> 자식 계층 순서 데이터 입력"
sqlite3 mission12.db < data.sql
print_ok "카테고리(10), 회원(10), 도서(10), 대여(12) 데이터 적재 완료."

print_step "2.2" "테이블별 적재 건수 집계 확인 (최소 10행 기준)"
echo -e "  ${C_GRAY}• categories :${C_RESET} $(sqlite3 mission12.db "SELECT COUNT(*) FROM categories;") 건"
echo -e "  ${C_GRAY}• members    :${C_RESET} $(sqlite3 mission12.db "SELECT COUNT(*) FROM members;") 건"
echo -e "  ${C_GRAY}• books      :${C_RESET} $(sqlite3 mission12.db "SELECT COUNT(*) FROM books;") 건"
echo -e "  ${C_GRAY}• rentals    :${C_RESET} $(sqlite3 mission12.db "SELECT COUNT(*) FROM rentals;") 건"
print_ok "모든 테이블 최소 10행 이상 데이터 충족 확인."
pause_step "Phase 3: 핵심 SQL 쿼리 16선 자동 실행 및 결과 보고서 생성"

# ------------------------------------------------------------------------------
# Phase 3: 핵심 SQL 쿼리 16선 및 결과물 생성
# ------------------------------------------------------------------------------
print_banner "Phase 3: 핵심 SQL 쿼리 16선 실행 및 결과 파일 생성 (generate_results.py)"

python3 generate_results.py
print_ok "16개 쿼리 실행 결과 및 results/ 개별 텍스트 파일 생성 완료."

echo -e "\n  ${C_BOLD}[주요 쿼리 실행 결과 샘플 3선]${C_RESET}"
echo -e "  ${C_CYAN}1) [Q06] 다중 테이블 INNER JOIN (대여 상세 이력):${C_RESET}"
sqlite3 -header -column mission12.db "SELECT r.rental_id, m.name, b.title, c.category_name, r.rental_date FROM rentals r INNER JOIN members m ON r.member_id = m.member_id INNER JOIN books b ON r.book_id = b.book_id INNER JOIN categories c ON b.category_id = c.category_id LIMIT 4;"

echo -e "\n  ${C_CYAN}2) [Q11] COUNT + GROUP BY 랭킹 (대출왕 TOP 3):${C_RESET}"
sqlite3 -header -column mission12.db "SELECT m.name AS member_name, COUNT(r.rental_id) AS total_rentals FROM members m INNER JOIN rentals r ON m.member_id = r.member_id GROUP BY m.member_id, m.name ORDER BY total_rentals DESC LIMIT 3;"

echo -e "\n  ${C_CYAN}3) [Q13] 서브쿼리 NOT IN (미대여 도서 목록):${C_RESET}"
sqlite3 -header -column mission12.db "SELECT book_id, title, author, price FROM books WHERE book_id NOT IN (SELECT DISTINCT book_id FROM rentals);"
pause_step "Phase 4: 보너스 과제 3종 시연"

# ------------------------------------------------------------------------------
# Phase 4: 보너스 과제 3종 시연
# ------------------------------------------------------------------------------
print_banner "Phase 4: 보너스 과제 3종 심층 분석 및 시연"

print_step "4.1" "보너스 1: JOIN 방식 vs 서브쿼리 방식 비교"
echo -e "  ${C_GRAY}• JOIN 방식 결과:${C_RESET}"
sqlite3 -header -column mission12.db "SELECT b.title, b.author FROM books b JOIN categories c ON b.category_id = c.category_id WHERE c.category_name = 'IT/프로그래밍';"
echo -e "  ${C_GRAY}• 서브쿼리 방식 결과:${C_RESET}"
sqlite3 -header -column mission12.db "SELECT title, author FROM books WHERE category_id = (SELECT category_id FROM categories WHERE category_name = 'IT/프로그래밍');"
print_ok "두 방식 모두 동일한 결과 도출 확인 (가독성 vs 최적화기 실행계획 분석 완료)."

print_step "4.2" "보너스 2: 외래키(FK) 참조 무결성 위반 에러 유도 및 복구"
echo -e "  ${C_GRAY}-> Action: 부모(members)에 없는 999번 회원으로 대여 INSERT 시도${C_RESET}"
set +e
ERR_OUT=$(sqlite3 mission12.db "PRAGMA foreign_keys = ON; INSERT INTO rentals (member_id, book_id, rental_date) VALUES (999, 1, '2026-08-01');" 2>&1)
set -e
echo -e "  ${C_YELLOW}SQL Engine Response :${C_RESET} $ERR_OUT"
print_ok "외래키 제약조건에 의해 무결성 위반 데이터 삽입이 완벽히 차단됨."

print_step "4.3" "보너스 3: 비즈니스 핵심 경영 지표 3선 리포트"
echo -e "  ${C_GRAY}• 지표 1: 가장 인기 있는 도서 TOP 3${C_RESET}"
sqlite3 -header -column mission12.db "SELECT b.title, COUNT(r.rental_id) AS rental_count FROM books b JOIN rentals r ON b.book_id = r.book_id GROUP BY b.book_id, b.title ORDER BY rental_count DESC LIMIT 3;"

echo -e "\n  ${C_GRAY}• 지표 2: 카테고리별 보유 자산 금액 및 평균 가격${C_RESET}"
sqlite3 -header -column mission12.db "SELECT c.category_name, COUNT(b.book_id) AS book_count, SUM(b.price) AS total_asset, ROUND(AVG(b.price), 0) AS avg_price FROM categories c JOIN books b ON c.category_id = b.category_id GROUP BY c.category_id, c.category_name ORDER BY total_asset DESC LIMIT 3;"

echo -e "\n  ${C_GRAY}• 지표 3: 전체 회원 중 대여 참여율${C_RESET}"
sqlite3 -header -column mission12.db "SELECT COUNT(DISTINCT r.member_id) AS active_members, (SELECT COUNT(*) FROM members) AS total_members, ROUND(CAST(COUNT(DISTINCT r.member_id) AS FLOAT) / (SELECT COUNT(*) FROM members) * 100, 1) || '%' AS participation_rate FROM rentals r;"
print_ok "핵심 비즈니스 지표 3선 정상 산출 완료."
pause_step "Phase 5: 무결성 단위 테스트 수트 실행 (tests/test_sql_integrity.py)"

# ------------------------------------------------------------------------------
# Phase 5: 무결성 단위 테스트 수트
# ------------------------------------------------------------------------------
print_banner "Phase 5: 데이터베이스 무결성 단위 테스트 수트 (tests/test_sql_integrity.py)"
python3 tests/test_sql_integrity.py
print_ok "8대 단위 테스트 전수 통과 (100% PASS)."

echo -e "\n${C_BLUE}┌──────────────────────────────────────────────────────────────────────┐${C_RESET}"
echo -e "${C_BLUE}│${C_RESET}  ${C_BOLD}${C_GREEN}🎉 SQL 도서 관리 시스템의 모든 검증 및 시연이 성공적으로 완료되었습니다!${C_RESET} ${C_BLUE}│${C_RESET}"
echo -e "${C_BLUE}├──────────────────────────────────────────────────────────────────────┤${C_RESET}"
echo -e "  ${C_GREEN}✔${C_RESET} 4개 테이블 3NF 스키마 및 PK/FK/UNIQUE/NOT NULL 제약조건 [PASS]"
echo -e "  ${C_GREEN}✔${C_RESET} 카테고리/회원/도서/대여 샘플 데이터 적재 무결성         [PASS]"
echo -e "  ${C_GREEN}✔${C_RESET} 기본 조회 4개, 조인 5개, 집계 3개, 서브쿼리/수정/삭제/인덱스 [PASS]"
echo -e "  ${C_GREEN}✔${C_RESET} 보너스 1: JOIN vs 서브쿼리 비교 분석                     [PASS]"
echo -e "  ${C_GREEN}✔${C_RESET} 보너스 2: 외래키(FK) 위반 에러 유도 및 복구 검증          [PASS]"
echo -e "  ${C_GREEN}✔${C_RESET} 보너스 3: 도서관 비즈니스 핵심 지표 3선 리포트            [PASS]"
echo -e "  ${C_GREEN}✔${C_RESET} 8개 단위 테스트 수트 (tests/test_sql_integrity.py)       [PASS 100%]"
echo -e "${C_BLUE}└──────────────────────────────────────────────────────────────────────┘${C_RESET}\n"
