def buy(db, array, med_id)
  # p array
  i = 0
  previously_bought = db.execute("SELECT * FROM previously_bought WHERE user_id = ?", session[:user_id])
  # p to_array(previously_bought)
  # previously_bought.each do |items|
  #   p items[1] 
    # p previously_bought[][0]
    # if previously_bought[items, 0] == session[:user_id]
    # end
    # ------------------------------------------------------------WIP-----------------------------------------------------------------
  # end
  med_id.each do |med_id|
    # p med_id
    bought = false

    if med_id > 0

      previously_bought.each do |items|
        p items[1]
        if items[1] == med_id
          bought = true
        end
      end
      if !bought
        # puts "adding to db"
        db.execute('INSERT INTO previously_bought (user_id, med_id) VALUES (?,?)', [session[:user_id], med_id])
      end

    end
  end
  while i < array.length
    # puts array[i]
    i += 1
  end
end