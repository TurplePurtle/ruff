defmodule Ruff.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :crypted_password, :string, null: false

      timestamps
    end
    create unique_index(:users, ["lower(username)"], name: :users_lower_username_index)

  end
end
