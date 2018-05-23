# Integrating with the Spree API

This guide explains how the Spree checkout flow works when using the Mollie gateway in combination with the Spree API.

## Set up your development environment

To make sure webhooks on your local machine can be called, we recommend installing `ngrok`.

Make sure `ngrok` listens to port `3000`:

```
❯ ./ngrok http 3000
```

You will then see a `Forwarding URL` which is using HTTPS. Using HTTPS for webhooks is a required for webhooks.

Make sure to set the new `ngrok` URL as the Hostname in your payment gateway settings: `http://localhost:3000/admin/payment_methods/4/edit`

Start your rails server:

```
rails server
```

## Checkout flow

Creating an order using the Spree API is pretty easy. You can test the order creation flow by executing the following actions:

1. Create a new `Spree::Order`.
2. Add items (`line_items`) to your order.
3. Walk through the checkout flow by transitioning to different states (`address`, `delivery`, `payment`, `complete`).
4. Create a new payment. Each `Spree::Payment` is related to one Mollie payment. You can create multiple payments for one order (in case the previous payment failed, for example).

### Create a new `Spree::Order`

```bash
curl -X "POST" "http://localhost:3000/api/v1/orders" \
     -H 'X-Spree-Token: <token>'
```

## Add a new line item to your order

```bash
curl -X "POST" "http://localhost:3000/api/v1/orders/R287180370/line_items?line_item%5Bvariant_id%5D=1&line_item%5Bquantity%5D=1" \
     -H 'X-Spree-Token: <token>'
```

## Start the checkout process

Spree has several checkout states, the default ones are:

1. `cart`
2. `address`
3. `delivery`
4. `payment`
5. `complete`

We're only covering the `payment` and `complete` steps. Documentation on the other checkout steps can be found in the Spree API documentation.

### Listing available payment methods

You an get a list of Mollie payment methods (and its issuers if any) by making the following request:

```bash
curl "http://localhost:3000/api/v1/mollie/methods" \
     -H 'X-Spree-Token: <token>'
```

This will return the following response:

```json
[
  {
    "attributes": {
      "resource": "method",
      "id": "ideal",
      "description": "iDEAL",
      "amount": {
        "minimum": "0.01",
        "maximum": "50000.00"
      },
      "image": {
        "normal": "https://www.mollie.com/images/payscreen/methods/ideal.png",
        "bigger": "https://www.mollie.com/images/payscreen/methods/ideal%402x.png"
      },
      "issuers": [
        {
          "resource": "issuer",
          "id": "ideal_TESTNL99",
          "name": "TBM Bank",
          "method": "ideal",
          "image": {
            "normal": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/TESTNL99.png",
            "bigger": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/TESTNL99%402x.png"
          }
        }
      ]
    },
    "id": "ideal",
    "description": "iDEAL",
    "amount": {
      "minimum": "0.01",
      "maximum": "50000.00"
    },
    "image": {
      "normal": "https://www.mollie.com/images/payscreen/methods/ideal.png",
      "bigger": "https://www.mollie.com/images/payscreen/methods/ideal%402x.png"
    }
  }
]
```

### Creating a new payment

When you're about to advance your order to the `payment` state, you can do so by calling:

```bash
curl -X "PUT" "http://localhost:3000/api/v1/checkouts/R805041440/next" \
     -H 'X-Spree-Token: <token>'
```

This will result in the following example response:

```json
{
    [...]
    number: R805041440,
    state: payment,
    item_total: 0.01,
    payment_state: null,
    payments: [],
    payment_methods: [
        {
            id: 4,
            name: Mollie,
            method_type: molliegateway,
        }
    ]
    [...]
}
```

In the example response above, the `payments ` array is empty, which means there are no payments created for the order. We need to tell Spree which `Spree::PaymentMethod` we would like to use for our payment (and which method we want to use for our payment).
We can use the ID that Spree just returned for this, in combination with the `id` of the preferred Mollie payment method (which we retrieved earlier).

```bash
curl -X "PUT" "http://localhost:3000/api/v1/checkouts/R287180370" \
     -H 'X-Spree-Token: <token>' \
     -d $'{
  "order": {
    "payments_attributes": [
      {
        "payment_method_id": "4"
      }
    ]
  },
  "payment_source": {
    "4": {
      "payment_method_name": "ideal"
    }
  }
}'
```

Spree will respond with the following example response:

```json
{
    [...]
    state: 'complete',
    payment_state: 'balance_due',
    payments: [
    {
        id: 96,
        source_type: "Spree::MolliePaymentSource",
        source_id: 100,
        amount: "0.02",
        display_amount: "€0.02",
        payment_method_id: 4,
        state: "pending",
        avs_response: null,
        created_at: "2018-03-17T15:55:13.000Z",
        updated_at: "2018-03-17T15:55:13.000Z",
        number: "PAP5KQV3",
        payment_method: { id: 4, name: "Mollie" },
        source: {
          id: 100,
          name: "iDEAL",
          payment_method_name: "ideal",
          payment_url:
            "https://www.mollie.com/paymentscreen/issuer/select/ideal/Hsnrg2nqqe",
        },
    }
    ]
}
```

The order has now been transitioned to the state `complete`, but the order has not been paid for. Also, no order confirmation mail has been sent to the customer.

In our `source` node, we get a `payment_url`. You should now redirect your users to this URL, so they can complete their payment.

If everything goes well, our order's `payment_state` will transition from `balance_due` to `paid`.

Did the payment fail? Make sure to create a new payment and redirect the user to the new `payment_url`.

## Payment states mapping

Each Mollie payment state will transition the order to the following order state:

| Mollie state | Spree order state |
|--------------|-------------------|
| paid         | complete          |
| cancelled    | failed            |
| expired      | failed            |
| failed       | failed            |
| refunded     | void              |

## Debugging the checkout flow

Each action within the Mollie gateway is logged in a separate log file. Find out more about Debugging.
