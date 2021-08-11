defmodule WhsApp.Operator.Operations do
  use Ecto.Schema
  import Ecto.Changeset

  alias WhsApp.Operator.Storage

  schema "operations" do
    field :title, :string, null: false
    field :operation, :string, null: false
    field :amount, :integer, null: false
    belongs_to :storage, Storage, foreign_key: :goods_id, type: :binary_id

    timestamps()
  end

  def changeset(storage, attrs) do
    storage
    |> cast(attrs, [:title, :operation, :amount, :goods_id])
    |> validate_required([:title, :operation, :amount, :goods_id])
  end
end
