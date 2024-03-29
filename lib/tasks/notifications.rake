task :notify_party_administrators => :environment do

    User.where(permissions: 1).each do |cur_admin|

        stale_parties = []

        Party.where(administrator: cur_admin.id).each do |cur_party|

            party_recent_action_time = 0
            actions = nil

            # Collect all actions for the party
            cur_party.users.each do |cur_user|
                if (actions.nil?)
                    actions = cur_user.user_actions.to_a
                else
                    actions += cur_user.user_actions.to_a
                end
            end

            # Sort in descending order by creation time
            actions.sort! {|left, right| right.updated_at <=> left.updated_at}

            recent_action_time = 0

            # Find the most recent actions that aren't things like spotify actions or invites.  We're interested in new questions, or standard link_tos
            actions.each do |cur_action|

                if (cur_action.action_type == UserAction.linkto_type)
                    test_link_to = LinkTo.find(cur_action.action_id)

                    if (test_link_to.is_standard_linkto)
                        party_recent_action_time = cur_action.created_at
                        break
                    else
                        next
                    end

                else
                    party_recent_action_time = cur_action.created_at
                    break
                end
            end

            if (party_recent_action_time == 0)
                # If we're in here, then the party has no actions assigned to it (outside of the standard ones)
                # So let's see if the party is more than 2 days old

                byebug
                puts cur_party.updated_at

                delta = Time.now - cur_party.updated_at

                if (delta > 2 * 24 * 60 * 60)
                    stale_parties << { party: cur_party, updated_at: cur_party.updated_at.time }
                end
            else
                delta = Time.now - party_recent_action_time.time

                if (delta > (5 * 24 * 60 * 60))
                    stale_parties << { party: cur_party, updated_at: party_recent_action_time.time }
                end
            end
        end

        if (stale_parties.length > 0)
            Outreach.notify_stale_parties(cur_admin, stale_parties).deliver_now
        end

    end

end