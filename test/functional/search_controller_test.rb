require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  context 'conduct search' do

    setup do
      stub_request(:get, /.*maps\.googleapis\.com.*/)
      stub_mixpanel
      FactoryGirl.create(:instance) unless Instance.first
    end

    should "not track search for empty query" do
      @tracker.expects(:conducted_a_search).never
      get :index, :q => nil
    end

    should 'track search for first page' do
      @tracker.expects(:conducted_a_search).once
      get :index, :q => 'adelaide', :page => 1

    end

    should 'not track search for second page' do
      @tracker.expects(:conducted_a_search).never
      get :index, :q => 'adelaide', :page => 2

    end

    should 'track search if ignore_search flag is set to 0' do
      @tracker.expects(:conducted_a_search).once
      get :index, :q => 'adelaide', :ignore_search_event => "0"
    end

    should 'not track search if ignore_search flag is set to 1' do
      @tracker.expects(:conducted_a_search).never
      get :index, :q => 'adelaide', :ignore_search_event => "1"
    end

    should 'not track second search for the same query' do
      @tracker.expects(:conducted_a_search).once
      get :index, :q => 'adelaide'
      get :index, :q => 'adelaide'
    end

    should 'not track second search for the different query' do
      @tracker.expects(:conducted_a_search).twice
      get :index, :q => 'adelaide'
      get :index, :q => 'auckland'
    end

  end

end

