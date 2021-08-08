defmodule WhsApp.Repo.Migrations.CreateOperationsTable do
  use Ecto.Migration

  def change do
    create table(:operations) do
      add :title, :string, null: false
      add :operation, :string, null: false
      add :amount, :integer, null: false
      add :goods_id, references(:storage, type: :uuid, on_delete: :nothing), null: false

      timestamps()
    end
  end
end
