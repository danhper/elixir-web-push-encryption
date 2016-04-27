# WebPushEncryption

Elixir implementation of [Web Push Payload encryption](https://developers.google.com/web/updates/2016/03/web-push-encryption?hl=en).

## Installation

  1. Add `web_push_encryption` to your list of dependencies in `mix.exs`.

    ```elixir
    def deps do
      [{:web_push_encryption, "~> 0.1.0"}]
    end
    ```

  2. Ensure `web_push_encryption` is started before your application:

    ```elixir
    def application do
      [applications: [:web_push_encryption]]
    end
    ```

## Usage

`WebPushEncryption` has two public API:

* `WebPushEncryption.encrypt/3`: Takes a body, a subscription, and an optional padding and returns a map containing `ciphertext`, `server_public_key` and `salt`.

* `WebPushEncryption.send_web_push/3`: Takes a body, a subcription, and a GCM secret key and sends a push notification with the given payload.

```elixir
body = ~s({"hello": "elixir"})
subscription = %{keys: %{p256dh: "P256DH", auth: "AUTH" }, endpoint: "ENDPOINT"}
gcm_api_key = "API_KEY"

# encrypt the body
encrypted_body = WebPushEncryption.encrypt(body, subscription)
# or just send the push
{:ok, response} = WebPushEncryption.send_web_push(body, subscription, gcm_api_key)
```

See the docs for more info.

## Client Sample

Here is the strict minimum client code to try it, you will need Chrome >= 50.
It should also work for Firefox >= 44 but I did not try it yet.

* `main.js`

```js
navigator.serviceWorker
  .register('sw.js').then(function(reg) {
    reg.pushManager.subscribe({
      userVisibleOnly: true
    }).then(function(sub) {
      console.log('subscription:', JSON.stringify(sub));
    }).catch(e => console.log(e));
  }).catch(function(error) {
    console.log('error: ', error);
  });
```

* `sw.js`

```js
self.addEventListener('push', function(event) {
  if (event.data) {
    console.log(event.data.json());
  }
});
```

* `manifest.json`

```json
{
    "short_name": "Push Sample",
    "name": "Push sample",
    "start_url": "index.html",
    "gcm_sender_id": "GCM_SENDER_ID"
}
```

* `index.html`


```html
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <title>Document</title>
        <link rel="manifest" href="/manifest.json">
        <script src="main.js"></script>
    </head>
    <body>
    </body>
</html>
```
