defmodule WebPushEncryption.EncryptTest do
  use ExUnit.Case

  alias WebPushEncryption.Encrypt

  @example_input "Hello, World."

  @example_server_keys %{
    public: 'BOg5KfYiBdDDRF12Ri17y3v+POPr8X0nVP2jDjowPVI/DMKU1aQ3OLdPH1iaakvR9/PHq6tNCzJH35v/JUz2crY=',
    private: 'uDNsfsz91y2ywQeOHljVoiUg3j5RGrDVAswRqjP3v90='
  }

  @example_salt "AAAAAAAAAAAAAAAAAAAAAA"

  @example_input "Hello, World."
  @example_output "CE2OS6BxfXsC2YbTdfkeWLlt4AKWbHZ3Fe53n5/4Yg=="

  @valid_subscription %{
    endpoint: "https://example-endpoint.com/example/1234",
    keys: %{
      auth: "8eDyX_uCN0XRhSbY5hs7Hg==",
      p256dh: "BCIWgsnyXDv1VkhqL2P7YRBvdeuDnlwAPT2guNhdIoW3IP7GmHh1SMKPLxRf7x8vJy6ZFK3ol2ohgn_-0yP7QQA="
    }
  }

  @salt_length 16
  @server_public_key_length 65

  test "encrypt throws error when the input is too large" do
    assert_raise ArgumentError, "Payload is too large. The current length is 4081 bytes plus 0 bytes of padding but the max length is 4078 bytes", fn ->
      Encrypt.encrypt(:binary.copy(<<0>>, 4081), "whatever", 0)
    end

    assert_raise ArgumentError, "Payload is too large. The current length is 13 bytes plus 4080 bytes of padding but the max length is 4078 bytes", fn ->
      Encrypt.encrypt(@example_input, "whatever", 4080)
    end
  end

  test "encrypts returns the message with a valid subscription" do
    response = Encrypt.encrypt(@example_input, @valid_subscription)
    assert is_binary(response.ciphertext)
    assert is_binary(response.salt)
    assert byte_size(response.salt) == @salt_length
    assert is_binary(response.server_public_key)
    assert byte_size(response.server_public_key) == @server_public_key_length
    IO.inspect(Base.encode64(response.ciphertext))
  end
end
