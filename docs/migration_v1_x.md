# Migration from v1.x

Version 2.x includes support for multicurrency payments and refunds. This feature has been introduced in the Mollie V2 API. Please refer to [Migrating from v1 to v2](https://docs.mollie.com/migrating-v1-to-v2) for a general overview of the switch to Mollie v2 API.

## Retrieving payment methods using Spree API

It's recommended to pass a `amount[currency]` and `amount[value]` URL params when fetching the available methods. This call will only return the available payment methods that are available for this currency and amount. 

```bash
curl "example.com/api/v1/mollie/methods?amount%5Bcurrency%5D=EUR&amount%5Bvalue%5D=10.00"
```