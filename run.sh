# run.sh
#!/bin/bash
rm -f test2.db  -- 기존 DB를 지우고 새로 깨끗하게 만들고 싶을 때 추가
sqlite3 test2.db <<EOF
.read schema.sql
.read data.sql
.read queries.sql
EOF
echo "✅ 데이터베이스 구축 및 쿼리 실행 완료!"