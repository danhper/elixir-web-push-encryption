defmodule WebPushEncryption.Push do
  @moduledoc """
  Module to send web push notifications with a payload through GCM
  """

  alias WebPushEncryption.Vapid

  @gcm_url "https://android.googleapis.com/gcm/send"
  @temp_gcm_url "https://gcm-http.googleapis.com/gcm"

  @fcm_url "https://fcm.googleapis.com/fcm/send"

  @doc """
  Sends a web push notification with a payload through GCM.

  ## Arguments

    * `message` is a binary payload. It can be JSON encoded
    * `subscription` is the subscription information received from the client.
       It should have the following form: `%{keys: %{auth: AUTH, p256dh: P256DH}, endpoint: ENDPOINT}`
    * `auth_token` [Optional] is the GCM api key matching the `gcm_sender_id` from the client `manifest.json`.
       It is not necessary for Mozilla endpoints.
    * `ttl` [Optional] is a non-negative integer Time To Live.
       It is the number of seconds that a message may be stored if the user is not immediately available.
       Mozilla Push Service only supports a maximum TTL of 5,184,000 seconds (about one month).

  ## Return value

  Returns the result of `HTTPoison.post`
  """
  @spec send_web_push(
          message :: binary,
          subscription :: map,
          auth_token :: binary | nil,
          ttl :: integer
        ) ::
          {:ok, any} | {:error, atom}
  def send_web_push(message, subscription, auth_token \\ nil, ttl \\ 0)

  def send_web_push(_message, _subscription, _auth_token, ttl)
      when not is_integer(ttl) or ttl < 0 do
    raise ArgumentError,
          "send_web_push expects a non-negative integer ttl"
  end

  def send_web_push(_message, %{endpoint: @gcm_url <> _registration_id}, nil, _ttl) do
    raise ArgumentError, "send_web_push requires an auth_token for gcm endpoints"
  end

  def send_web_push(message, %{endpoint: endpoint} = subscription, auth_token, ttl) do
    payload = WebPushEncryption.Encrypt.encrypt(message, subscription)

    headers =
      Vapid.get_headers(make_audience(endpoint), "aesgcm")
      |> Map.merge(%{
        "TTL" => to_string(ttl),
        "Content-Encoding" => "aesgcm",
        "Encryption" => "salt=#{ub64(payload.salt)}"
      })

    headers =
      headers
      |> Map.put("Crypto-Key", "dh=#{ub64(payload.server_public_key)};" <> headers["Crypto-Key"])

    {endpoint, headers} = make_request_params(endpoint, headers, auth_token)
    options = [
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        versions: [:"tlsv1.2"],
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]
    http_client().post(endpoint, payload.ciphertext, headers, options)
  end

  def send_web_push(_message, _subscription, _auth_token, _ttl) do
    raise ArgumentError,
          "send_web_push expects a subscription endpoint with an endpoint parameter"
  end

  defp make_request_params(endpoint, headers, auth_token) do
    cond do
      gcm_url?(endpoint) ->
        {make_gcm_endpoint(endpoint), headers |> Map.merge(fcm_gcm_authorization(auth_token))}

      fcm_url?(endpoint) and not is_nil(auth_token) ->
        {endpoint, headers |> Map.merge(fcm_gcm_authorization(auth_token))}

      true ->
        {endpoint, headers}
    end
  end

  defp make_audience(endpoint) do
    parsed = URI.parse(endpoint)
    parsed.scheme <> "://" <> parsed.host
  end

  defp fcm_url?(url), do: String.starts_with?(url, @fcm_url)
  defp gcm_url?(url), do: String.starts_with?(url, @gcm_url)
  defp make_gcm_endpoint(endpoint), do: String.replace(endpoint, @gcm_url, @temp_gcm_url)
  defp fcm_gcm_authorization(auth_token), do: %{"Authorization" => "key=#{auth_token}"}

  defp ub64(value) do
    Base.url_encode64(value, padding: false)
  end

  defp http_client() do
    Application.get_env(:web_push_encryption, :http_client, HTTPoison)
  end
end
