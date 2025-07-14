from datetime import date

from flask import render_template, request, redirect, url_for, flash, session, jsonify
import psycopg2

import joblib

# Load your trained model
model = joblib.load('loan_default_model.pkl')


def create_routes(app):
    conn = psycopg2.connect(host='localhost', dbname='banking_db', user='postgres', password='postgres', port='5432')
    cursor = conn.cursor()

    @app.route('/', methods=['GET', 'POST'])
    @app.route('/login', methods=['GET', 'POST'])
    def login():
        if request.method == 'POST':
            username = request.form['username']
            password = request.form['password']

            try:
                # Dynamically using the form data for authentication
                query = "SELECT * FROM USERLOGIN WHERE username = %s AND password = %s"
                cursor.execute(query, (username, password))  # Using parameterized query to avoid SQL injection

                result = cursor.fetchone()  # Fetch one row since we are expecting a single match

                # Check if result exists
                if result:
                    session['logged_in'] = True  # Set session variable to track the login state
                    session['username'] = username
                    flash('You have logged in successfully!', 'success')  # Flash success message
                    return redirect(url_for('home'))  # Redirect to the 'home' route after successful login
                else:
                    flash('Invalid username or password. Please try again.', 'danger')  # Flash error message

            except Exception as e:
                flash(f"An error occurred while trying to log in: {e}", 'danger')  # Flash error message

        return render_template('login.html')  # Render the login page if it's a GET request

    @app.route('/home')
    def home():
        if 'logged_in' in session:  # Check if the user is logged in
            return render_template('home.html', username=session['username'])  # Show home page
        else:
            flash('You need to log in first.', 'warning')  # Flash a warning message
            return redirect(url_for('login'))

    @app.route('/dashboard')
    def dashboard():
        return render_template('dashboard.html')
    

    @app.route('/accounts', methods=['GET'])
    def accounts():
        if 'logged_in' not in session:
            flash('You need to log in first.', 'warning')
            return redirect(url_for('login'))

        username = session['username']

        try:
            # Prepare SQL query
            query = """
            SELECT 
            A.AccountID,
            A.AccountType,
            A.AccountNumber,
            A.CurrentBalance,
            A.DateOpened,
            A.DateClosed,
            A.AccountStatus,
            C.CustomerID,
            C.Username
        FROM 
            USERLOGIN C
        JOIN 
            CUSTOMER_ACCOUNT CA ON C.CustomerID = CA.Customer_CustomerID
        JOIN 
            ACCOUNT A ON CA.Account_AccountID = A.AccountID
        WHERE 
            C.Username = %s;
            """

            # Execute the query
            cursor.execute(query, (username,))
            accounts_data = cursor.fetchall()
            print(accounts_data)
            # Create a structure to hold account details
            account_details = {}
            for account in accounts_data:
                account_id, account_type, account_number, balance, date_opened, date_closed, account_status, customer_id, username = account
                account_details[account_type] = {
                    'account_id': account_id,
                    'account_number': account_number,
                    'balance': balance,
                    'date_opened': date_opened,
                    'date_closed': date_closed,
                    'account_status': account_status
                }

            return render_template('accounts.html', accounts=account_details)

        except Exception as e:
            print(e)
            flash(f"An error occurred while fetching account details: {e}", 'danger')
            return redirect(url_for('login'))

    @app.route('/loans', methods=['GET'])
    def loans():
        if 'logged_in' not in session:
            flash('You need to log in first.', 'warning')
            return redirect(url_for('login'))

        username = session['username']

        try:
            # Prepare the SQL query to fetch loan applications for the logged-in user
            query = """
            SELECT 
                LA.ApplicationID,
                LA.LoanType,
                LA.RequestedAmount,
                LA.Status,
                LA.ApplicationDate,
                L.LoanID,
                L.LoanAmount,
                L.InterestRate,
                L.Term,
                L.StartDate,
                L.EndDate,
                L.Status AS LoanStatus
            FROM 
                USERLOGIN UL
            JOIN 
                CUSTOMER C ON UL.CustomerID = C.CustomerID
            JOIN 
                LOANAPPLICATIONS LA ON C.Person_PersonID = LA.PersonID
            LEFT JOIN 
                LOAN L ON LA.ApplicationID = L.LoanApplications_ApplicationID
            WHERE 
                UL.Username = %s;
            """

            # Execute the query
            cursor.execute(query, (username,))
            loan_data = cursor.fetchall()

            # Create a structured dictionary for loan details
            loans_details = []
            for loan in loan_data:
                application_id, loan_type, requested_amount, application_status, application_date, loan_id, loan_amount, interest_rate, term, start_date, end_date, loan_status = loan

                loans_details.append({
                    'application_id': application_id,
                    'loan_type': loan_type,
                    'requested_amount': f"${requested_amount:,.2f}",
                    'application_status': application_status,
                    'application_date': application_date.strftime("%Y-%m-%d"),
                    'loan_id': loan_id if loan_id else None,
                    'loan_amount': f"${loan_amount:,.2f}" if loan_amount else None,
                    'interest_rate': f"{interest_rate}%" if interest_rate else None,
                    'term': f"{term} years" if term else None,
                    'start_date': start_date.strftime("%Y-%m-%d") if start_date else None,
                    'end_date': end_date.strftime("%Y-%m-%d") if end_date else None,
                    'loan_status': loan_status if loan_status else "N/A"
                })

            # Render the loan details on the loans.html template
            return render_template('loans.html', loans=loans_details)

        except Exception as e:
            print(e)
            flash(f"An error occurred while fetching loan details: {e}", 'danger')
            return redirect(url_for('dashboard'))
    
    import numpy as np

    @app.route('/loan_predict', methods=['GET', 'POST'])
    def loan_predict():
        if request.method == 'POST':
            try:
                requestedamount = float(request.form['requestedamount'])
                loanamount = float(request.form['loanamount'])
                interestrate = float(request.form['interestrate'])
                term = int(request.form['term'])
                loantype = request.form['loantype']

                loan_type_map = {
                    'Home Loan': 0,
                    'Car Loan': 1,
                    'Personal Loan': 2,
                    'Business Loan': 3,
                    'Education Loan': 4
                }
                loantype_encoded = loan_type_map.get(loantype, 0)

                # Additional engineered features
                log_requestedamount = np.log1p(requestedamount)
                log_loanamount = np.log1p(loanamount)
                loan_to_request_ratio = loanamount / requestedamount if requestedamount else 0
                is_high_interest = 1 if interestrate > 6 else 0

                X_input = [[
                    log_requestedamount,
                    log_loanamount,
                    interestrate,
                    term,
                    loantype_encoded,
                    loan_to_request_ratio,
                    is_high_interest
                ]]

                prediction = model.predict(X_input)[0]
                result = 'High Risk' if prediction == 1 else 'Low Risk'

                return render_template('result.html', result=result)

            except Exception as e:
                return f"Error: {str(e)}"

        return render_template('loan_predict.html')



    @app.route('/get_transactions/<int:account_id>', methods=['GET'])
    def get_transactions(account_id):
        try:
            # Query to fetch transactions for the given account
            query = """
            SELECT 
                t.TransactionDate AS date, 
                t.TransactionType AS description, 
                t.Amount AS amount
            FROM 
                TRANSACTION t
            JOIN 
                ACCOUNT a ON a.AccountID = t.Account_AccountID
            WHERE 
                a.AccountID = %s;
            """

            # Execute the query
            cursor.execute(query, (account_id,))
            transactions = cursor.fetchall()

            # Prepare the response
            transaction_data = [{'date': transaction[0], 'description': transaction[1], 'amount': transaction[2]} for
                                transaction in transactions]

            # Return transaction data as JSON
            return jsonify({'transactions': transaction_data})

        except Exception as e:
            return jsonify({'error': str(e)}), 500

    @app.route('/get_loan_payments/<int:loan_id>', methods=['GET'])
    def get_loan_payments(loan_id):
        print("fecting data now")
        try:
            # Query to fetch loan payments for the given loan
            query = """
            SELECT 
                lp.ScheduledPaymentDate AS scheduled_date, 
                lp.PaidDate AS paid_date, 
                lp.PaymentAmount AS payment_amount, 
                lp.PrincipalAmount AS principal_amount, 
                lp.InterestAmount AS interest_amount, 
                lp.PaidAmount AS paid_amount
            FROM 
                LOAN_PAYMENT lp
            JOIN 
                LOAN l ON l.LoanID = lp.Loan_LoanID
            WHERE 
                l.LoanID = %s;
            """

            # Execute the query
            cursor.execute(query, (loan_id,))
            loan_payments = cursor.fetchall()

            # Prepare the response
            payment_data = [
                {
                    'scheduled_date': payment[0].strftime("%Y-%m-%d") if payment[0] else None,
                    'paid_date': payment[1].strftime("%Y-%m-%d") if payment[1] else None,
                    'payment_amount': f"${payment[2]:,.2f}" if payment[2] else None,
                    'principal_amount': f"${payment[3]:,.2f}" if payment[3] else None,
                    'interest_amount': f"${payment[4]:,.2f}" if payment[4] else None,
                    'paid_amount': f"${payment[5]:,.2f}" if payment[5] else None,
                }
                for payment in loan_payments
            ]

            # Return loan payment data as JSON
            return jsonify({'loan_payments': payment_data})

        except Exception as e:
            return jsonify({'error': str(e)}), 500


    @app.route('/loan_application', methods=['GET', 'POST'])
    def loan_application():
        if request.method == 'GET':
            return render_template('loan_application.html')

        data = request.json
        loan_amount = float(data.get('loan_amount'))
        loan_purpose = data.get('loan_purpose')
        loan_term = int(data.get('loan_term'))

        if 'username' not in session:
            return jsonify({"success": False, "message": "You must be logged in to apply for a loan."})

        username = session['username']

        if not (loan_amount and loan_purpose and loan_term):
            return jsonify({"success": False, "message": "All fields are required."})

        try:
            # Get PersonID
            cursor.execute("""
                SELECT P.PersonID 
                FROM USERLOGIN UL
                JOIN PERSON P ON UL.Customer_CustomerID = P.PersonID
                WHERE UL.Username = %s
            """, (username,))
            person = cursor.fetchone()
            if not person:
                return jsonify({"success": False, "message": "User not found."})
            person_id = person[0]

        # Predict Loan Risk
            log_requestedamount = np.log1p(loan_amount)
            log_loanamount = np.log1p(loan_amount)  # same as request for new loans
            interestrate = 6.5  # Static value unless collected from form
            term = loan_term
            loan_type_map = {
                'Home Loan': 0,
                'Car Loan': 1,
                'Personal Loan': 2,
                'Business Loan': 3,
                'Education Loan': 4
            }
            loantype_encoded = loan_type_map.get(loan_purpose, 0)
            loan_to_request_ratio = 1
            is_high_interest = 1 if interestrate > 6 else 0

            X_input = [[
                log_requestedamount,
                log_loanamount,
                interestrate,
                term,
                loantype_encoded,
                loan_to_request_ratio,
                is_high_interest
            ]]

            prediction = model.predict(X_input)[0]
            risk_level = 'High Risk' if prediction == 1 else 'Low Risk'

            # Generate ApplicationID
            cursor.execute("SELECT COALESCE(MAX(ApplicationID), 0) + 1 FROM LOANAPPLICATIONS")
            new_application_id = cursor.fetchone()[0]

        # Insert into LOANAPPLICATIONS
            cursor.execute("""
                INSERT INTO LOANAPPLICATIONS (ApplicationID, PersonID, LoanType, RequestedAmount, Status, ApplicationDate)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (new_application_id, person_id, loan_purpose, loan_amount, "Pending", date.today()))
            conn.commit()

            return jsonify({
                "success": True,
                "message": "Loan application created successfully.",
                "risk_prediction": risk_level
            })

        except Exception as e:
            return jsonify({"success": False, "message": f"Database error: {e}"})


    @app.route('/logout')
    def logout():
        session.clear()
        return redirect(url_for('login'))
