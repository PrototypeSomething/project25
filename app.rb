require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/flash'
require 'sinatra/reloader'
require 'bcrypt'
require_relative "model.rb"
require_relative "logic.rb"

enable :sessions


get ('/') do
  isLoggedIn()
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  meds = db.execute("SELECT * FROM meds") # WHERE id = ?",id)
  cart = db.execute("SELECT * FROM cart") # WHERE id = ?",id)
  p cart
  # p meds
  slim(:home, locals:{meds:meds, cart:cart})
end

get ('/cart') do
  isLoggedIn()
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  meds = db.execute("SELECT * FROM meds") # WHERE id = ?",id)
  cart = db.execute("SELECT * FROM cart") # WHERE id = ?",id)
  slim(:cart, locals:{meds:meds, cart:cart})
end

get ('/signup') do
  slim(:signup)
end

get ('/login') do
  slim(:login)
end

post ('/login') do
  p params[:username]
  p params[:password]
  redirect(login_user(params[:username], params[:password]))
end

post ('/logout') do
  session[:user_id] = nil
  session[:admin] = nil
  flash[:notice] = "You have been logged out."
  redirect('/login')
end

get ('/account') do
  isLoggedIn()
  db = SQLite3::Database.new('db/db.db')
  meds = db.execute("SELECT * FROM meds")
  previously_bought = (db.execute("SELECT * FROM previously_bought"))
  slim(:account, locals:{previously_bought:previously_bought, meds:meds})
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
    "Passwords didn't match ):"
  end
end

get ('/newmed') do
  isLoggedIn()
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
  db.results_as_hash = true
  i = 0
  if number >= 0
    while i < number
      db.execute('INSERT INTO cart (user_id, med_id) VALUES (?,?)', [session[:user_id], med_id])
      i += 1
    end
  elsif number < 0
    # while i > number
      # db.execute('INSERT INTO cart (user_id, med_id) VALUES (?,?)', [session[:user_id], med_id])
      p duplicates = db.execute('SELECT id FROM cart WHERE user_id = ? AND med_id = ? LIMIT ?', [session[:user_id], med_id, number.abs])
      # db.execute('DELETE FROM cart (user_id, med_id) VALUES (?,?)', [session[:user_id], med_id])
      duplicates.each do |row|
        db.execute('DELETE FROM cart WHERE id = ?', [row['id'].to_i])
      end
      i -= 1
    # end
  end
  flash[:notice] = "Aja baja din lilla jävel"
  redirect('/')
end

post ('/cart/buy') do
  meds = to_array(params[:antal])
  med_id = to_array(params[:med_id])
  # number = params[:antal].to_i
  # puts med_id
  # p meds
  # puts meds
  # p med_id
  
  db = SQLite3::Database.new('db/db.db')

  buy(db, meds, med_id)

  # db = SQLite3::Database.new('db/db.db')
  # i = 0
  # while i < number
  #   db.execute('INSERT INTO cart (user_id, med_id) VALUES (?,?)', [session[:user_id], med_id])
  #   i += 1
  # end
  redirect('/cart')
end