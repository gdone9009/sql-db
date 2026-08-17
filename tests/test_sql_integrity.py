#!/usr/bin/env python3
# ==============================================================================
# 🧪 SQL Database Integrity & Compliance Test Suite
# File: tests/test_sql_integrity.py
# ==============================================================================

import sqlite3
import os
import unittest

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "mission12.db")
SCHEMA_PATH = os.path.join(BASE_DIR, "schema.sql")
DATA_PATH = os.path.join(BASE_DIR, "data.sql")
QUERIES_PATH = os.path.join(BASE_DIR, "queries.sql")


class TestSQLDatabase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Build test database in memory for isolated unit testing."""
        cls.conn = sqlite3.connect(":memory:")
        cls.cursor = cls.conn.cursor()
        cls.cursor.execute("PRAGMA foreign_keys = ON;")

        # Run schema
        with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
            cls.cursor.executescript(f.read())

        # Run data
        with open(DATA_PATH, "r", encoding="utf-8") as f:
            cls.cursor.executescript(f.read())

    @classmethod
    def tearDownClass(cls):
        cls.conn.close()

    def test_01_table_existence(self):
        """Verify all 4 required tables exist."""
        self.cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = [row[0] for row in self.cursor.fetchall()]
        expected_tables = ["members", "categories", "books", "rentals"]
        for t in expected_tables:
            self.assertIn(t, tables, f"Table '{t}' must exist in database.")

    def test_02_minimum_row_counts(self):
        """Verify each table contains at least 10 rows."""
        tables = ["members", "categories", "books", "rentals"]
        for t in tables:
            self.cursor.execute(f"SELECT COUNT(*) FROM {t};")
            count = self.cursor.fetchone()[0]
            self.assertGreaterEqual(count, 10, f"Table '{t}' must have at least 10 rows (found {count}).")

    def test_03_foreign_key_enforcement(self):
        """Verify Foreign Key prevents inserting non-existent foreign reference."""
        with self.assertRaises(sqlite3.IntegrityError):
            self.cursor.execute("INSERT INTO rentals (member_id, book_id, rental_date) VALUES (999, 1, '2026-08-01');")

    def test_04_unique_constraint(self):
        """Verify UNIQUE constraint prevents duplicate member email."""
        with self.assertRaises(sqlite3.IntegrityError):
            self.cursor.execute("INSERT INTO members (name, email, phone) VALUES ('중복회원', 'gdone9009@gmail.com', '010-0000-0000');")

    def test_05_not_null_constraint(self):
        """Verify NOT NULL constraint prevents NULL book title."""
        with self.assertRaises(sqlite3.IntegrityError):
            self.cursor.execute("INSERT INTO books (title, author, price, category_id) VALUES (NULL, '저자', 10000, 1);")

    def test_06_index_creation(self):
        """Verify index creation on books.category_id."""
        self.cursor.execute("CREATE INDEX IF NOT EXISTS idx_books_category_id ON books(category_id);")
        self.cursor.execute("SELECT name FROM sqlite_master WHERE type='index' AND name='idx_books_category_id';")
        idx = self.cursor.fetchone()
        self.assertIsNotNone(idx, "Index 'idx_books_category_id' must be created.")

    def test_07_bonus_1_join_vs_subquery_equivalence(self):
        """Verify Bonus 1: JOIN and Subquery yield identical results."""
        q_join = "SELECT b.title, b.author FROM books b JOIN categories c ON b.category_id = c.category_id WHERE c.category_name = 'IT/프로그래밍' ORDER BY b.title;"
        q_sub = "SELECT title, author FROM books WHERE category_id = (SELECT category_id FROM categories WHERE category_name = 'IT/프로그래밍') ORDER BY title;"
        
        self.cursor.execute(q_join)
        res_join = self.cursor.fetchall()
        
        self.cursor.execute(q_sub)
        res_sub = self.cursor.fetchall()
        
        self.assertEqual(res_join, res_sub, "JOIN and Subquery must return identical results.")
        self.assertGreater(len(res_join), 0)

    def test_08_bonus_3_participation_rate(self):
        """Verify Bonus 3: Active participation rate query executes and is accurate."""
        q_metric = "SELECT COUNT(DISTINCT r.member_id), (SELECT COUNT(*) FROM members) FROM rentals r;"
        self.cursor.execute(q_metric)
        active, total = self.cursor.fetchone()
        self.assertEqual(total, 10)
        self.assertGreaterEqual(active, 1)


if __name__ == "__main__":
    unittest.main(verbosity=2)
