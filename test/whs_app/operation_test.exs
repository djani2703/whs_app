defmodule WhsApp.OperationTest do
  use WhsApp.DataCase

  alias WhsApp.Operation
  alias WhsApp.Operator

  describe "operations" do
    @incorrect_attrs %{title: nil, operation: nil, amount: nil, goods_id: nil}
    @correct_goods_attrs %{
      title: "Elixir in action",
      units_in_stock: 10,
      reserved: 5,
      active: true
    }

    def test_operation() do
      {:ok, goods} = Operator.add_new_good(@correct_goods_attrs)

      {:ok, operation} =
        Operation.add_operation(%{
          title: goods.title,
          operation: "new",
          amount: 5,
          goods_id: goods.id
        })

      operation
    end

    test "get_all_operations returns all operations" do
      operation = test_operation()
      assert Operation.get_all_operations() == [operation]
    end

    test "add_operation with correct data creates a new operation" do
      operation = test_operation()
      assert operation.title == "Elixir in action"
      assert operation.amount == 5
    end

    test "add_operation with incorrect data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Operation.add_operation(@incorrect_attrs)
    end
  end
end
