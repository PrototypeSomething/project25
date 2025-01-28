require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

get ('/') do
  db = SQLite3::Database.new('db/db.db')
  db.results_as_hash = true
  meds = db.execute("SELECT * FROM meds") # WHERE id = ?",id)
  p meds
  slim(:home, locals:{meds:meds})
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
  user_id = 1 #session[:id].to_i
  db = SQLite3::Database.new('db/db.db')
  db.execute('INSERT INTO cart (user_id, med_id) VALUES (?,?)', [user_id, med_id])
end