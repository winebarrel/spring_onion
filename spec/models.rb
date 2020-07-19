# frozen_string_literal: true

class Actor < ActiveRecord::Base
  self.table_name = 'actor'
  self.primary_key = 'actor_id'
end

class ActorInfo < ActiveRecord::Base
  self.table_name = 'actor_info'
  self.primary_key = 'actor_info_id'
end

class Address < ActiveRecord::Base
  self.table_name = 'address'
  self.primary_key = 'address_id'
end

class Category < ActiveRecord::Base
  self.table_name = 'category'
  self.primary_key = 'category_id'
end

class City < ActiveRecord::Base
  self.table_name = 'city'
  self.primary_key = 'city_id'
end

class Country < ActiveRecord::Base
  self.table_name = 'country'
  self.primary_key = 'country_id'
end

class Customer < ActiveRecord::Base
  self.table_name = 'customer'
  self.primary_key = 'customer_id'
end

class CustomerList < ActiveRecord::Base
  self.table_name = 'customer_list'
  self.primary_key = 'customer_list_id'
end

class Film < ActiveRecord::Base
  self.table_name = 'film'
  self.primary_key = 'film_id'
end

class FilmActor < ActiveRecord::Base
  self.table_name = 'film_actor'
  self.primary_key = 'film_actor_id'
end

class FilmCategory < ActiveRecord::Base
  self.table_name = 'film_category'
  self.primary_key = 'film_category_id'
end

class FilmList < ActiveRecord::Base
  self.table_name = 'film_list'
  self.primary_key = 'film_list_id'
end

class FilmText < ActiveRecord::Base
  self.table_name = 'film_text'
  self.primary_key = 'film_text_id'
end

class Inventory < ActiveRecord::Base
  self.table_name = 'inventory'
  self.primary_key = 'inventory_id'
end

class Language < ActiveRecord::Base
  self.table_name = 'language'
  self.primary_key = 'language_id'
end

class NicerButSlowerFilmList < ActiveRecord::Base
  self.table_name = 'nicer_but_slower_film_list'
  self.primary_key = 'nicer_but_slower_film_list_id'
end

class Payment < ActiveRecord::Base
  self.table_name = 'payment'
  self.primary_key = 'payment_id'
end

class Rental < ActiveRecord::Base
  self.table_name = 'rental'
  self.primary_key = 'rental_id'
end

class SalesByFilmCategory < ActiveRecord::Base
  self.table_name = 'sales_by_film_category'
  self.primary_key = 'sales_by_film_category_id'
end

class SalesByStore < ActiveRecord::Base
  self.table_name = 'sales_by_store'
  self.primary_key = 'sales_by_store_id'
end

class Staff < ActiveRecord::Base
  self.table_name = 'staff'
  self.primary_key = 'staff_id'
end

class StaffList < ActiveRecord::Base
  self.table_name = 'staff_list'
  self.primary_key = 'staff_list_id'
end

class Store < ActiveRecord::Base
  self.table_name = 'store'
  self.primary_key = 'store_id'
end
