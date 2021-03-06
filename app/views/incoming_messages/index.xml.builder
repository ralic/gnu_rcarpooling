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

xml.incoming_messages(:user_id => @user.id, :user_href => user_url(@user)) do
  @incoming_messages.each do |m|
    xml.incoming_message(:id => m.id, :href => incoming_message_url(m)) do
      xml.subject(h m.subject)
      xml.sender(:id => m.sender.id, :href => user_url(m.sender))
    end
  end
end
