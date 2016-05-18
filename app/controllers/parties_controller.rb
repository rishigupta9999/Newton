class PartiesController < ApplicationController
  layout "creative"
  
  before_action :set_party, only: [:show, :edit, :update, :destroy]

  # GET /parties
  # GET /parties.json
  def index
    @current_nav_selection = "nav_parties"
    
    @parties = Party.all
  end

  # GET /parties/1
  # GET /parties/1.json
  def show
    @current_nav_selection = "nav_parties"
  end

  # GET /parties/new
  def new
    @current_nav_selection = "nav_parties"
    
    @party = Party.new
  end

  # GET /parties/1/edit
  def edit
    @current_nav_selection = "nav_parties"
    
    @all_events = Event.all
    #@party_events = @party.events.to_a #Event.all.to_a
    #party = Party.find(params[:id])
    #@party.events << Event.find(1)
  end

  def unregister_event
     @party = Party.find(params[:party])
     @event = Event.find(params[:event])

     @party.events.delete(@event)

     redirect_to action: 'edit', id: @party.id
  end


  # POST /parties
  # POST /parties.json
  def create
    @party = Party.new(party_params)
    respond_to do |format|
      if @party.save
        format.html { redirect_to @party, notice: 'Party was successfully created.' }
        format.json { render :show, status: :created, location: @party }
      else
        format.html { render :new }
        format.json { render json: @party.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parties/1
  # PATCH/PUT /parties/1.json
  def update
    if params[:party][:event_id].nil? == false
      @event = Event.find(params[:party][:event_id])

      #prevents double insert
      if @party.events.exists?( @event.id ) == false
        @party.events << @event
      end
    end

    respond_to do |format|
      if @party.update(party_params)
        format.html { redirect_to @party, notice: 'Party was successfully updated.' }
        format.json { render :show, status: :ok, location: @party }
      else
        format.html { render :edit }
        format.json { render json: @party.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parties/1
  # DELETE /parties/1.json
  def destroy
    @party.destroy
    respond_to do |format|
      format.html { redirect_to parties_url, notice: 'Party was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_party
      @party = Party.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def party_params
      params.require(:party).permit(:name, :description)
    end
end
