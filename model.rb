# @!group Model

##
# Processes the purchase of medications.
# Updates the stock in the database, adds items to the previously bought list,
# and clears the user's cart.
#
# @param [SQLite3::Database] db The database connection.
# @param [Array<Integer>] array The quantities of medications to purchase.
# @param [Array<Integer>] med_id The IDs of the medications to purchase.
# @return [void]
#
# @raise [RuntimeError] If there is not enough stock for a medication.
def buy(db, array, med_id)
  # Fetch previously bought items for the user
  previously_bought = db.execute("SELECT * FROM previously_bought WHERE user_id = ?", session[:user_id])

  med_id.each_with_index do |med_id, index|
    bought = false

    if med_id > 0
      # Check if the item was already bought
      previously_bought.each do |items|
        if items[1] == med_id
          bought = true
          break
        end
      end

      # Add to previously_bought if not already bought
      unless bought
        db.execute('INSERT INTO previously_bought (user_id, med_id) VALUES (?,?)', [session[:user_id], med_id])
      end

      # Subtract the number of meds bought from the stock
      quantity_bought = array[index].to_i
      current_stock = db.execute('SELECT stock FROM meds WHERE id = ?', [med_id]).first&.dig(0).to_i
      new_stock = current_stock - quantity_bought

      if new_stock >= 0
        db.execute('UPDATE meds SET stock = ? WHERE id = ?', [new_stock, med_id])
      else
        raise "Not enough stock for medication ID #{med_id}"
      end
    end
  end

  # Clear the user's cart
  db.execute('DELETE FROM cart WHERE user_id = ?', session[:user_id])
end

##
# Logs in the user by verifying the username and password.
# Sets session variables for the user and admin status.
#
# @param [String] username The username entered by the user.
# @param [String] password The password entered by the user.
# @return [String] The route to redirect to after login.
#
# @example Successful login
#   login_user("john_doe", "password123") # => "/"
#
# @example Failed login
#   login_user("john_doe", "wrong_password") # => "/login"
def login_user(username, password)
  p username
  p password
  db = SQLite3::Database.new("db/db.db")
  db.results_as_hash = true
  results = db.execute("SELECT * FROM users WHERE username = ?", [username])
  p !results.nil?
  p results
  p results[0]["passw"]
  if !results.nil?
      hashed_password = results[0]["passw"]
      p "Hashed password from DB: #{hashed_password}"

      if BCrypt::Password.new(hashed_password) == password
          session[:user_id] = results[0]["id"]
          p session[:user_id]
          p results[0]["access"]
          if results[0]["access"] == 1
              session[:admin] = true
          end
          flash[:notice] = "Welcome back! #{username}"
          return "/"
      else
          flash[:notice] = "Oops! Something went wrong, please try again!"
          return "/login"
      end
  else
      flash[:notice] = "Oops! Something went wrong, please try again!"
      return "/login" 
  end
end

##
# Checks if the user is logged in.
#
# @return [Boolean] `true` if the user is logged in, `false` otherwise.
#
# @example
#   loggedIn() # => true
def loggedIn()
  return !session[:user_id].nil?
end

##
# Ensures the user is logged in.
# Redirects to the login page if the user is not logged in.
#
# @return [void]
#
# @raise [Sinatra::NotFound] Redirects to `/login` if the user is not logged in.
def isLoggedIn()
  if session[:user_id].nil?
    flash[:notice] = "You must be logged in to access this page."
    redirect('/login')
  end
end

##
# Checks if the user is an admin.
#
# @return [Boolean] `true` if the user is an admin, `false` otherwise.
#
# @example
#   isAdmin() # => true
def isAdmin()
  return session[:admin] == true
end