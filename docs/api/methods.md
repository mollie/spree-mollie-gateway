# Get Mollie payment methods

Returns a list of Mollie payment methods (and its issuers) which are enabled for your website profile.

## Parameters
This endpoint behaves just like very other Spree API endpoint. If your endpoints require authentication, make sure you sent the `X-Spree-Token` header.

## Example request

```bash
curl "http://localhost:3000/api/v1/mollie/methods" \
     -H 'Content-Type: application/json; charset=utf-8'
```

## Example response

```bash
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

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