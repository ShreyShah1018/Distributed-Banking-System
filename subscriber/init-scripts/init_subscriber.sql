\c banking_subscriber_db

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
    FOR year IN 2023..2024 LOOP
        EXECUTE format(
            'CREATE TABLE FRAUD_ALERTS_%s PARTITION OF FRAUD_ALERTS FOR VALUES FROM (''%s-01-01 00:00:00'') TO (''%s-12-31 23:59:59'');', year, year, year
        );
    END LOOP;
END $$;

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

CREATE SUBSCRIPTION my_bank_sub
    CONNECTION 'host=postgres-publisher port=5432 dbname=banking_db user=replication_user password=replication'
    PUBLICATION my_bank_pub;
