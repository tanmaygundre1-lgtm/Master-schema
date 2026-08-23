BEGIN;

-- 1. School
INSERT INTO school (id, name, code, email, phone, address, city, state, country, postal_code, status) VALUES
(1, 'Bright Future Public School', 'BFPS', 'info@brightfuture.edu.in', '+91 9876543210', '123 Education Lane', 'Pune', 'Maharashtra', 'India', '411001', 'active');

-- 2. Academic Years
INSERT INTO academic_year (id, school_id, name, start_date, end_date, is_current) VALUES
(1, 1, '2024-2025', '2024-04-01', '2025-03-31', FALSE),
(2, 1, '2025-2026', '2025-04-01', '2026-03-31', TRUE);

-- 3. School Classes
INSERT INTO school_class (id, school_id, class_name, class_order) VALUES
(1, 1, 'Nursery', 1),
(2, 1, 'LKG', 2),
(3, 1, 'UKG', 3),
(4, 1, 'Class 1', 4),
(5, 1, 'Class 2', 5);

-- 4. Sections
INSERT INTO section (id, school_id, class_id, section_name) VALUES
(1, 1, 1, 'A'), (2, 1, 1, 'B'),
(3, 1, 2, 'A'), (4, 1, 2, 'B'),
(5, 1, 3, 'A'), (6, 1, 3, 'B'),
(7, 1, 4, 'A'), (8, 1, 4, 'B'),
(9, 1, 5, 'A'), (10, 1, 5, 'B');

-- 5. App Users
INSERT INTO app_user (id, school_id, name, email, password_hash, role, status) VALUES
(1, 1, 'Super Admin', 'superadmin@brightfuture.edu.in', '$2a$10$1RCMoF/VdCmfQjneWWD3eOpH9qBaUTPPMdL97UdAHbUxRH/AXrjri', 'super_admin', 'active'),
(2, 1, 'Rahul Counselor', 'counselor@brightfuture.edu.in', '$2a$10$H6J5SKFv7nfrInohi1mMt.LOi/4yEL40wF0uH6tTZjnGFrOiXu2gG', 'counselor', 'active'),
(3, 1, 'Neha Counselor', 'counselor2@brightfuture.edu.in', '$2a$10$H6J5SKFv7nfrInohi1mMt.LOi/4yEL40wF0uH6tTZjnGFrOiXu2gG', 'counselor', 'active'),
(4, 1, 'Amit Accountant', 'accountant@brightfuture.edu.in', '$2a$10$H6J5SKFv7nfrInohi1mMt.LOi/4yEL40wF0uH6tTZjnGFrOiXu2gG', 'accountant', 'active'),
(5, 1, 'Riya Admin', 'admin@brightfuture.edu.in', '$2a$10$aRpBMw9U8MxUvve8v3zi2e6XLfgGjEyP3nseyXRcTDsJ9L5GS5FVy', 'admin', 'active');

-- 6. Leads
INSERT INTO lead (id, school_id, first_name, last_name, phone, email, source, status, follow_up_status, assigned_to) VALUES
(1, 1, 'Rajesh', 'Sharma', '9876543001', 'rajesh.sharma@example.com', 'website', 'converted', 'contacted', 2),
(2, 1, 'Amit', 'Patil', '9876543002', 'amit.patil@example.com', 'walk-in', 'converted', 'contacted', 2),
(3, 1, 'Sunita', 'Deshmukh', '9876543003', 'sunita.d@example.com', 'referral', 'converted', 'contacted', 3),
(4, 1, 'Suresh', 'Kulkarni', '9876543004', 'suresh.k@example.com', 'website', 'converted', 'contacted', 3),
(5, 1, 'Priya', 'Joshi', '9876543005', 'priya.j@example.com', 'social_media', 'converted', 'contacted', 2),
(6, 1, 'Vikram', 'Singh', '9876543006', 'vikram.s@example.com', 'advertisement', 'new', 'pending', 3),
(7, 1, 'Anil', 'Verma', '9876543007', 'anil.v@example.com', 'website', 'new', 'pending', 2),
(8, 1, 'Kiran', 'Rao', '9876543008', 'kiran.r@example.com', 'walk-in', 'contacted', 'contacted', 3),
(9, 1, 'Sneha', 'Nair', '9876543009', 'sneha.n@example.com', 'referral', 'interested', 'contacted', 2),
(10, 1, 'Manoj', 'Tiwari', '9876543010', 'manoj.t@example.com', 'website', 'new', 'pending', 3);

-- 7. Applications
INSERT INTO application (id, school_id, academic_year_id, lead_id, application_number, status, current_step, assigned_to, submitted_at) VALUES
(1, 1, 2, 1, 'APP-2025-001', 'approved', 6, 2, CURRENT_TIMESTAMP),
(2, 1, 2, 2, 'APP-2025-002', 'approved', 6, 2, CURRENT_TIMESTAMP),
(3, 1, 2, 3, 'APP-2025-003', 'approved', 6, 3, CURRENT_TIMESTAMP),
(4, 1, 2, 4, 'APP-2025-004', 'approved', 6, 3, CURRENT_TIMESTAMP),
(5, 1, 2, 5, 'APP-2025-005', 'approved', 6, 2, CURRENT_TIMESTAMP),
(6, 1, 2, 8, 'APP-2025-006', 'submitted', 6, 3, CURRENT_TIMESTAMP),
(7, 1, 2, 9, 'APP-2025-007', 'in_progress', 3, 2, NULL),
(8, 1, 2, NULL, 'APP-2025-008', 'rejected', 6, 2, CURRENT_TIMESTAMP),
(9, 1, 2, NULL, 'APP-2025-009', 'submitted', 6, 3, CURRENT_TIMESTAMP),
(10, 1, 2, NULL, 'APP-2025-010', 'draft', 1, 2, NULL);

-- 8. Application Student Info
INSERT INTO application_student_info (id, application_id, first_name, last_name, date_of_birth, gender, blood_group, aadhar_number) VALUES
(1, 1, 'Aarav', 'Sharma', '2020-05-15', 'Male', 'O+', '123456789012'),
(2, 2, 'Vihaan', 'Patil', '2020-08-20', 'Male', 'B+', '123456789013'),
(3, 3, 'Ananya', 'Deshmukh', '2019-11-10', 'Female', 'A+', '123456789014'),
(4, 4, 'Sai', 'Kulkarni', '2019-02-25', 'Male', 'AB+', '123456789015'),
(5, 5, 'Advait', 'Joshi', '2018-07-30', 'Male', 'O-', '123456789016'),
(6, 6, 'Riya', 'Rao', '2020-01-12', 'Female', 'B-', '123456789017'),
(7, 7, 'Arjun', 'Nair', '2019-09-05', 'Male', 'A-', '123456789018'),
(8, 8, 'Kavya', 'Menon', '2021-03-22', 'Female', 'O+', '123456789019'),
(9, 9, 'Ishaan', 'Iyer', '2020-12-14', 'Male', 'B+', '123456789020'),
(10, 10, 'Diya', 'Das', '2021-06-18', 'Female', 'AB-', '123456789021');

-- 9. Application Parent Info
INSERT INTO application_parent_info (id, application_id, father_name, father_phone, mother_name, primary_contact_person, primary_contact_relation, primary_contact_phone) VALUES
(1, 1, 'Rajesh Sharma', '9876543001', 'Sunita Sharma', 'Rajesh Sharma', 'Father', '9876543001'),
(2, 2, 'Amit Patil', '9876543002', 'Priya Patil', 'Amit Patil', 'Father', '9876543002'),
(3, 3, 'Sunil Deshmukh', '9876543003', 'Anita Deshmukh', 'Sunil Deshmukh', 'Father', '9876543003'),
(4, 4, 'Suresh Kulkarni', '9876543004', 'Neha Kulkarni', 'Suresh Kulkarni', 'Father', '9876543004'),
(5, 5, 'Ajay Joshi', '9876543005', 'Pooja Joshi', 'Pooja Joshi', 'Mother', '9876543105'),
(6, 6, 'Kiran Rao', '9876543008', 'Meena Rao', 'Kiran Rao', 'Father', '9876543008'),
(7, 7, 'Vivek Nair', '9876543009', 'Sneha Nair', 'Sneha Nair', 'Mother', '9876543009'),
(8, 8, 'Rajiv Menon', '9876543110', 'Aarti Menon', 'Rajiv Menon', 'Father', '9876543110'),
(9, 9, 'Srinivas Iyer', '9876543111', 'Laxmi Iyer', 'Srinivas Iyer', 'Father', '9876543111'),
(10, 10, 'Rahul Das', '9876543112', 'Priyanka Das', 'Rahul Das', 'Father', '9876543112');

-- 10. Application Academic Info
INSERT INTO application_academic_info (id, application_id, desired_class) VALUES
(1, 1, 'Nursery'), (2, 2, 'LKG'), (3, 3, 'UKG'), (4, 4, 'Class 1'), (5, 5, 'Class 2'),
(6, 6, 'Nursery'), (7, 7, 'LKG'), (8, 8, 'UKG'), (9, 9, 'Class 1'), (10, 10, 'Nursery');

-- 11. Application Documents
INSERT INTO application_documents (id, application_id, document_type, file_name, verification_status, uploaded_by, verified_by, verified_at) VALUES
(1, 1, 'birth_certificate', 'aarav_birth_cert.pdf', 'approved', 2, 3, '2025-05-01 10:00:00'),
(2, 1, 'aadhar_card', 'aarav_aadhar.pdf', 'approved', 2, 3, '2025-05-01 10:05:00'),
(3, 2, 'birth_certificate', 'vihaan_birth_cert.pdf', 'approved', 2, 3, '2025-05-02 11:00:00'),
(4, 3, 'birth_certificate', 'ananya_birth_cert.pdf', 'approved', 3, 2, '2025-05-03 09:30:00'),
(5, 4, 'birth_certificate', 'sai_birth_cert.pdf', 'approved', 3, 2, '2025-05-04 14:15:00'),
(6, 5, 'birth_certificate', 'advait_birth_cert.pdf', 'approved', 2, 3, '2025-05-05 16:45:00'),
(7, 6, 'birth_certificate', 'riya_birth_cert.pdf', 'pending', 3, NULL, NULL),
(8, 8, 'birth_certificate', 'kavya_birth_cert.pdf', 'rejected', 2, 3, '2025-05-08 10:00:00');

-- 12. Application Progress
INSERT INTO application_progress (id, application_id, step_1_student_info, step_2_parent_info, step_3_academic_info, step_4_photos, step_5_documents, step_6_review) VALUES
(1, 1, 'completed', 'completed', 'completed', 'completed', 'completed', 'completed'),
(2, 2, 'completed', 'completed', 'completed', 'completed', 'completed', 'completed'),
(3, 3, 'completed', 'completed', 'completed', 'completed', 'completed', 'completed'),
(4, 4, 'completed', 'completed', 'completed', 'completed', 'completed', 'completed'),
(5, 5, 'completed', 'completed', 'completed', 'completed', 'completed', 'completed'),
(6, 6, 'completed', 'completed', 'completed', 'completed', 'completed', 'completed'),
(7, 7, 'completed', 'completed', 'in_progress', 'pending', 'pending', 'pending'),
(8, 8, 'completed', 'completed', 'completed', 'completed', 'completed', 'completed'),
(9, 9, 'completed', 'completed', 'completed', 'completed', 'completed', 'completed'),
(10, 10, 'in_progress', 'pending', 'pending', 'pending', 'pending', 'pending');

-- 13. Application Photos
INSERT INTO application_photos (id, application_id, photo_type, file_path, file_size, mime_type) VALUES
(1, 1, 'student_photo', '/uploads/photos/aarav.jpg', 150000, 'image/jpeg'),
(2, 2, 'student_photo', '/uploads/photos/vihaan.jpg', 160000, 'image/jpeg');

-- 14. Admissions
INSERT INTO admission (id, school_id, application_id, lead_id, academic_year_id, class_id, section_id, admission_date, status, admission_type, registration_number) VALUES
(1, 1, 1, 1, 2, 1, 1, '2025-05-01', 'active', 'new', 'REG-2025-001'),
(2, 1, 2, 2, 2, 2, 3, '2025-05-02', 'active', 'new', 'REG-2025-002'),
(3, 1, 3, 3, 2, 3, 5, '2025-05-03', 'active', 'new', 'REG-2025-003'),
(4, 1, 4, 4, 2, 4, 7, '2025-05-04', 'active', 'new', 'REG-2025-004'),
(5, 1, 5, 5, 2, 5, 9, '2025-05-05', 'active', 'new', 'REG-2025-005');

-- 15. Student Class
INSERT INTO student_class (id, school_id, admission_id, class_id, enrollment_date, status) VALUES
(1, 1, 1, 1, '2025-05-01', 'active'),
(2, 1, 2, 2, '2025-05-02', 'active'),
(3, 1, 3, 3, '2025-05-03', 'active'),
(4, 1, 4, 4, '2025-05-04', 'active'),
(5, 1, 5, 5, '2025-05-05', 'active');

-- 16. Fee Structure
INSERT INTO fee_structure (id, school_id, academic_year_id, class_id, fee_component, installment_no, amount, due_day_of_month) VALUES
(1, 1, 2, 1, 'Admission Fee', 1, 10000.00, 10),
(2, 1, 2, 1, 'Tuition Fee', 1, 5000.00, 10),
(3, 1, 2, 1, 'Tuition Fee', 2, 5000.00, 10),
(4, 1, 2, 2, 'Admission Fee', 1, 12000.00, 10),
(5, 1, 2, 2, 'Tuition Fee', 1, 6000.00, 10),
(6, 1, 2, 3, 'Admission Fee', 1, 12000.00, 10),
(7, 1, 2, 3, 'Tuition Fee', 1, 6000.00, 10),
(8, 1, 2, 4, 'Admission Fee', 1, 15000.00, 10),
(9, 1, 2, 4, 'Tuition Fee', 1, 7500.00, 10),
(10, 1, 2, 5, 'Admission Fee', 1, 15000.00, 10),
(11, 1, 2, 5, 'Tuition Fee', 1, 7500.00, 10);

-- 17. Student Fee Assignments
INSERT INTO student_fee_assignment (id, school_id, admission_id, fee_structure_id, due_date, final_amount, status) VALUES
(1, 1, 1, 1, '2025-05-10', 10000.00, 'completed'),
(2, 1, 1, 2, '2025-06-10', 5000.00, 'completed'),
(3, 1, 1, 3, '2025-09-10', 5000.00, 'pending'),
(4, 1, 2, 4, '2025-05-10', 12000.00, 'partial'),
(5, 1, 2, 5, '2025-06-10', 6000.00, 'pending'),
(6, 1, 3, 6, '2025-05-10', 12000.00, 'completed'),
(7, 1, 4, 8, '2025-05-10', 15000.00, 'pending'),
(8, 1, 5, 10, '2025-05-10', 15000.00, 'completed');

-- 18. Invoices
INSERT INTO invoice (id, school_id, admission_id, invoice_number, total_amount, paid_amount, pending_amount, status, invoice_date, due_date) VALUES
(1, 1, 1, 'INV-2025-001', 15000.00, 15000.00, 0.00, 'paid', '2025-05-01', '2025-05-10'),
(2, 1, 2, 'INV-2025-002', 12000.00, 6000.00, 6000.00, 'partial', '2025-05-02', '2025-05-10'),
(3, 1, 3, 'INV-2025-003', 12000.00, 12000.00, 0.00, 'paid', '2025-05-03', '2025-05-10'),
(4, 1, 4, 'INV-2025-004', 15000.00, 0.00, 15000.00, 'pending', '2025-05-04', '2025-05-10'),
(5, 1, 5, 'INV-2025-005', 15000.00, 15000.00, 0.00, 'paid', '2025-05-05', '2025-05-10');

-- 19. Payments
INSERT INTO payment (id, school_id, admission_id, invoice_id, transaction_id, amount, payment_method, status) VALUES
(1, 1, 1, 1, 'TXN-001', 15000.00, 'bank_transfer', 'successful'),
(2, 1, 2, 2, 'TXN-002', 6000.00, 'credit_card', 'successful'),
(3, 1, 3, 3, 'TXN-003', 12000.00, 'upi', 'successful'),
(4, 1, 5, 5, 'TXN-004', 15000.00, 'cash', 'successful');

-- 20. Payment Receipts
INSERT INTO payment_receipts (id, school_id, admission_id, payment_id, receipt_number) VALUES
(1, 1, 1, 1, 'RCPT-001'),
(2, 1, 2, 2, 'RCPT-002'),
(3, 1, 3, 3, 'RCPT-003'),
(4, 1, 5, 4, 'RCPT-004');

-- 21. Refund Requests
INSERT INTO refund_requests (id, school_id, admission_id, payment_id, invoice_id, requested_amount, approved_amount, status, reason) VALUES
(1, 1, 1, 1, 1, 5000.00, 5000.00, 'approved', 'Overpaid tuition fee by mistake.'),
(2, 1, 3, 3, 3, 12000.00, 0.00, 'requested', 'Student withdrawing before start of session.');

-- 22. Lead Activity
INSERT INTO lead_activity (id, school_id, lead_id, activity_type, notes, outcome, created_by) VALUES
(1, 1, 1, 'call', 'Called to discuss admission process', 'positive', 2),
(2, 1, 2, 'visit', 'Visited campus for inquiry', 'positive', 2),
(3, 1, 3, 'email', 'Sent fee structure details', 'pending', 3),
(4, 1, 6, 'call', 'Not reachable', 'negative', 3),
(5, 1, 8, 'whatsapp', 'Sent admission brochure', 'positive', 3);

-- 23. Audit Log
INSERT INTO audit_log (id, school_id, user_id, action, entity, entity_id, status, change_summary) VALUES
(1, 1, 1, 'create', 'school', 1, 'success', 'Created school record'),
(2, 1, 5, 'create', 'academic_year', 1, 'success', 'Created academic year 2025-2026'),
(3, 1, 5, 'create', 'school_class', 1, 'success', 'Created Nursery class'),
(4, 1, 2, 'update', 'lead', 1, 'success', 'Updated lead status to converted'),
(5, 1, 3, 'create', 'application', 3, 'success', 'Created application for lead 3');

-- 24. Communication Log
INSERT INTO communication_log (id, school_id, recipient_type, recipient_id, channel, subject, message, status, created_by) VALUES
(1, 1, 'lead', 1, 'email', 'Welcome to Bright Future', 'Thank you for your interest...', 'delivered', 2),
(2, 1, 'lead', 2, 'sms', NULL, 'Your campus visit is confirmed.', 'sent', 2),
(3, 1, 'parent', 1, 'whatsapp', NULL, 'Your payment of 15000 is received.', 'delivered', 4);

-- 25. Message Template
INSERT INTO message_template (id, school_id, name, category, subject, content) VALUES
(1, 1, 'Welcome Email', 'Lead Management', 'Welcome to Bright Future Public School', 'Dear {{name}}, Thank you for your interest...'),
(2, 1, 'Payment Receipt', 'Fee Management', 'Payment Receipt - {{receipt_no}}', 'Dear Parent, We have received your payment of {{amount}}...'),
(3, 1, 'Visit Confirmation', 'Campus Visit', 'Campus Visit Scheduled', 'Your visit is scheduled for {{date}} at {{time}}.');

-- 26. Campaign
INSERT INTO campaign (id, school_id, name, channel, status, start_date, end_date) VALUES
(1, 1, 'Admissions 2026 Drive', 'email', 'active', '2025-01-01', '2025-06-30'),
(2, 1, 'Open House Invite', 'sms', 'completed', '2025-02-01', '2025-02-15');

-- 27. Scheduled Emails
INSERT INTO scheduled_emails (id, school_id, sender_id, recipient_type, recipient_id, recipients, subject, message, scheduled_at, status) VALUES
(1, 1, 2, 'lead', 6, 'vikram.s@example.com', 'Admission Open', 'Admissions are open for 2026.', '2025-12-01 10:00:00', 'pending'),
(2, 1, 3, 'lead', 7, 'anil.v@example.com', 'Campus Visit Reminder', 'Reminder for your visit.', '2025-11-20 09:00:00', 'sent');

-- 28. Campus Visit
INSERT INTO campus_visit (id, school_id, lead_id, visit_date, start_time, end_time, visitor_name, visitor_phone, number_of_visitors, status, created_by, assigned_to) VALUES
(1, 1, 2, '2025-04-15', '10:00:00', '11:00:00', 'Amit Patil', '9876543002', 2, 'completed', 2, 2),
(2, 1, 4, '2025-04-20', '11:00:00', '12:00:00', 'Suresh Kulkarni', '9876543004', 3, 'completed', 3, 3),
(3, 1, 7, '2025-05-10', '14:00:00', '15:00:00', 'Anil Verma', '9876543007', 1, 'scheduled', 2, 2);

-- 29. Task
INSERT INTO task (id, school_id, assigned_to, title, task_description, priority, is_done, due_date) VALUES
(1, 1, 2, 'Follow up with Anil', 'Call Anil regarding campus visit', 'high', FALSE, '2025-05-09'),
(2, 1, 3, 'Verify Documents for Kavya', 'Check birth certificate validity', 'medium', TRUE, '2025-05-01'),
(3, 1, 4, 'Reconcile Bank Statement', 'Check payments from last week', 'high', FALSE, '2025-05-05');

-- 30. Service Provider Staff
INSERT INTO service_provider_staff (id, full_name, email, password_hash, internal_role) VALUES
(1, 'System Admin', 'admin@serviceprovider.com', '$2a$10$KbY9VPdEiMsNGXn/6DPMh.nadT.qAhakVUOx8HI6z10a8cYg9H2Xu', 'super_admin'),
(2, 'Support Rep', 'support@serviceprovider.com', '$2a$10$KbY9VPdEiMsNGXn/6DPMh.nadT.qAhakVUOx8HI6z10a8cYg9H2Xu', 'support');

-- Reset sequences to prevent errors on future inserts
SELECT setval(pg_get_serial_sequence('school', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM school;
SELECT setval(pg_get_serial_sequence('academic_year', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM academic_year;
SELECT setval(pg_get_serial_sequence('school_class', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM school_class;
SELECT setval(pg_get_serial_sequence('section', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM section;
SELECT setval(pg_get_serial_sequence('app_user', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM app_user;
SELECT setval(pg_get_serial_sequence('lead', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM lead;
SELECT setval(pg_get_serial_sequence('application', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM application;
SELECT setval(pg_get_serial_sequence('application_student_info', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM application_student_info;
SELECT setval(pg_get_serial_sequence('application_parent_info', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM application_parent_info;
SELECT setval(pg_get_serial_sequence('application_academic_info', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM application_academic_info;
SELECT setval(pg_get_serial_sequence('application_documents', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM application_documents;
SELECT setval(pg_get_serial_sequence('application_progress', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM application_progress;
SELECT setval(pg_get_serial_sequence('application_photos', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM application_photos;
SELECT setval(pg_get_serial_sequence('admission', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM admission;
SELECT setval(pg_get_serial_sequence('student_class', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM student_class;
SELECT setval(pg_get_serial_sequence('fee_structure', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM fee_structure;
SELECT setval(pg_get_serial_sequence('student_fee_assignment', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM student_fee_assignment;
SELECT setval(pg_get_serial_sequence('invoice', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM invoice;
SELECT setval(pg_get_serial_sequence('payment', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM payment;
SELECT setval(pg_get_serial_sequence('payment_receipts', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM payment_receipts;
SELECT setval(pg_get_serial_sequence('refund_requests', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM refund_requests;
SELECT setval(pg_get_serial_sequence('lead_activity', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM lead_activity;
SELECT setval(pg_get_serial_sequence('audit_log', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM audit_log;
SELECT setval(pg_get_serial_sequence('communication_log', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM communication_log;
SELECT setval(pg_get_serial_sequence('message_template', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM message_template;
SELECT setval(pg_get_serial_sequence('campaign', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM campaign;
SELECT setval(pg_get_serial_sequence('scheduled_emails', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM scheduled_emails;
SELECT setval(pg_get_serial_sequence('campus_visit', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM campus_visit;
SELECT setval(pg_get_serial_sequence('task', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM task;
SELECT setval(pg_get_serial_sequence('service_provider_staff', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM service_provider_staff;

COMMIT;
