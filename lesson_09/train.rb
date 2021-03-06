# frozen_string_literal: true

require_relative 'manufacturer'
require_relative 'instance_counter'
require_relative 'validation'

class Train
  include Manufacturer
  include InstanceCounter
  include Validation

  regexp = /^[а-яa-z0-9]{3}-?[а-яa-z0-9]{2}$/i

  attr_accessor :speed
  attr_reader :current_station, :carriages, :number, :type
  validate :number, :presence
  validate :number, :format, regexp

  @@trains = {}

  TYPES = { passenger: 'Пассажирский', cargo: 'Грузовой' }.freeze

  def initialize(number, type)
    @number = number
    @speed = 0
    @type = TYPES[type]
    @carriages = []
    @@trains[number] = self
    register_instance
    validate!
  end

  def self.find(number)
    @@trains[number]
  end

  def stop
    @speed = 0
  end

  def stopped?
    @speed.zero?
  end

  def add_carriage(carriage)
    @carriages << carriage if stopped? && correct_carriage_type?(carriage)
  end

  def remove_carriage
    return unless stopped?

    @carriages.pop if @carriages.length > 1
  end

  def add_route(route)
    @route = route
    @current_station = @route.stations.first

    # move train to 1st station in route
    @current_station.add_train(self)
  end

  def move_forward
    return if @route.stations[current_station_index] == @route.stations.last

    @current_station.remove_train(self)
    @current_station = @route.stations[current_station_index + 1]
    @current_station.add_train(self)
  end

  def move_backward
    return if @route.stations[current_station_index] == @route.stations.first

    @current_station.remove_train(self)
    @current_station = @route.stations[current_station_index - 1]
    @current_station.add_train(self)
  end

  def next_station
    @route.stations[current_station_index + 1]
  end

  def prev_station
    @route.stations[current_station_index - 1]
  end

  def each_carriage
    return if @carriages.empty?

    @carriages.each { |carriage| yield(carriage) }
  end

  private

  # Вынесен в private, т.к. это вспомогательный метод, который не нужен в интерфейсе класса
  def current_station_index
    @route.stations.index(@current_station)
  end

  def correct_carriage_type?(carriage)
    carriage.type == @type
  end
end
