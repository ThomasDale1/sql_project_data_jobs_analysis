CREATE TABLE job_applied (
    job_id INT,
    application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(50)
);

SELECT * FROM job_applied;

INSERT INTO job_applied
    (job_id, application_sent_date, custom_resume, resume_file_name, cover_letter_sent, cover_letter_file_name, status)
VALUES
    (1, '2023-10-01', true, 'resume1.pdf', true, 'cover_letter1.pdf', 'Applied'),
    (2, '2023-10-05', false, 'resume2.pdf', false, NULL, 'Pending'),
    (3, '2023-10-10', true, 'resume3.pdf', true, 'cover_letter3.pdf', 'Interview Scheduled'),
    (4, '2023-10-15', false, 'resume4.pdf', false, NULL, 'Rejected'),
    (5, '2023-10-20', true, 'resume5.pdf', true, 'cover_letter5.pdf', 'Offer Received');

ALTER TABLE job_applied
ADD contact VARCHAR(50);

UPDATE job_applied
SET contact = 'Erlich Bachman'
WHERE job_id = 1;
UPDATE job_applied
SET contact = 'Richard Hendricks'
WHERE job_id = 2;
UPDATE job_applied
SET contact = 'Dinesh Chugtai'  
WHERE job_id = 3;
UPDATE job_applied
SET contact = 'Bertram Gilfoyle'
WHERE job_id = 4;
UPDATE job_applied
SET contact = 'Jared Dunn'
WHERE job_id = 5;

ALTER TABLE job_applied
RENAME COLUMN contact TO contact_person;

ALTER TABLE job_applied
ALTER COLUMN contact_person TYPE INT;

ALTER TABLE job_applied
DROP COLUMN contact_person;

DROP TABLE job_applied;