function viewDetails(accountType) {
    // Get account details from the clicked element
    const accountItem = document.querySelector(`.account-item[data-account-type='${accountType}']`);
    const accountId = accountItem.getAttribute('data-account-id');
    const balance = accountItem.getAttribute('data-balance');

    // Update account information in the "account details" section
    document.getElementById('detail-account-type').textContent = accountType.charAt(0).toUpperCase() + accountType.slice(1) + " Account";
    document.getElementById('detail-balance').textContent = "Current Balance: $" + balance;

    // Simulate an AJAX call to get the transaction details for the selected account
    fetch(`/get_transactions/${accountId}`)
        .then(response => response.json())
        .then(data => {
            const transactionList = document.getElementById('transaction-list');
            transactionList.innerHTML = ''; // Clear the previous transactions

            // Loop through the transaction data and display it
            data.transactions.forEach(transaction => {
                const li = document.createElement('li');
                li.textContent = `${transaction.date}   ${transaction.description} : ${transaction.amount}`;
                transactionList.appendChild(li);
            });

            // Show the account details section
            document.getElementById('account-details').style.display = 'block';
        })
        .catch(error => {
            console.error('Error fetching transaction details:', error);
        });
}
