defmodule WebPushEncryption.Mixfile do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :web_push_encryption,
      version: @version,
      elixir: "~> 1.4",
      description: "Web push encryption library",
      source_url: "https://github.com/tuvistavie/elixir-web-push-encryption",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: [source_ref: "#{@version}", extras: ["README.md"], main: "readme"]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:jose, "~> 1.11.1"},
      {:poison, "~> 3.0", only: [:dev, :test]},
      {:earmark, "~> 1.0", only: :dev},
      {:hkdf_erlang, "~> 0.1.0"},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
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
