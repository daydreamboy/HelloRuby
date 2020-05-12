require_relative '../AbstractInterface'

##
# Define an interface `BicycleInterface`
class BicycleInterface
  include AbstractInterface

  # Some documentation on the change_gear method
  def change_gear(new_value)
    BicycleInterface.api_not_implemented(self)
  end

  # Some documentation on the speed_up method
  def speed_up(increment)
    BicycleInterface.api_not_implemented(self)
  end

  # Some documentation on the apply_brakes method
  def apply_brakes(decrement)
    # do some work here
    puts 'apply_brakes'
  end
end

##
# A class confirms the interface
class AcmeBicycle < BicycleInterface
end

bike = AcmeBicycle.new
bike.apply_brakes(2)
bike.change_gear(1) # AbstractInterface::InterfaceNotImplementedError: AcmeBicycle needs to implement 'change_gear' for interface Bicycle!


