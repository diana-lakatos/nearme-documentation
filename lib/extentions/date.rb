class Date
  def weekend?
    !weekday?
  end

  def weekday?
    (1..5) === wday
  end
end
