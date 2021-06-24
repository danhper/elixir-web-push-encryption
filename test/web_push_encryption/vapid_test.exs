defmodule WebPushEncryption.VapidTest do
  use ExUnit.Case

  alias WebPushEncryption.Vapid

  @otp_version :otp_release
               |> :erlang.system_info()
               |> List.to_integer()

  test "get_headers" do
    assert %{"Authorization" => "WebPush " <> jwt, "Crypto-Key" => "p256ecdsa=" <> public_key} =
             Vapid.get_headers("http://localhost/", "aesgcm")

    decoded_public_key = Base.url_decode64!(public_key, padding: false)

    private_key_record =
      if @otp_version < 24 do
        {:ECPrivateKey, 1, <<>>, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, decoded_public_key}
      else
        {:ECPrivateKey, 1, <<>>, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, decoded_public_key, nil}
      end

    jwk = JOSE.JWK.from_key(private_key_record)

    assert {true, _, _} = JOSE.JWT.verify_strict(jwk, ["ES256"], jwt)
  end
end
