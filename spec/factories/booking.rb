Factory.define :booking do |b|
  b.association :user
  b.association :workplace
  b.date { Date.today }
end