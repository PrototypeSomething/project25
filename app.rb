require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require_relative "model.rb"

enable :sessions


get ('/') do
  session[:user_id] = 1 #session[:id].to_i
  # @user_id = 1 #session[:id].to_i
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  meds = db.execute("SELECT * FROM meds") # WHERE id = ?",id)
  cart = db.execute("SELECT * FROM cart") # WHERE id = ?",id)
  p cart
  # p meds
  slim(:home, locals:{meds:meds, cart:cart})
end

get ('/cart') do
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  meds = db.execute("SELECT * FROM meds") # WHERE id = ?",id)
  cart = db.execute("SELECT * FROM cart") # WHERE id = ?",id)
  # cart = db.execute("SELECT * FROM cart INNER JOIN cart.med_id = meds.id WHERE user_id = ?", session[:user_id]) # WHERE id = ?",id)
  # p cart
  slim(:cart, locals:{meds:meds, cart:cart})
end

get ('/signup') do
  slim(:signup)
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/db.db')
    db.execute('INSERT INTO users (username,passw) VALUES (?,?)',[username,password_digest])
    redirect('/')
  else
    "lösenorden matchade inte ):"
  end
end

get ('/newmed') do
  slim(:newmed)
end

post ('/newmed/confirm') do
  name = params[:name]
  stock = params[:stock]
  description = params[:description]
  price = params[:price]
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  db.execute('INSERT INTO meds (name, stock, description, price) VALUES (?,?,?,?)', [name, stock, description, price])
  redirect('/')
end

post ('/cart/add') do
  med_id = params[:id]
  number = params[:antal].to_i
  p med_id
  db = SQLite3::Database.new('db/db.db')
  i = 0
  while i < number
    db.execute('INSERT INTO cart (user_id, med_id) VALUES (?,?)', [session[:user_id], med_id])
    i += 1
  end
  redirect('/')
end

post ('/cart/buy') do
  meds = params[:antal]
  # number = params[:antal].to_i
  puts meds
  # buy(meds)

  # db = SQLite3::Database.new('db/db.db')
  # i = 0
  # while i < number
  #   db.execute('INSERT INTO cart (user_id, med_id) VALUES (?,?)', [session[:user_id], med_id])
  #   i += 1
  # end
  redirect('/cart')
end