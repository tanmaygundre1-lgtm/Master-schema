-- Legacy Fee Module Migration Script
-- PostgreSQL 15+
--
-- Purpose:
--   - Map legacy fee-module `classes` into `school_class`
--   - Rebuild `student_class` as an admission-anchored operational mapping table
--   - Resolve legacy student ownership through application/admission workflow records
--
-- Notes:
--   - Replace the school identifier in the params CTE before running.
--   - The script does not create, populate, or reference a standalone master student table.
--   - Legacy fee tables should remain available until the mapping is validated.

BEGIN;

-- Set the tenant scope for the migration.
WITH
    params AS (
        SELECT 1::BIGINT AS school_id
    )
INSERT INTO
    school_class (
        school_id,
        class_name,
        class_order
    )
SELECT DISTINCT
    p.school_id,
    c.class_name,
    NULL::INT
FROM classes c
    CROSS JOIN params p
ON CONFLICT (school_id, class_name) DO NOTHING;

CREATE TEMP TABLE legacy_class_map AS
WITH params AS (
    SELECT 1::BIGINT AS school_id
)
SELECT
    c.id AS legacy_class_id,
    sc.id AS school_class_id
FROM classes c
    JOIN params p ON TRUE
    JOIN school_class sc ON sc.school_id = p.school_id
    AND sc.class_name = c.class_name;

CREATE TEMP TABLE legacy_student_application_map AS
SELECT DISTINCT ON (s.id)
    s.id AS legacy_student_id,
    asi.application_id
FROM students s
    JOIN application_student_info asi ON (
        (
            s.email IS NOT NULL
            AND asi.email = s.email
        )
        OR (
            s.phone IS NOT NULL
            AND asi.phone = s.phone
        )
        OR (
            asi.first_name = s.first_name
            AND asi.last_name = s.last_name
            AND asi.date_of_birth IS NOT DISTINCT FROM s.date_of_birth
        )
    )
ORDER BY
    s.id,
    CASE
        WHEN s.email IS NOT NULL
        AND asi.email = s.email THEN 1
        WHEN s.phone IS NOT NULL
        AND asi.phone = s.phone THEN 2
        ELSE 3
    END,
    asi.application_id;

CREATE TEMP TABLE legacy_student_admission_map AS
SELECT
    lsam.legacy_student_id,
    ad.id AS admission_id
FROM legacy_student_application_map lsam
    JOIN application a ON a.id = lsam.application_id
    JOIN admission ad ON ad.application_id = a.id;

INSERT INTO
    student_class (
        school_id,
        admission_id,
        class_id,
        enrollment_date,
        status
    )
SELECT DISTINCT
    ad.school_id,
    lsam.admission_id,
    lcm.school_class_id,
    COALESCE(
        sc.enrollment_date,
        CURRENT_DATE
    ),
    LOWER(COALESCE(sc.status, 'active'))
FROM
    student_class sc
    JOIN legacy_student_admission_map lsam ON lsam.legacy_student_id = sc.student_id
    JOIN legacy_class_map lcm ON lcm.legacy_class_id = sc.class_id
    JOIN admission ad ON ad.id = lsam.admission_id
ON CONFLICT (admission_id, class_id) DO NOTHING;

COMMIT;