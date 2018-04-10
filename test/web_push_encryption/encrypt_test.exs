defmodule WebPushEncryption.EncryptTest do
  use ExUnit.Case

  alias WebPushEncryption.Encrypt

  @salt_length 16
  @server_public_key_length 65

  defmodule DummyCrypto do
    @behaviour WebPushEncryption.Crypto

    def strong_rand_bytes(n) do
      :binary.copy(<<0>>, n)
    end

    def generate_key(_type, _params) do
      {Base.decode64!(Fixtures.example_server_keys().public),
       Base.decode64!(Fixtures.example_server_keys().private)}
    end
  end

  test "encrypt throws error when the input is too large" do
    assert_raise ArgumentError,
                 "Payload is too large. The current length is 4081 bytes plus 0 bytes of padding but the max length is 4078 bytes",
                 fn ->
                   Encrypt.encrypt(:binary.copy(<<0>>, 4081), "whatever", 0)
                 end

    assert_raise ArgumentError,
                 "Payload is too large. The current length is 13 bytes plus 4080 bytes of padding but the max length is 4078 bytes",
                 fn ->
                   Encrypt.encrypt(Fixtures.example_input(), "whatever", 4080)
                 end
  end

  test "encrypt returns the message with a valid subscription" do
    response = Encrypt.encrypt(Fixtures.example_input(), Fixtures.valid_subscription())
    assert is_binary(response.ciphertext)
    assert is_binary(response.salt)
    assert byte_size(response.salt) == @salt_length
    assert is_binary(response.server_public_key)
    assert byte_size(response.server_public_key) == @server_public_key_length
  end

  test "encrypt returns the correct output" do
    Application.put_env(
      :web_push_encryption,
      :crypto_impl,
      WebPushEncryption.EncryptTest.DummyCrypto
    )

    response = Encrypt.encrypt(Fixtures.example_input(), Fixtures.valid_subscription())
    assert response.ciphertext == Base.decode64!(Fixtures.example_output())
  after
    Application.delete_env(:web_push_encryption, :crypto_impl)
  end
end
