require 'test_helper'

class NewAccountControllerTest < ActionController::TestCase

    def setup
        session[:user_id] = users(:steve_jobs).id
        session[:fb_info] = Hash.new({
            provider: 'facebook',
            uid: users(:steve_jobs).uid,
            info: {
              first_name: "Test",
              last_name:  "User",
              email:      users(:steve_jobs).email
            },
            credentials: {
              token: "123456",
              expires_at: Time.now + 1.week
            }
        })

        ActionMailer::Base.deliveries = []
    end


    test "Load Home Page" do
        get :home
        assert_response :success
    end

    test "No party invites" do
      # Destroy all invites...
      PartyInvite.where(dst_user_id: users(:steve_jobs).id).destroy_all

      # ...But then artifically assign a party invitation link_to to see if this gets cleaned up

      action = UserAction.new
      action.user_id = users(:steve_jobs).id
      action.action_type = UserAction.linkto_type
      action.action_id = LinkTo.get_party_invitation_link.id
      action.save

      # Similarly destroy all join party requests...
      user = User.find(users(:steve_jobs).id)
      current_party = user.get_owned_parties[user.current_party_index.to_i]

      Rails.logger.debug "foobar"
      Rails.logger.debug user.current_party_index
      Rails.logger.debug current_party

      JoinPartyRequest.where(party_id: current_party.id).destroy_all

      # ...Then artifically assign a party join request
      action = UserAction.new
      action.user_id = users(:steve_jobs).id
      action.action_type = UserAction.linkto_type
      action.action_id = LinkTo.get_request_to_join_party_link.id
      action.save

      get :home
      assert_response :success
    end

    test "Invite party member" do

      assert_difference('PartyInvite.count', 1) do
        user = users(:steve_wozniak)
        user.opt_in

        names = user.name.split(" ")

        post :submit_party_invite_request, { first_name: names[0], last_name: names[1], email: user.email }
        assert_not ActionMailer::Base.deliveries.empty?
      end

    end

    test "Invite party member no e_mail" do

      assert_difference('PartyInvite.count', 1) do
        user = users(:steve_wozniak)
        user.opt_out

        names = user.name.split(" ")

        post :submit_party_invite_request, { first_name: names[0], last_name: names[1], email: user.email }
        assert ActionMailer::Base.deliveries.empty?
      end

    end

    test "Request to join party" do

      assert_difference('JoinPartyRequest.count', 1) do
        User.find(parties(:chocolate_eaters_party).owner_user_id).opt_in

        post :request_to_join_party, { party_id: parties(:chocolate_eaters_party).id, description: "Having me in your party *is* that big of a deal"  }
        assert_not ActionMailer::Base.deliveries.empty?
      end

    end

    test "Request to join party no-mail" do

      assert_difference('JoinPartyRequest.count', 1) do
        User.find(parties(:chocolate_eaters_party).owner_user_id).opt_out

        post :request_to_join_party, { party_id: parties(:chocolate_eaters_party).id, description: "Having me in your party *is* that big of a deal"  }
        assert ActionMailer::Base.deliveries.empty?
      end

    end

end
