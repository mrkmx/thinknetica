require_relative 'instance_counter'

class Station
  include InstanceCounter

  @@stations = []

  attr_reader :trains, :name

  def initialize(name)
    @name = name
    @trains = []
    @@stations << self
    register_instance
  end

  def self.all
    @@stations
  end

  def count_trains_by_type(type)
    counter = @trains.count {|t| type == t.train_type}
    puts "#{counter} #{type} trains on \"#{@name}\""
  end
  
  def add_train(train)
    @trains << train
  end

  def remove_train(train)
    @trains.delete(train)
  end
end
