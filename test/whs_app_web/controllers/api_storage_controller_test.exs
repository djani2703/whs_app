defmodule WhsAppWeb.ApiStorageControllerTest do
  use WhsAppWeb.ConnCase

  alias WhsApp.Operator

  @correct_attrs %{title: "Elixir in action", units_in_stock: 10, reserved: 5, active: true}

  def test_goods(attrs) do
    case Operator.add_new_good(attrs) do
      {:ok, goods} ->
        goods

      {:error, _} = error ->
        error
    end
  end

  test "api_balance_products returns all products on balance", %{conn: conn} do
    conn = get(conn, Routes.api_storage_path(conn, :api_balance_products))
    assert json_response(conn, 200)["ok"] == []
  end

  test "api_balance_product returns product on balance by id", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.api_storage_path(conn, :api_balance_product, goods.id))

    assert json_response(conn, 200)["ok"] == %{
             "title" => "Elixir in action",
             "units_in_stock" => 10,
             "reserved" => 5
           }
  end

  test "api_balance_product with incorrect id returns error message", %{conn: conn} do
    conn = get(conn, Routes.api_storage_path(conn, :api_balance_product, :incorrect_id))
    assert json_response(conn, 200)["error"] == "Product not found.."
  end

  test "api_reserve_product returns reserved product message", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.api_storage_path(conn, :api_reserve_product, goods.id, 5))

    assert json_response(conn, 200)["ok"] == %{
             "title" => "Elixir in action",
             "units_in_stock" => 5,
             "reserved" => 10
           }
  end

  test "api_reserve_product with incorrect id returns error message", %{conn: conn} do
    conn = get(conn, Routes.api_storage_path(conn, :api_reserve_product, :incorrect_id, 15))
    assert json_response(conn, 200)["error"] == "Product not found.."
  end

  test "api_reserve_product with large amount returns error message", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.api_storage_path(conn, :api_reserve_product, goods.id, 15))
    assert json_response(conn, 200)["error"] == "Large value to reserve products.."
  end

  test "api_reserve_product with small amount returns error message", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.api_storage_path(conn, :api_reserve_product, goods.id, 0))
    assert json_response(conn, 200)["error"] == "Enter value for amount greater than 0."
  end

  test "api_unreserve_product returns unreserved product message", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.api_storage_path(conn, :api_unreserve_product, goods.id, 5))

    assert json_response(conn, 200)["ok"] == %{
             "title" => "Elixir in action",
             "units_in_stock" => 15,
             "reserved" => 0
           }
  end
end
