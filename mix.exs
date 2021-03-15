defmodule App.MixProject do
    use Mix.Project

    def project do
        [
            app: :app,
            version: "0.1.0",
            elixir: "~> 1.11",
            start_permanent: Mix.env() == :prod,
            deps: deps()
        ]
    end

    def application do
        [
            extra_applications: [:logger],
            mod: {App.Application, []}
        ]
    end

    defp deps do
        [
            {:eventsource_ex, git: "https://github.com/cwc/eventsource_ex.git"},
            {:elixir_uuid, "~> 1.2"},
            {:poison, "~> 3.1"},
            {:mongodb, "~> 0.5.1"}
        ]
    end
end




