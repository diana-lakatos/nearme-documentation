class DNM.UI.GeoPosition
   constructor:  ->
     @observers = []
     
   register:(observer) ->
     @observers.push(observer)

   notify:  ->
     #iterate through observer and communicate new position
     _.each( @observers, (observer) =>
         observer.update(@)
     )
  
   setAddress: (address) ->
     @address = address
     @notify()

   setPosition: (position) ->
     @longitude = position.longitude
     @latitude = position.latitude
     @notify()

