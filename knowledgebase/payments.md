
## NearMe payments
  * Various payments accounts: [link](https://near-me.atlassian.net/wiki/pages/viewpage.action?spaceKey=ENGINEERING&title=Test+Payments)
  * Flow explained: [link](https://docs.google.com/document/d/1vvRU46FMPVebDxzONeXUfMHWEtXgi5SBQ6_ZCkUxwT4/pub)
---
### Payment providers list
#### [Stripe](https://www.stripe.com/)
- Integrated services:
  - Incoming payments with: ACH and CreditCard
  - Merchant Account management (managed accounts)
  - Webhooks
  - Payouts: "Stripe Connect"
- Service to implement:
  - BitCoin
  - Standalone Merchant Accounts
  - Separate charges/transfers for US: [link](https://stripe.com/docs/connect/charges-transfers)

#### [Braintree](https://www.braintreepayments.com/)

- Integrated services:
  - Incoming payments with: CreditCard and PayPal
  - Merchant Account management (Braintree Marketplace)
  - Webhooks
  - Payouts

#### PayPal
- Integrated services
  - PayPal payments PRO - only in US Credit Card payment
  - PayPal Adaptive Payemtns - recurring payouts
  - PayPal Express
  - PayPal Express in Chain Payments
  - Integrated PayPal Signup - MerchantAccount management
- Future implementation
  - Merchant Boarding for Adaptive Payments using Integrated PayPal signup (in progress)
  - Webhooks

#### Integration Candidates
  1. [MangoPay](https://www.mangopay.com/)

---
### Payments with **Paid Link**

  1. Go to listing page: https://staging.near-me.com/locations/qa-san-francisco-ca-usa-14090/qa-25295 and "Book"
  2. Pay and choose **Bank of America**
    * username:  plaid_test
    * password:  plaid_good
    * "You say tomato, I say ?": tomato
