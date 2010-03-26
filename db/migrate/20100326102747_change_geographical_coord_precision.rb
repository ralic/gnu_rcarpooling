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

class ChangeGeographicalCoordPrecision < ActiveRecord::Migration
  def self.up
    change_column :places, :latitude, :decimal, :precision => 11,
        :scale => 8
    change_column :places, :longitude, :decimal, :precision => 11,
        :scale => 8
  end

  def self.down
    change_column :places, :latitude, :float
    change_column :places, :longitude, :float
  end
end