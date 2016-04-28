defmodule WebPushEncryption.Encrypt do
  @moduledoc """
  Module to encrypt notification payloads.

  See the following links for details about the encryption process.

  https://developers.google.com/web/updates/2016/03/web-push-encryption?hl=en
  """

  alias WebPushEncryption.Crypto

  @max_payload_length 4078

  @one_buffer <<1>>

  @auth_info "Content-Encoding: auth" <> <<0>>


  @doc """
  Encrypts a web push notification body.

  ## Arguments

    * `message` the body to encrypt
    * `subscription`: See `WebPushEncryption.Push.send_web_push/3`
    * `padding_length`: An optional padding length

  ## Return value

  Returns the encrypted body as well as the necessary information in the following form:

  ```elixir
  %{ciphertext: ciphertext,               # the encrypted payload
    salt: salt,                           # the generated salt used during the encryption
    server_public_key: server_public_key} # the generated public key used during encryption
  ```
  """
  @spec encrypt(message :: binary, subscription :: map, padding_length :: non_neg_integer) :: map
  def encrypt(message, subscription, padding_length \\ 0)
  def encrypt(message, _subscription, padding_length)
      when byte_size(message) + padding_length > @max_payload_length do
    raise ArgumentError, "Payload is too large. The current length is #{byte_size(message)} bytes plus"
                                <> " #{padding_length} bytes of padding but the max length is #{@max_payload_length} bytes"
  end
  def encrypt(message, subscription, padding_length) do
    padding = make_padding(padding_length)

    plaintext = padding <> message

    :ok = validate_subscription(subscription)

    client_public_key = Base.url_decode64!(subscription.keys.p256dh)
    client_auth_token = Base.url_decode64!(subscription.keys.auth)

    :ok = validate_length(client_auth_token, 16, "Subscription's Auth token is not 16 bytes.")
    :ok = validate_length(client_public_key, 65, "Subscription's client key (p256dh) is invalid.")

    salt = Crypto.rand_bytes(16)

    {server_public_key, server_private_key} = Crypto.generate_key(:ecdh, :prime256v1)

    shared_secret = :crypto.compute_key(:ecdh, client_public_key, server_private_key, :prime256v1)

    prk = hkdf(client_auth_token, shared_secret, @auth_info, 32)

    context = create_context(client_public_key, server_public_key)

    content_encryption_key_info = create_info("aesgcm", context)
    content_encryption_key = hkdf(salt, prk, content_encryption_key_info, 16)

    nonce_info = create_info("nonce", context)
    nonce = hkdf(salt, prk, nonce_info, 12)

    ciphertext = encrypt_payload(plaintext, content_encryption_key, nonce)
    %{ciphertext: ciphertext, salt: salt, server_public_key: server_public_key}
  end

  defp hkdf(salt, ikm, info, length) do
    prk_hmac = :crypto.hmac_init(:sha256, salt)
    prk_hmac = :crypto.hmac_update(prk_hmac, ikm)
    prk = :crypto.hmac_final(prk_hmac)

    info_hmac = :crypto.hmac_init(:sha256, prk)
    info_hmac = :crypto.hmac_update(info_hmac, info)
    info_hmac = :crypto.hmac_update(info_hmac, @one_buffer)
    :crypto.hmac_final(info_hmac) |> :binary.part(0, length)
  end

  defp create_context(client_public_key, _server_public_key) when byte_size(client_public_key) != 65,
    do: raise ArgumentError, "invalid client public key length"
  defp create_context(_client_public_key, server_public_key) when byte_size(server_public_key) != 65,
    do: raise ArgumentError, "invalid server public key length"
  defp create_context(client_public_key, server_public_key) do
    <<0,
      byte_size(client_public_key) :: unsigned-big-integer-size(16)>> <>
      client_public_key <>
    <<byte_size(server_public_key) :: unsigned-big-integer-size(16)>> <>
      server_public_key
  end

  defp create_info(_type, context) when byte_size(context) != 135,
    do: raise ArgumentError, "Context argument has invalid size"
  defp create_info(type, context) do
    "Content-Encoding: " <>
    type <>
    <<0>> <>
    "P-256" <>
    context
  end

  defp encrypt_payload(plaintext, content_encryption_key, nonce) do
    {cipher_text, cipher_tag} = :crypto.block_encrypt(:aes_gcm, content_encryption_key, nonce, {"", plaintext})
    cipher_text <> cipher_tag
  end

  defp validate_subscription(%{keys: %{p256dh: p256dh, auth: auth}})
      when not is_nil(p256dh) and not is_nil(auth) do
    :ok
  end
  defp validate_subscription(_subscription) do
    raise ArgumentError, "Subscription is missing some encryption details."
  end

  defp validate_length(bytes, expected_size, _message) when byte_size(bytes) == expected_size, do: :ok
  defp validate_length(_bytes, _expected_size, message) do
    raise ArgumentError, message
  end

  defp make_padding(padding_length) do
    binary_length = <<padding_length :: unsigned-big-integer-size(16)>>
    binary_length <> :binary.copy(<<0>>, padding_length)
  end
end
