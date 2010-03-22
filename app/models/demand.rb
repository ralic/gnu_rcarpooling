# Copyright (C) 2010  Roberto Maestroni
#
# This file is part of Rcarpooling.
#
# Rcarpooling is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rcarpooling is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero Public License for more details.
#
# You should have received a copy of the GNU Affero Public License
# along with Rcarpooling.  If not, see <http://www.gnu.org/licenses/>.

class Demand < ActiveRecord::Base

  has_one :fulfilled_demand, :dependent => :nullify


  belongs_to :suitor,
      :foreign_key => "suitor_id",
      :class_name => "User"


  belongs_to :departure_place,
      :foreign_key => "departure_place_id",
      :class_name => "Place"


  belongs_to :arrival_place,
      :foreign_key => "arrival_place_id",
      :class_name => "Place"



  validates_presence_of :suitor, :departure_place, :arrival_place,
      :earliest_departure_time, :latest_arrival_time, :expiry_time


  validate :latest_arrival_time_must_be_later_than_earliest_departure_time,
      :expiry_time_must_be_earlier_than_or_equal_to_earliest_departure_time


  validate_on_create :expiry_time_must_be_later_than_5_minutes_from_now,
      :earliest_departure_time_must_be_later_than_10_minutes_from_now



  def chilled?
    fulfilled_demand && fulfilled_demand.chilled?
  end


  def fulfilled?
    fulfilled_demand && true
  end


  def expired?
    Time.now >= expiry_time
  end


  def self.find_all_not_fulfilled_and_not_expired
    result_set = []
    self.find(:all).each do |demand|
      result_set << demand if !demand.expired? and !demand.fulfilled?
    end
    result_set
  end


  private


  def latest_arrival_time_must_be_later_than_earliest_departure_time
    if latest_arrival_time and earliest_departure_time
      unless latest_arrival_time > earliest_departure_time
        errors.add(:latest_arrival_time,
                   "must be later than earliest departure time")
      end
    end
  end


  def earliest_departure_time_must_be_later_than_10_minutes_from_now
    if earliest_departure_time and !(earliest_departure_time >
                                     10.minutes.from_now)
      errors.add(:earliest_departure_time,
                 "must be later than 10 minutes from now")
    end
  end


  def expiry_time_must_be_earlier_than_or_equal_to_earliest_departure_time
    if expiry_time and earliest_departure_time
      unless expiry_time <= earliest_departure_time
        errors.add(:expiry_time,
                   "must be earlier than or " +
                   "equal to earliest departure time")
      end
    end
  end


  def expiry_time_must_be_later_than_5_minutes_from_now
    if expiry_time and !(expiry_time > 5.minutes.from_now)
      errors.add(:expiry_time, "must be later than 5 minutes from now")
    end
  end

end
