function viewLoanDetails(loanType) {
    const loanDetailsUrl = `/get_loan_payments/${loanType}`;

    fetch(loanDetailsUrl)
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                alert(data.error); // Show error if any
            } else {
                const loanPayments = data.loan_payments;

                // Update loan details
                document.getElementById('detail-loan-type').textContent = `${loanType.charAt(0).toUpperCase() + loanType.slice(1)} Loan`;
                document.getElementById('detail-loan-amount').textContent = `Loan Amount Paid: $${loanPayments.reduce((sum, payment) => sum + parseFloat(payment.payment_amount.slice(1)), 0).toFixed(2)}`;

                // Clear existing list and add new installments
                const installmentList = document.getElementById('installment-list');
                installmentList.innerHTML = '';
                loanPayments.forEach(payment => {
                    const li = document.createElement('li');
                    li.innerHTML = `
                        <span class="label">Scheduled Date:</span> <span class="value">${payment.scheduled_date}</span>
                        <br>
                        <span class="label">Payment Amount:</span> <span class="value">${payment.payment_amount}</span>
                        <br>
                        <span class="label">Paid Amount:</span> <span class="value">${payment.paid_amount}</span>
                        <br>
                        <span class="label">Principal Amount:</span> <span class="value">${payment.principal_amount}</span>
                        <br>
                        <span class="label">Interest Amount:</span> <span class="value">${payment.interest_amount}</span>
                        <br>
                        <span class="label">Paid Date:</span> <span class="value">${payment.paid_date || 'Not Paid Yet'}</span>
                        <br>
                    `;
                    installmentList.appendChild(li);
                });

                // Display the loan details section
                document.getElementById('loan-details').style.display = 'block';
            }
        })
        .catch(error => {
            alert("An error occurred while fetching loan details.");
            console.error(error);
        });
}
