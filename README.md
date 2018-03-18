[<img src="https://www.mollie.com/assets/images/mollie/logo-black.svg" width="110">](https://www.mollie.com/)
  
This is the official Mollie payment gateway for Spree Commerce. Implement this to easily accept all major payment methods, including iDEAL, Bancontact, Visa, Mastercard, AmEx, and many more, in your Spree Commerce storefront.
 
This gateway supports all aspect of Spree Commerce and payments can be created through both `spree_frontend` and `spree_api`.

Please go to the [signup page](https://www.mollie.com/signup) to create a new Mollie account and start receiving payments in a couple of minutes.

> Our pricing is always per transaction. No startup fees, no monthly fees, and no gateway fees. No hidden fees, period.

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Configuring Mollie Gateway](#configuring-mollie-gateway)
5. [API endpoints](#api-endpoints)
6. [License](#license)

## Features

* Support for all available Mollie payment methods.
* Support for [one-click payments](https://www.mollie.com/en/features/checkout).
* Fast in-house support. You will always be helped by someone who knows our products intimately.
* Multiple translations: English and Dutch.
* Event log for debugging purposes.
* Available for `spree_api` and `spree_frontend`.
* Allow returning customers to <a href="https://www.mollie.com/en/features/checkout" title="One-click payments">use their previous payment details</a> and pay instantly.

## Requirements
- Spree 3.4.x or newer.
- Rails 5.1.x or newer.  

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
This gateway comes with a couple of API endpoints which seamlessly integrate with the Spree API. <a href="docs/api">View an overview of the available API endpoints.</a>  

## License
BSD (Berkeley Software Distribution) License. Copyright (c) 2014-2018, Mollie B.V.