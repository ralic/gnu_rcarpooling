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

class OfferingsController < ApplicationController

  before_filter :authenticate, :except => "new"

  # GET /offerings
  def index
    @offerer = User.find(params[:uid])
    respond_to do |format|
      format.html do
        @offerings = @offerer.offerings.paginate :page => params[:page],
          :order => 'created_at DESC', :per_page => 4
      end
      format.xml do
        @offerings = @offerer.offerings.find(:all,
                                             :order => "created_at DESC")
      end
    end
  end


  # GET /offerings/new
  def new
    @offering = Offering.new(:departure_time => 12.minutes.from_now,
                             :expiry_time => 7.minutes.from_now,
                             :seating_capacity => 4)
    @places = Place.find :all
  end


  # GET /offerings/:id
  def show
    @offering = Offering.find_by_id(params[:id])
    if @offering
      if @offering.offerer == User.find(params[:uid])
        unless @offering.in_use?
          respond_to do |format|
            format.html
            format.xml
          end
        else
          redirect_to( used_offering_url(@offering.used_offering),
                       :status => :temporary_redirect)
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end


  # POST /offerings
  def create
    @offering = Offering.new params[:offering]
    # clean some dangerous fields :P
    @offering.length = nil
    @offering.arrival_time = nil
    @offering.offerer = nil
    #
    edge = EdgeByCar.find_by_departure_place_id_and_arrival_place_id(
      @offering.departure_place_id, @offering.arrival_place_id)
    if edge
      @offering.length = edge.length
      @offering.arrival_time = @offering.departure_time +
          edge.travel_duration.minutes if @offering.departure_time
    end
    #
    @offering.offerer = User.find(params[:uid])
    #
    if @offering.save
      # now process the offering just saved :)
      # use the default notifier
      processor = OfferingProcessorFactory.build_processor
      processor.process_incoming_offering(@offering)
      #
      respond_to do |format|
        format.html do
          flash[:notice] = I18n.t('notices.offering_created')
          redirect_to offering_url(@offering)
        end
        format.xml do
          render :action => "show", :status => :created,
              :location => @offering
        end
      end
    else
      respond_to do |format|
        format.html do
          @places = Place.find :all
          render :action => "new"
        end
        format.xml do
          render :xml => @offering.errors,
              :status => :unprocessable_entity
        end
      end
    end
  end


  # DELETE /offerings/:id
  def destroy
    @offering = Offering.find_by_id(params[:id])
    if @offering
      if @offering.offerer == User.find(params[:uid])
        if @offering.in_use?
          redirect_to(used_offering_url(@offering.used_offering),
                      :status => :temporary_redirect)
        else
          unless @offering.chilled?
            processor = OfferingProcessorFactory.build_processor
            processor.revoke_offering(@offering)
            @offering.destroy
            respond_to do |format|
              format.html do
                flash[:notice] = I18n.t('notices.offering_deleted')
                redirect_to offerings_url
              end
              format.xml { head :ok }
            end
          else
            head :method_not_allowed
          end
        end
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end

end
