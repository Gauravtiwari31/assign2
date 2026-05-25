-- =====================================================================
-- PART 2: SQL QUERY IMPLEMENTATION & VERIFICATION
-- SYSTEM: CodeJudge Database System
-- =====================================================================

-- =====================================================================
-- SECTION 1: BASIC RETRIEVAL AND FILTERING
-- =====================================================================

-- Query 1.1: List all active students with cohort details
-- Purpose: Retrieve essential profile details for students currently active in the system.
SELECT s.student_id, s.name, s.email, b.batch_name, e.enrolled_at AS admission_date
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN batches b ON e.batch_id = b.batch_id
WHERE b.is_active = 1;

-- Query 1.2: Identify missing or structurally malformed emails
-- Purpose: Audit the dataset to identify user accounts requiring contact data cleaning.
SELECT student_id, name, email 
FROM students
WHERE email IS NULL 
   OR email = '' 
   OR email NOT LIKE '%@%._%';

-- Query 1.3: List filtered algorithmic core problems
-- Purpose: Isolate fundamental problems suitable for foundational training phases.
SELECT problem_id, title, difficulty, max_score
FROM problems
WHERE difficulty IN ('Easy', 'Medium');

-- Query 1.4: Track real-time continuous platform submissions
-- Purpose: Monitor recent execution activity across evaluation containers.
SELECT submission_id, student_id, problem_id, submitted_at, language
FROM submissions
ORDER BY submitted_at DESC
LIMIT 20;

-- Query 1.5: Isolate infrastructure or runtime error cases
-- Purpose: Extract submissions failing to meet successful criteria for error logs.
SELECT submission_id, student_id, problem_id, language
FROM submissions
WHERE submission_id NOT IN (
    SELECT DISTINCT submission_id 
    FROM plagiarism_flags 
    WHERE similarity_score > 85.0
);

-- =====================================================================
-- SECTION 2: JOINS
-- =====================================================================

-- Query 2.1: Master submission log compilation
-- Purpose: Denormalize submission entries for dashboard display panels.
SELECT sub.submission_id, s.name AS student_name, p.title AS problem_title, sub.language, p.max_score, sub.submitted_at
FROM submissions sub
INNER JOIN students s ON sub.student_id = s.student_id
INNER JOIN problems p ON sub.problem_id = p.problem_id;

-- Query 2.2: Comprehensive student enrollment tracking
-- Purpose: Audit platform reach by including students without active course pairings.
SELECT s.student_id, s.name, s.email, e.batch_id
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id;

-- Query 2.3: Course metric distribution profiles
-- Purpose: Aggregate structural registration trends across the curriculum.
SELECT c.course_id, c.course_name, COUNT(e.student_id) AS enrolled_students_count
FROM courses c
LEFT JOIN batches b ON c.course_id = b.course_id
LEFT JOIN enrollments e ON b.batch_id = e.batch_id
GROUP BY c.course_id, c.course_name;

-- Query 2.4: Execution validation records
-- Purpose: Map security test metadata against raw execution records.
SELECT pf.flag_id, s.name AS student_name, p.title AS problem_title, pf.similarity_score
FROM plagiarism_flags pf
INNER JOIN submissions sub ON pf.submission_id = sub.submission_id
INNER JOIN students s ON sub.student_id = s.student_id
INNER JOIN problems p ON sub.problem_id = p.problem_id;

-- Query 2.5: Zero-activity diagnostic review
-- Purpose: Isolate students who enrolled in courses but haven't submitted code.
SELECT s.student_id, s.name, c.course_name
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN batches b ON e.batch_id = b.batch_id
INNER JOIN courses c ON b.course_id = c.course_id
LEFT JOIN submissions sub ON s.student_id = sub.student_id
WHERE sub.submission_id IS NULL;


-- =====================================================================
-- SECTION 3: AGGREGATION AND HAVING
-- =====================================================================

-- Query 3.1: Language distribution statistics
-- Purpose: Evaluate platform tool usage metrics across runtime execution files.
SELECT language, COUNT(*) AS execution_count
FROM submissions
GROUP BY language;

-- Query 3.2: Performance metrics breakdown
-- Purpose: Track the average execution scores across individual algorithmic challenges.
SELECT p.problem_id, p.title, AVG(p.max_score) AS dynamic_avg_score
FROM problems p
INNER JOIN submissions s ON p.problem_id = s.problem_id
GROUP BY p.problem_id, p.title;

-- Query 3.3: High-activity platform users
-- Purpose: Find students with more than 5 code submission instances.
SELECT s.student_id, s.name, COUNT(sub.submission_id) AS total_submissions
FROM students s
INNER JOIN submissions sub ON s.student_id = sub.student_id
GROUP BY s.student_id, s.name
HAVING COUNT(sub.submission_id) > 5;

-- Query 3.4: Identify bottleneck algorithmic barriers
-- Purpose: Isolate problems where security failure flags affect over 60% of attempts.
SELECT p.problem_id, p.title, COUNT(pf.flag_id) * 100.0 / COUNT(sub.submission_id) AS plagiarism_rate
FROM problems p
INNER JOIN submissions sub ON p.problem_id = sub.problem_id
LEFT JOIN plagiarism_flags pf ON sub.submission_id = pf.submission_id
GROUP BY p.problem_id, p.title
HAVING plagiarism_rate > 60.0;

-- Query 3.5: Identify high-volume testing challenges
-- Purpose: Isolate the top 10 most heavily targeted execution files.
SELECT p.problem_id, p.title, COUNT(sub.submission_id) AS attempt_count
FROM problems p
INNER JOIN submissions sub ON p.problem_id = sub.problem_id
GROUP BY p.problem_id, p.title
ORDER BY attempt_count DESC
LIMIT 10;


-- =====================================================================
-- SECTION 4: SUBQUERIES / SET LOGIC
-- =====================================================================

-- Query 4.1: Identify top-performing cohorts
-- Purpose: Find students whose historical average scores outpace overall system means.
SELECT student_id, name
FROM students
WHERE student_id IN (
    SELECT student_id 
    FROM submissions sub
    INNER JOIN problems p ON sub.problem_id = p.problem_id
    GROUP BY student_id
    HAVING AVG(p.max_score) > (SELECT AVG(max_score) FROM problems)
);

-- Query 4.2: Identify unutilized assessment assets
-- Purpose: Isolate structural problem items receiving zero execution requests.
SELECT problem_id, title 
FROM problems
WHERE problem_id NOT IN (SELECT DISTINCT problem_id FROM submissions);

-- Query 4.3: Identity zero-execution profiles via set check
-- Purpose: Flag accounts with zero submission database footprint using subqueries.
SELECT student_id, name, email 
FROM students
WHERE student_id NOT IN (SELECT DISTINCT student_id FROM submissions);

-- Query 4.4: Cross-language proficient students
-- Purpose: Find engineers submitting solutions in both Python and Java frameworks.
SELECT student_id, name 
FROM students
WHERE student_id IN (SELECT student_id FROM submissions WHERE language = 'Python')
  AND student_id IN (SELECT student_id FROM submissions WHERE language = 'Java');

-- Query 4.5: Standout performance parsing
-- Purpose: Isolate the exact second-highest score value tied to problem item #1.
SELECT MAX(max_score) AS second_highest_score
FROM problems
WHERE max_score < (SELECT MAX(max_score) FROM problems WHERE problem_id = 1);
