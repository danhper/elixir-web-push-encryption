defmodule WebPushEncryption.VapidTest do
  use ExUnit.Case

  alias WebPushEncryption.Vapid

  test "get_headers" do

    assert %{"Authorization" => "WebPush " <> jwt,
      "Crypto-Key" => "p256ecdsa=" <> public_key} = Vapid.get_headers("http://localhost/", "aesgcm")

    jwk = {:ECPrivateKey,
           1,
           <<>>,
           {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}},
           Base.url_decode64!(public_key, padding: false)}
           |> JOSE.JWK.from_key()

    assert {true, _, _} = JOSE.JWT.verify_strict(jwk, ["ES256"], jwt)
  end

end
