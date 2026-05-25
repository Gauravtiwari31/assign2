# Database Design Reasoning & Relational Analysis

### 1. LEFT JOIN vs. INNER JOIN Operational Usage
In **Query 2.3** (Course registration distribution profiles), using a `LEFT JOIN` is necessary instead of an `INNER JOIN`. If we use an `INNER JOIN`, any newly created course that has no active student enrollments would return a count of zero rows and be omitted from the output. A `LEFT JOIN` preserves these courses in the output matrix, returning `0` values via aggregation handling.

### 2. HAVING vs. WHERE Execution Order
In **Query 3.3** (Isolating high-activity students), individual row records must first be grouped using `GROUP BY student_id`. Because SQL execution order runs `WHERE` filters *before* aggregation occurs, it cannot evaluate conditions based on aggregate values like `COUNT(submission_id)`. We must use `HAVING` to filter after the groupings are calculated.

### 3. Subquery Strategy
In **Query 4.1** (Identifying top performers), we need to compare individual student average metrics against a global platform baseline score. This baseline calculation (`SELECT AVG(max_score) FROM problems`) must run first as an independent, single-value scalar subquery before the outer comparative query can filter student profiles.

### 4. Handling Misleading Duplicate Counts
When using functions like `COUNT(e.student_id)` alongside multiple joined tracking tables (e.g., combining attendance logs with test result sets), duplicate records can artificially inflate results. If a student has 3 attendance marks and 2 submissions, joining all three tables without distinct modifiers can cause a cross-product result of $3 \times 2 = 6$ records. To maintain accuracy, you must specify `COUNT(DISTINCT student_id)`.

### 5. Addressed Edge Cases
While writing **Query 1.2** (Identifying invalid emails), checking only for `NULL` values is insufficient. Application frontends often submit empty space values (`''`) or malformed structural payloads. The query addresses this edge case by validating email composition patterns using structural string token evaluations:
```sql
WHERE email IS NULL OR email = '' OR email NOT LIKE '%@%._%';
