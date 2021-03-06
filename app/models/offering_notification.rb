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

class OfferingNotification < Notification

  belongs_to :offering


  validates_presence_of :offering

  validate :offerer_must_be_the_recipient


  def user
    offering && offering.offerer
  end

  private

  def offerer_must_be_the_recipient
    if offering and recipient
      unless offering.offerer == recipient
        errors.add(:offering, I18n.t('activerecord.errors.messages.' +
                    'offering_notification.offerer_must_be_the_recipient'))
      end
    end
  end

end
