CREATE database UPI;
use UPI;
create TABLE PAYMENTS(PAYMENT_ID INT);
drop TABLE PAYMENTS;
CREATE TABLE USER(user_id INT AUTO_INCREMENT PRIMARY KEY,name VARCHAR(255) NOT NULL,mobile_number VARCHAR(10) UNIQUE NOT NULL,
hashedpin VARCHAR(255) NOT NULL,registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, email VARCHAR(255) UNIQUE NOT NULL ); 
CREATE TABLE MERCHANT (merchantid INT AUTO_INCREMENT PRIMARY KEY, businessname VARCHAR(255) NOT NULL,contactname VARCHAR(255) NOT NULL,          
upi_id VARCHAR(50) UNIQUE NOT NULL);
CREATE TABLE BANK (bank_id INT AUTO_INCREMENT PRIMARY KEY,bank_name VARCHAR(255) NOT NULL,ifsc_code VARCHAR(20) UNIQUE NOT NULL,  
branch_name VARCHAR(255) NOT NULL);
CREATE TABLE Account (account_id INT AUTO_INCREMENT PRIMARY KEY,user_id INT,bank_id INT,account_number VARCHAR(20) UNIQUE NOT NULL,FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,  
FOREIGN KEY (bank_id) REFERENCES Bank(bank_id) ON DELETE CASCADE );
CREATE TABLE EncryptionKey (encry_id INT AUTO_INCREMENT PRIMARY KEY,user_id INT UNIQUE,generation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
expiry_date TIMESTAMP NOT NULL,FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE);
CREATE TABLE VPA (vpa_id INT AUTO_INCREMENT PRIMARY KEY,user_id INT NOT NULL,vpa_address VARCHAR(255) UNIQUE NOT NULL,
FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE);
CREATE TABLE Transaction (transac_id INT AUTO_INCREMENT PRIMARY KEY,sender_id INT NOT NULL,sender_type ENUM('USER', 'MERCHANT') NOT NULL,
receiver_id INT NOT NULL,receiver_type ENUM('USER', 'MERCHANT') NOT NULL,status ENUM('PENDING', 'SUCCESS', 'FAILED') NOT NULL,
timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,amount DECIMAL(10,2) NOT NULL,vpa_id INT NOT NULL,FOREIGN KEY (vpa_id) REFERENCES VPA(vpa_id) ON DELETE CASCADE
);
CREATE TABLE Device (device_id INT AUTO_INCREMENT PRIMARY KEY,user_id INT NOT NULL,device_type ENUM('MOBILE', 'TABLET', 'LAPTOP') NOT NULL,
FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE);
CREATE TABLE Session (sess_id INT AUTO_INCREMENT PRIMARY KEY,user_id INT NOT NULL,device_id INT NOT NULL,encry_id INT NOT NULL,
login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,logout_time TIMESTAMP NULL,FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
FOREIGN KEY (device_id) REFERENCES Device(device_id) ON DELETE CASCADE,FOREIGN KEY (encry_id) REFERENCES EncryptionKey(encry_id) ON DELETE CASCADE
);
SHOW TABLES;
DESC User;
DESC Merchant;
DESC Bank;
desc account;
desc vpa;
desc encryptionkey;
desc transaction;
desc session;
desc device;
INSERT INTO User (name, mobile_number, hashedpin, email) 
VALUES ('Alice', '9876543210', 'hashed_pin_1', 'alice@example.com'),
       ('Bob', '8765432109', 'hashed_pin_2', 'bob@example.com');
select * from user;
INSERT INTO Merchant (businessname, contactname, upi_id) 
VALUES ('ShopX', 'John Doe', 'shopx@upi'),
       ('MartY', 'Jane Smith', 'marty@upi');
select *from merchant;
INSERT INTO Bank (bank_name, ifsc_code, branch_name) 
VALUES ('Bank A', 'BANK0001', 'Main Branch'),
       ('Bank B', 'BANK0002', 'City Branch');
select * from bank;
INSERT INTO Account (user_id, bank_id, account_number) 
VALUES (1, 1, '1234567890'),
       (2, 2, '0987654321');
select * from account;
INSERT INTO VPA (user_id, vpa_address) 
VALUES 
(1, 'alice@upi'),
(2, 'bob@upi');
select * from vpa;
INSERT INTO EncryptionKey (user_id, expiry_date) 
VALUES 
(1, '2026-03-27'),
(2, '2026-03-27');
select *from encryptionkey;
INSERT INTO Device (user_id, device_type) 
VALUES 
(1, 'Mobile'),
(2, 'Laptop');
select * from device;
INSERT INTO Session (user_id, device_id, encry_id, logout_time) 
VALUES 
(1, 1, 1, '2025-03-27 11:00:00'),
(2, 2, 2, '2025-03-27 13:00:00');
select * from session;
INSERT INTO Transaction (sender_id, sender_type, receiver_id, receiver_type, status, amount, vpa_id) 
VALUES 
(1, 'USER', 2, 'MERCHANT', 'SUCCESS', 500.00, 1),
(2, 'MERCHANT', 1, 'USER', 'PENDING', 1200.00, 2);
select * from transaction;
SELECT * FROM Transaction WHERE sender_id = 1 OR receiver_id = 1;
UPDATE User SET email = 'new_email@example.com' WHERE user_id = 1;
select * from user;
SELECT 
    t.transac_id, 
    u1.name AS sender_name, 
    u2.name AS receiver_name, 
    t.amount, 
    t.status, 
    t.timestamp
FROM Transaction t
JOIN User u1 ON t.sender_id = u1.user_id
JOIN User u2 ON t.receiver_id = u2.user_id;
select * from merchant;
SELECT sender_id, SUM(amount) AS total_sent 
FROM Transaction 
WHERE status = 'SUCCESS' 
GROUP BY sender_id;
SELECT s.sess_id, u.name, d.device_type, s.login_time 
FROM Session s
JOIN User u ON s.user_id = u.user_id
JOIN Device d ON s.device_id = d.device_id
WHERE s.logout_time IS NULL;
SELECT * FROM Session;
INSERT INTO Session (user_id, device_id, encry_id, login_time, logout_time) 
VALUES (2, 1, 1, NOW(), NULL);
UPDATE Session 
SET logout_time = NULL 
WHERE sess_id = 2;
SELECT s.sess_id, u.name, d.device_type, s.login_time 
FROM Session s
JOIN User u ON s.user_id = u.user_id
JOIN Device d ON s.device_id = d.device_id
WHERE s.logout_time IS NULL;
SELECT 
    t.transac_id, 
    CASE 
        WHEN t.sender_type = 'USER' THEN u.name 
        ELSE m.businessname 
    END AS sender_name, 

    CASE 
        WHEN t.receiver_type = 'USER' THEN u2.name 
        ELSE m2.businessname 
    END AS receiver_name, 

    t.amount, 
    t.status, 
    t.timestamp
FROM Transaction t
LEFT JOIN User u ON t.sender_id = u.user_id AND t.sender_type = 'USER'
LEFT JOIN Merchant m ON t.sender_id = m.merchantid AND t.sender_type = 'MERCHANT'
LEFT JOIN User u2 ON t.receiver_id = u2.user_id AND t.receiver_type = 'USER'
LEFT JOIN Merchant m2 ON t.receiver_id = m2.merchantid AND t.receiver_type = 'MERCHANT' WHERE t.status="success";
SELECT u.name, 
       COUNT(t.transac_id) AS total_transactions, 
       SUM(t.amount) AS total_amount
FROM Transaction t
JOIN User u ON t.sender_id = u.user_id OR t.receiver_id = u.user_id
WHERE t.status = 'SUCCESS'
GROUP BY u.user_id;
SELECT m.businessname, 
       COUNT(t.transac_id) AS total_transactions, 
       SUM(t.amount) AS total_revenue
FROM Transaction t
JOIN Merchant m ON t.receiver_id = m.merchantid AND t.receiver_type = 'MERCHANT'
WHERE t.status = 'SUCCESS'
GROUP BY m.merchantid;
SELECT u.name, COUNT(t.transac_id) AS transaction_count
FROM Transaction t
JOIN User u ON t.sender_id = u.user_id OR t.receiver_id = u.user_id
GROUP BY u.user_id
ORDER BY transaction_count DESC
LIMIT 5;
SELECT t.transac_id, 
       u1.name AS sender_name, 
       u2.name AS receiver_name, 
       t.amount, 
       t.timestamp
FROM Transaction t
LEFT JOIN User u1 ON t.sender_id = u1.user_id AND t.sender_type = 'USER'
LEFT JOIN Merchant m1 ON t.sender_id = m1.merchantid AND t.sender_type = 'MERCHANT'
LEFT JOIN User u2 ON t.receiver_id = u2.user_id AND t.receiver_type = 'USER'
LEFT JOIN Merchant m2 ON t.receiver_id = m2.merchantid AND t.receiver_type = 'MERCHANT'
WHERE t.status = 'PENDING';
SELECT 
    t.transac_id, 
    COALESCE(u1.name, m1.businessname) AS sender_name,  -- Get User name or Merchant name
    COALESCE(u2.name, m2.businessname) AS receiver_name, -- Get User name or Merchant name
    t.amount, 
    t.timestamp
FROM Transaction t
LEFT JOIN User u1 ON t.sender_id = u1.user_id AND t.sender_type = 'USER'
LEFT JOIN Merchant m1 ON t.sender_id = m1.merchantid AND t.sender_type = 'MERCHANT'
LEFT JOIN User u2 ON t.receiver_id = u2.user_id AND t.receiver_type = 'USER'
LEFT JOIN Merchant m2 ON t.receiver_id = m2.merchantid AND t.receiver_type = 'MERCHANT'
WHERE t.status = 'PENDING';
SELECT * FROM Transaction
WHERE timestamp >= NOW() - INTERVAL 1 DAY;
SELECT t.transac_id, u1.name AS sender, u2.name AS receiver, 
       t.amount, t.status, t.timestamp
FROM Transaction t
JOIN User u1 ON t.sender_id = u1.user_id
JOIN User u2 ON t.receiver_id = u2.user_id
WHERE t.status = 'FAILED';
SELECT 
    t.transac_id, 
    COALESCE(u1.name, m1.businessname) AS sender, 
    COALESCE(u2.name, m2.businessname) AS receiver, 
    t.amount, 
    t.status, 
    t.timestamp
FROM Transaction t
LEFT JOIN User u1 ON t.sender_id = u1.user_id AND t.sender_type = 'USER'
LEFT JOIN Merchant m1 ON t.sender_id = m1.merchantid AND t.sender_type = 'MERCHANT'
LEFT JOIN User u2 ON t.receiver_id = u2.user_id AND t.receiver_type = 'USER'
LEFT JOIN Merchant m2 ON t.receiver_id = m2.merchantid AND t.receiver_type = 'MERCHANT'
WHERE t.status = 'FAILED';
SELECT COUNT(*) FROM Transaction WHERE status = 'FAILED';
SELECT u.name, w.balance 
FROM Wallet w 
JOIN User u ON w.user_id = u.user_id;
SELECT u.name, SUM(t.amount) AS total_spent
FROM Transaction t
JOIN User u ON t.sender_id = u.user_id
WHERE t.status = 'SUCCESS'
GROUP BY u.name;
SELECT m.businessname, SUM(t.amount) AS total_received
FROM Transaction t
JOIN Merchant m ON t.receiver_id = m.merchantid
WHERE t.status = 'SUCCESS'
GROUP BY m.businessname;
ALTER TABLE User ADD COLUMN balance DECIMAL(10,2) DEFAULT 0;
ALTER TABLE Merchant ADD COLUMN balance DECIMAL(10,2) DEFAULT 0;
UPDATE User 
SET balance = balance - (SELECT amount FROM Transaction WHERE transac_id = ?) 
WHERE user_id = (SELECT sender_id FROM Transaction WHERE transac_id = ?) 
AND status = 'SUCCESS';
UPDATE Merchant 
SET balance = balance + (SELECT amount FROM Transaction WHERE transac_id = ?) 
WHERE merchantid = (SELECT receiver_id FROM Transaction WHERE transac_id = ?) 
AND status = 'SUCCESS';























