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

class AuthenticatorFactoryMock

  def build_authenticator(account_name, password)
    AuthenticatorMock.new(account_name, password)
  end


  private

  class AuthenticatorMock

    def initialize(account_name, password)
      @account_name = account_name
      @password = password
    end


    def authenticate
      uid = User.authenticate(@account_name, @password)
      if uid
        uid # it is a known user, already signed
      else
        pu = PotentialUser.find_by_account_name_and_password(
          @account_name, @password)
        if pu
          -1
        else
          false
        end
      end
    end # method authenticate

  end # private class


end
