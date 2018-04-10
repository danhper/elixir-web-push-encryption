defmodule Mix.Tasks.WebPush.Gen.Keypair do
  def run(_) do
    {public, private} = :crypto.generate_key(:ecdh, :prime256v1)

    IO.puts("# Put the following in your config.exs:")
    IO.puts("")
    IO.puts("config :web_push_encryption, :vapid_details,")
    IO.puts("  subject: \"mailto:administrator@example.com\",")
    IO.puts("  public_key: \"#{ub64(public)}\",")
    IO.puts("  private_key: \"#{ub64(private)}\"")
    IO.puts("")
  end

  defp ub64(value) do
    Base.url_encode64(value, padding: false)
  end
end
