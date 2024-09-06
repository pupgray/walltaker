class LizardRoundJob < ApplicationJob
  queue_as :default

  def perform(lizard_username)
    pornbot = User.find_by(username: lizard_username)

    unless pornbot
      puts "#{lizard_username} is missing! The account could not be found, are migrations run correctly?"
      return
    end

    mascot_name = case lizard_username
                  when "PornLizardTaylor"
                    "taylor"
                  when "PornLizardWarren"
                    "warren"
                  when "PornLizardKi"
                    "ki"
                  else
                    ''
                  end

    puts "#{lizard_username} has awoken"
    links = Link.with_ability_to('can_be_set_by_lizard').is_online.joins(:user).where(user: { mascot: mascot_name }).order(Arel.sql('RANDOM()')).limit(4)

    puts "Found #{links.count} links to set this round"

    set_count = 0

    links.each do |link|
      next if link.past_links.last.present? && link.past_links.last&.created_at.after?(10.minutes.ago)

      is_user_perverted = link.user.pervert

      tags = case lizard_username
             when "PornLizardTaylor"
               if is_user_perverted
                 '~impregnation ~impregnation_request excessive_cum ~presenting_hindquarters ~cum_in_pussy ~cum_in_ass ~cum_pool score:>80 -swf'
               else
                 'public ~public_sex ~penis_milking ~public_masturbation ~free_use ~leaking_cum ~cum_on_face ~cum_on_butt ~cum_on_clothing score:>100 -swf'
               end
             when "PornLizardWarren"
               if is_user_perverted
                 'hyper ~huge_breasts ~huge_penis ~himbo ~bimbofication ~horsecock ~hyper_breasts ~udders -obese score:>70 -swf'
               else
                 '~big_penis ~big_balls close_up ~big_breasts ~plump_labia ~crotch_shot -obese -hyper ~huge_balls score:>50 -swf'
               end
             when "PornLizardKi"
               if is_user_perverted
                 '~latex ~rubber glistening_body ~bdsm ~goo_creature ~slime score:>50 -swf'
               else
                 '~massage romantic ~embrace ~cuddle ~hug ~hand_holding score:>90 -swf'
               end
             else
               ''
             end

      controller = ApplicationController.new
      results = controller.get_tag_results "order:random #{tags} -nightmare_fuel", nil, nil, link, 1
      begin
        if results[0] && results[0]['file']['url']
          result = link.update(
            HashWithIndifferentAccess.new(
              {
                post_url: results[0]['file']['url'],
                post_thumbnail_url: results[0]['sample']['url'] || results[0]['preview']['url'],
                post_description: results[0]['description'],
                set_by_id: pornbot.id,
                response_type: nil,
                response_text: nil
              }
            )
          )

          if result
            puts "Set link_id=#{link.id} to #{results[0]['file']['url']}"
            set_count += 1
            tag_string = "#{results[0]['tags']['general'].join(' ')} #{results[0]['tags']['character'].join(' ')} #{results[0]['tags']['species'].join(' ')} #{results[0]['tags']['lore'].join(' ')} #{results[0]['tags']['copyright'].join(' ')} #{results[0]['tags']['meta'].join(' ')} rating:#{results[0]['rating']}"
            PastLink.log_link(link, tag_string).save
            pornbot.set_count = pornbot.set_count.to_i + 1
            pornbot.save
          end
        end
      rescue
        puts "bad post selected, moving on"
      end
      sleep(1.second)
    end

    puts "Done! Set #{set_count} links in the end"
  end
end
