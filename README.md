# CyberSource Demo

Team Zulu plans to implement CyberSource Secure Acceptance (Hosted Checkout) to give visiting students a way to pay for their courses.

This is a demo project to help demonstrate how to implement this particular CyberSource offering. It's worth noting immediately that CyberSource's developer documentation is geared more towards its newer API solutions, which we do not plan to use.

This Sinatra application is based largely on the example found at:

[Secure Acceptance Hosted Checkout Docs](https://developer.cybersource.com/library/documentation/dev_guides/Secure_Acceptance_Hosted_Checkout/Secure_Acceptance_Hosted_Checkout.pdf) > Payment Configuration > Samples In Scripting Languages > Ruby 

You will need to log into the [CyberSource dashboard](https://ubctest.cybersource.com), set up a Profile, and create an access key for that profile. Once that is done, you will replaces the values in the app that are currently set to `YOUR_PROFILE_ID`, `YOUR_ACCESS_KEY`, and `YOUR_SECRET_KEY`.

## Setup

After cloning this repository to your machine:

```bash
> cd cybersource-demo
> bundle
# ...
> rackup -o localhost
```

Rack should now be serving the application at `localhost:9292`

---

## Testing

If you navigate to `localhost:9292` in your browser, you should see a small `form` with a few values already filled in. In our real app, these values will be populated by our own internal logic, and we will use JavaScript to automatically submit this form when the page loads. (At least, that's what they propose, but this doesn't _need_ to be done by JavaScript).

In the demo app, you can replicate that automatic form submission by manually hitting "Submit."

This will now bring you to a read-only `form` with all of the necessary data included, as well as an HMAC-signature to verify the data when it reaches CyberSource. When the user clicks the submit button on this `form`, it will create a POST request from their browser that will take them to a page hosted by CyberSource, where they will fill in their personal/credit-card information.

You can complete this step with your own credit card number (NOOOOO) or with [the test credentials that they offer](https://developer.cybersource.com/library/documentation/dev_guides/Secure_Acceptance_Hosted_Checkout/html/index.html#t=Topics%2Ftesting_EBC2.htm), such as:

Discover: `6011111111111117` (any expiration date should work)

After they complete their transaction, CyberSource will notify us directly via the "Merchant POST URL", and the user will be redirected back to our app for confirmation with the "Custom Redirect After Checkout" setting. Both of these will not work with this demo app unless you follow the section below, [Configuring webhooks with `ngrok`](#configuring-webhooks-with-ngrok).

CyberSource can include a whole lot of [reply fields](https://developer.cybersource.com/library/documentation/dev_guides/Secure_Acceptance_Hosted_Checkout/html/index.html#t=Topics%2FReply_Fields.htm%23XREF_93716_Reply_Fields).

### Hardcoded things that will need to be changed

- secret_key
- access_key
- profile_id
- transaction_type
- reference_number
- amount
- currency

### Configuring webhooks with `ngrok`

Using `ngrok`, you can also hook into CyberSources webhooks for

- backend notifications (directly from CyberSource to this app)
  - route is called `/backoffice` in this app
- to send customers back to your app after a purchase
  - route is called `/receipt` in this app
    
To do so, call `ngrok http 9292`, which will provide you with a unique `XXXXXXXXXXXXX.ngrok.io` address which will intercept traffic to that host and pass it instead to your machine's `localhost:9292`.

If you then log into [the CyberSource test dashboard](https://ubctest.cybersource.com) and locate the relevant profile, you can 


- update the `Notifications > Merchant Notifications > Merchant POST URL` to be `XXXXXXXXXXXXX.ngrok.io/backoffice`
- update the `Customer Response > Custom Redirect After Checkout` to be `XXXXXXXXXXXXX.ngrok.io/receipt`

Note that to make any changes to a Profile you need to go through the convoluted process of:

- Finding the profile
- hitting "Edit"
- make any updates and saving them
- hitting "Promote Profile" again
