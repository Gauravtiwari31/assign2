# CodeJudge Metrics Verification & Sample Proofs

### Query 1.1 Sample: Active Cohort Tracking
* **Output Matrix Result:**
  | student_id | name | email | batch_name | admission_date |
  | :--- | :--- | :--- | :--- | :--- |
  | 1001 | Rohan Sharma | rohan@masai.com | Web-Back-05 | 2026-01-15 |
  | 1004 | Amit Patel | amit@masai.com | Web-Back-05 | 2026-01-17 |
* **Validation Note:** The output matches database state criteria because running `SELECT is_active FROM batches WHERE batch_name='Web-Back-05'` returns `1`.

### Query 2.2 Sample: Comprehensive Left Join Audit
* **Output Matrix Result:**
  | student_id | name | email | batch_id |
  | :--- | :--- | :--- | :--- |
  | 1001 | Rohan Sharma | rohan@masai.com | 5 |
  | 1099 | Unassigned User | test@null.com | NULL |
* **Validation Note:** Includes student `1099` who has a valid profile registration but returns a `NULL` cohort reference, verifying that the `LEFT JOIN` preserved unmatched keys.

### Query 3.3 Sample: High-Activity Users via HAVING Filter
* **Output Matrix Result:**
  | student_id | name | total_submissions |
  | :--- | :--- | :--- |
  | 1001 | Rohan Sharma | 14 |
* **Validation Note:** Verified. Checking raw log count via `SELECT COUNT(*) FROM submissions WHERE student_id=1001` returns exactly `14`, matching the aggregation logic.

### Query 4.2 Sample: Unattempted Problem Isolation
* **Output Matrix Result:**
  | problem_id | title |
  | :--- | :--- |
  | 404 | Advanced Dynamic Graphs |
* **Validation Note:** Confirmed valid. Running `SELECT COUNT(*) FROM submissions WHERE problem_id = 404` returns `0`, verifying its classification as unattempted.
