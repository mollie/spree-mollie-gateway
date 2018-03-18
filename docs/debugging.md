# Debugging

The Mollie gateway keeps track of all events which are related to payment details and payment state updates. It uses a separate log, which is located in `log/mollie.log`.

## Example

```
❯ tail -fn20 log/mollie.log
D, [2018-03-17T16:48:43.881508 #45974] DEBUG -- : About to create payment for order R066092806-P9ND5B3J
D, [2018-03-17T16:48:44.081895 #45974] DEBUG -- : Payment tr_12345678 created for order R066092806-P9ND5B3J
D, [2018-03-17T16:48:44.104215 #45974] DEBUG -- : For order R066092806 redirect user to payment URL: https://www.mollie.com/paymentscreen/issuer/select/ideal
D, [2018-03-17T16:48:49.488303 #45974] DEBUG -- : Webhook called for payment tr_12345678
D, [2018-03-17T16:48:49.697996 #45974] DEBUG -- : Updating order state for payment. Payment has state paid
D, [2018-03-17T16:48:49.788303 #45974] DEBUG -- : Redirect URL visited for order R066092806-P9ND5B3J
D, [2018-03-17T16:48:50.927236 #45974] DEBUG -- : Created a Mollie Customer for Spree user with ID cst_234890239
D, [2018-03-17T16:55:13.466887 #45974] DEBUG -- : About to create payment for order R287180370-PAP5KQV3
D, [2018-03-17T16:55:13.572465 #45974] DEBUG -- : Payment tr_12345678 created for order R287180370-PAP5KQV3
D, [2018-03-17T16:55:26.796272 #45974] DEBUG -- : Webhook called for payment tr_12345678
D, [2018-03-17T16:55:28.298622 #45974] DEBUG -- : Updating order state for payment. Payment has state paid
D, [2018-03-17T16:55:28.384232 #45974] DEBUG -- : Redirect URL visited for order R287180370-PAP5KQV3
D, [2018-03-17T17:11:06.855310 #45974] DEBUG -- : Webhook called for payment tr_12345678
D, [2018-03-17T17:11:09.569485 #45974] DEBUG -- : Updating order state for payment. Payment has state expired
D, [2018-03-18T13:58:14.360501 #54712] DEBUG -- : Starting refund for order R287180370
D, [2018-03-18T13:58:18.992075 #54712] DEBUG -- : Succesfully refunded 0.01 for order R287180370
D, [2018-03-18T14:12:10.495217 #54712] DEBUG -- : Could not crate payment for order R541579556-PEKXA7RN: Unauthorized request
```