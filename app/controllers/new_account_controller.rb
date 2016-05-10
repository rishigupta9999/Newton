class QuestionAnswerPair
    attr_accessor :question
    attr_accessor :answer
    attr_accessor :action_id
end

class NewAccountController < ApplicationController   

    def initialize
        super
    end

    def home
        user_id = session[:user_id]
        actions = UserAction.where("user_id = " + user_id.to_s)

        @user = User.find(user_id)
        @num_actions = actions.count

        actions_array = actions.to_a

        @questions = Array.new
        @current_nav_selection = "nav_home"

        actions_array.each do |cur_action|

            if (cur_action.action_type == 0)
                qaPair = QuestionAnswerPair.new

                qaPair.question = Question.find(cur_action.action_id)
                qaPair.answer = QuestionAnswer.new
                qaPair.action_id = cur_action.id

                @questions << qaPair
            end
        end
    end

    def enter_answer
        questionAnswer = QuestionAnswer.new

        action = UserAction.find(params[:action_id])

        questionAnswer.question_id = action.action_id
        questionAnswer.user_id = session[:user_id]
        questionAnswer.answer_integer = params[:answer_integer]
        questionAnswer.answer_text = params[:answer_text]

        questionAnswer.save

        action.destroy

        render nothing: true
    end

    def calendar
        user_id = session[:user_id]
        @user = User.find(user_id)
        @current_party = @user.party_at_index(0); #eventually will be the current party for this user (party 0 is a hack)

        @current_nav_selection = "nav_calendar"
    end

    def stats
        @current_nav_selection = "nav_stats"
    end

    def party
        @current_nav_selection = "nav_party"
    end

    def feedback
        @current_nav_selection = "nav_feedback"
    end

    def profile
        @current_nav_selection = ""
    end

    def settings
        @current_nav_selection = ""
    end
    
end
