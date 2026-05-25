# CodeJudge Execution System Engine — Part 2

This directory contains the production DDL verification suite, logical constraints, and validation proofs for the CodeJudge database engine.

## File Contents
* `queries.sql`: Clean, well-commented SQL DDL/DML verification code scripts.
* `query_outputs.md`: Proof records matching verified schema outputs.
* `sql_reasoning.md`: Engineering analysis covering join architectures and query optimization strategies.

## Execution Guide
To run and test the query suite using the SQLite command-line interface:
```bash
sqlite3 codejudge.db < queries.sql
