[<img src="https://www.mollie.com/assets/images/mollie/logo-black.svg" width="110">](https://www.mollie.com/)
  
Quickly integrate all major payment methods in Spree Commerce, wherever you need them. Simply drop them ready-made into your Spree Commerce webshop with this powerful plugin by Mollie. Mollie is dedicated to making payments better for Spree Commerce.

> Next level payments, for Spree Commerce

No need to spend weeks on paperwork or security compliance procedures. No more lost conversions because you don’t support a shopper’s favorite payment method or because they don’t feel safe. We made payments intuitive and safe for merchants and their customers.

1. [Payment methods](#payment-methods)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Configuring Mollie Gateway](#configuring-mollie-gateway)
6. [License](#license)

## Payment methods

Credit cards:

* VISA (International)
* MasterCard (International)
* American Express (International)
* Cartes Bancaires (France)
* CartaSi (Italy)

Debit cards:

* V Pay (International)
* Maestro (International)

Alternative payment methods:

* iDEAL (Netherlands)
* Bancontact (Belgium)
* Home'Pay (Belgium)
* PayPal (International)
* SOFORTbanking (EU)
* Belfius (Belgium)
* KBC/CBC payment button (Belgium)
* SEPA - Credit Transfer (EU)
* SEPA - Direct Debit (EU)
* Bitcoin (International)
* Paysafecard (International)
* Gift cards (Netherlands)

Please go to the [signup page](https://www.mollie.com/signup) to create a new Mollie account and start receiving payments in a couple of minutes. Contact info@mollie.com if you have any questions or comments about this plugin.

> Our pricing is always per transaction. No startup fees, no monthly fees, and no gateway fees. No hidden fees, period.

## Features

* Support for all available Mollie payment methods.
* Support for [one-click payments](https://www.mollie.com/en/features/checkout).
* Transparent pricing. No startup fees, no monthly fees, and no gateway fees. No hidden fees, period.
* Configurable pay outs: daily, weekly, monthly - whatever you prefer.
* [Powerful dashboard](https://www.mollie.com/en/features/dashboard) on mollie.com to easily keep track of your payments.
* Fast in-house support. You will always be helped by someone who knows our products intimately.
* Multiple translations: English and Dutch.
* Event log for debugging purposes.

## Requirements
- Spree 3.4.x or higher.
- Rails 5.1.x or higher.  

## Installation

Open your `Gemfile` and add `spree_mollie_gateway`.

```ruby
gem 'spree_mollie_gateway'
```

Install the gem by running `bundle install`.

Run the installer which takes care of copying migrations:

```bash
bundle exec rails g spree_mollie_gateway:install
```

## Configuring Mollie Gateway

1. Configure a new payment method (`Spree Admin -> Configurations -> Payment Methods -> New Payment Method`).
2. Select `Spree::Gateway::MollieGateway` as a `Provider`.
3. Fill in your live / test `API key`.
4. Fill in your hostname. Used for generating the webhook URL and redirect URL.
5. Select "Front End" in the `Display` selectbox.
6. Fill in "Mollie" for the `Name` field.
7. Save and you're done!

## License
[GPLv2 (GNU General Public License, version 2) License](http://www.gnu.org/licenses/gpl-2.0.html).
Copyright (c) 2018, Mollie B.V.