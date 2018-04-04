defmodule WebPushEncryption.Push do
  @moduledoc """
  Module to send web push notifications with a payload through GCM
  """

  alias WebPushEncryption.Vapid

  @gcm_url "https://android.googleapis.com/gcm/send"
  @temp_gcm_url "https://gcm-http.googleapis.com/gcm"

  @doc """
  Sends a web push notification with a payload through GCM.

  ## Arguments

    * `message` is a binary payload. It can be JSON encoded
    * `subscription` is the subscription information received from the client.
       It should have the following form: `%{keys: %{auth: AUTH, p256dh: P256DH}, endpoint: ENDPOINT}`
    * `auth_token` [Optional] is the GCM api key matching the `gcm_sender_id` from the client `manifest.json`.
       It is not necessary for Mozilla endpoints.

  ## Return value

  Returns the result of `HTTPoison.post`
  """
  @spec send_web_push(message :: binary, subscription :: map, auth_token :: binary | nil) :: {:ok, any} | {:error, atom}
  def send_web_push(message, subscription, auth_token \\ nil)
  def send_web_push(_message, %{endpoint: @gcm_url <> _registration_id}, nil) do
    raise ArgumentError, "send_web_push requires an auth_token for gcm endpoints"
  end
  def send_web_push(message, %{endpoint: endpoint} = subscription, auth_token) do
    payload = WebPushEncryption.Encrypt.encrypt(message, subscription)

    headers = Vapid.get_headers(make_audience(endpoint), "aesgcm")
    |> Map.merge(
      %{
        "TTL" => "0",
        "Content-Encoding" => "aesgcm",
        "Encryption" => "salt=#{ub64(payload.salt)}",
      })

    headers = headers |> Map.put("Crypto-Key", "dh=#{ub64(payload.server_public_key)};" <> headers["Crypto-Key"])

    {endpoint, headers} = make_request_params(endpoint, headers, auth_token)

    IO.inspect headers, label: "headers"

    HTTPoison.post(endpoint, payload.ciphertext, headers)
  end
  def send_web_push(_message, _subscription, _auth_token) do
    raise ArgumentError, "send_web_push expects a subscription endpoint with an endpoint parameter"
  end

  defp make_request_params(endpoint, headers, auth_token) do
    if gcm_url?(endpoint) do
      {make_gcm_endpoint(endpoint), headers ++ [gcm_authorization(auth_token)]}
    else
      {endpoint, headers}
    end
  end

  defp make_audience(endpoint) do
    parsed = URI.parse(endpoint)
    parsed.scheme <> "://" <> parsed.host
  end

  defp gcm_url?(url), do: String.contains?(url,  @gcm_url)
  defp make_gcm_endpoint(endpoint), do: String.replace(endpoint, @gcm_url, @temp_gcm_url)
  defp gcm_authorization(auth_token), do: {"Authorization", "key=#{auth_token}"}

  defp ub64(value) do
    Base.url_encode64(value, padding: false)
  end
end
