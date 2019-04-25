# Get Mollie payment methods

Returns a list of Mollie payment methods (and its issuers) which are enabled for your website profile.

## Headers

This endpoint behaves just like very other Spree API endpoint. If your endpoints require authentication, make sure you send the `X-Spree-Token` header.

## Parameters

If you would like to obtain a list of payment methods for a specific currency, you should send an `amount` object containing value and currency. Only methods that support the `amount` and `currency` are returned.

| URL Parameter        | Required?  |
| -------------------- | ----------:|
| amount[currency]     | No         |
| amount[value]        | No         |

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
    "resource": "method",
    "id": "ideal",
    "description": "iDEAL",
    "image": {
      "size1x": "https://www.mollie.com/images/payscreen/methods/ideal.png",
      "size2x": "https://www.mollie.com/images/payscreen/methods/ideal%402x.png"
    },
    "issuers": [
      {
        "resource": "issuer",
        "id": "ideal_ABNANL2A",
        "name": "ABN AMRO",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/ABNANL2A.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/ABNANL2A.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_ASNBNL21",
        "name": "ASN Bank",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/ASNBNL21.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/ASNBNL21.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_BUNQNL2A",
        "name": "bunq",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/BUNQNL2A.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/BUNQNL2A.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_INGBNL2A",
        "name": "ING",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/INGBNL2A.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/INGBNL2A.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_KNABNL2H",
        "name": "Knab",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/KNABNL2H.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/KNABNL2H.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_MOYONL21",
        "name": "Moneyou",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/MOYONL21.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/MOYONL21.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_RABONL2U",
        "name": "Rabobank",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/RABONL2U.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/RABONL2U.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_RBRBNL21",
        "name": "RegioBank",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/RBRBNL21.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/RBRBNL21.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_SNSBNL2A",
        "name": "SNS Bank",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/SNSBNL2A.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/SNSBNL2A.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_TRIONL2U",
        "name": "Triodos Bank",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/TRIONL2U.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/TRIONL2U.png"
        }
      },
      {
        "resource": "issuer",
        "id": "ideal_FVLBNL22",
        "name": "van Lanschot",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/FVLBNL22.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/ideal-issuer-icons/FVLBNL22.png"
        }
      }
    ],
    "_links": {
      "self": {
        "href": "https://api.mollie.com/v2/methods/ideal",
        "type": "application/hal+json"
      }
    }
  },
  {
    "resource": "method",
    "id": "creditcard",
    "description": "Credit card",
    "image": {
      "size1x": "https://www.mollie.com/images/payscreen/methods/creditcard.png",
      "size2x": "https://www.mollie.com/images/payscreen/methods/creditcard%402x.png"
    },
    "_links": {
      "self": {
        "href": "https://api.mollie.com/v2/methods/creditcard",
        "type": "application/hal+json"
      }
    }
  },
  {
    "resource": "method",
    "id": "paypal",
    "description": "PayPal",
    "image": {
      "size1x": "https://www.mollie.com/images/payscreen/methods/paypal.png",
      "size2x": "https://www.mollie.com/images/payscreen/methods/paypal%402x.png"
    },
    "_links": {
      "self": {
        "href": "https://api.mollie.com/v2/methods/paypal",
        "type": "application/hal+json"
      }
    }
  },
  {
    "resource": "method",
    "id": "bancontact",
    "description": "Bancontact",
    "image": {
      "size1x": "https://www.mollie.com/images/payscreen/methods/mistercash.png",
      "size2x": "https://www.mollie.com/images/payscreen/methods/mistercash%402x.png"
    },
    "_links": {
      "self": {
        "href": "https://api.mollie.com/v2/methods/mistercash",
        "type": "application/hal+json"
      }
    }
  },
  {
    "resource": "method",
    "id": "banktransfer",
    "description": "Bank transfer",
    "image": {
      "size1x": "https://www.mollie.com/images/payscreen/methods/banktransfer.png",
      "size2x": "https://www.mollie.com/images/payscreen/methods/banktransfer%402x.png"
    },
    "_links": {
      "self": {
        "href": "https://api.mollie.com/v2/methods/banktransfer",
        "type": "application/hal+json"
      }
    }
  },
  {
    "resource": "method",
    "id": "sofort",
    "description": "SOFORT Banking",
    "image": {
      "size1x": "https://www.mollie.com/images/payscreen/methods/sofort.png",
      "size2x": "https://www.mollie.com/images/payscreen/methods/sofort%402x.png"
    },
    "_links": {
      "self": {
        "href": "https://api.mollie.com/v2/methods/sofort",
        "type": "application/hal+json"
      }
    }
  },
  {
    "resource": "method",
    "id": "kbc",
    "description": "KBC/CBC Payment Button",
    "image": {
      "size1x": "https://www.mollie.com/images/payscreen/methods/kbc.png",
      "size2x": "https://www.mollie.com/images/payscreen/methods/kbc%402x.png"
    },
    "issuers": [
      {
        "resource": "issuer",
        "id": "cbc",
        "name": "CBC",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/kbc-issuer-icons/cbc.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/kbc-issuer-icons/cbc.png"
        }
      },
      {
        "resource": "issuer",
        "id": "kbc",
        "name": "KBC",
        "image": {
          "size1x": "https://www.mollie.com/images/checkout/v2/kbc-issuer-icons/kbc.png",
          "size2x": "https://www.mollie.com/images/checkout/v2/kbc-issuer-icons/kbc.png"
        }
      }
    ],
    "_links": {
      "self": {
        "href": "https://api.mollie.com/v2/methods/kbc",
        "type": "application/hal+json"
      }
    }
  },
  {
    "resource": "method",
    "id": "belfius",
    "description": "Belfius Pay Button",
    "image": {
      "size1x": "https://www.mollie.com/images/payscreen/methods/belfius.png",
      "size2x": "https://www.mollie.com/images/payscreen/methods/belfius%402x.png"
    },
    "_links": {
      "self": {
        "href": "https://api.mollie.com/v2/methods/belfius",
        "type": "application/hal+json"
      }
    }
  },
  {
    "resource": "method",
    "id": "inghomepay",
    "description": "ING Home'Pay",
    "image": {
      "size1x": "https://www.mollie.com/images/payscreen/methods/inghomepay.png",
      "size2x": "https://www.mollie.com/images/payscreen/methods/inghomepay%402x.png"
    },
    "_links": {
      "self": {
        "href": "https://api.mollie.com/v2/methods/inghomepay",
        "type": "application/hal+json"
      }
    }
  },
]

```