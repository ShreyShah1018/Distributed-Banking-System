document.getElementById('loan-form').addEventListener('submit', function(e) {
    e.preventDefault();

    const loanAmount = document.getElementById('loan-amount').value;
    const loanPurpose = document.getElementById('loan-purpose').value;
    const loanTermYears = document.getElementById('loan-term').value;
    const loanTermMonths = parseInt(loanTermYears) * 12; // Convert years to months

    fetch('/loan_application', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            loan_amount: loanAmount,
            loan_purpose: loanPurpose,
            loan_term: loanTermMonths
        })
    })
    .then(response => response.json())
    .then(data => {
        const messageBox = document.getElementById('response-message');
        if (data.success) {
            messageBox.innerHTML = `
                <p><strong>${data.message}</strong></p>
                <p>Predicted Risk: <strong>${data.risk_prediction}</strong></p>
            `;
            messageBox.style.color = 'green';
        } else {
            messageBox.textContent = data.message;
            messageBox.style.color = 'red';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        document.getElementById('response-message').textContent = 'An error occurred.';
    });
});
