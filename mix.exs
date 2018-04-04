defmodule WebPushEncryption.Mixfile do
  use Mix.Project

  @version "0.1.3"

  def project do
    [app: :web_push_encryption,
     version: @version,
     elixir: "~> 1.1",
     description: "Web push encryption lilbrary",
     source_url: "https://github.com/tuvistavie/elixir-web-push-encryption",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps(),
     docs: [source_ref: "#{@version}", extras: ["README.md"], main: "readme"]]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [{:httpoison, "~> 0.8"},
     {:jose, "~> 1.8"},
     {:poison, "~> 3.0"},
     {:earmark,   "~> 0.2", only: :dev},
     {:ex_doc,    "~> 0.11", only: :dev}]
  end

  defp package do
    [
      maintainers: ["Daniel Perez"],
      files: ["lib", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/tuvistavie/elixir-web-push-encryption",
        "Docs" => "http://hexdocs.pm/web_push_encryption/"
      }
    ]
  end
end
