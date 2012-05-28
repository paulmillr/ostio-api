class ActiveRecord::Base
  def self.inheritance_column
    :rails_type
  end
end
