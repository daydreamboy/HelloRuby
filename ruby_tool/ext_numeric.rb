
##
# `duration` method
# create a duration method for Numeric instance
#
# @see https://stackoverflow.com/a/1679963
#
class Numeric
  def duration
    # Note: display days/hours/minutes as integer, and display seconds as its original type
    secs  = self
    minutes  = secs.to_int / 60
    hours = minutes.to_int / 60
    days  = hours.to_int / 24

    if days > 0
      "#{days} days and #{hours % 24} hours"
    elsif hours > 0
      "#{hours} hours and #{minutes % 60} minutes"
    elsif minutes > 0
      "#{minutes} minutes and #{secs % 60} seconds"
    elsif secs >= 0
      "#{secs} seconds"
    end
  end
end