# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :web_push_encryption, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:web_push_encryption, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :web_push_encryption, :vapid_details,
  subject: "mailto:administrator@example.com",
  public_key: "BPdTTUfAs1WuIWhnCxEed1ngeysGfjDkxa8Glv3dTlCjMcTXgUChXzZpm0VtqwaYhFFLPzdmyDiV207d4r04j8Q",
  private_key: "VKEwdAVds8EIirGISfNDCSIaBkCbM_DiFazF4eIR198"
