use Mix.Config

config :logger, level: :debug

config :git_hooks,
  hooks: [
    pre_commit: [
      verbose: true,
      tasks: [
        {:cmd, "mix format --check-formatted --dry-run --check-equivalent"}
      ]
    ],
    pre_push: [
      verbose: true,
      tasks: [
        {:cmd, "mix clean"},
        {:cmd, "mix compile --warnings-as-errors"},
        {:cmd, "mix credo --strict"},
        {:cmd, "mix dialyzer --halt-exit-status"}
      ]
    ]
  ]
