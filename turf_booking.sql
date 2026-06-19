CREATE DATABASE turf_booking_analytics;
USE turf_booking_analytics;

-- 1. CUSTOMERS  

CREATE TABLE customers (
    customer_id        VARCHAR(10)     NOT NULL,
    full_name          VARCHAR(100)    NOT NULL,
    gender              ENUM('Male','Female','Other') NOT NULL,
    age                 TINYINT UNSIGNED NOT NULL,
    email               VARCHAR(150)    NOT NULL,
    phone               VARCHAR(15)     NOT NULL,
    city                VARCHAR(50)     NOT NULL,
    state               VARCHAR(50)     NOT NULL,
    membership_tier     ENUM('Bronze','Silver','Gold','Platinum') NOT NULL DEFAULT 'Bronze',
    join_date           DATE            NOT NULL,
    total_bookings      INT UNSIGNED    NOT NULL DEFAULT 0,
    preferred_sport     VARCHAR(30)     NOT NULL,
    is_active           ENUM('Yes','No') NOT NULL DEFAULT 'Yes',
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id),
    UNIQUE KEY uq_customers_email (email),
    UNIQUE KEY uq_customers_phone (phone),
    INDEX idx_customers_city (city),
    INDEX idx_customers_membership (membership_tier)
) ENGINE=InnoDB;
select * from customers

-- 2. TURFS  

CREATE TABLE turfs (
    turf_id             VARCHAR(10)     NOT NULL,
    turf_name           VARCHAR(150)    NOT NULL,
    city                VARCHAR(50)     NOT NULL,
    state               VARCHAR(50)     NOT NULL,
    address             VARCHAR(255)    NOT NULL,
    sport_type          VARCHAR(30)     NOT NULL,
    surface_type        VARCHAR(40)     NOT NULL,
    size_sqft           INT UNSIGNED    NOT NULL,
    hourly_rate         DECIMAL(10,2)   NOT NULL,
    capacity            SMALLINT UNSIGNED NOT NULL,
    amenities           VARCHAR(255)    NULL,
    owner_name          VARCHAR(100)    NOT NULL,
    contact_number      VARCHAR(15)     NOT NULL,
    opening_time        TIME            NOT NULL,
    closing_time        TIME            NOT NULL,
    rating_avg          DECIMAL(3,2)    NOT NULL DEFAULT 0.00,
    active_since        DATE            NOT NULL,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (turf_id),
    UNIQUE KEY uq_turfs_contact (contact_number),
    INDEX idx_turfs_city (city),
    INDEX idx_turfs_sport (sport_type),
    CONSTRAINT chk_turfs_rating CHECK (rating_avg BETWEEN 0 AND 5)
) ENGINE=InnoDB;
 select * from turfs
 
 -- 3. STAFF 

CREATE TABLE staff (
    staff_id            VARCHAR(10)     NOT NULL,
    full_name           VARCHAR(100)    NOT NULL,
    role                 ENUM('Ground Manager','Receptionist','Maintenance Staff','Security Guard','Cafeteria Staff','Coach') NOT NULL,
    assigned_turf_id     VARCHAR(10)     NOT NULL,
    phone                VARCHAR(15)     NOT NULL,
    email                VARCHAR(150)    NOT NULL,
    hire_date            DATE            NOT NULL,
    monthly_salary       DECIMAL(10,2)   NOT NULL,
    shift_type           ENUM('Morning','Evening','Night','Full-Day') NOT NULL,
    employment_status    ENUM('Active','On Leave','Resigned') NOT NULL DEFAULT 'Active',
    created_at           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (staff_id),
    UNIQUE KEY uq_staff_email (email),
    UNIQUE KEY uq_staff_phone (phone),
    INDEX idx_staff_turf (assigned_turf_id),
    INDEX idx_staff_role (role),
    CONSTRAINT fk_staff_turf
        FOREIGN KEY (assigned_turf_id) REFERENCES turfs (turf_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;
 select * from staff
 
 -- 4. SLOTS  

CREATE TABLE slots (
    slot_id              VARCHAR(12)     NOT NULL,
    turf_id              VARCHAR(10)     NOT NULL,
    slot_date            DATE            NOT NULL,
    start_time           TIME            NOT NULL,
    end_time             TIME            NOT NULL,
    day_of_week          VARCHAR(10)     NOT NULL,
    price                DECIMAL(10,2)   NOT NULL,
    is_peak_hour         ENUM('Yes','No') NOT NULL DEFAULT 'No',
    status               ENUM('Booked','Available','Blocked') NOT NULL DEFAULT 'Available',
    created_at           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (slot_id),
    UNIQUE KEY uq_slots_turf_date_time (turf_id, slot_date, start_time),
    INDEX idx_slots_turf (turf_id),
    INDEX idx_slots_date (slot_date),
    INDEX idx_slots_status (status),
    CONSTRAINT fk_slots_turf
        FOREIGN KEY (turf_id) REFERENCES turfs (turf_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_slots_time CHECK (start_time < end_time)
) ENGINE=InnoDB;
 select * from slots
 
 -- 5. BOOKINGS  

CREATE TABLE bookings (
    booking_id           VARCHAR(10)     NOT NULL,
    customer_id          VARCHAR(10)     NOT NULL,
    turf_id              VARCHAR(10)     NOT NULL,
    booking_date         DATE            NOT NULL,
    booking_time         TIME            NOT NULL,
    slot_start_time      TIME            NOT NULL,
    slot_end_time        TIME            NOT NULL,
    duration_hours       TINYINT UNSIGNED NOT NULL DEFAULT 1,
    number_of_players    TINYINT UNSIGNED NOT NULL,
    sport_type           VARCHAR(30)     NOT NULL,
    amount               DECIMAL(10,2)   NOT NULL,
    booking_status        ENUM('Confirmed','Completed','Cancelled','No-Show','Pending') NOT NULL DEFAULT 'Pending',
    booking_channel       ENUM('Mobile App','Website','Walk-in','Phone Call') NOT NULL,
    promo_code_used       VARCHAR(20)     NOT NULL DEFAULT 'NONE',
    created_at            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id),
    INDEX idx_bookings_customer (customer_id),
    INDEX idx_bookings_turf (turf_id),
    INDEX idx_bookings_date (booking_date),
    INDEX idx_bookings_status (booking_status),
    CONSTRAINT fk_bookings_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_bookings_turf
        FOREIGN KEY (turf_id) REFERENCES turfs (turf_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_bookings_slot_time CHECK (slot_start_time < slot_end_time)
) ENGINE=InnoDB;
select * from bookings

-- 6. PAYMENTS 

CREATE TABLE payments (
    payment_id            VARCHAR(10)     NOT NULL,
    booking_id            VARCHAR(10)     NOT NULL,
    customer_id           VARCHAR(10)     NOT NULL,
    payment_date          DATE            NOT NULL,
    payment_time          TIME            NOT NULL,
    base_amount           DECIMAL(10,2)   NOT NULL,
    tax_amount            DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    total_amount          DECIMAL(10,2)   NOT NULL,
    payment_method         ENUM('UPI','Credit Card','Debit Card','Net Banking','Wallet','Cash') NOT NULL,
    payment_gateway        ENUM('Razorpay','PayU','CCAvenue','Paytm','Cashfree','Instamojo') NOT NULL,
    transaction_id         VARCHAR(30)     NOT NULL,
    payment_status          ENUM('Success','Failed','Refunded','Pending') NOT NULL DEFAULT 'Pending',
    refund_amount          DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    created_at             TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (payment_id),
    UNIQUE KEY uq_payments_booking (booking_id),
    UNIQUE KEY uq_payments_transaction (transaction_id),
    INDEX idx_payments_customer (customer_id),
    INDEX idx_payments_status (payment_status),
    INDEX idx_payments_date (payment_date),
    CONSTRAINT fk_payments_booking
        FOREIGN KEY (booking_id) REFERENCES bookings (booking_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_payments_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;
 select * from payments
 
 -- 7. REVIEWS  

CREATE TABLE reviews (
    review_id              VARCHAR(10)     NOT NULL,
    booking_id             VARCHAR(10)     NOT NULL,
    customer_id            VARCHAR(10)     NOT NULL,
    turf_id                VARCHAR(10)     NOT NULL,
    rating                 TINYINT UNSIGNED NOT NULL,
    review_tag             VARCHAR(100)    NULL,
    review_date            DATE            NOT NULL,
    would_recommend         ENUM('Yes','No') NOT NULL,
    response_from_owner     ENUM('Yes','No') NOT NULL DEFAULT 'No',
    created_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    UNIQUE KEY uq_reviews_booking (booking_id),
    INDEX idx_reviews_customer (customer_id),
    INDEX idx_reviews_turf (turf_id),
    INDEX idx_reviews_rating (rating),
    CONSTRAINT fk_reviews_booking
        FOREIGN KEY (booking_id) REFERENCES bookings (booking_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reviews_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reviews_turf
        FOREIGN KEY (turf_id) REFERENCES turfs (turf_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;
 select * from reviews
 
 -- 8. EQUIPMENT  

CREATE TABLE equipment (
    equipment_id            VARCHAR(10)     NOT NULL,
    turf_id                 VARCHAR(10)     NOT NULL,
    equipment_name           VARCHAR(50)     NOT NULL,
    quantity                 SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    purchase_date            DATE            NOT NULL,
    purchase_cost             DECIMAL(10,2)   NOT NULL,
    `condition`               ENUM('New','Good','Fair','Worn','Needs Replacement') NOT NULL DEFAULT 'Good',
    last_inspection_date       DATE            NULL,
    supplier                  VARCHAR(150)    NOT NULL,
    created_at                 TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (equipment_id),
    INDEX idx_equipment_turf (turf_id),
    INDEX idx_equipment_condition (`condition`),
    CONSTRAINT fk_equipment_turf
        FOREIGN KEY (turf_id) REFERENCES turfs (turf_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;
 select * from equipment 
 
 -- 9. MAINTENANCE  

CREATE TABLE maintenance (
    maintenance_id            VARCHAR(10)     NOT NULL,
    turf_id                   VARCHAR(10)     NOT NULL,
    maintenance_type           VARCHAR(50)     NOT NULL,
    maintenance_date            DATE            NOT NULL,
    performed_by_staff_id        VARCHAR(10)     NOT NULL,
    cost                         DECIMAL(10,2)   NOT NULL,
    duration_hours               TINYINT UNSIGNED NOT NULL,
    status                       ENUM('Completed','Scheduled','In Progress') NOT NULL DEFAULT 'Scheduled',
    notes                        VARCHAR(255)    NULL,
    created_at                   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (maintenance_id),
    INDEX idx_maintenance_turf (turf_id),
    INDEX idx_maintenance_staff (performed_by_staff_id),
    INDEX idx_maintenance_date (maintenance_date),
    CONSTRAINT fk_maintenance_turf
        FOREIGN KEY (turf_id) REFERENCES turfs (turf_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_maintenance_staff
        FOREIGN KEY (performed_by_staff_id) REFERENCES staff (staff_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;
select * from maintenance
 
 -- 10. CANCELLATIONS  

CREATE TABLE cancellations (
    cancellation_id            VARCHAR(10)     NOT NULL,
    booking_id                 VARCHAR(10)     NOT NULL,
    customer_id                VARCHAR(10)     NOT NULL,
    cancellation_date           DATE            NOT NULL,
    reason                      VARCHAR(100)    NOT NULL,
    cancelled_by                 ENUM('Customer','Turf Owner','System') NOT NULL,
    refund_percentage             TINYINT UNSIGNED NOT NULL DEFAULT 0,
    refund_amount                 DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    refund_status                  ENUM('Processed','Pending','Not Applicable') NOT NULL DEFAULT 'Pending',
    created_at                     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cancellation_id),
    UNIQUE KEY uq_cancellations_booking (booking_id),
    INDEX idx_cancellations_customer (customer_id),
    INDEX idx_cancellations_date (cancellation_date),
    CONSTRAINT fk_cancellations_booking
        FOREIGN KEY (booking_id) REFERENCES bookings (booking_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cancellations_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_cancellations_refund_pct CHECK (refund_percentage BETWEEN 0 AND 100)
) ENGINE=InnoDB;
 select * from cancellations
 select * from payments
 
 -- Q1-Customers with MORE than 5 bookings
SELECT 
    customer_id,
    COUNT(*) AS total_bookings
FROM bookings
GROUP BY customer_id
HAVING COUNT(*) > 5;

-- Q2- Monthly Revenue report
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    SUM(total_amount) AS revenue
FROM payments
WHERE payment_status = 'Success'
GROUP BY month
ORDER BY month;

-- Q3-Top Customers by Bookings
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(b.booking_id) AS total_bookings
FROM customers c
JOIN bookings b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_bookings DESC;

-- Q4-Top Revenue Turfs

SELECT 
    t.turf_name,
    SUM(p.total_amount) AS revenue
FROM turfs t
JOIN bookings b ON t.turf_id = b.turf_id
JOIN payments p ON b.booking_id = p.booking_id
GROUP BY t.turf_name
ORDER BY revenue DESC;

-- Q5-Most Popular Turf limit 5
SELECT
    t.turf_name,
    COUNT(b.booking_id) AS total_bookings
FROM turfs t
JOIN bookings b
ON t.turf_id = b.turf_id
GROUP BY t.turf_name
ORDER BY total_bookings DESC
limit 5;

-- Q6-Write a SQL query to generate a complete booking report showing customer details, turf details, booking information, and payment information for all bookings.

SELECT
    b.booking_id,
    c.customer_id,
    c.full_name AS customer_name,
    t.turf_name,
    b.booking_date,
    b.slot_start_time,
    b.slot_end_time,
    b.amount,
    b.booking_status,
    p.payment_method,
    p.payment_status,
    p.total_amount
FROM bookings b
INNER JOIN customers c
    ON b.customer_id = c.customer_id
INNER JOIN turfs t
    ON b.turf_id = t.turf_id
LEFT JOIN payments p
    ON b.booking_id = p.booking_id
ORDER BY b.booking_date DESC;

-- Q7- Find the total revenue generated by each turf and display the highest revenue turf first.
SELECT
    t.turf_id,
    t.turf_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(p.total_amount) AS total_revenue
FROM turfs t
INNER JOIN bookings b
    ON t.turf_id = b.turf_id
INNER JOIN payments p
    ON b.booking_id = p.booking_id
WHERE p.payment_status = 'Success'
GROUP BY t.turf_id, t.turf_name
ORDER BY total_revenue DESC;


-- Q8 Create a stored procedure to generate a complete booking report showing customer details, turf details, booking details, and payment details.
DELIMITER //

CREATE PROCEDURE GetBookingReport()
BEGIN
    SELECT
        b.booking_id,
        c.customer_id,
        c.full_name AS customer_name,
        t.turf_name,
        b.booking_date,
        b.slot_start_time,
        b.slot_end_time,
        b.amount,
        b.booking_status,
        p.payment_method,
        p.payment_status,
        p.total_amount
    FROM bookings b
    INNER JOIN customers c
        ON b.customer_id = c.customer_id
    INNER JOIN turfs t
        ON b.turf_id = t.turf_id
    LEFT JOIN payments p
        ON b.booking_id = p.booking_id
    ORDER BY b.booking_date DESC;
END //

DELIMITER ;

-- Q9- Create a View to display a complete booking report showing customer details, turf details, booking information, and payment information.

CREATE VIEW vw_booking_report AS
SELECT
    b.booking_id,
    c.customer_id,
    c.full_name AS customer_name,
    t.turf_name,
    b.booking_date,
    b.slot_start_time,
    b.slot_end_time,
    b.amount,
    b.booking_status,
    p.payment_method,
    p.payment_status,
    p.total_amount
FROM bookings b
INNER JOIN customers c
    ON b.customer_id = c.customer_id
INNER JOIN turfs t
    ON b.turf_id = t.turf_id
LEFT JOIN payments p
    ON b.booking_id = p.booking_id;
    
SELECT * FROM vw_booking_report;

-- Q10- Create a trigger to automatically increase the customer's total_bookings count whenever a new booking is inserted.
DELIMITER //

CREATE TRIGGER trg_update_total_bookings
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    UPDATE customers
    SET total_bookings = total_bookings + 1
    WHERE customer_id = NEW.customer_id;
END //

DELIMITER ;

-- Q11-Generate a cancellation report showing customer name, booking ID, cancellation date, reason, and refund amount.

SELECT
    c.full_name,
    ca.booking_id,
    ca.cancellation_date,
    ca.reason,
    ca.refund_amount,
    ca.refund_status
FROM cancellations ca
INNER JOIN customers c
    ON ca.customer_id = c.customer_id
ORDER BY ca.cancellation_date DESC;

-- Q12-peak booking hour top 1

SELECT
    slot_start_time,
    slot_end_time,
    COUNT(*) AS total_bookings
FROM bookings
WHERE booking_status IN ('Confirmed', 'Completed')
GROUP BY slot_start_time, slot_end_time
ORDER BY total_bookings DESC
limit 1