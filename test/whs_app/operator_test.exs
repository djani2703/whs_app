defmodule WhsApp.OperatorTest do
  use WhsApp.DataCase

  alias WhsApp.Operator
  alias WhsApp.Operator.Storage
  alias WhsApp.Operation

  describe "storage" do
    @correct_attrs %{title: "Elixir in action", units_in_stock: 10, reserved: 5, active: true}
    @update_attrs %{title: "Dell XPS 15", units_in_stock: 10, reserved: 2, active: true}
    @incorrect_attrs %{title: nil, units_in_stock: nil, reserved: nil, active: nil}

    @correct_operation_attrs %{
      title: "Elixir in action",
      operation: "new",
      amount: 5,
      goods_id: "43f7d354-912c-49f1-89fa-c127244b3ff7"
    }

    def test_goods(attrs \\ %{}) do
      {:ok, goods} =
        attrs
        |> Enum.into(@correct_attrs)
        |> Operator.add_new_good()

      goods
    end

    def test_operation(attrs \\ %{}) do
      {:ok, operation} =
        attrs
        |> Enum.into(@correct_operation_attrs)
        |> Operation.add_operation()

      operation
    end

    test "get_all_goods returns all storage" do
      goods = test_goods(@correct_attrs)
      assert Operator.get_all_goods() == [goods]
    end

    test "get_balance_goods returns storage on balance products" do
      goods = test_goods(@correct_attrs)
      assert Operator.get_balance_goods() == [goods]
    end

    test "add_new_good with correct data creates a new item in storage" do
      assert {:ok, %Storage{} = goods} = Operator.add_new_good(@correct_attrs)
      assert goods.title == "Elixir in action"
      assert goods.units_in_stock == 10
    end

    test "add_new_good with incorrect data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Operator.add_new_good(@incorrect_attrs)
    end

    test "change_goods returns a storage changeset" do
      goods = test_goods()
      assert %Ecto.Changeset{} = Operator.change_goods(goods)
    end

    test "get_goods! returns the storage with given id" do
      goods = test_goods(@correct_attrs)
      assert Operator.get_goods!(goods.id) == {:ok, goods}
    end

    test "update_goods with correct data updates the storage" do
      goods = test_goods()
      assert {:ok, %Storage{} = goods} = Operator.update_goods(goods, @update_attrs)
      assert goods.title == "Dell XPS 15"
      assert goods.units_in_stock == 10
    end

    test "update_goods with incorrect data returns error changeset" do
      goods = test_goods()
      assert {:error, %Ecto.Changeset{}} = Operator.update_goods(goods, @incorrect_attrs)
    end

    test "add_operation_note with incorrect data returns error changeset" do
      goods = test_goods(@correct_attrs)
      {:ok, operation} = Operator.add_operation_note(goods, 0, "new")

      assert Operation.get_all_operations() == [operation]
    end
  end
end
