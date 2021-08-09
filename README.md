## WHS app - place where your goods keep well!

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Web
Has a user interface for working with the storage.

The following functions are available:
1) View all products in stock
2) View product info
3) Add new product to stock
4) Add the number of products
5) Remove the number of products
6) Reserve the number of products
7) View products on balance
8) View all activities

## Api
To use the API, you can send a GET request from a browser, Postman application or *nix shell.

The following APIs have been implemented:
1) Get leftovers from the warehouse. Path: /api/balance
2) Get leftovers for a specific product. Path: /api/balance/:uuid
3) Reserve the number of products. Path: /api/reserve/:uuid/:amount

where uuid - universally unique identifier, amount - quantity of item.

For example: http://localhost:4000/api/balance.