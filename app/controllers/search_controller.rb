# -*- encoding: utf-8 -*-
class SearchController < ApplicationController
  include RoomHelper

  SEARCH_LIMIT = 20

  def index
    @rooms = search_from
  end

  def search
    if params[:search].blank? or params[:search][:message].blank?
      redirect_to :action => :index
      return
    end

    @query = params[:search][:message]
    @rooms = search_from
    @room_id = params[:room].blank? ? "" : params[:room][:id]
    if @room_id.blank?
      @results = Message.find_by_text :text => @query, :rooms => Room.all_live(current_user)
    else
      find_room(@room_id, :not_auth => true) do
        @results = Message.find_by_text(:text => @query, :rooms => [ @room ], :limit => SEARCH_LIMIT)
      end
    end
  end

  def search_more
    @messages = []
    if params[:search_message].blank? or params[:room_id].blank?
      render :template => 'chat/messages', :layout => false
      return
    end

    @last_message_id = params[:id]
    @query = params[:search_message]
    @room_id = params[:room_id]
    find_room(@room_id, :not_auth => true) do
      @results = Message.find_by_text(:text => @query, :rooms => [ @room ], :limit => SEARCH_LIMIT, :message_id => @last_message_id)
      if @results.size > 0
        @messages = @results.first[:messages]
      end
    end
    render :template => 'chat/messages', :layout => false
  end

  private
  def search_from
    Room.all_live(current_user).map {|room| [room.title, room.id]}
  end
end
