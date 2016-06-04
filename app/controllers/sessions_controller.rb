class SessionsController < ApplicationController

    def new
        redirect_to '/auth/facebook'
    end

    def create
        auth = request.env["omniauth.auth"]
        user = User.where(  :provider => auth['provider'], :uid => auth['uid']).first
        if( user.nil?)
            user = User.create_with_omniauth(auth)
            # new user, send a welcome message (btw I am pretty sure the email field should be valid #VERIFY)
            Outreach.welcome(user).deliver_now
        end

        if user.current_party_index.nil?
            user.current_party_index = 0
            user.save
        end

        session[:user_id] = user.id
        session[:fb_info] = auth.info

        redirect_to controller: 'new_account', action: 'home'
    end

    def destroy
        reset_session
        redirect_to root_url, notice => 'Signed out'
    end

    def handle_spotify_auth
        auth = request.env["omniauth.auth"]
        spotify_token = auth['credentials']['token']
        #TODO save spotify token on Newton server
        # ...


        # take player back to their home page
        redirect_to controller: 'new_account', action: 'home'
    end

end
