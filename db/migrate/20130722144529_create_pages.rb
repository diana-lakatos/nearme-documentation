class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :path, null: false
      t.text :content
      t.integer :instance_id
      t.string :hero_image

      t.timestamps
    end

    content = <<-MARKDOWN
Our offices, located in StartupHQ at 5th &amp; Harrison

# About

We are changing the way people work around the world. Our platform allows anyone to list and book workspace anywhere, any time. From Barcelona to Berlin, Rome to Rotterdam; the world is your workplace.

## How we began

Our founders, Michelle and Adam, have a story that goes like this:

Michelle was running her first start-up when she realized her much-too-large office with a way-too-long lease was a fat number on her fixed overhead.

While traveling overseas, she noticed how connected she could be with her team, even when she was halfway across the world. So when she returned, she shut down the office!

Now that Michelle had a virtual company, however, she encountered a new hurdle: She needed short-term, flexible office space, and she needed it fast. (Working from home in your PJs sounds dreamy, but if you've done it, you know it's not all that it's cracked up to be.)

Adam had similar troubles when opening an office in the U.S., and found that long, expensive leases had very limited options.

After a few chai teas and full-fat lattes, the two entrepreneurs realized a problem existed in the office space world that needed to be solved and they were the team to do it! Desks Near Me went live in San Francisco, California in May, 2012.

We practice what we preach by listing space at our headquarters, in addition to booking desks all over the world. Since our launch, we've been helping thousands of businesses and workers of all types. The adoption has been more than we initially hoped for.  We hope to help you too! Which brings us to &hellip;

## What we do

We offer two types of services. First, we help professionals easily find work spaces within businesses that have unused, spare space to share. Using our platform, guests can search thousands of spaces around the world, in businesses of all sizes. Private desks and offices, conference rooms, and a variety of other work spaces can be easily booked for hourly, daily, weekly, and monthly use, both online and via our mobile app.

We are also a marketplace for businesses that want to list spare space. Using our platform, they can reduce overhead, expand networks, and access tools to easily manage space rental and guests.

## Meet the team

### Michelle Regner Founder &amp; CEO

Michelle's entrepreneurial spirit first revealed itself at age 9, when she sold fruit from her parents' backyard and teamed up with her best friend, Sarah, to sell friendship bracelets to kids in the neighborhood.

Years later, she graduated from Notre Dame de Namur and went on to land a plum job in finance at Morgan Stanley. But her entrepreneurial side came knocking, and soon she left to pave her own path by launching Innercircuit, a Software-as-a-Service company. It started as a small family business, but quickly grew into a national payment and communications hub for residential property managers and renters. Michelle had found her calling.

When she's not at her desk, you can find Michelle snowboarding, running, traveling, perfecting baked goods, and most importantly spending time with her family. She doesn't believe she can do "too much."

### Adam Broadway Founder &amp; COO

Adam is a hyper-active "life addict." After leaving home at 16, he went on to start his own computer hardware and networking company by age 18. Then, at 25, he sold the computer hardware company to focus on software development. His last Software-as-a-Service company was acquired by a NASDAQ-listed multinational

When he's away from his desk, Adam paraglides, rides motorcycle safaris through Death Valley, enjoys climbing hard obstacles and thinks outside the box. As a practical joker with a serious side, Adam gets annoyed writing about himself in the third person. (Really, I do.)


### Sai Perchard Product Manager &amp; Developer

In early Fall of 2012, Sai left his hometown of Adelaide, Australia to join the Desks Near Me team in San Francisco as a developer and product manager.

Prior to working for Desks Near Me, Sai completed degrees in Law and Commerce at the University of Adelaide. During this period Sai worked in corporate finance, technology consulting, founded a startup, and freelanced as a developer in his spare time.

Now a resident of California, he enjoys biking &amp; hiking, Japanese cuisine, street photography, and going to as many electronic music shows as possible. He maintains a minimalist aesthetic &amp; philisophy.
    MARKDOWN

    instance = Instance.where(name: 'DesksNearMe').first

    tempfile = open('http://blog.desksnear.me/images/pages/startup-hq.jpg')
    file = ActionDispatch::Http::UploadedFile.new(filename: 'startup-hq.jpg', tempfile: tempfile)

    Page.create(instance: instance,
                content: content,
                path: 'about',
                hero_image: file)
  end

end
