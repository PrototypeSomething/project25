def buy(db, array, med_id)
  # p array
  i = 0
  previously_bought = db.execute("SELECT * FROM previously_bought WHERE user_id = ?", session[:user_id])
  p previously_bought
  previously_bought.each do |items|
    # ------------------------------------------------------------WIP-----------------------------------------------------------------
  end
  med_id.each do |med_id|
    # p med_id
    if med_id > 0
      p true
      db.execute('INSERT INTO previously_bought (user_id, med_id) VALUES (?,?)', [session[:user_id], med_id])
    end
  end
  while i < array.length
    # puts array[i]
    i += 1
  end
end