require 'spec_helper'

describe UsersSearchEngine do
  let(:search_engine) { UsersSearchEngine.new }
  
  it 'can search by name, nickname or email including some string ignoring capital letters' do
    user_with_first_name_starting_with_a = FactoryGirl.create(:user, first_name: 'ABEL', last_name: 'DRUNK', email: 'abel_drunk@newyorktimes.com', nickname: 'abel_drunk')
    user_with_first_name_including_with_a = FactoryGirl.create(:user, first_name: 'LIAM', last_name: 'DRUNK', email: 'liam_drunk@newyorktimes.com', nickname: 'liam_drunk')
    user_with_first_name_ending_with_a = FactoryGirl.create(:user, first_name: 'JUANA', last_name: 'DRUNK', email: 'juana_drunk@newyorktimes.com', nickname: 'juana_drunk')
    user_with_last_name_starting_with_a = FactoryGirl.create(:user, first_name: 'ERIC', last_name: 'ANTHONY', email: 'eric_anthony@newyorktimes.com', nickname: 'eric_anthony')
    user_with_last_name_including_with_a = FactoryGirl.create(:user, first_name: 'ERIC', last_name: 'HAAS', email: 'aric_haas@newyorktimes.com', nickname: 'eric_haas')
    user_with_last_name_ending_with_a = FactoryGirl.create(:user, first_name: 'ERIC', last_name: 'MADONNA', email: 'eric_maddona@newyorktimes.com', nickname: 'eric_madonna')
    user_with_email_starting_with_a = FactoryGirl.create(:user, first_name: 'JOHN', last_name: 'ZIN', email: 'a_john_zin@newyorktimes.com', nickname: 'john_zin')
    user_with_email_including_with_a = FactoryGirl.create(:user, first_name: 'JOHN', last_name: 'MILK', email: 'john_milk@milka.com', nickname: 'john_milk')
    user_with_email_ending_with_a = FactoryGirl.create(:user, first_name: 'JOHN', last_name: 'POT', email: 'john_pot@newyorktimes.aa', nickname: 'john_pot')
    user_with_nickname_starting_with_a = FactoryGirl.create(:user, first_name: 'GIN', last_name: 'ZIN', email: 'gin_zin@newyorktimes.com', nickname: 'a_gin_zin')
    user_with_nickname_including_with_a = FactoryGirl.create(:user, first_name: 'GIN', last_name: 'MILK', email: 'gin_milk@newyorktimes.com', nickname: 'gin_a_milk')
    user_with_nickname_ending_with_a = FactoryGirl.create(:user, first_name: 'GIN', last_name: 'POT', email: 'gin_pot@newyorktimes.com', nickname: 'gin_pot_a')
    user_without_a = FactoryGirl.create(:user, first_name: 'ERIC', last_name: 'DRUNK', email: 'eric_drunk@newyorktimes.com', nickname: 'eric_drunk')

    found_users = search_engine.with_name_nickname_or_email_including('a').all

    expect(found_users).not_to include user_without_a
    expect(found_users).to include user_with_first_name_starting_with_a, 
                                   user_with_first_name_including_with_a,
                                   user_with_first_name_ending_with_a,
                                   user_with_last_name_starting_with_a,
                                   user_with_last_name_including_with_a,
                                   user_with_last_name_ending_with_a,
                                   user_with_email_starting_with_a,
                                   user_with_email_including_with_a,
                                   user_with_email_ending_with_a,
                                   user_with_nickname_starting_with_a,
                                   user_with_nickname_including_with_a,
                                   user_with_nickname_ending_with_a
  end

  it 'can search users playing in a specific tournament' do
    tournament = FactoryGirl.create(:tournament)
    another_tournament = FactoryGirl.create(:tournament)
    user_playing_tournament = FactoryGirl.create(:user, rankings: [FactoryGirl.create(:ranking, tournament: tournament, points: 1, position: 1)])
    another_user_playing_another_tournament = FactoryGirl.create(:user, rankings: [FactoryGirl.create(:ranking, tournament: another_tournament, points: 1, position: 1)])

    found_users = search_engine.playing_tournament(tournament).all

    expect(found_users).to have(1).item
    expect(found_users).to include user_playing_tournament
    expect(found_users).not_to include another_user_playing_another_tournament
  end
  
  it 'can order by first name followed by last name' do
    expected_third_user = FactoryGirl.create(:user, first_name: 'C', last_name: 'C')
    expected_first_user = FactoryGirl.create(:user, first_name: 'A', last_name: 'A')
    expected_second_user = FactoryGirl.create(:user, first_name: 'A', last_name: 'B')

    found_users = search_engine.sorted_by_name.all

    expect(found_users).to have(3).items
    expect(found_users.first).to eq expected_first_user
    expect(found_users.second).to eq expected_second_user
    expect(found_users.third).to eq expected_third_user
  end
  
  it 'can order by ranking points' do
    tournament = FactoryGirl.create(:tournament)
    another_tournament = FactoryGirl.create(:tournament)

    first_user = FactoryGirl.create(:user, rankings: [
      FactoryGirl.create(:ranking, tournament: tournament, points: 1000, position: 1),
      FactoryGirl.create(:ranking, tournament: another_tournament, points: 100, position: 2)]
    )
    second_user = FactoryGirl.create(:user, rankings: [
      FactoryGirl.create(:ranking, tournament: tournament, points: 5, position: 2),
      FactoryGirl.create(:ranking, tournament: another_tournament, points: 1001, position: 1)]
    )

    found_users = search_engine.sorted_by_ranking.all

    expect(found_users.to_a).to have(2).items
    expect(found_users.first).to eq second_user
    expect(found_users.second).to eq first_user
  end
end
