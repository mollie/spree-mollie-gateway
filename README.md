[<img src="https://www.mollie.com/assets/images/mollie/logo-black.svg" width="110">](https://www.mollie.com/)

[![Build Status](https://travis-ci.org/mollie/spree-mollie-gateway.svg?branch=master)](https://travis-ci.org/mollie/spree-mollie-gateway) [![Gem Version](https://badge.fury.io/rb/spree_mollie_gateway.svg)](https://badge.fury.io/rb/spree_mollie_gateway) 
  
This is the official Mollie payment gateway for Spree Commerce. Implement this to easily accept all major payment methods, including iDEAL, Bancontact, Visa, Mastercard, AmEx, and many more, in your Spree Commerce storefront.
 
This gateway supports all aspect of Spree Commerce and payments can be created through both `spree_frontend` and `spree_api`.

Please go to the [signup page](https://www.mollie.com/signup) to create a new Mollie account and start receiving payments in a couple of minutes.

> Our pricing is always per transaction. No startup fees, no monthly fees, and no gateway fees. No hidden fees, period.

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Configuring Mollie Gateway](#configuring-mollie-gateway)
5. [API endpoints](#api-endpoints)
6. [Upgrading](#upgrading)
6. [API documentation](#api-documentation)
6. [Want to help us make our API client even better?](#want-to-help-us-make-our-api-client-even-better)
6. [License](#license)
7. [Support](#support)

## Features

* Support for all available Mollie payment methods.
* Multicurrency payments
* Support for [one-click payments](https://www.mollie.com/en/features/checkout).
* Fast in-house support. You will always be helped by someone who knows our products intimately.
* Multiple translations: English and Dutch.
* Refund orders from the Spree admin.
* Event log for <a href="docs/debugging.md">debugging purposes</a>.
* Available for `spree_api` and `spree_frontend`.
* Allow returning customers to <a href="https://www.mollie.com/en/features/checkout" title="One-click payments">use their previous payment details</a> and pay instantly.

## Requirements
- Spree 3.1.0 or newer.  

## Installation

1. Add the extension to your Gemfile using:

```ruby
gem 'spree_mollie_gateway'
```

2. Install the gem by running `bundle install`.

3. Run the installer which takes care of copying migrations:

```bash
bundle exec rails g spree_mollie_gateway:install
```

## Configuring Mollie Gateway

<img src="https://info.mollie.com/hubfs/configuration.jpg" alt="Add new Payment Method." />

1. Configure a new payment method (`Spree Admin -> Configurations -> Payment Methods -> New Payment Method`).
2. Select `Spree::Gateway::MollieGateway` as a `Provider`.
3. Fill in your live / test `API key`.
4. Fill in your hostname. Used for generating the webhook URL and redirect URL.
5. Select "Front End" in the `Display` selectbox.
7. Save and you're done!

## API endpoints
This gateway comes with a couple of API endpoints which seamlessly integrate with the [Spree API](https://guides.spreecommerce.org/api/).

- <a href="docs/api">Overview of available API endpoints.</a>

## Upgrading

- <a href="docs/migration_v1_x.md">Migration from v1.x</a> 

## API documentation

If you wish to learn more about our API, please visit the [Mollie API Documentation](https://docs.mollie.com).

## Want to help us make our API client even better?

Want to help us make our API client even better? We take [pull requests](https://github.com/mollie/mollie-api-ruby/pulls?utf8=%E2%9C%93&q=is%3Apr), sure. But how would you like to contribute to a technology oriented organization? Mollie is hiring developers and system engineers. [Check out our vacancies](https://jobs.mollie.com/) or [get in touch](mailto:recruitment@mollie.com).

## License
[BSD (Berkeley Software Distribution) License](https://opensource.org/licenses/bsd-license.php). Copyright (c) 2014-2018, Mollie B.V.

## Support
Contact: [www.mollie.com](https://www.mollie.com) — info@mollie.com — +31 20-612 88 55

+ [More information about iDEAL via Mollie](https://www.mollie.com/en/payments/ideal/)
+ [More information about Credit card via Mollie](https://www.mollie.com/en/payments/credit-card/)
+ [More information about Bancontact via Mollie](https://www.mollie.com/en/payments/bancontact/)
+ [More information about SOFORT Banking via Mollie](https://www.mollie.com/en/payments/sofort/)
+ [More information about SEPA Bank transfer via Mollie](https://www.mollie.com/en/payments/bank-transfer/)
+ [More information about SEPA Direct debit via Mollie](https://www.mollie.com/en/payments/direct-debit/)
+ [More information about Bitcoin via Mollie](https://www.mollie.com/en/payments/bitcoin/)
+ [More information about PayPal via Mollie](https://www.mollie.com/en/payments/paypal/)
+ [More information about KBC/CBC Payment Button via Mollie](https://www.mollie.com/en/payments/kbc-cbc/)
+ [More information about Belfius Direct Net via Mollie](https://www.mollie.com/en/payments/belfius)
+ [More information about paysafecard via Mollie](https://www.mollie.com/en/payments/paysafecard/)
+ [More information about ING Home’Pay via Mollie](https://www.mollie.com/en/payments/ing-homepay/)
+ [More information about Gift cards via Mollie](https://www.mollie.com/en/payments/gift-cards)
+ [More information about EPS via Mollie](https://www.mollie.com/en/payments/eps)
+ [More information about Giropay via Mollie](https://www.mollie.com/en/payments/giropay)
