require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/flash'
require 'sinatra/reloader'
require 'bcrypt'
require_relative "model.rb"
require_relative "logic.rb"

enable :sessions

##
# Displays the home page.
# Fetches all medications and the user's cart from the database.
#
# @return [String] Rendered Slim template for the home page.
get ('/') do
  isLoggedIn()
  meds = fetch_all_meds()
  cart = fetch_user_cart()
  slim(:home, locals: { meds: meds, cart: cart })
end

##
# Displays the user's cart.
# Fetches all medications and the user's cart from the database.
#
# @return [String] Rendered Slim template for the cart page.
get ('/cart') do
  isLoggedIn()
  meds = fetch_all_meds()
  cart = fetch_user_cart()
  slim(:"cart/index", locals: { meds: meds, cart: cart })
end

##
# Displays the signup page.
#
# @return [String] Rendered Slim template for the signup page.
get ('users/signup') do
  slim(:"users/new")
end

##
# Displays the login page.
#
# @return [String] Rendered Slim template for the login page.
get ('/login') do
  slim(:"users/login")
end

##
# Logs in the user.
# Redirects to the appropriate page based on login success or failure.
#
# @param [String] username The username entered by the user.
# @param [String] password The password entered by the user.
# @return [String] Redirects to the appropriate route.
post ('/login') do
  redirect(login_user(params[:username], params[:password]))
end

##
# Logs out the user.
# Clears the session and redirects to the login page.
#
# @return [String] Redirects to the login page.
get ('/logout') do
  session[:user_id] = nil
  session[:admin] = nil
  flash[:notice] = "You have been logged out."
  redirect('/login')
end

##
# Displays the admin panel.
# Fetches all medications, cart items, and users from the database.
# Only accessible to admin users.
#
# @return [String] Rendered Slim template for the admin panel.
get ('/admin') do
  isLoggedIn()
  if isAdmin()
    meds = fetch_all_meds()
    cart = fetch_all_cart_items()
    users = fetch_all_users()
    slim(:"admin/index", locals: { meds: meds, cart: cart, users: users })
  else
    redirect('/')
  end
end

##
# Displays the user's account page.
# Fetches all medications and previously bought items for the user.
#
# @return [String] Rendered Slim template for the account page.
get ('/account') do
  isLoggedIn()
  meds = fetch_all_meds()
  previously_bought = fetch_user_purchases()
  slim(:"/users/index", locals: { previously_bought: previously_bought, meds: meds })
end

##
# Creates a new user.
# Hashes the password and stores the user in the database.
#
# @param [String] username The username entered by the user.
# @param [String] password The password entered by the user.
# @param [String] password_confirm The password confirmation entered by the user.
# @return [String] Redirects to the home page or displays an error message.
post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    create_user(username, password_digest)
    redirect('/')
  else
    "Passwords didn't match ):"
  end
end

##
# Displays the form to add a new medication.
# Only accessible to admin users.
#
# @return [String] Rendered Slim template for adding a new medication.
get ('/newmed') do
  isLoggedIn()
  if isAdmin()
    slim(:"meds/new")
  else
    redirect('/')
  end
end

##
# Adds a new medication to the database.
# Only accessible to admin users.
#
# @param [String] name The name of the medication.
# @param [Integer] stock The stock quantity of the medication.
# @param [String] description The description of the medication.
# @param [Float] price The price of the medication.
# @return [String] Redirects to the home page.
post ('/newmed/confirm') do
  if isAdmin()
    name = params[:name]
    stock = params[:stock]
    description = params[:description]
    price = params[:price]
    add_medication(name, stock, description, price)
  end
  redirect('/')
end

##
# Displays the delete medications page.
# Fetches all medications from the database and renders the delete page.
# Only accessible to admin users.
#
# @return [String] Rendered Slim template for the delete medications page.
# @example
#   GET /meds/delete
#   # Renders the delete.slim view with a list of medications.
get ('/meds/delete') do
  isLoggedIn()
  if isAdmin()
    meds = fetch_all_meds()
    slim(:"meds/delete", locals: { meds: meds })
  else
    redirect('/')
  end
end

##
# Deletes a medication from the database.
# Only accessible to admin users.
#
# @param [Integer] id The ID of the medication to delete.
# @return [String] Redirects to the admin page after deletion.
# @example
#   POST /meds/delete
#   # Deletes the medication with the specified ID and redirects to /admin.
post ('/meds/delete') do
  isLoggedIn()
  if isAdmin()
    delete_medication(params[:id])
    redirect('/admin')
  else
    redirect('/')
  end
end

##
# Adds items to the user's cart.
# Updates the cart in the database.
#
# @param [Integer] med_id The ID of the medication to add.
# @param [Integer] number The quantity of the medication to add.
# @return [String] Redirects to the home page.
post ('/cart/add') do
  med_id = params[:id]
  number = params[:antal].to_i
  update_cart(session[:user_id], med_id, number)
  flash[:notice] = "Cart updated."
  redirect('/')
end

##
# Processes the purchase of items in the cart.
# Updates the stock in the database and clears the cart.
#
# @param [Array<Integer>] meds The quantities of medications to purchase.
# @param [Array<Integer>] med_id The IDs of the medications to purchase.
# @return [String] Redirects to the cart page.
post ('/cart/buy') do
  meds = to_array(params[:antal])
  med_id = to_array(params[:med_id])
  process_purchase(meds, med_id)
  redirect('/cart')
end