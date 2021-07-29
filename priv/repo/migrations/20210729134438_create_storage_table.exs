defmodule WhsApp.Repo.Migrations.CreateStorageTable do
  use Ecto.Migration

  def change do
    create table(:storage, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, size: 100, null: false
      add :units_in_stock, :integer, default: 0, null: false
      add :reserved, :integer, default: 0, null: false
      add :active, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:storage, [:title], name: :index_for_unique_title)
  end
end
