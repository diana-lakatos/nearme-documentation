String::hashCode = () ->
  @hash = 0
  if (this.length == 0)
    @hash
  for i in [0..this.length-1]
      char = this.charCodeAt(i)
      @hash = ((@hash<<5)-@hash)+char
      @hash = @hash & @hash; # Convert to 32bit integer
  @hash
