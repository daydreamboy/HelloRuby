require_relative '../AbstractInterface2'

class Bicycle
  include AbstractInterface

  needs_implementation self, :change_gear, :new_value
  needs_implementation self, :speed_up, :increment

  # Some documentation on the apply_brakes method
  def apply_brakes(decrement)
    # do some work here
  end

end

class AcmeBicycle < Bicycle
end

bike = AcmeBicycle.new
bike.change_gear(1) # AbstractInterface::InterfaceNotImplementedError: AcmeBicycle needs to implement 'change_gear' for interface Bicycle!
