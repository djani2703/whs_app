defmodule WhsAppWeb.StorageControllerTest do
  use WhsAppWeb.ConnCase

  alias WhsApp.Operator

  @correct_attrs %{title: "Elixir in action", units_in_stock: 10, reserved: 5, active: true}
  @success_blocked_attrs %{title: "Macbook Pro 16", units_in_stock: 0, reserved: 0, active: true}
  @already_blocked_attrs %{title: "Dell Xps", units_in_stock: 10, reserved: 0, active: false}
  @incorrect_attrs %{title: nil, units_in_stock: nil, reserved: nil, active: nil}

  def test_goods(attrs) do
    case Operator.add_new_good(attrs) do
      {:ok, goods} ->
        goods

      {:error, _} = error ->
        error
    end
  end

  test "not_found returns a page for undefined routes", %{conn: conn} do
    conn = get(conn, "/fsa241sl")
    assert html_response(conn, 200) =~ "Page not found.."
  end

  test "all_products returns all storage", %{conn: conn} do
    conn = get(conn, Routes.storage_path(conn, :all_products))
    assert html_response(conn, 200) =~ "All goods:"
  end

  test "balance_products returns all products on balance", %{conn: conn} do
    conn = get(conn, Routes.storage_path(conn, :balance_products))
    assert html_response(conn, 200) =~ "On balance goods:"
  end

  test "new_product redirects to the product add form", %{conn: conn} do
    conn = get(conn, Routes.storage_path(conn, :new_product))
    assert html_response(conn, 200) =~ "Add new good:"
  end

  test "create_product creates a new product in store and shows it", %{conn: conn} do
    conn = post(conn, Routes.storage_path(conn, :create_product, storage: @correct_attrs))
    %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == Routes.storage_path(conn, :show_product, id)

    conn = get(conn, Routes.storage_path(conn, :show_product, id))
    assert html_response(conn, 200) =~ "New good added successfully!"
  end

  test "create_product with incorrect params returns a form to change params values", %{
    conn: conn
  } do
    conn = post(conn, Routes.storage_path(conn, :create_product, storage: @incorrect_attrs))
    assert html_response(conn, 200) =~ "Oops, something went wrong!"
  end

  test "show_product with correct params returns product info", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :show_product, goods.id))
    assert html_response(conn, 200) =~ "Product info:"
  end

  test "show_product with incorrect id returns all products page with message", %{conn: conn} do
    conn = get(conn, Routes.storage_path(conn, :show_product, :incorrect_id))
    assert redirected_to(conn) == Routes.storage_path(conn, :all_products)
  end

  test "block_product without units in stock returns product block message", %{conn: conn} do
    goods = test_goods(@success_blocked_attrs)
    conn = get(conn, Routes.storage_path(conn, :can_block_product?, goods))
    assert redirected_to(conn) == Routes.storage_path(conn, :show_product, goods.id)

    conn = get(conn, Routes.storage_path(conn, :show_product, goods.id))
    assert html_response(conn, 200) =~ "Product blocked successfully!"
  end

  test "block_product with units in stock returns have in stock message", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :can_block_product?, goods))
    assert redirected_to(conn) == Routes.storage_path(conn, :all_products)

    conn = get(conn, Routes.storage_path(conn, :all_products))
    assert html_response(conn, 200) =~ "Cannot block product: have in stock.."
  end

  test "block_product that is already blocked returns a message that it is blocked", %{conn: conn} do
    goods = test_goods(@already_blocked_attrs)
    conn = get(conn, Routes.storage_path(conn, :can_block_product?, goods))
    assert redirected_to(conn) == Routes.storage_path(conn, :all_products)

    conn = get(conn, Routes.storage_path(conn, :all_products))
    assert html_response(conn, 200) =~ "Cannot block product: already blocked.."
  end

  test "block_product with incorrect params returns a form to change active value", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = put(conn, Routes.storage_path(conn, :block_product, goods), storage: @incorrect_attrs)
    assert html_response(conn, 200) =~ "Block product:"
  end

  test "can_add_products? with correct params returns products added msg", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :can_add_products?, goods.id))
    assert html_response(conn, 200) =~ "Add amount of product:"

    conn =
      put(conn, Routes.storage_path(conn, :add_products, goods), storage: %{add_amount: "50"})

    assert redirected_to(conn) == Routes.storage_path(conn, :show_product, goods.id)
    assert get_flash(conn, "info") == "Products added successfully!"
  end

  test "add_products with large amount returns put large msg", %{conn: conn} do
    goods = test_goods(@correct_attrs)

    conn =
      put(conn, Routes.storage_path(conn, :add_products, goods),
        storage: %{add_amount: "500000000"}
      )

    assert redirected_to(conn) == Routes.storage_path(conn, :all_products)
    assert get_flash(conn, "info") == "Large value to put products.."
  end

  test "add_products with small amount returns enter greater than 0 value", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = put(conn, Routes.storage_path(conn, :add_products, goods), storage: %{add_amount: "0"})
    assert redirected_to(conn) == Routes.storage_path(conn, :all_products)
    assert get_flash(conn, "info") == "Enter value for amount greater than 0."
  end

  test "add_products with incorrect request data returns incorrect data msg", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = put(conn, Routes.storage_path(conn, :add_products, goods))
    assert redirected_to(conn) == Routes.storage_path(conn, :all_products)
    assert get_flash(conn, "info") == "Invalid changing amount request data.."
  end

  test "can_remove_products? with correct params returns products removed msg", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :can_remove_products?, goods.id))
    assert html_response(conn, 200) =~ "Remove amount of product:"

    conn =
      put(conn, Routes.storage_path(conn, :remove_products, goods), storage: %{remove_amount: "1"})

    assert redirected_to(conn) == Routes.storage_path(conn, :show_product, goods.id)
    assert get_flash(conn, "info") == "Products removed successfully!"
  end

  test "can_reserve_products? with correct params returns products reserved msg", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :can_reserve_products?, goods.id))
    assert html_response(conn, 200) =~ "Reserve amount of product:"

    conn =
      put(conn, Routes.storage_path(conn, :reserve_products, goods),
        storage: %{reserve_amount: "1"}
      )

    assert redirected_to(conn) == Routes.storage_path(conn, :show_product, goods.id)
    assert get_flash(conn, "info") == "Products reserved successfully!"
  end

  test "api_balance_products returns all products on balance", %{conn: conn} do
    conn = get(conn, Routes.storage_path(conn, :api_balance_products))
    assert json_response(conn, 200)["ok"] == []
  end

  test "api_balance_product returns product on balance by id", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :api_balance_product, goods.id))

    assert json_response(conn, 200)["ok"] == %{
             "title" => "Elixir in action",
             "units_in_stock" => 10,
             "reserved" => 5
           }
  end

  test "api_balance_product with incorrect id returns error message", %{conn: conn} do
    conn = get(conn, Routes.storage_path(conn, :api_balance_product, :incorrect_id))
    assert json_response(conn, 200)["error"] == "Product not found.."
  end

  test "api_reserve_product returns reserved product message", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :api_reserve_product, goods.id, 5))

    assert json_response(conn, 200)["ok"] == %{
             "title" => "Elixir in action",
             "units_in_stock" => 5,
             "reserved" => 10
           }
  end

  test "api_reserve_product with incorrect id returns error message", %{conn: conn} do
    conn = get(conn, Routes.storage_path(conn, :api_reserve_product, :incorrect_id, 15))
    assert json_response(conn, 200)["error"] == "Product not found.."
  end

  test "api_reserve_product with large amount returns error message", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :api_reserve_product, goods.id, 15))
    assert json_response(conn, 200)["error"] == "Large value to reserve products.."
  end

  test "api_reserve_product with small amount returns error message", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :api_reserve_product, goods.id, 0))
    assert json_response(conn, 200)["error"] == "Enter value for amount greater than 0."
  end

  test "api_unreserve_product returns unreserved product message", %{conn: conn} do
    goods = test_goods(@correct_attrs)
    conn = get(conn, Routes.storage_path(conn, :api_unreserve_product, goods.id, 5))

    assert json_response(conn, 200)["ok"] == %{
             "title" => "Elixir in action",
             "units_in_stock" => 15,
             "reserved" => 0
           }
  end
end
