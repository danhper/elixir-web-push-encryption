defmodule WebPushEncryption do

  defdelegate send_web_push(message, subscription, auth_token), to: WebPushEncryption.Push

  defdelegate encrypt(message, subscription), to: WebPushEncryption.Encrypt
  defdelegate encrypt(message, subscription, padding_length), to: WebPushEncryption.Encrypt
end
