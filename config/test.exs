use Mix.Config

# # Example Vapid keypair. Generate your own: mix gen.web_push_keys

config :web_push_encryption, :vapid_details,
  subject: "mailto:administrator@example.com",
  public_key: "BDntLA3k5K1tsrFOXXAuS_9Ey30jxy-R2CAosC2DOQnTs8LpQGxpTEx3AcPXinVYFFpJI6tT_RJC8pHgUsdbhOk",
  private_key: "RVPPDBVNmJtSLoZ28jE1SumpG4HyhhCPfcix3bvxbLw"

config :web_push_encryption,
  http_client: HTTPoisonSandbox
