# coding: utf-8
require 'yaml'
require 'benchmark'

namespace :volte do
  desc 'Setup Volte'
  task setup: :environment do
    time = Benchmark.realtime do
      @instance = Instance.find(194)
      @instance.allowed_countries = ['Australia']
      @instance.default_country = 'Australia'
      @instance.allowed_currencies = ['AUD']
      @instance.default_currency = 'AUD'
      @instance.time_zone = 'Sydney'
      @instance.force_accepting_tos = true
      @instance.skip_company = true
      @instance.wish_lists_enabled = true
      @instance.save!
      @instance.set_context!

      setup = VolteSetup.new(@instance, File.join(Rails.root, 'lib', 'tasks', 'volte'))
      setup.create_transactable_types!
      setup.create_custom_attributes!
      setup.create_categories!
      setup.create_or_update_form_components!

      setup.set_theme_options
      setup.create_content_holders
      setup.create_liquid_views
      # setup.create_mailers
      # setup.create_smses
      setup.create_pages
      setup.create_translations

      setup.create_waiver_agreements!

      setup.create_workflow_alerts
      setup.expire_cache
      setup.add_package_to_transactables
    end

    puts "\nDone in #{time.round(2)}s\n\n"
  end

  class VolteSetup
    def initialize(instance, theme_path)
      @instance = instance
      @theme_path = theme_path
      @default_profile_type = InstanceProfileType.find(566)
    end

    def create_transactable_types!
      @instance.transactable_types.where(name: 'Fashion Item').destroy_all

      transactable_type = @instance.transactable_types.where(name: 'Item').first_or_initialize
      transactable_type.attributes = {
        name: 'Item',
        slug: 'item',
        show_path_format: '/:transactable_type_id/:id',

        default_search_view: 'list',
        skip_payment_authorization: true,
        hours_for_guest_to_confirm_payment: 24,
        single_transactable: false,
        show_price_slider: true,
        skip_location: false,
        show_categories: true,
        category_search_type: 'OR',
        bookable_noun: 'Item',
        enable_photo_required: true,
        lessor: 'Lender',
        lessee: 'Borrower',
        enable_reviews: true,
        require_transactable_during_onboarding: true
      }
      transactable_type.default_availability_template = @instance.availability_templates.where(name: '24/7').first

      transactable_type.time_based_booking ||= transactable_type.build_time_based_booking(
        enabled: true,
        cancellation_policy_enabled: '1',
        cancellation_policy_hours_for_cancellation: 24, # RT to confirm
        cancellation_policy_penalty_percentage: 30, # RT to confirm
        service_fee_guest_percent: 5,
        service_fee_host_percent: 15,
        minimum_lister_service_fee_cents: 500
      )

      transactable_type.time_based_booking.both_side_confirmation = true
      transactable_type.time_based_booking.pricings.where(unit: 'day', number_of_units: 4).first_or_initialize
      transactable_type.time_based_booking.pricings.where(unit: 'day', number_of_units: 8).first_or_initialize
      transactable_type.time_based_booking.pricings.where(unit: 'day', number_of_units: 30).first_or_initialize

      transactable_type.save!
      transactable_type.time_based_booking.save!

      fc = transactable_type.reservation_type.form_components.first
      fc.name = 'Request Item'
      fc.form_fields = [
        {'reservation' => 'start_date'},
        {'reservation' => 'price'},
        {'reservation' => 'waiver_agreements'},
        {'reservation' => 'payments'},
        {'reservation' => 'shipping_address_google'}
      ]
      fc.save
    end

    def create_waiver_agreements!
      @instance.waiver_agreement_templates.where(name: "Bond Value Terms").first_or_create!(
        content: "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean euismod bibendum laoreet. Proin gravida dolor sit amet lacus accumsan et viverra justo commodo. Proin sodales pulvinar tempor. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nam fermentum, nulla luctus pharetra vulputate, felis tellus mollis orci, sed rhoncus sapien nunc eget odio.</p>\r\n \r\n<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean euismod bibendum laoreet. Proin gravida dolor sit amet lacus accumsan et viverra justo commodo. Proin sodales pulvinar tempor. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nam fermentum, nulla luctus pharetra vulputate, felis tellus mollis orci, sed rhoncus sapien nunc eget odio.</p>\r\n \r\n<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean euismod bibendum laoreet. Proin gravida dolor sit amet lacus accumsan et viverra justo commodo. Proin sodales pulvinar tempor. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nam fermentum, nulla luctus pharetra vulputate, felis tellus mollis orci, sed rhoncus sapien nunc eget odio.</p>")
    end

    def create_custom_attributes!
      @transactable_type = TransactableType.first
      @transactable_type.custom_attributes.where(name: 'item_comments').destroy_all

      create_custom_attribute(@transactable_type, {
        name: 'item_type',
        label: 'Item Type',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Dress', 'Bag', 'Millinery', 'Outerwear', 'Accessories'],
        searchable: true,
        input_html_options: { 'data-show-field' => 'value-dependent' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_bag',
        label: 'Item Style',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Clutch', 'Hobo', 'Mini bags', 'Satchels', 'Shoulder Bags', 'Totes', 'Wallets'],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'bag' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_milinery',
        label: 'Item Style',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Fascinator', 'Hat'],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'milinery' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_outerwear',
        label: 'Item Style',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["Blazer", "Coat", "Denim", "Leather", "Fur"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'outerwear' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_dress',
        label: 'Item Style',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Bridesmaid', 'Formal', 'Races', 'Wedding', 'Guest', 'Cocktail',
          'Work Function', 'Daytime', 'Mother of the Bride', 'Evening', 'Ball',
          'Maternity', 'Bridal', 'Black Tie', 'Jumpsuit', 'Playsuit'
        ],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'dress' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_accessories',
        label: 'Item Subtype',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Necklace', 'Belt', 'Other'],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'accessories' }
      })


      create_custom_attribute(@transactable_type, {
        name: 'dress_size',
        label: 'Dress Size',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["One size", "6", "8", "10", "12", "14", "16", "18", "20"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'dress' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'milinery_size',
        label: 'Milinery Size',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["One size", "Small", "Medium", "Large"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'milinery' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'outerwear_size',
        label: 'Outerwear Size',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["One size", "6", "8", "10", "12", "14", "16", "18", "20"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'outerwear' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'dress_length',
        label: 'Dress Length',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["Mini", "Knee Length", "Midi", "Floor Length"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'dress' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'color',
        label: 'Color',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: [
          "Black", "Brown", "Blue", "Cream", "Gold", "Green", "Grey", "Navy", "Orange", "Pink",
          "Print", "Purple ", "Red", "Silver", "White", "Yellow", "Assign your own color"
        ],
        searchable: true
      })

      create_custom_attribute(@transactable_type, {
        name: 'designer_name',
        label: 'Item Designer',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: [
          "321", "1 by O2nd", "10 Crosby Derek Lam", "11 By Boris Bidjan Saberi", "22/4 by Stephanie Hahn", "3.1 Phillip Lim", "4.collective", "5 Preview", "A Lange & Sohn", "A.F. Vandevorst", "A.L.C.", "A.P.C.", "Aamaya by Priyanka", "ABS by Allen Schwartz", "Abyss by Abby", "Ace of Something", "Acne Studios", "Adam", "Adam Heath", "Adam Lippes", "Adeam", "Adelyn Rae", "Adorn Collection", "Adrianna Pappell", "Adrienne Landau", "Ae'lkemi", "Agnona", "Aje", "Akin by Ginger & Smart", "Akira", "Alala New", "Alamour", "Alannah Hill", "Alberta Ferretti", "Alessandra Rich", "Alex Perry", "Alexander McQueen", "Alexander Wang", "Alexis", "Alexis Bittar", "Ali Ro", "Alice + Olivia", "Alice and Olivia", "Alice by Temperley", "Alice McCall", "Alin Le Kal", "Allanah Hill", "Allison Parris", "Allport Millinery", "Ally Capellino", "Alonova", "Altuzarra", "Alyx", "Amanda Dudley Millinery", "Amanda Uprichard", "Amelie Pichard", "And Re Walker", "Andrea Incontri", "Angela Menz Millinery", "Anine Bing", "Aniseh Fakhri", "Ann Demeulemeester", "Anna Campbell", "Anna Scholz", "Anna Sui", "Anndra Neen", "Anne Klein", "Antonino Valenti", "Antonio Berardi", "Antonio Grimaldi", "Antonio Marras", "Anya Hindmarch", "Area Di Barbara Bologna", "Armani", "Armani Collezioni", "Armani Exchange", "Ash", "Ashish", "Asilio", "Assali", "Astr", "Atmos&Here", "Audemars Piguet", "August Street", "Aurelio Costarella", "Avanblanc", "Ayr", "Azzedine Alaia", "B May", "Backstage", "Badgley Mischka", "Badley Mischka", "Bailey 44", "Baja East", "Balenciaga", "Bally", "Balmain", "Bao Bao Issey Miyake", "Barbara Bui", "Bariano", "Bark", "BB Dakota", "BCBGMAXAZRIA", "Bec & Bridge", "Bell & Ross", "Benedetta Bruzziches", "Bertoni 1949", "Bianca Spender", "Bibhu Mohapatra", "Bill Hicks", "Bionda Castana", "Black Halo", "Blancpain", "Bless’ed are the Meek", "Blumarine", "Body Frock", "Bojena King", "BOLLÉ", "Bonita", "Borbonese", "Bottega Veneta", "Boutique Moschino", "Breitling", "Bremont", "Brixton", "Bronx and Banco", "Brother Vellies", "Brunello Cucinelli", "Buccellati", "Building Block", "Burberry", "Bvlgari", "By Johnny", "By Malene Birger", "By Nicola", "C/MEO Collective", "C&M", "Calvin Klein", "Calvin Klein Collection", "Camilla", "Camilla and Marc", "Candela", "Carla Murley", "Carla Zampatti", "Carlos Miele", "Carmen Marc Valvo", "Carole Maher", "Caroline Constas", "Caroline Herrera", "Cartier", "Cartier Vintage", "Carven", "Casio", "Catherine Deane", "Cedric Charlier", "Celine", "Celine Collard", "Cerrone", "Cesare Paciotti", "Chalayan", "Chan Luu", "Charlotte Olympia", "Cherevichkiotvichki", "Chiara Ferragni", "Chloe", "Chopard", "Chris Benz", "Christian Dior", "Christian Esber", "Christian Louboutin", "Christian Pellizzari", "Christian Siriano", "Christopher Kane", "Christopher Raeburn", "Cityshop", "Claudie Pierlot", "Closed", "Clover Canyon", "Coach", "Collection", "COmme Des Garcons", "Contrarian", "Corey", "Cue", "Current / Elliot", "Cushnie Et Ochs", "Cut 25", "Cutuli Cult", "Cynthia Rowley", "Cynthia Steffe", "Damir Doma", "Danica Erard Millinery", "Daniel Avakian", "Daniel Wellington", "Dannijo", "David Koma", "David Lawrence", "David Meister", "Deadly Ponies", "Delphine Delafon", "Delpozo", "Derek Lam", "Derek Lam 10 Crosby", "Desa 1972", "Design Studio", "Designinverso", "Diamond Emporium", "Diane Von Furstenberg", "Diesel", "Dion Lee", "Dior", "DKNY", "Dolce & Gabbana", "Dominic Louis", "Donna Karan New York", "Donna Tobin", "Dooney & Bourke", "Dsquared2", "Easton Pearson", "Eastpak", "Echo", "Eddie Borgo", "Edie Parker", "Eileen Kirby", "Elena Ghisellini", "Elie Saab", "Elie Tahari", "Elizabeth and James", "Elle Zeitoune", "Ellery", "Elliatt", "Eloquii", "Emanuel Ungaro", "Emilio Pucci", "Emma Cook", "Emporio Armani", "Equipment", "Erdem", "Erika Cavallini", "Erin Fetherston", "Ermanno Gallamini", "Escada", "Esmondo", "Etoile Isabel Marant", "Etro", "Etudes Studio", "Eugenia Kim", "Eva Franco", "Eytys", "Fabiana Filippi", "Fairfax & Roberts", "Faith Connexion", "Fay", "Fendi", "Ferrari", "Festina", "Figue", "Fillies Collection", "Finders Keepers", "Fiona by Fiona Powell", "Flannel", "Folli Follie", "For Love and Lemons", "Ford Millinery", "Forte Couture", "Fossil", "Franchi", "Free People", "French Connection", "Furla", "Gabriela Cadena", "Galanni", "Galleria Couture", "Galvan", "Gedebe", "George", "Getting back to square one", "Giamba", "Giambattista Valli", "Giancarlo Petriglia", "Giles", "Ginger & Smart", "Giorgio Armani", "Givenchy", "Golden Goose Deluxe Brand", "Grace & Hart", "Grace and Blaze", "Grace Loves Lace", "Graff", "Greg Lauren", "Gregory Ladner", "Greylin", "Gucci", "Guidi", "Guild Prime", "H the label", "Halston Heritage", "Hansen and Gretel", "Harry Winston", "Hatmaker", "Haus", "Haute Hippie", "Hayward", "Helen Kaminski", "Helmut Lang", "Henrik Vibskov", "Henry Roth", "Henson", "Hermes", "Herschel Supply Co", "Herve Leger", "Hogan", "Holland Cooper", "Honor", "House of Holland", "House of Voltaire", "Htc Hollywood Trading Company", "Hugo Boss", "Hunter Bell", "Iceberg", "Igigi", "INTER-PRET-US", "Isaac Reina", "Isabel Benenato", "Isabel Marant", "Issa", "Issey Miyake", "IWC Schaffhausen", "J.Mendel", "J.O.A.", "J.W.Anderson", "J’Aton Couture", "Jacquemus", "Jaeger - LeCoultre", "Jamin Puech", "Jan Logan", "Jane Taylor", "Jason Wu", "Jay Godfrey", "Jayson Brunsdon", "Jenni Kayne", "Jenny Packham", "Jeremy Scott", "Jerome Dreyfuss", "Jil Sander", "Jill & Jack Millinery", "Jill Jill Stuart", "Jimmy Choo", "Jocelyn", "Jocelyn Outerwear", "Joesph", "Joie", "Jonathan Howard", "Jonathan Simkhai", "Joseph", "Josh Goot", "Joshua Sanders", "Josie Natori", "Jovani", "Joyrich", "Julia Jordan", "Julie Fleming", "Junarose", "Just Cavalli", "Kacey Devlin", "Kael Lagerfield", "Kailis", "KAREN WALKER", "Karen Zambos", "Karina Grimaldi", "Karl Donoghue", "Karl Lagerfeld", "Karla Spectic", "Karolina Zmarlak", "Kate Spade", "Kate Spade New York", "Kate Sylvester", "KAUFMANFRANCO", "Kay Unger", "Kayu", "Keely Hunter Millinery", "Keepsake the Label", "Kenzo", "Kerrie Stanley", "Khalo", "Khirma Eliazov", "Kim Fletcher", "Kim Wiebenga Millinery", "Kookai", "Kotur", "Ksubi", "KTZ", "Kuku", "L’Autre Chose", "La Mania", "La Petite Robe di Chiara Boni", "Landero", "Langhem", "Lanveer", "Lanvin", "Laundry by Shelli Segal", "Laveer", "Lea Da Gloria", "Lee Matthews", "Lela Rose", "Les Petits Joueurs", "Life with Bird", "Likely", "Lilly Pulitzer", "Lilya", "Line + Dot", "Lisa Marie Fernandez", "Lisa Tan Millinery", "Lizzie Fortunato Jewels", "Loeffler Randall", "Loewe", "Longchamp", "Lost & Found Ria Dunn", "Louis Moinet", "Louis Vuitton Vintage", "Louise Macdonald", "Love Honour", "Love Lotus Millinery", "Love Moschino", "Love Nookie", "Loveless", "Lover", "Lovers + Friends", "Lovisa", "Lulu Guinness", "M Missoni", "M2malletier", "Ma+", "Madeleine Thompson", "Maison Margiela", "Maiyet", "Maje", "Manish Arora", "Manning Cartell", "Mansur Gavriel", "Manu Atelier", "Manurina", "Mara Hoffman", "Marc by Marc Jacobs", "Marc Jacobs", "Marchesa Notte", "Marchesa Voyage", "MARCOBOLOGNA", "Mariana Hardwick", "Marilena Romeo", "Marina Rinaldi", "Marissa Webb", "Mark & James by Badgley Mischka", "Marni", "Marsell", "Martha Medeiros", "Martin Grant", "Mary Katrantzou", "Maticevski", "Matison Stone", "Matthew Eager", "Matthew Williamson", "MAUI JIM", "Maurie & Eve", "Max Alexander", "Max Mara", "MCM", "McQ Alexander McQueen", "Megan Park", "Melissa Jackson", "Melissa Masse", "Mes Demoiselle", "Michael Kors", "Michael Kors Collection", "Michael Lo Sordo", "Michi New", "Mido", "Mignon", "Mikimoto", "Milana", "Milly", "Mimco", "Mina Perhonen", "Minkpink", "Misha", "Misha Collection", "Missoni", "MIU MIU", "ML Monique Lhuillier", "MLV", "Moncler", "Monique Lhuilier", "Monreal London", "Moreau", "Morgan and Taylor", "Morrison", "Moschino Cheap and Chic", "Movado", "MSGM", "Mt Rainer Design", "Mugler", "Mulberry", "Murley & Co Millinery", "Muveil", "Myriam Schaefer", "N.21", "Nachiket Barve", "Naeem Khan", "Nancy King", "Nanette Lepore", "Nanushka", "Narciso Rodriguez", "Natalie Bikicki", "Natalie Rolt", "Natasha Gan", "Nathalie Trad", "Needle and Thread", "Neil Barrett", "Nerinda Winter", "Newbark", "Nha Khanh", "Nicholas", "Nicholas The Label", "Nicola Finetti", "Nicole Miller", "Nicopanda", "Niels Peeraer", "Nightcap", "Nike", "Nina Ricci", "Nixon", "Noam Hanoch", "Norma Kamali", "Numero 10", "O2nd", "OAKLEY", "OAKLEY WOMEN'S", "Of Mercer", "Olay Gulsen", "Olga Berg", "Olga Berg", "Olympia Le-Tan", "Omega", "Opening Ceremony", "Orciani", "Oroton", "Oscar De La Renta", "Osman", "Oxs Rubber Soul", "Paco Rabanne", "Pallas Couture", "Pamella Roland", "Panerai", "Paper Crown", "Paris Kyne", "Parker", "Pas Pour Toi", "Pasduchas", "Paspaley", "Patek Philippe", "Paul Smith", "Pencey", "Perrin Paris", "PERSOL", "Peter Som", "Pfeiffer", "Philip Lim", "Philipp Plein", "Phillip Rhodes", "Philosophy di Lorenzo Serafini", "Piaget", "Piaget SA", "Piamita", "Pierre Balmain", "Pierre Hardy", "Pink Stitch", "Pink Tartan", "Plein Sud", "POLO", "Portia and Scarlett", "Prabal Gurung", "Prada", "PRADA LINEA ROSSA", "Pramma", "PREEN", "Preen by Thornton Bregazzi", "Privacy Please", "Proenza Schouler", "Qwstion", "Rachel Comey", "Rachel Gilbert", "Rachel Roy", "Rachel Zoe", "Rag & Bone", "RALPH", "Ralph Lauren", "Raoul", "Rauwolf", "RAY-BAN", "RAY-BAN JR.", "Razak", "Realisation Par", "Reality Studio", "Rebecca Minkoff", "Rebecca Share Milliner", "Rebecca Taylor", "Rebecca Valance", "Red Valentino", "Reem Acra", "Reformation", "Reny Kestel Millinery", "Richard Nylon", "Rick Owens", "Robert Cavalli", "Robert Rodriguez", "Roberto Cavalli", "Rochas", "Rocio", "Rodeo Show", "Roksanda", "Roland Mouret", "Rolex", "Romance was born", "Ronny Kobo", "Rosendorff", "Rosetta Getty", "Rula Galayini", "RVN", "Ryan Lo", "S. Rush Millinery", "Sachin & Babi", "Saint Laurent", "Saloni", "Salvatore Ferragamo", "Samantha Wills", "Samantha Wynne", "Sandro", "Santoni", "Sara Battaglia", "Sara Phillips", "Sarah’s Bag", "Sass", "Sass & Bide", "Sassy Millinery", "Savas", "Saylor", "Scanlan and Theodore", "Scanlan Theodore", "SEAFOLLY", "Secret Weapons", "Seduce", "See By Chloe", "Seiko", "Self Portrait", "Sensi Studio", "Serapian", "Serena Lindeman Millinery", "SERENGETI", "Sergio Rossi", "Serpui", "Shakuhachi", "Sheike", "Sherri Hill", "Shinola", "Shona Joy", "Shoshanna", "Simone Rocha", "Sir the Label", "Slate & Willow", "Smythe", "Smythson", "Societe Anonyme", "Solace London", "Sonia Rykiel", "Sophia Webster", "Sophie Beale Millinery", "Sophie Hulme", "Sophie Theallet", "SPY", "ST by Olcay Gulsen", "Stand Leather", "Staple the Label", "Status Anxiety", "Steele", "Steffen Schraut", "Stella McCartney", "Steph Audino", "Stephanie Spencer Millinery", "Steven Khalil", "Stone Cold Fox", "Studio Aniss", "Studio Minc", "Stylestalker", "Suboo", "Suno", "Swarovski", "T by Alexander Wang", "Taboo Millinery", "Tadashi Shoji", "TAG Heuer", "Talitha", "Tanya Tayor", "Tart Collections", "Tarvydas", "Ted Baker", "Telfar", "Temperley London", "Thakoon", "The Cambridge Satchel Company", "The Cartel", "The Jetset Diaries", "The Row", "The Volon", "Theia", "Theodora and Callum", "Theory", "Theyskens Theory", "Thom Browne", "Thomas Wylde", "Thurley", "Tibi", "Tiffany & Co", "Tigerlilly", "Tod’s", "Tom Ford", "Tomas Maier", "Tomasini", "Tommy Hilfiger", "Toni Maticevski", "Tony Burch", "Torb and Reiner Millinery", "Tory Burch", "Tory Burch", "Tracy Reese", "Trina Turk", "Troubadour", "Tularosa", "Twelfth Street by Cynthia Vincent", "Twenty", "Twin-set", "Ty-Lr", "Tylr", "Ulla Johnson", "Ulysse Nardin", "Unreal fur", "Unspoken", "Vacheron Constantin", "Valas", "Valentino", "Van Clef and Arpels", "Vanessa Bruno", "Vera Bradley", "Vera Wang", "Veronica Beard", "Versace", "Versace Collection", "Versus", "Versus by Versace", "Victoria Beckham", "Vie la V", "Viktor & Rolf", "Viktoria and Woods", "Viktoria Novak", "Vince", "Vionnet", "Vivienne Westwood Anglomania", "Vivinenne Westwood", "VOGUE EYEWEAR", "Ward & Wylie", "Waverly Grey", "Wayne Cooper", "Werkstatt München", "Wheels & Dollbaby", "White Suede", "Whiting & Davis", "William Sharp", "Willow", "Willow & Hunter", "Wish", "WXYZ Jewelry", "X by NBD", "Y-3", "Y/Project", "Yazbukey", "Yeojin Bae", "Yigal Azrouel", "Yliana Yepez", "Yoana Baraschi", "Yoshio Kubo", "Yumi Kim", "Yves Saint Laurent", "Z Spoke Zac Posen", "Zac Posen", "Zac Zac Posen", "Zachery the Label", "Zadig & Voltaire", "Zanellato", "Zhivago", "Zilla", "Zimmerman", "Zorza Goodman"
        ],
        searchable: true
      })

      create_custom_attribute(@transactable_type, {
        name: 'retail_value',
        label: 'Retail Value',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true,
        searchable: false,
        wrapper_html_options: { 'data-money-value-container' => true },
        input_html_options: { 'type' => 'number', 'data-money-value' => true }
      })

      create_custom_attribute(@transactable_type, {
        name: 'bond_value',
        label: 'Bond Value',
        attribute_type: 'integer',
        html_tag: 'input',
        required: "1",
        public: true,
        searchable: false,
        wrapper_html_options: { 'data-money-value-container' => true },
        input_html_options: { 'type' => 'number', 'data-money-value' => true }
      })

      create_custom_attribute(@transactable_type, {
        name: 'dry_cleaning',
        label: 'Dry Cleaning',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['By Lender', 'By Borrower'],
        searchable: false
      })

      # create_custom_attribute(@transactable_type, {
      #   name: 'shipping_cost',
      #   label: 'Dry Cleaning',
      #   attribute_type: 'string',
      #   html_tag: 'select',
      #   required: "0",
      #   public: true,
      #   valid_values: ['By Lender', 'By Borrower'],
      #   searchable: false
      # })

      create_custom_attribute(@default_profile_type,         name: 'contact_person_name',
                                                             label: 'Contact Person Name',
                                                             hint: 'If you provided company name in the field above, please let us know your real name here',
                                                             attribute_type: 'string',
                                                             html_tag: 'input',
                                                             required: '0',
                                                             public: true,
                                                             searchable: false)

      create_custom_attribute(@default_profile_type,         name: 'facebook_url',
                                                             label: 'Facebook URL',
                                                             attribute_type: 'string',
                                                             html_tag: 'input',
                                                             required: '0',
                                                             public: true)

      create_custom_attribute(@default_profile_type,         name: 'google_url',
                                                             label: 'Google+ URL',
                                                             attribute_type: 'string',
                                                             html_tag: 'input',
                                                             required: '0',
                                                             public: true)

      create_custom_attribute(@default_profile_type,         name: 'instagram_url',
                                                             label: 'Instagram URL',
                                                             attribute_type: 'string',
                                                             html_tag: 'input',
                                                             required: '0',
                                                             public: true)

      create_custom_attribute(@default_profile_type,         name: 'twitter_url',
                                                             label: 'Twitter URL',
                                                             attribute_type: 'string',
                                                             html_tag: 'input',
                                                             required: '0',
                                                             public: true)

      create_custom_attribute(@default_profile_type,         name: 'pinterest_url',
                                                             label: 'Pinterest URL',
                                                             attribute_type: 'string',
                                                             html_tag: 'input',
                                                             required: '0',
                                                             public: true)
    end

    def create_categories!
    end

    def create_or_update_form_components!
      TransactableType.first.form_components.destroy_all

      component = TransactableType.first.form_components.where(form_type: 'space_wizard').first_or_initialize
      component.name = 'Fill out the information below'
      component.form_fields = [
        { 'user' => 'name' },
        { 'user' => 'contact_person_name ' },
        { 'location' => 'address' },
        { 'user' => 'mobile_phone' },
        { 'transactable' => 'name' },
        { 'transactable' => 'photos' },
        { 'transactable' => 'item_type' },
        { 'transactable' => 'item_style_accessories' },
        { 'transactable' => 'item_style_bag' },
        { 'transactable' => 'item_style_dress' },
        { 'transactable' => 'item_style_milinery' },
        { 'transactable' => 'item_style_outerwear' },
        { 'transactable' => 'dress_size' },
        { 'transactable' => 'milinery_size' },
        { 'transactable' => 'outerwear_size' },
        { 'transactable' => 'dress_length' },
        { 'transactable' => 'color' },
        { 'transactable' => 'designer_name' },
        { 'transactable' => 'description' },
        { 'transactable' => 'price' },
        { 'transactable' => 'retail_value' },
        { 'transactable' => 'bond_value' },
        { 'transactable' => 'dry_cleaning' },
        { 'transactable' => 'package_details' },
        { 'transactable' => 'tags' }
      ]
      component.save!
      component = TransactableType.first.form_components.where(form_type: 'transactable_attributes').first_or_initialize
      component.name = 'Details'
      component.form_fields = [
        { 'transactable' => 'name' },
        { 'transactable' => 'location_id' },
        { 'transactable' => 'photos' },
        { 'transactable' => 'item_type' },
        { 'transactable' => 'item_style_accessories' },
        { 'transactable' => 'item_style_bag' },
        { 'transactable' => 'item_style_dress' },
        { 'transactable' => 'item_style_milinery' },
        { 'transactable' => 'item_style_outerwear' },
        { 'transactable' => 'dress_size' },
        { 'transactable' => 'milinery_size' },
        { 'transactable' => 'outerwear_size' },
        { 'transactable' => 'dress_length' },
        { 'transactable' => 'color' },
        { 'transactable' => 'designer_name' },
        { 'transactable' => 'description' },
        { 'transactable' => 'price' },
        { 'transactable' => 'retail_value' },
        { 'transactable' => 'bond_value' },
        { 'transactable' => 'unavailable_periods' },
        { 'transactable' => 'dry_cleaning' },
        { 'transactable' => 'package_details' },
        { 'transactable' => 'tags' }
      ]
      component.save!

      component = @default_profile_type.form_components.where(form_type: 'instance_profile_types').first_or_initialize
      component.form_fields = [
        { 'user' => 'name' },
        { 'user' => 'contact_person_name' },
        { 'user' => 'password' },
        { 'user' => 'email' },
        { 'user' => 'mobile_phone' },
        { 'user' => 'facebook_url' },
        { 'user' => 'google_url' },
        { 'user' => 'instagram_url' },
        { 'user' => 'twitter_url' },
        { 'user' => 'pinterest_url' },
        { 'user' => 'avatar' }
      ]
      component.save!

      component = @instance.form_components.where(form_type: 'location_attributes').first_or_initialize
      component.form_fields = [
        { 'location' => 'name' },
        { 'location' => 'address' },
        { 'location' => 'time_zone' },
        { 'location' => 'description' },
        { 'location' => 'location_type' },
        { 'location' => 'email' },
        { 'location' => 'administrator' },
        { 'location' => 'special_notes' },
        { 'location' => 'assigned_waiver_agreement_templates' }
      ]
      component.save!
    end

    def create_workflow_alerts
      Utils::DefaultAlertsCreator::ReservationCreator.new.notify_enquirer_of_lister_confirmed_with_double_confirmation!
    end

    def add_package_to_transactables
      default_package = DimensionsTemplate.find_by(name:'Briefcase')
      with_no_package = Transactable
                          .joins('left join transactable_dimensions_templates tdt on tdt.transactable_id = transactables.id')
                          .where('tdt.id is null')

      with_no_package.each do |item|
        item.dimensions_template = default_package
        item.save!
      end
    end

    def update_delivery_instace_id
      Delivery.where(instance_id: nil).update_all(instance_id: 194)
    end

    def set_theme_options
      theme = @instance.theme

      theme.color_green = '#4fc6e1'
      theme.color_blue = '#05caf9'
      theme.color_red = '#e83d33'
      theme.color_orange = '#ff8d00'
      theme.color_gray = '#333333'
      theme.color_black = '#171717'
      theme.color_white = '#ffffff'
      theme.call_to_action = 'Learn more'

      theme.contact_email = 'support@thevolte.com'

      theme.facebook_url = 'https://www.facebook.com/thevolte/'
      theme.twitter_url = 'https://twitter.com/the_volte/'
      theme.gplus_url = 'https://plus.google.com'
      theme.instagram_url = 'https://www.instagram.com/thevolte/'
      theme.youtube_url = 'https://www.youtube.com'
      theme.blog_url = '/blog'
      theme.linkedin_url = 'https://www.linkedin.com'

      #   theme.remote_favicon_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2760/favicon.png'
      #   theme.remote_icon_retina_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2761/apple-touch-icon-60_2x.png'

      theme.updated_at = Time.now
      theme.save!
    end

    def create_pages
      puts "\nCreating pages:"
      templates = get_templates_from_dir(File.join(@theme_path, 'pages'))
      templates.each do |template|
        create_page(template.name, template.body)
        puts "\t- #{template.name}"
      end
    end

    def create_content_holders
      puts "\nCreating content holders:"

      templates = get_templates_from_dir(File.join(@theme_path, 'content_holders'),         inject_pages: 'any_page',
                                                                                            position: 'head_bottom')

      templates.each do |template|
        create_content_holder(template.name, template.body, template.inject_pages, template.position)
        puts "\t- #{template.name}"
      end
    end

    def create_mailers
      puts "\nCreating mailers:"
      templates = get_templates_from_dir(File.join(@theme_path, 'mailers'))
      templates.each do |template|
        create_email(template.liquid_path, template.body)
        puts "\t- #{template.name}"
      end
    end

    def create_smses
      puts "\nCreating smses:"
      templates = get_templates_from_dir(File.join(@theme_path, 'sms'))
      templates.each do |template|
        create_email(template.liquid_path, template.body)
        puts "\t- #{template.name}"
      end
    end

    def create_liquid_views
      puts "\nCreating liquid views:"

      templates = get_templates_from_dir(File.join(@theme_path, 'liquid_views'),         partial: true)

      templates.each do |template|
        create_liquid_view(template.liquid_path, template.body, template.partial)
        puts "\t- #{template.name}"
      end
    end

    # TODO: This should support multiple locales
    def create_translations
      puts "\nTranslating:"

      transformation_hash = {
        # 'reservation' => 'offer',
        # 'Reservation' => 'Offer',
        # 'booking' => 'offer',
        # 'Booking' => 'Offer',
        'host' => 'Lender',
        'Host' => 'Lender',
        'guest' => 'Borrower',
        'Guest' => 'Borrower',
        'this listing' => 'your Item',
        'that listing' => 'your Item',
        'This listing' => 'Your Item',
        'That listing' => 'Your Item',
        # 'listing' => 'Item'
      }

      (Dir.glob(Rails.root.join('config', 'locales', '*.en.yml')) + Dir.glob(Rails.root.join('config', 'locales', 'en.yml'))).each do |yml_filename|
        en_locales = YAML.load_file(yml_filename)
        en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])

        en_locales_hash.each_pair do |key, value|
          next if value.blank?
          new_value = value
          transformation_hash.keys.each do |word|
            new_value = new_value.gsub(word, transformation_hash[word])
          end
          if value != new_value
            t = Translation.find_or_initialize_by(locale: 'en', key: key, instance_id: @instance.id)
            t.value = new_value
            t.skip_expire_cache = true
            t.save!
            print '.'
            $stdout.flush
          end
        end
      end

      locales = YAML.load_file(File.join(@theme_path, 'translations', 'en.yml'))

      unless locales['en'].nil?
        locales_hash = convert_hash_to_dot_notation(locales['en'])

        locales_hash.each_pair do |key, value|
          create_translation(key, value, 'en')
          print '.'
          $stdout.flush
        end
      end

      puts "\n"
    end

    def expire_cache
      puts "\nClearing cache..."
      CacheExpiration.send_expire_command 'InstanceView', instance_id: @instance.id
      CacheExpiration.send_expire_command 'Translation', instance_id: @instance.id
      CacheExpiration.send_expire_command 'CustomAttribute', instance_id: @instance.id
      Rails.cache.clear
    end

    private

    def convert_hash_to_dot_notation(hash, path = '')
      hash.each_with_object({}) do |(k, v), ret|
        key = path + k

        if v.is_a? Hash
          ret.merge! convert_hash_to_dot_notation(v, key + '.')
        else
          ret[key] = v
        end
      end
    end

    def get_templates_from_dir(template_folder, defaults = {})
      template_files = Dir.entries(template_folder).select { |e| File.file?(File.join(template_folder, e)) && e != '.keep' }
      template_files.map! { |filename| load_file_with_yaml_front_matter(File.join(template_folder, filename), defaults) }
    end

    def create_email(path, body)
      iv = InstanceView.where(instance_id: @instance.id, view_type: 'email', path: path, handler: 'liquid', format: 'html', partial: false).first_or_initialize
      iv.locales = Locale.all
      iv.transactable_types = TransactableType.all
      iv.body = body
      iv.save!

      iv = InstanceView.where(instance_id: @instance.id, view_type: 'email', path: path, handler: 'liquid', format: 'text', partial: false).first_or_initialize
      iv.body = ActionView::Base.full_sanitizer.sanitize(body)
      iv.locales = Locale.all
      iv.transactable_types = TransactableType.all
      iv.save!
    end

    def create_sms(path, body)
      iv = InstanceView.where(instance_id: @instance.id, view_type: 'sms', path: path, handler: 'liquid', format: 'text', partial: false).first_or_initialize
      iv.locales = Locale.all
      iv.transactable_types = TransactableType.all
      iv.body = body
      iv.save!
    end

    def create_page(path, body)
      slug = path.parameterize
      page = @instance.theme.pages.where(slug: slug).first_or_initialize
      page.path = path
      page.content = body
      page.save
    end

    def create_content_holder(name, body, inject_pages, position)
      inject_pages = [inject_pages] if inject_pages.is_a?(String)
      ch = @instance.theme.content_holders.where(
        name: name
      ).first_or_initialize

      ch.update!(content: body,
                 inject_pages: inject_pages,
                 position: position)
    end

    def create_translation(key, value, locale)
      @instance.translations.where(
        locale: locale,
        key: key
      ).first_or_initialize.update!(value: value)
    end

    def create_liquid_view(path, body, partial)
      iv = InstanceView.where(
        instance_id: @instance.id,
        path: path
      ).first_or_initialize
      iv.update!(transactable_types: TransactableType.all,
                 body: body,
                 format: 'html',
                 handler: 'liquid',
                 partial: partial,
                 view_type: 'view',
                 locales: Locale.all)
    end

    def load_file_with_yaml_front_matter(path, config = {})
      body = File.read(path)
      regex = /\A---(.|\n)*?---\n/

      # search for YAML front matter
      yfm = body.match(regex)
      if yfm
        config = config.merge(YAML.load(yfm[0]))
        body.gsub!(regex, '')
      end
      config = config.merge(body: body)

      config['liquid_path'] ||= File.basename(path, '.*').gsub('--', '/')
      config['name'] ||= File.basename(path, '.*').gsub('--', '/').humanize.titleize
      config['path'] ||= path

      OpenStruct.new(config)
    end

    def create_custom_attribute(object, hash)
      hash = hash.with_indifferent_access
      ca = object.custom_attributes.where(name: hash.delete(:name)).first_or_initialize
      ca.assign_attributes(hash)
      ca.save!
    end
  end
end
