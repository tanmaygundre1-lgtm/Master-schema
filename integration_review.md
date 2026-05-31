# Integrated Schema Review

## 1. Architecture Review

The Admission module is the source of truth and should remain the canonical ownership layer for fee ownership, class placement, academic year, section, and school tenancy.

The fee migration should not create or populate a standalone master `student` table. Legacy fee data should be resolved through the Admission workflow entities already present in the schema, especially:

- `application`
- `application_student_info`
- `admission`
- `school_class` as the class master
- `school_id` on all business tables that need tenancy control

The final integrated model should therefore treat fee objects as operational records attached to `admission(id)`, not as independent student or class masters.

## 2. Duplicate Table Analysis

| Legacy Fee Table   | Action            | Reason                                                                                                                     |
| ------------------ | ----------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `students`         | Remove            | Legacy source table only. Migration must not create, populate, or reference a standalone target student master.            |
| `classes`          | Remove            | Duplicate class master. Admission already owns class identity through `school_class` and `section`.                        |
| `student_class`    | Keep and Refactor | Useful operational mapping table for reporting and fee assignment, but it must reference `admission` and `school_class`.   |
| `transactions`     | Merge             | Its role overlaps the canonical fee transaction stack already represented by `invoice`, `payment`, and `payment_receipts`. |
| `fee_structure`    | Keep and Modify   | Core fee configuration table, but it must reference the Admission class master (`school_class`).                           |
| `refund_requests`  | Merge             | Canonical version already exists in the Admission-first schema and must be the one retained.                               |
| `payment_receipts` | Merge             | Canonical version already exists in the Admission-first schema and must be the one retained.                               |

## 3. Foreign Key Mapping Report

| Current FK                                           | New FK                                         | Reason                                                                                                  |
| ---------------------------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `students(id)`                                       | Removed                                        | Legacy source-table dependency only; no standalone student master should exist in the migration target. |
| `classes(id)`                                        | Removed                                        | Class ownership is already held by `school_class`.                                                      |
| `student_class.student_id -> students.id`            | `student_class.admission_id -> admission.id`   | Fee assignment and reporting should follow admission, not a duplicate student master.                   |
| `student_class.class_id -> classes.id`               | `student_class.class_id -> school_class.id`    | Class reference must point to the Admission class master.                                               |
| `fee_structure.class_id -> classes.id`               | `fee_structure.class_id -> school_class.id`    | Fee rules must attach to the Admission class master.                                                    |
| `transactions.student_id -> students.id`             | `payment.admission_id -> admission.id`         | Transactions must be owned by admission.                                                                |
| `transactions.class_id -> classes.id`                | `payment.admission_id -> admission.id`         | Class ownership is implied by admission and should not be duplicated in fee transactions.               |
| `refund_requests.student_id -> students.id`          | `refund_requests.admission_id -> admission.id` | Refunds should follow the same admission anchor as payments.                                            |
| `payment_receipts.transaction_id -> transactions.id` | `payment_receipts.payment_id -> payment.id`    | Receipts should be tied to canonical payment rows.                                                      |

## 4. Required Changes

- Preserve all Admission module tables unchanged.
- Add a refactored `student_class` table that links `school_id`, `admission_id`, and `school_class.id`.
- Keep fee configuration in `fee_structure`, but point it at `school_class`.
- Keep transactional fee records anchored to `admission(id)` only.
- Remove the duplicate fee-master tables `students` and `classes` from the final integrated schema.
- Merge legacy `transactions` into the canonical `payment` flow.
- Keep the canonical `refund_requests` and `payment_receipts` definitions from the integrated schema, not the legacy fee-module versions.
- No Admission table changes are required for this integration.

## 5. Tables To Keep

### Admission master and operational tables

- `school`
- `academic_year`
- `school_class`
- `section`
- `student`
- `lead`
- `app_user`
- `admission`
- `application`
- `application_student_info`
- `application_parent_info`
- `application_academic_info`
- `application_documents`
- `application_progress`
- `application_photos`
- `lead_activity`
- `audit_log`
- `communication_log`
- `message_template`
- `campaign`
- `scheduled_emails`
- `campus_visit`
- `task`
- `service_provider_staff`

### Fee tables kept in canonical form

- `fee_structure`
- `student_class`
- `student_fee_assignment`
- `invoice`
- `payment`
- `payment_receipts`
- `refund_requests`

## 6. Tables Recommended For Removal

- `students`
- `classes`
- legacy `transactions` after migration into the canonical payment flow
- legacy fee-module variants of `payment_receipts` and `refund_requests` once migrated into the canonical schema

## 7. Migration SQL

See [migration_sql.sql](migration_sql.sql) for the migration script that:

- maps legacy `classes` into `school_class`
- maps legacy `students` through `application_student_info` and then into `admission`
- rebuilds `student_class` from the Admission `admission` table plus class mapping

## 8. Final Integrated Schema

The canonical schema file is [schema.sql](schema.sql). It has been updated to include the refactored `student_class` table and already anchors fee transactions to `admission(id)`.

## 9. Deployment Order

1. Deploy the Admission master schema.
2. Deploy the fee integration tables and canonical fee stack.
3. Run the migration script for legacy `students`, `classes`, and `student_class` mappings through the Admission workflow.
4. Move legacy transactional rows into the canonical payment stack if old fee data exists.
5. Validate foreign keys, row counts, and school-scoped ownership.
6. Decommission the legacy fee-master tables after reconciliation.

## 10. Risks and Recommendations

- Student matching may be ambiguous if the legacy fee module lacks stable identifiers; use email, phone, DOB, and name together during migration.
- Class matching may need a manual review where class naming differs between modules.
- If multiple applications or admissions match a legacy student record, the student-to-admission mapping should be verified before loading `student_class` rows.
- Keep one canonical school context per load run to avoid cross-tenant contamination.
- Before dropping legacy fee tables, reconcile row counts between the source and the integrated schema.
