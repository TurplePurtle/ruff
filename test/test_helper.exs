ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Ruff.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Ruff.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Ruff.Repo)

