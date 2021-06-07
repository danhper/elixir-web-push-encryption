defmodule WebPushEncryption.VapidTest do
  use ExUnit.Case

  alias WebPushEncryption.Vapid

  test "get_headers" do
    assert %{"Authorization" => "WebPush " <> jwt, "Crypto-Key" => "p256ecdsa=" <> public_key} =
             Vapid.get_headers("http://localhost/", "aesgcm")

    otp_version =
      :erlang.system_info(:otp_release) |> String.Chars.to_string() |> String.to_integer()

    jwk =
      if otp_version < 24 do
        {:ECPrivateKey, 1, <<>>, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}},
         Base.url_decode64!(public_key, padding: false)}
      else
        {:ECPrivateKey, 1, <<>>, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}},
         Base.url_decode64!(public_key, padding: false), nil}
      end
      |> JOSE.JWK.from_key()

    assert {true, _, _} = JOSE.JWT.verify_strict(jwk, ["ES256"], jwt)
  end
end
