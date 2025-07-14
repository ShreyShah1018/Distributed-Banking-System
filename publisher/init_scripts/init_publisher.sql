CREATE USER replication_user WITH REPLICATION LOGIN PASSWORD 'replication';

GRANT CONNECT ON DATABASE banking_db TO replication_user;

\c banking_db 

CREATE TABLE IF NOT EXISTS PERSON (
    PersonID INT PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    DOB DATE,
    Email VARCHAR(255),
    PhoneNumber VARCHAR(255),
    TaxIdentifier VARCHAR(255),
    Address_1 VARCHAR(255),
    Address_2 VARCHAR(255),
    ApartmentNumber INT,
    State VARCHAR(255),
    County VARCHAR(255),
    PostalCode INT,
    Country VARCHAR(255),
    OnboardingApplication_ApplicationID INT
);
 

CREATE TABLE IF NOT EXISTS ONBOARDINGAPPLICATION (
    ApplicationID INT PRIMARY KEY,
    PersonID INT,
    ApplicationStatus VARCHAR(255),
    SubmissionDate DATE,
    ApprovalDate DATE,
    FOREIGN KEY (PersonID) REFERENCES PERSON(PersonID)
);
 

CREATE TABLE IF NOT EXISTS BRANCH (
    BranchID INT PRIMARY KEY,
    BranchName VARCHAR(255),
    Address_1 VARCHAR(255),
    Address_2 VARCHAR(255),
    ApartmentNumber INT,
    State VARCHAR(255),
    County VARCHAR(255),
    PostalCode INT,
    Country VARCHAR(255),
    PhoneNumber VARCHAR(255)
);
 

CREATE TABLE IF NOT EXISTS USER_ROLES (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(255),
    permissions JSONB
);
 

CREATE TABLE IF NOT EXISTS EMPLOYEE (
    EmployeeID INT PRIMARY KEY,
    role_id INT,
    Position VARCHAR(255),
    Person_PersonID INT,
    Branch_BranchID INT,
    FOREIGN KEY (role_id) REFERENCES USER_ROLES(role_id),
    FOREIGN KEY (Person_PersonID) REFERENCES PERSON(PersonID),
    FOREIGN KEY (Branch_BranchID) REFERENCES BRANCH(BranchID)
);
 

CREATE TABLE IF NOT EXISTS CUSTOMER (
    CustomerID INT PRIMARY KEY,
    CustomerType VARCHAR(255),
    Person_PersonID INT,
    FOREIGN KEY (Person_PersonID) REFERENCES PERSON(PersonID)
);

CREATE TABLE IF NOT EXISTS USERLOGIN (
    LoginID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    Username VARCHAR(255) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    LastLoginTime DATE,
    Salt VARCHAR(255) NOT NULL,
    Customer_CustomerID INT NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (Customer_CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE IF NOT EXISTS ACCOUNT (
    AccountID INT PRIMARY KEY,
    AccountType VARCHAR(255),
    AccountNumber VARCHAR(255),
    CurrentBalance DECIMAL(18, 2),
    DateOpened DATE,
    DateClosed DATE,
    AccountStatus VARCHAR(255),
    Branch_BranchID INT,
    FOREIGN KEY (Branch_BranchID) REFERENCES BRANCH(BranchID)
);
 

CREATE TABLE IF NOT EXISTS CUSTOMER_ACCOUNT (
    Customer_CustomerID INT,
    Account_AccountID INT,
    FOREIGN KEY (Customer_CustomerID) REFERENCES CUSTOMER(CustomerID),
    FOREIGN KEY (Account_AccountID) REFERENCES ACCOUNT(AccountID)
);
 

CREATE TABLE IF NOT EXISTS TRANSACTION (
    TransactionID INT PRIMARY KEY,
    Account_AccountID INT,
    Amount DECIMAL(18, 2),
    TransactionType VARCHAR(255),
    TransactionDate DATE,
    FOREIGN KEY (Account_AccountID) REFERENCES ACCOUNT(AccountID)
);
 

CREATE TABLE IF NOT EXISTS TRANSACTION_LOGS (
    LogID INT PRIMARY KEY,
    TransactionID INT,
    LogDetails VARCHAR(255),
    CreatedAt TIMESTAMP,
    FOREIGN KEY (TransactionID) REFERENCES TRANSACTION(TransactionID)
);
 

CREATE TABLE IF NOT EXISTS PAYMENT_GATEWAY_LOGS (
    GatewayLogID INT PRIMARY KEY,
    TransactionLogID INT,
    GatewayName VARCHAR(255),
    Status VARCHAR(255),
    GatewayTimestamp TIMESTAMP,
    FOREIGN KEY (TransactionLogID) REFERENCES TRANSACTION_LOGS(LogID)
);
 

CREATE TABLE IF NOT EXISTS LOANAPPLICATIONS (
    ApplicationID INT PRIMARY KEY,
    PersonID INT,
    LoanType VARCHAR(255),
    RequestedAmount DECIMAL(18, 2),
    Status VARCHAR(255),
    ApplicationDate DATE
);
 

CREATE TABLE IF NOT EXISTS LOAN (
    LoanID INT PRIMARY KEY,
    LoanType VARCHAR(255),
    LoanAmount INT,
    InterestRate DECIMAL(5, 2),
    Term INT,
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(255),
    Customer_CustomerID INT,
    LoanApplications_ApplicationID INT,
    FOREIGN KEY (Customer_CustomerID) REFERENCES CUSTOMER(CustomerID),
    FOREIGN KEY (LoanApplications_ApplicationID) REFERENCES LOANAPPLICATIONS(ApplicationID)
);
 

CREATE TABLE IF NOT EXISTS LOAN_PAYMENT (
    LoanPaymentID INT PRIMARY KEY,
    ScheduledPaymentDate DATE,
    PaymentAmount DECIMAL(18, 2),
    PrincipalAmount DECIMAL(18, 2),
    InterestAmount DECIMAL(18, 2),
    PaidAmount DECIMAL(18, 2),
    PaidDate DATE,
    Loan_LoanID INT,
    FOREIGN KEY (Loan_LoanID) REFERENCES LOAN(LoanID)
);
 

CREATE TABLE IF NOT EXISTS KYC (
    KYCID INT PRIMARY KEY,
    PersonID INT,
    VerificationType VARCHAR(255),
    Status VARCHAR(255),
    DocumentID INT,
    Person_PersonID INT,
    FOREIGN KEY (Person_PersonID) REFERENCES PERSON(PersonID)
);
 

CREATE TABLE IF NOT EXISTS NOTIFICATIONS (
    NotificationID INT PRIMARY KEY,
    CustomerID INT,
    Message VARCHAR(255),
    NotificationType VARCHAR(255),
    Status VARCHAR(255),
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);
 

CREATE TABLE IF NOT EXISTS SERVICE_REQUESTS (
    RequestID INT PRIMARY KEY,
    CustomerID INT,
    Details VARCHAR(255),
    Status VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);
 

CREATE TABLE IF NOT EXISTS SUPPORT_TICKETS (
    TicketID INT PRIMARY KEY,
    RequestID INT,
    IssueDescription VARCHAR(255),
    Status VARCHAR(255),
    FOREIGN KEY (RequestID) REFERENCES SERVICE_REQUESTS(RequestID)
);
 

CREATE TABLE IF NOT EXISTS SECURITYQUESTIONS (
    QuestionID INT PRIMARY KEY,
    QuestionText VARCHAR(255)
);
 

CREATE TABLE IF NOT EXISTS CUSTOMERSECURITYANSWERS (
    answer_id INT PRIMARY KEY,
    customer_id INT,
    question_id INT,
    answer VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(CustomerID),
    FOREIGN KEY (question_id) REFERENCES SECURITYQUESTIONS(QuestionID)
);
 

CREATE TABLE IF NOT EXISTS FRAUD_ALERTS (
    AlertID INT PRIMARY KEY,
    CustomerID INT,
    Description VARCHAR(255),
    Timestamp TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);

CREATE TABLE IF NOT EXISTS FRAUD_CASES (
    CaseID INT PRIMARY KEY,
    CustomerID INT,
    Details VARCHAR(255),
    ResolutionStatus VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);
 

CREATE TABLE IF NOT EXISTS CUSTOMER_FEEDBACK (
    feedback_id INT PRIMARY KEY,
    customer_id INT,
    comments VARCHAR(255),
    rating INT,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(CustomerID)
);
 

CREATE TABLE IF NOT EXISTS NOTIFICATIONS_PREFERENCES (
    preference_id INT PRIMARY KEY,
    customer_id INT,
    type VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(CustomerID)
);
 

CREATE TABLE IF NOT EXISTS ATM_LOCATIONS (
    ATMID INT PRIMARY KEY,
    Location VARCHAR(255),
    BranchID INT,
    FOREIGN KEY (BranchID) REFERENCES BRANCH(BranchID)
);
 

CREATE TABLE IF NOT EXISTS ATM_TRANSACTIONS (
    atm_transaction_id INT PRIMARY KEY,
    account_id INT,
    amount DECIMAL(18, 2),
    atm_location VARCHAR(255),
    FOREIGN KEY (account_id) REFERENCES ACCOUNT(AccountID)
);
 

CREATE TABLE IF NOT EXISTS CARD (
    CardID INT PRIMARY KEY,
    CardNumber BIGINT,
    CardType VARCHAR(255),
    CustomerID INT,
    AccountID INT,
    IssueDate DATE,
    ExpiryDate DATE,
    CreditLimit DECIMAL(18, 2),
    CardStatus VARCHAR(255),
    CVV INT,
    Account_AccountID INT,
    FOREIGN KEY (Account_AccountID) REFERENCES ACCOUNT(AccountID)
);
 

CREATE TABLE IF NOT EXISTS BENEFICIARY (
    BeneficiaryID INT PRIMARY KEY,
    CustomerID INT,
    BeneficiaryName VARCHAR(255),
    AccountNumber VARCHAR(255),
    RoutingNumber VARCHAR(255),
    BankName VARCHAR(255),
    Email VARCHAR(255),
    PhoneNumber VARCHAR(255),
    Account_AccountID INT,
    FOREIGN KEY (Account_AccountID) REFERENCES ACCOUNT(AccountID)
);
 

CREATE TABLE IF NOT EXISTS AUDITLOGS (
    LogID INT PRIMARY KEY,
    SessionId VARCHAR(255),
    CustomerID INT,
    LoginID INT,
    ActionType VARCHAR(255),
    Timestamp TIMESTAMP,
    DeviceInfo VARCHAR(255),
    IPAddress VARCHAR(255),
    Person_PersonID INT,
    FOREIGN KEY (Person_PersonID) REFERENCES PERSON(PersonID)
);
 

CREATE TABLE IF NOT EXISTS SCHEDULEDPAYMENTS (
    ScheduleID INT PRIMARY KEY,
    FromAccountID INT,
    ToAccountID INT,
    Amount DECIMAL(18, 2),
    Frequency VARCHAR(255),
    NextExecutionDate DATE,
    Status VARCHAR(255),
    TotalExecutions INT,
    Account_AccountID INT,
    FOREIGN KEY (Account_AccountID) REFERENCES ACCOUNT(AccountID)
);
 

CREATE TABLE IF NOT EXISTS STANDINGORDER (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    FromAccountID INT,
    BeneficiaryName VARCHAR(255),
    BeneficiaryAccountNumber VARCHAR(255),
    RoutingNumber VARCHAR(255),
    Amount DECIMAL(18, 2),
    Frequency VARCHAR(255),
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(255),
    Account_AccountID INT,
    FOREIGN KEY (Account_AccountID) REFERENCES ACCOUNT(AccountID)
);

INSERT INTO PERSON VALUES
    (1, 'John', 'Doe', '1985-05-15', 'john.doe@example.com', '1234567890', 'TX12345', '123 Main St', 'Apt 4B', 4, 'Texas', 'Dallas', 75201, 'USA', 101),
    (2, 'Jane', 'Smith', '1990-08-20', 'jane.smith@example.com', '0987654321', 'CA54321', '456 Elm St', NULL, NULL, 'California', 'Los Angeles', 90001, 'USA', 102),
    (3, 'Michael', 'Brown', '1983-11-05', 'michael.brown@example.com', '2345678901','NY67890', '789 Pine St', 'Suite 300', NULL, 'New York', 'New York', 10001, 'USA', 103),
    (4, 'Emily', 'Davis', '1992-03-12', 'emily.davis@example.com', '3456789012', 'FL34567', '321 Oak St', NULL, 2, 'Florida', 'Miami', 33101, 'USA', 104),
    (5, 'William', 'Wilson', '1978-01-25', 'william.wilson@example.com', '4567890123', 'IL45678', '654 Maple St', NULL, NULL, 'Illinois', 'Chicago', 60601, 'USA', 105),
    (6, 'Sophia', 'Johnson', '1995-12-14', 'sophia.johnson@example.com', '5678901234', 'PA78901', '987 Cedar St', NULL, 5, 'Pennsylvania', 'Philadelphia', 19101, 'USA', 106),
    (7, 'Daniel', 'Moore', '1987-09-09', 'daniel.moore@example.com', '6789012345', 'GA23456', '543 Birch St', 'Floor 2', NULL, 'Georgia', 'Atlanta', 30301, 'USA', 107),
    (8, 'Olivia', 'Garcia', '1993-06-17', 'olivia.garcia@example.com', '7890123456', 'WA34567', '321 Willow St', NULL, NULL, 'Washington', 'Seattle', 98101, 'USA', 108),
    (9, 'James', 'Martinez', '1982-02-11', 'james.martinez@example.com', '8901234567', 'TX12390', '123 Spruce St', NULL, NULL, 'Texas', 'Austin', 73301, 'USA', 109),
    (10, 'Isabella', 'Lopez', '1991-04-29', 'isabella.lopez@example.com', '9012345678', 'CO45678', '654 Redwood St', NULL, NULL, 'Colorado', 'Denver', 80201, 'USA', 110);

INSERT INTO ONBOARDINGAPPLICATION VALUES
    (101, 1, 'Pending', '2023-11-01', NULL),
    (102, 2, 'Approved', '2023-10-15', '2023-10-20'),
    (103, 3, 'Rejected', '2023-09-12', '2023-09-15'),
    (104, 4, 'Pending', '2023-11-05', NULL),
    (105, 5, 'Approved', '2023-09-20', '2023-09-25'),
    (106, 6, 'Pending', '2023-11-10', NULL),
    (107, 7, 'Approved', '2023-08-30', '2023-09-02'),
    (108, 8, 'Pending', '2023-11-15', NULL),
    (109, 9, 'Rejected', '2023-07-20', '2023-07-22'),
    (110, 10, 'Pending', '2023-11-20', NULL);

INSERT INTO BRANCH VALUES
    (1, 'Main Branch', '100 Main St', NULL, NULL, 'New York', 'New York', 10001, 'USA', '123-456-7890'),
    (2, 'Downtown Branch', '200 Elm St', NULL, NULL, 'California', 'Los Angeles', 90001, 'USA', '234-567-8901'),
    (3, 'Uptown Branch', '300 Oak St', NULL, NULL, 'Texas', 'Houston', 77001, 'USA', '345-678-9012'),
    (4, 'Midtown Branch', '400 Pine St', NULL, NULL, 'Illinois', 'Chicago', 60601, 'USA', '456-789-0123'),
    (5, 'South Branch', '500 Maple St', NULL, NULL, 'Florida', 'Miami', 33101, 'USA', '567-890-1234'),
    (6, 'East Branch', '600 Birch St', NULL, NULL, 'Washington', 'Seattle', 98101, 'USA', '678-901-2345'),
    (7, 'West Branch', '700 Cedar St', NULL, NULL, 'Colorado', 'Denver', 80201, 'USA', '789-012-3456'),
    (8, 'North Branch', '800 Spruce St', NULL, NULL, 'Georgia', 'Atlanta', 30301, 'USA', '890-123-4567'),
    (9, 'Suburban Branch', '900 Redwood St', NULL, NULL, 'Pennsylvania', 'Philadelphia',19101, 'USA', '901-234-5678'),
    (10, 'City Branch', '1000 Willow St', NULL, NULL, 'Texas', 'Austin', 73301, 'USA', '012-345-6789');

INSERT INTO USER_ROLES VALUES
    (1, 'Admin', '{"permissions":["view", "edit", "delete", "create"]}'),
    (2, 'Manager', '{"permissions":["view", "edit", "create"]}'),
    (3, 'Clerk', '{"permissions":["view", "create"]}'),
    (4, 'Customer Support', '{"permissions":["view", "edit"]}'),
    (5, 'Auditor', '{"permissions":["view"]}'),
    (6, 'Loan Officer', '{"permissions":["view", "edit", "approve"]}'),
    (7, 'Teller', '{"permissions":["view", "create", "update"]}'),
    (8, 'IT Support', '{"permissions":["view", "edit", "delete"]}'),
    (9, 'Compliance Officer', '{"permissions":["view", "audit"]}'),
    (10, 'Marketing', '{"permissions":["view", "create"]}');

INSERT INTO EMPLOYEE VALUES
    (1, 1, 'Branch Manager', 1, 1),
    (2, 2, 'Teller', 2, 2),
    (3, 3, 'Loan Officer', 3, 3),
    (4, 4, 'Customer Support', 4, 4),
    (5, 5, 'Auditor', 5, 5),
    (6, 6, 'Compliance Officer', 6, 6),
    (7, 7, 'IT Specialist', 7, 7),
    (8, 8, 'Marketing Executive', 8, 8),
    (9, 9, 'Branch Manager', 9, 9),
    (10, 10, 'Teller', 10, 10);

INSERT INTO CUSTOMER VALUES
    (1, 'Individual', 1),
    (2, 'Individual', 2),
    (3, 'Corporate', 3),
    (4, 'Individual', 4),
    (5, 'Corporate', 5),
    (6, 'Individual', 6),
    (7, 'Corporate', 7),
    (8, 'Individual', 8),
    (9, 'Corporate', 9),
    (10, 'Individual', 10);

INSERT INTO USERLOGIN(CustomerID, Username, Password, LastLoginTime, Salt, Customer_CustomerID) VALUES
    (1, 'user1', 'password1', '2024-11-20', 'salt1', 1),
    (2, 'user2', 'password2', '2024-11-21', 'salt2', 2),
    (3, 'user3', 'password3', '2024-11-22', 'salt3', 3),
    (4, 'user4', 'password4', '2024-11-23', 'salt4', 4),
    (5, 'user5', 'password5', '2024-11-24', 'salt5', 5),
    (6, 'user6', 'password6', '2024-11-25', 'salt6', 6),
    (7, 'user7', 'password7', '2024-11-26', 'salt7', 7),
    (8, 'user8', 'password8', '2024-11-27', 'salt8', 8),
    (9, 'user9', 'password9', '2024-11-28', 'salt9', 9),
    (10, 'user10', 'password10', '2024-11-29', 'salt10', 10);

INSERT INTO ACCOUNT VALUES
    (1, 'Savings', '1000001', 5000.00, '2023-01-01', NULL, 'Active', 1),
    (2, 'Checking', '1000002', 2000.00, '2023-02-01', NULL, 'Active', 2),
    (3, 'Savings', '1000003', 15000.00, '2023-03-01', NULL, 'Active', 3),
    (4, 'Checking', '1000004', 800.00, '2023-04-01', NULL, 'Active', 4),
    (5, 'Savings', '1000005', 12000.00, '2023-05-01', NULL, 'Active', 5),
    (6, 'Savings', '1000006', 7000.00, '2023-06-01', NULL, 'Active', 6),
    (7, 'Checking', '1000007', 300.00, '2023-07-01', NULL, 'Active', 7),
    (8, 'Savings', '1000008', 6000.00, '2023-08-01', NULL, 'Active', 8),
    (9, 'Checking', '1000009', 2500.00, '2023-09-01', NULL, 'Active', 9),
    (10, 'Savings', '1000010', 8000.00, '2023-10-01', NULL, 'Active', 10);

INSERT INTO CUSTOMER_ACCOUNT VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 7),
    (8, 8),
    (9, 9),
    (10, 10);

INSERT INTO TRANSACTION VALUES
    (1, 1, 100.00, 'Deposit', '2023-11-01'),
    (2, 2, 50.00, 'Withdrawal', '2023-11-02'),
    (3, 3, 200.00, 'Deposit', '2023-11-03'),
    (4, 4, 30.00, 'Withdrawal', '2023-11-04'),
    (5, 5, 500.00, 'Deposit', '2023-11-05'),
    (6, 6, 100.00, 'Withdrawal', '2023-11-06'),
    (7, 7, 700.00, 'Deposit', '2023-11-07'),
    (8, 8, 20.00, 'Withdrawal', '2023-11-08'),
    (9, 9, 300.00, 'Deposit', '2023-11-09'),
    (10, 10, 90.00, 'Withdrawal', '2023-11-10');

INSERT INTO TRANSACTION_LOGS VALUES
    (1, 1, 'Transaction successful', '2023-11-01 10:00:00'),
    (2, 2, 'Transaction successful', '2023-11-02 11:00:00'),
    (3, 3, 'Transaction successful', '2023-11-03 12:00:00'),
    (4, 4, 'Transaction failed', '2023-11-04 13:00:00'),
    (5, 5, 'Transaction successful', '2023-11-05 14:00:00'),
    (6, 6, 'Transaction failed', '2023-11-06 15:00:00'),
    (7, 7, 'Transaction successful', '2023-11-07 16:00:00'),
    (8, 8, 'Transaction failed', '2023-11-08 17:00:00'),
    (9, 9, 'Transaction successful', '2023-11-09 18:00:00'),
    (10, 10, 'Transaction successful', '2023-11-10 19:00:00');

INSERT INTO PAYMENT_GATEWAY_LOGS VALUES
    (1, 1, 'PayPal', 'Success', '2023-11-01 10:05:00'),
    (2, 2, 'Stripe', 'Success', '2023-11-02 11:05:00'),
    (3, 3, 'Square', 'Failed', '2023-11-03 12:05:00'),
    (4, 4, 'PayPal', 'Failed', '2023-11-04 13:05:00'),
    (5, 5, 'Stripe', 'Success', '2023-11-05 14:05:00'),
    (6, 6, 'Square', 'Failed', '2023-11-06 15:05:00'),
    (7, 7, 'PayPal', 'Success', '2023-11-07 16:05:00'),
    (8, 8, 'Stripe', 'Success', '2023-11-08 17:05:00'),
    (9, 9, 'Square', 'Success', '2023-11-09 18:05:00'),
    (10, 10, 'PayPal', 'Failed', '2023-11-10 19:05:00');

INSERT INTO LOANAPPLICATIONS VALUES
    (1, 1, 'Home Loan', 100000.00, 'Pending', '2023-11-01'),
    (2, 2, 'Car Loan', 20000.00, 'Approved', '2023-10-20'),
    (3, 3, 'Personal Loan', 5000.00, 'Rejected', '2023-10-15'),
    (4, 4, 'Home Loan', 150000.00, 'Pending', '2023-11-03'),
    (5, 5, 'Car Loan', 25000.00, 'Approved', '2023-09-15'),
    (6, 6, 'Personal Loan', 8000.00, 'Pending', '2023-08-25'),
    (7, 7, 'Home Loan', 90000.00, 'Approved', '2023-07-14'),
    (8, 8, 'Car Loan', 30000.00, 'Rejected', '2023-06-18'),
    (9, 9, 'Personal Loan', 10000.00, 'Pending', '2023-05-22'),
    (10, 10, 'Home Loan', 120000.00, 'Approved', '2023-04-10');

INSERT INTO LOAN VALUES
    (1, 'Home Loan', 100000, 3.5, 240, '2023-11-10', '2043-11-10', 'Active', 1, 1),
    (2, 'Car Loan', 20000, 5.0, 60, '2023-10-30', '2028-10-30', 'Closed', 2, 2),
    (3, 'Personal Loan', 5000, 6.5, 36, '2023-09-20', '2026-09-20', 'Rejected', 3, 3),
    (4, 'Home Loan', 150000, 4.0, 240, '2023-12-01', '2043-12-01', 'Pending', 4, 4),
    (5, 'Car Loan', 25000, 4.5, 72, '2023-08-01', '2029-08-01', 'Active', 5, 5),
    (6, 'Personal Loan', 8000, 7.0, 48, '2023-07-01', '2027-07-01', 'Pending', 6, 6),
    (7, 'Home Loan', 90000, 3.8, 180, '2023-06-01', '2038-06-01', 'Active', 7, 7),
    (8, 'Car Loan', 30000, 4.2, 60, '2023-05-01', '2028-05-01', 'Rejected', 8, 8),
    (9, 'Personal Loan', 10000, 6.0, 36, '2023-04-01', '2026-04-01', 'Pending', 9, 9),
    (10, 'Home Loan', 120000, 3.9, 240, '2023-03-01', '2043-03-01', 'Active', 10, 10);

INSERT INTO LOAN_PAYMENT VALUES
    (1, '2023-12-01', 500.00, 400.00, 100.00, NULL, NULL, 1),
    (2, '2023-12-01', 300.00, 250.00, 50.00, NULL, NULL, 2),
    (3, '2023-12-01', 200.00, 150.00, 50.00, NULL, NULL, 3),
    (4, '2023-12-01', 600.00, 500.00, 100.00, NULL, NULL, 4),
    (5, '2023-12-01', 350.00, 300.00, 50.00, NULL, NULL, 5),
    (6, '2023-12-01', 250.00, 200.00, 50.00, NULL, NULL, 6),
    (7, '2023-12-01', 400.00, 350.00, 50.00, NULL, NULL, 7),
    (8, '2023-12-01', 500.00, 400.00, 100.00, NULL, NULL, 8),
    (9, '2023-12-01', 300.00, 250.00, 50.00, NULL, NULL, 9),
    (10, '2023-12-01', 450.00, 400.00, 50.00, NULL, NULL, 10);

INSERT INTO KYC VALUES
    (1, 1, 'Passport', 'Verified', 101, 1),
    (2, 2, 'Driver License', 'Verified', 102, 2),
    (3, 3, 'National ID', 'Pending', 103, 3),
    (4, 4, 'Passport', 'Rejected', 104, 4),
    (5, 5, 'Driver License', 'Verified', 105, 5),
    (6, 6, 'National ID', 'Verified', 106, 6),
    (7, 7, 'Passport', 'Pending', 107, 7),
    (8, 8, 'Driver License', 'Verified', 108, 8),
    (9, 9, 'National ID', 'Rejected', 109, 9),
    (10, 10, 'Passport', 'Verified', 110, 10);

INSERT INTO NOTIFICATIONS VALUES
    (1, 1, 'Welcome to our bank!', 'Welcome', 'Sent', '2023-11-01', '2023-11-30'),
    (2, 2, 'Your statement is ready.', 'Statement', 'Sent', '2023-11-01', '2023-11-30'),
    (3, 3, 'Your loan application is pending.', 'Loan Update', 'Pending', '2023-11-01', '2023-11-30'),
    (4, 4, 'We have updated our terms.', 'Update', 'Sent', '2023-11-01', '2023-11-30'),
    (5, 5, 'Your account balance is low.', 'Alert', 'Sent', '2023-11-01', '2023-11-30'),
    (6, 6, 'Your payment is due soon.', 'Reminder', 'Sent', '2023-11-01', '2023-11-30'),
    (7, 7, 'New services are available.', 'Promotion', 'Sent', '2023-11-01', '2023-11-30'),
    (8, 8, 'Your transaction was successful.', 'Transaction', 'Sent', '2023-11-01', '2023-11-30'),
    (9, 9, 'Your account has been updated.', 'Account', 'Sent', '2023-11-01', '2023-11-30'),
    (10, 10, 'Welcome to premium banking.', 'Welcome', 'Sent', '2023-11-01', '2023-11-30');

INSERT INTO SERVICE_REQUESTS VALUES
    (1, 1, 'Request for account statement.', 'Open'),
    (2, 2, 'Change of address request.', 'Closed'),
    (3, 3, 'Request for loan details.', 'In Progress'),
    (4, 4, 'Help with online banking.', 'Open'),
    (5, 5, 'Query about account charges.', 'Closed'),
    (6, 6, 'Request for card replacement.', 'In Progress'),
    (7, 7, 'Request for account closure.', 'Open'),
    (8, 8, 'Query about interest rates.', 'Closed'),
    (9, 9, 'Help with password reset.', 'In Progress'),
    (10, 10, 'Request for cheque book.', 'Open');

INSERT INTO SUPPORT_TICKETS VALUES
    (1, 1, 'Issue with account statement.', 'Resolved'),
    (2, 2, 'Address update failed.', 'Closed'),
    (3, 3, 'Loan details missing.', 'Pending'),
    (4, 4, 'Online banking error.', 'In Progress'),
    (5, 5, 'Unexplained account charges.', 'Resolved'),
    (6, 6, 'Card replacement delay.', 'Pending'),
    (7, 7, 'Account closure process.', 'In Progress'),
    (8, 8, 'Interest rate discrepancy.', 'Resolved'),
    (9, 9, 'Password reset not working.', 'Closed'),
    (10, 10, 'Cheque book request delay.', 'Open');

INSERT INTO SECURITYQUESTIONS VALUES
    (1, 'What is your mother’s maiden name?'),
    (2, 'What was your first pet’s name?'),
    (3, 'What was the name of your first school?'),
    (4, 'What is your favorite book?'),
    (5, 'What was the make of your first car?'),
    (6, 'What city were you born in?'),
    (7, 'What is your father’s middle name?'),
    (8, 'What was your childhood nickname?'),
    (9, 'What is your favorite movie?'),
    (10, 'What is your dream job?');

INSERT INTO CUSTOMERSECURITYANSWERS VALUES
    (1, 1, 1, 'Smith'),
    (2, 2, 2, 'Buddy'),
    (3, 3, 3, 'Greenwood'),
    (4, 4, 4, 'The Alchemist'),
    (5, 5, 5, 'Toyota'),
    (6, 6, 6, 'Boston'),
    (7, 7, 7, 'James'),
    (8, 8, 8, 'Ollie'),
    (9, 9, 9, 'Inception'),
    (10, 10, 10, 'Engineer');

INSERT INTO FRAUD_ALERTS VALUES
    (1, 1, 'Suspicious login attempt.', '2023-11-15 10:00:00'),
    (2, 2, 'Multiple failed login attempts.', '2023-11-16 11:00:00'),
    (3, 3, 'Unusual account activity.', '2023-11-17 12:00:00'),
    (4, 4, 'Transaction flagged as suspicious.', '2023-11-18 13:00:00'),
    (5, 5, 'Unusual location for login.', '2023-11-19 14:00:00'),
    (6, 6, 'Account accessed from unknown device.', '2023-11-20 15:00:00'),
    (7, 7, 'High-value transaction flagged.', '2023-11-21 16:00:00'),
    (8, 8, 'Fraudulent transaction detected.', '2023-11-22 17:00:00'),
    (9, 9, 'Suspicious activity on card.', '2023-11-23 18:00:00'),
    (10, 10, 'Account locked due to fraud alert.', '2023-11-24 19:00:00');

INSERT INTO FRAUD_CASES VALUES
    (1, 1, 'Unauthorized account access detected.', 'Open'),
    (2, 2, 'Suspicious transaction flagged.', 'Closed'),
    (3, 3, 'Phishing attempt reported.', 'In Progress'),
    (4, 4, 'Multiple failed login attempts.', 'Open'),
    (5, 5, 'Unusual withdrawal activity.', 'Resolved'),
    (6, 6, 'Fraudulent check deposit.', 'Pending'),
    (7, 7, 'Unauthorized card usage.', 'In Progress'),
    (8, 8, 'Fake identity detected.', 'Resolved'),
    (9, 9, 'High-value transfer flagged.', 'Closed'),
    (10, 10, 'Unusual account changes.', 'Pending');

INSERT INTO CUSTOMER_FEEDBACK VALUES
    (1, 1, 'Excellent service!', 5),
    (2, 2, 'Friendly staff but slow service.', 4),
    (3, 3, 'Loan application process was tedious.', 3),
    (4, 4, 'Online banking is user-friendly.', 5),
    (5, 5, 'Not satisfied with transaction fees.', 2),
    (6, 6, 'Great support from customer service.', 5),
    (7, 7, 'ATM withdrawal issue unresolved.', 3),
    (8, 8, 'Good experience overall.', 4),
    (9, 9, 'Mobile app needs improvement.', 3),
    (10, 10, 'Quick response to my query.', 5);

INSERT INTO NOTIFICATIONS_PREFERENCES VALUES
    (1, 1, 'Email'),
    (2, 2, 'SMS'),
    (3, 3, 'Push Notification'),
    (4, 4, 'Email'),
    (5, 5, 'SMS'),
    (6, 6, 'Push Notification'),
    (7, 7, 'Email'),
    (8, 8, 'SMS'),
    (9, 9, 'Push Notification'),
    (10, 10, 'Email');

INSERT INTO ATM_LOCATIONS VALUES
    (1, 'Downtown', 1),
    (2, 'Uptown', 2),
    (3, 'City Center', 3),
    (4, 'Suburbs', 4),
    (5, 'Airport', 5),
    (6, 'Train Station', 6),
    (7, 'Shopping Mall', 7),
    (8, 'Hotel Lobby', 8),
    (9, 'Gas Station', 9),
    (10, 'University Campus', 10);

INSERT INTO ATM_TRANSACTIONS VALUES
    (1, 1, 200.00, 'Downtown'),
    (2, 2, 100.00, 'Uptown'),
    (3, 3, 50.00, 'City Center'),
    (4, 4, 300.00, 'Suburbs'),
    (5, 5, 400.00, 'Airport'),
    (6, 6, 150.00, 'Train Station'),
    (7, 7, 80.00, 'Shopping Mall'),
    (8, 8, 90.00, 'Hotel Lobby'),
    (9, 9, 250.00, 'Gas Station'),
    (10, 10, 100.00, 'University Campus');

INSERT INTO CARD VALUES
    (1, 1234567890123456, 'Credit', 1, 1, '2023-01-01', '2026-01-01', 5000.00, 'Active', 123, 1),
    (2, 2345678901234567, 'Debit', 2, 2, '2023-02-01', '2026-02-01', NULL, 'Active', 234, 2),
    (3, 3456789012345678, 'Credit', 3, 3, '2023-03-01', '2026-03-01', 10000.00, 'Inactive', 345, 3),
    (4, 4567890123456789, 'Debit', 4, 4, '2023-04-01', '2026-04-01', NULL, 'Active', 456, 4),
    (5, 5678901234567890, 'Credit', 5, 5, '2023-05-01', '2026-05-01', 7000.00, 'Active', 567, 5),
    (6, 6789012345678901, 'Debit', 6, 6, '2023-06-01', '2026-06-01', NULL, 'Active', 678, 6),
    (7, 7890123456789012, 'Credit', 7, 7, '2023-07-01', '2026-07-01', 3000.00, 'Inactive', 789, 7),
    (8, 8901234567890123, 'Debit', 8, 8, '2023-08-01', '2026-08-01', NULL, 'Active', 890, 8),
    (9, 9012345678901234, 'Credit', 9, 9, '2023-09-01', '2026-09-01', 6000.00, 'Active', 901, 9),
    (10, 1234567890123450, 'Debit', 10, 10, '2023-10-01', '2026-10-01', NULL, 'Active', 123, 10);

INSERT INTO BENEFICIARY VALUES
    (1, 1, 'Alice Johnson', '987654321', '111222333', 'Bank A', 'alice.j@example.com', '111-222-3333', 1),
    (2, 2, 'Bob Smith', '123456789', '222333444', 'Bank B', 'bob.s@example.com', '222-333-4444', 2),
    (3, 3, 'Charlie Brown', '555666777', '333444555', 'Bank C', 'charlie.b@example.com', '333-444-5555', 3),
    (4, 4, 'Daisy White', '444555666', '444555666', 'Bank D', 'daisy.w@example.com', '444-555-6666', 4),
    (5, 5, 'Ethan Green', '666777888', '555666777', 'Bank E', 'ethan.g@example.com', '555-666-7777', 5),
    (6, 6, 'Fiona Blue', '777888999', '666777888', 'Bank F', 'fiona.b@example.com', '666-777-8888', 6),
    (7, 7, 'George Black', '888999000', '777888999', 'Bank G', 'george.b@example.com', '777-888-9999', 7),
    (8, 8, 'Hannah Gold', '999000111', '888999000', 'Bank H', 'hannah.g@example.com', '888-999-0000', 8),
    (9, 9, 'Ian Silver', '000111222', '999000111', 'Bank I', 'ian.s@example.com', '999-000-1111', 9),
    (10, 10, 'Jack Copper', '111222333', '000111222', 'Bank J', 'jack.c@example.com', '000-111-2222', 10);

INSERT INTO AUDITLOGS VALUES
    (1, 'session1', 1, 1, 'Login', '2023-11-01 10:00:00', 'Device1', '192.168.1.1', 1),
    (2, 'session2', 2, 2, 'Transfer', '2023-11-02 11:00:00', 'Device2', '192.168.1.2', 2),
    (3, 'session3', 3, 3, 'Withdrawal', '2023-11-03 12:00:00', 'Device3', '192.168.1.3', 3),
    (4, 'session4', 4, 4, 'Deposit', '2023-11-04 13:00:00', 'Device4', '192.168.1.4', 4),
    (5, 'session5', 5, 5, 'Loan Application', '2023-11-05 14:00:00', 'Device5', '192.168.1.5', 5),
    (6, 'session6', 6, 6, 'Account Update', '2023-11-06 15:00:00', 'Device6', '192.168.1.6', 6),
    (7, 'session7', 7, 7, 'Login', '2023-11-07 16:00:00', 'Device7', '192.168.1.7', 7),
    (8, 'session8', 8, 8, 'Payment', '2023-11-08 17:00:00', 'Device8', '192.168.1.8', 8),
    (9, 'session9', 9, 9, 'Withdrawal', '2023-11-09 18:00:00', 'Device9', '192.168.1.9', 9),
    (10, 'session10', 10, 10, 'Deposit', '2023-11-10 19:00:00', 'Device10', '192.168.1.10', 10);

INSERT INTO SCHEDULEDPAYMENTS VALUES
    (1, 1, 2, 200.00, 'Monthly', '2023-12-01', 'Active', 12, 1),
    (2, 2, 3, 150.00, 'Weekly', '2023-11-30', 'Active', 52, 2),
    (3, 3, 4, 300.00, 'Quarterly', '2023-12-15', 'Pending', 4, 3),
    (4, 4, 5, 500.00, 'Yearly', '2023-12-01', 'Active', 1, 4),
    (5, 5, 6, 250.00, 'Monthly', '2023-12-10', 'Active', 12, 5),
    (6, 6, 7, 400.00, 'Weekly', '2023-12-05', 'Pending', 52, 6),
    (7, 7, 8, 100.00, 'Monthly', '2023-12-08', 'Active', 12, 7),
    (8, 8, 9, 350.00, 'Quarterly', '2023-12-20', 'Active', 4, 8),
    (9, 9, 10, 450.00, 'Yearly', '2024-01-01', 'Active', 1, 9),
    (10, 10, 1, 600.00, 'Monthly', '2023-12-15', 'Active', 12, 10);

INSERT INTO STANDINGORDER VALUES
    (1, 1, 1, 'Alice Johnson', '987654321', '111222333', 500.00, 'Monthly', '2023-11-01', '2024-11-01', 'Active', 1),
    (2, 2, 2, 'Bob Smith', '123456789', '222333444', 300.00, 'Weekly', '2023-11-15', '2024-11-15', 'Active', 2),
    (3, 3, 3, 'Charlie Brown', '555666777', '333444555', 250.00, 'Quarterly', '2023-12-01','2024-12-01', 'Pending', 3),
    (4, 4, 4, 'Daisy White', '444555666', '444555666', 400.00, 'Monthly', '2023-12-01', '2024-12-01', 'Active', 4),
    (5, 5, 5, 'Ethan Green', '666777888', '555666777', 350.00, 'Yearly', '2023-12-10', '2024-12-10', 'Active', 5),
    (6, 6, 6, 'Fiona Blue', '777888999', '666777888', 150.00, 'Monthly', '2023-12-15', '2024-12-15', 'Pending', 6),
    (7, 7, 7, 'George Black', '888999000', '777888999', 450.00, 'Weekly', '2023-12-20', '2024-12-20', 'Active', 7),
    (8, 8, 8, 'Hannah Gold', '999000111', '888999000', 300.00, 'Quarterly', '2023-12-01', '2024-12-01', 'Active', 8),
    (9, 9, 9, 'Ian Silver', '000111222', '999000111', 500.00, 'Yearly', '2023-12-01', '2024-12-01', 'Pending', 9),
    (10, 10, 10, 'Jack Copper', '111222333', '000111222', 600.00, 'Monthly', '2023-12-15','2024-12-15', 'Active', 10);


CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS EMPLOYEE CASCADE;

CREATE TABLE EMPLOYEE (
    EmployeeID INT NOT NULL,
    role_id INT NOT NULL,
    Position VARCHAR(255),
    Person_PersonID INT NOT NULL,
    Branch_BranchID INT NOT NULL,
    PRIMARY KEY (EmployeeID, Branch_BranchID),
    FOREIGN KEY (role_id) REFERENCES USER_ROLES(role_id),
    FOREIGN KEY (Person_PersonID) REFERENCES PERSON(PersonID),
    FOREIGN KEY (Branch_BranchID) REFERENCES BRANCH(BranchID)
) PARTITION BY LIST (Branch_BranchID);

DO $$
BEGIN
    FOR branch_id IN 1..10 LOOP
        EXECUTE format(
            'CREATE TABLE EMPLOYEE_BRANCH_%s PARTITION OF EMPLOYEE FOR VALUES IN (%s);', branch_id, branch_id
        );
    END LOOP;
END $$;

INSERT INTO EMPLOYEE VALUES
    (1, 1, 'Branch Manager', 1, 1),
    (2, 2, 'Teller', 2, 2),
    (3, 3, 'Loan Officer', 3, 3),
    (4, 4, 'Customer Support', 4, 4),
    (5, 5, 'Auditor', 5, 5),
    (6, 6, 'Compliance Officer', 6, 6),
    (7, 7, 'IT Specialist', 7, 7),
    (8, 8, 'Marketing Executive', 8, 8),
    (9, 9, 'Branch Manager', 9, 9),
    (10, 10, 'Teller', 10, 10);

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS NOTIFICATIONS CASCADE;

CREATE TABLE NOTIFICATIONS (
    NotificationID INT NOT NULL,
    CustomerID INT NOT NULL,
    Message VARCHAR(255),
    NotificationType VARCHAR(255) NOT NULL,
    Status VARCHAR(255),
    StartDate DATE,
    EndDate DATE,
    PRIMARY KEY (NotificationID, NotificationType)
) PARTITION BY LIST (NotificationType);

DO $$
DECLARE
    notification_type TEXT;
BEGIN
    FOR notification_type IN
    SELECT UNNEST(ARRAY['Welcome', 'Statement', 'Loan Update', 'Promotion'])
    LOOP
        EXECUTE format(
            'CREATE TABLE NOTIFICATIONS_%s PARTITION OF NOTIFICATIONS FOR VALUES IN (''%s'');', LOWER(replace(notification_type, ' ', '_')), notification_type
        );
    END LOOP;
END $$;

INSERT INTO NOTIFICATIONS VALUES
    (1, 1001, 'Welcome to our service!', 'Welcome', 'Sent', '2024-01-01', '2024-01-02'),
    (2, 1002, 'Your statement is ready.', 'Statement', 'Sent', '2024-02-01', '2024-02-02'),
    (3, 1003, 'Your loan application status.', 'Loan Update', 'Pending', '2024-03-01', '2024-03-15'),
    (4, 1004, 'Exclusive promotion just for you!', 'Promotion', 'Sent', '2024-04-01', '2024-04-30'),
    (5, 1005, 'Welcome aboard!', 'Welcome', 'Sent', '2024-01-05', '2024-01-06'),
    (6, 1006, 'Monthly statement available.', 'Statement', 'Read', '2024-02-10', '2024-02-11'),
    (7, 1007, 'Loan repayment schedule update.', 'Loan Update', 'Completed', '2024-03-20', '2024-03-25'),
    (8, 1008, 'Special discount for our loyal customers!', 'Promotion', 'Sent', '2024-04-10', '2024-04-20'),
    (9, 1009, 'Welcome! We’re glad to have you.', 'Welcome', 'Sent', '2024-01-15', '2024-01-16'),
    (10, 1010, 'Your annual statement is ready.', 'Statement', 'Pending', '2024-02-15', '2024-02-16');

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS FRAUD_ALERTS CASCADE;

CREATE TABLE FRAUD_ALERTS (
    AlertID INT NOT NULL,
    CustomerID INT NOT NULL,
    Description VARCHAR(255),
    Timestamp TIMESTAMP NOT NULL,
    PRIMARY KEY (AlertID, Timestamp)
) PARTITION BY RANGE (Timestamp);

DO $$
BEGIN
    FOR year IN 2023..2024 
    LOOP
        EXECUTE format(
            'CREATE TABLE FRAUD_ALERTS_%s PARTITION OF FRAUD_ALERTS FOR VALUES FROM (''%s-01-01 00:00:00'') TO (''%s-12-31 23:59:59'');', year, year, year
        );
    END LOOP;
END $$;

INSERT INTO FRAUD_ALERTS VALUES
    (1, 2001, 'Suspicious login detected', '2023-01-15 08:30:00'),
    (2, 2002, 'Multiple failed login attempts', '2023-03-10 14:45:00'),
    (3, 2003, 'Unusual transaction detected', '2023-06-20 12:00:00'),
    (4, 2004, 'Suspicious IP address login', '2023-09-05 19:20:00'),
    (5, 2005, 'Large withdrawal alert', '2023-12-11 22:15:00'),
    (6, 2006, 'Suspicious login detected', '2024-02-17 10:00:00'),
    (7, 2007, 'Unusual transaction detected', '2024-04-25 16:30:00'),
    (8, 2008, 'Multiple failed login attempts', '2024-07-01 09:15:00'),
    (9, 2009, 'Large withdrawal alert', '2024-10-08 23:45:00'),
    (10, 2010, 'Suspicious IP address login', '2024-12-20 05:30:00');

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS LOAN_PAYMENT CASCADE;

CREATE TABLE LOAN_PAYMENT (
    LoanPaymentID INT NOT NULL,
    ScheduledPaymentDate DATE NOT NULL,
    PaymentAmount DECIMAL(18, 2),
    PrincipalAmount DECIMAL(18, 2),
    InterestAmount DECIMAL(18, 2),
    PaidAmount DECIMAL(18, 2),
    PaidDate DATE,
    Loan_LoanID INT NOT NULL,
    PRIMARY KEY (LoanPaymentID, Loan_LoanID) 
) PARTITION BY LIST (Loan_LoanID);

DO $$
BEGIN
    FOR loan_id IN 1..10 LOOP
    EXECUTE format(
        'CREATE TABLE LOAN_PAYMENT_LOAN_%s PARTITION OF LOAN_PAYMENT FOR VALUES IN (%s);', loan_id, loan_id
    );
    END LOOP;
END $$;

INSERT INTO LOAN_PAYMENT VALUES
    (1, '2024-01-15', 500.00, 300.00, 200.00, 500.00, '2024-01-15', 1),
    (2, '2024-02-15', 600.00, 400.00, 200.00, 600.00, '2024-02-15', 2),
    (3, '2024-03-15', 700.00, 500.00, 200.00, 700.00, '2024-03-15', 3),
    (4, '2024-04-15', 800.00, 600.00, 200.00, 800.00, '2024-04-15', 4),
    (5, '2024-05-15', 900.00, 700.00, 200.00, 900.00, '2024-05-15', 5),
    (6, '2024-06-15', 550.00, 350.00, 200.00, 550.00, '2024-06-15', 1),
    (7, '2024-07-15', 650.00, 450.00, 200.00, 650.00, '2024-07-15', 2),
    (8, '2024-08-15', 750.00, 550.00, 200.00, 750.00, '2024-08-15', 3),
    (9, '2024-09-15', 850.00, 650.00, 200.00, 850.00, '2024-09-15', 4),
    (10, '2024-10-15', 950.00, 750.00, 200.00, 950.00, '2024-10-15', 5);

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS CARD CASCADE;

CREATE TABLE CARD (
    CardID INT NOT NULL,
    CardNumber BIGINT NOT NULL,
    CardType VARCHAR(255) NOT NULL,
    CustomerID INT NOT NULL,
    AccountID INT NOT NULL,
    IssueDate DATE,
    ExpiryDate DATE,
    CreditLimit DECIMAL(18, 2),
    CardStatus VARCHAR(255),
    CVV INT,
    Account_AccountID INT NOT NULL,
    PRIMARY KEY (CardID, CardType)
) PARTITION BY LIST (CardType);

DO $$
DECLARE
    card_type TEXT;
BEGIN
    FOR card_type IN
        SELECT UNNEST(ARRAY['Credit', 'Debit'])
    LOOP
        EXECUTE format(
            'CREATE TABLE CARD_%s PARTITION OF CARD FOR VALUES IN (''%s'');', LOWER(card_type), card_type
        );
    END LOOP;
END $$;

INSERT INTO CARD VALUES
    (1, 1234567812345678, 'Credit', 1001, 2001, '2022-01-01', '2027-01-01', 5000.00, 'Active', 123, 2001),
    (2, 1234567812345679, 'Debit', 1002, 2002, '2023-02-01', '2028-02-01', NULL, 'Active', 234, 2002),
    (3, 1234567812345680, 'Credit', 1003, 2003, '2021-03-01', '2026-03-01', 10000.00, 'Blocked', 345, 2003),
    (4, 1234567812345681, 'Debit', 1004, 2004, '2020-04-01', '2025-04-01', NULL, 'Inactive', 456, 2004),
    (5, 1234567812345682, 'Credit', 1005, 2005, '2024-05-01', '2029-05-01', 7500.00, 'Active', 567, 2005),
    (6, 1234567812345683, 'Debit', 1006, 2006, '2022-06-01', '2027-06-01', NULL, 'Active', 678, 2006),
    (7, 1234567812345684, 'Credit', 1007, 2007, '2023-07-01', '2028-07-01', 3000.00, 'Active', 789, 2007),
    (8, 1234567812345685, 'Debit', 1008, 2008, '2021-08-01', '2026-08-01', NULL, 'Blocked', 890, 2008),
    (9, 1234567812345686, 'Credit', 1009, 2009, '2020-09-01', '2025-09-01', 12000.00, 'Inactive', 901, 2009),
    (10, 1234567812345687, 'Debit', 1010, 2010, '2024-10-01', '2029-10-01', NULL, 'Active', 112, 2010);

CREATE INDEX idx_account_number ON account(accountid); 
CREATE INDEX idx_account_type ON account(accounttype); 
CREATE INDEX idx_person_email ON person(email); 
CREATE INDEX idx_person_phone ON person(phonenumber ); 
CREATE INDEX idx_transaction_account_id ON transaction(Account_AccountID); 
CREATE INDEX idx_transaction_type ON transaction(TransactionType); 
CREATE INDEX idx_transaction_date ON transaction(TransactionDate); 
CREATE INDEX idx_loan_application_person_id ON loanapplications(PersonID); 
CREATE INDEX idx_loan_application_status ON loanapplications(status); 
CREATE INDEX idx_loan_customer_id ON loan(Customer_CustomerID); 
CREATE INDEX idx_loan_type ON loan(LoanType); 
CREATE INDEX idx_loan_status ON loan(status);

GRANT SELECT ON public.userlogin TO replication_user;
GRANT SELECT ON public.person TO replication_user;
GRANT SELECT ON public.onboardingapplication TO replication_user;
GRANT SELECT ON public.branch TO replication_user;
GRANT SELECT ON public.user_roles TO replication_user;
GRANT SELECT ON public.employee TO replication_user;
GRANT SELECT ON public.customer TO replication_user;
GRANT SELECT ON public.account TO replication_user;
GRANT SELECT ON public.customer_account TO replication_user;
GRANT SELECT ON public.transaction TO replication_user;
GRANT SELECT ON public.transaction_logs TO replication_user;
GRANT SELECT ON public.payment_gateway_logs TO replication_user;
GRANT SELECT ON public.loanapplications TO replication_user;
GRANT SELECT ON public.loan TO replication_user;
GRANT SELECT ON public.loan_payment TO replication_user;
GRANT SELECT ON public.kyc TO replication_user;
GRANT SELECT ON public.notifications TO replication_user;
GRANT SELECT ON public.service_requests TO replication_user;
GRANT SELECT ON public.support_tickets TO replication_user;
GRANT SELECT ON public.securityquestions TO replication_user;
GRANT SELECT ON public.customersecurityanswers TO replication_user;
GRANT SELECT ON public.fraud_alerts TO replication_user;
GRANT SELECT ON public.fraud_cases TO replication_user;
GRANT SELECT ON public.customer_feedback TO replication_user;
GRANT SELECT ON public.notifications_preferences TO replication_user;
GRANT SELECT ON public.atm_locations TO replication_user;
GRANT SELECT ON public.atm_transactions TO replication_user;
GRANT SELECT ON public.card TO replication_user;
GRANT SELECT ON public.beneficiary TO replication_user;
GRANT SELECT ON public.auditlogs TO replication_user;
GRANT SELECT ON public.scheduledpayments TO replication_user;
GRANT SELECT ON public.standingorder TO replication_user;

GRANT USAGE ON SCHEMA public TO replication_user;


CREATE PUBLICATION my_bank_pub FOR TABLE userlogin, person, onboardingapplication, branch, user_roles, employee, customer, account, customer_account, transaction, transaction_logs, payment_gateway_logs, loanapplications, loan, loan_payment, kyc, notifications, service_requests, support_tickets, securityquestions, customersecurityanswers, fraud_alerts, fraud_cases, customer_feedback, notifications_preferences, atm_locations, atm_transactions, card, beneficiary, auditlogs, scheduledpayments, standingorder;