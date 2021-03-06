# encoding: utf-8
#
# This file is a part of Redmine CRM (redmine_contacts) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2011-2015 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_contacts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_contacts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_contacts.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../test_helper', __FILE__)

class AutoCompletesControllerTest < ActionController::TestCase
  fixtures :projects, :issues, :issue_statuses,
           :enumerations, :users, :issue_categories,
           :trackers,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :workflows,
           :journals, :journal_details
  fixtures :email_addresses if ActiveRecord::VERSION::MAJOR >= 4

  RedmineContacts::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts).directory + '/test/fixtures/', [:contacts,
                                                                                                                    :contacts_projects,
                                                                                                                    :contacts_issues,
                                                                                                                    :deals,
                                                                                                                    :notes,
                                                                                                                    :tags,
                                                                                                                    :taggings,
                                                                                                                    :queries])

  def setup
    RedmineContacts::TestCase.prepare

    @controller = AutoCompletesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1
  end

  def test_contacts_should_not_be_case_sensitive
    get :contacts, :project_id => 'ecookbook', :q => 'ma'
    assert_response :success
    assert_not_nil assigns(:contacts)
    assert assigns(:contacts).detect {|contact| contact.name.match /Marat/}
  end

  def test_contacts_should_accept_term_param
    get :contacts, :project_id => 'ecookbook', :term => 'ma'
    assert_response :success
    assert_not_nil assigns(:contacts)
    assert assigns(:contacts).detect {|contact| contact.name.match /Marat/}
  end

  def test_companies_should_not_be_case_sensitive
    get :companies, :project_id => 'ecookbook', :q => 'domo'
    assert_response :success
    assert_not_nil assigns(:companies)
    assert assigns(:companies).detect {|contact| contact.name.match /Domoway/}
  end

  def test_contacts_should_return_json
    get :contacts, :project_id => 'ecookbook', :q => 'marat'
    assert_response :success
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Array, json
    contact = json.last
    assert_kind_of Hash, contact
    assert_equal 2, contact['id']
    assert_equal 2, contact['value']
    assert_equal 'Marat Aminov', contact['name']
  end

  def test_companies_should_return_json
    get :companies, :project_id => 'ecookbook', :q => 'domo'
    assert_response :success
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Array, json
    contact = json.first
    assert_kind_of Hash, contact
    assert_equal 3, contact['id']
    assert_equal 'Domoway', contact['value']
    assert_equal 'Domoway', contact['label']
  end

  def test_contact_tags_should_return_json
    get :contact_tags, :q => 'ma'
    assert_response :success
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Array, json
    tag = json.last
    assert_match 'main', tag
  end

  def test_taggable_tags_should_return_json
    get :taggable_tags, :q => 'ma', :taggable_type => 'contact'
    assert_response :success
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Array, json
    tag = json.last
    assert_match 'main', tag
  end
  def test_deals_should_return_json
    get :deals, :q => 'redmine'
    assert_response :success
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Array, json
    deal = json.last
    assert_kind_of Hash, deal
    assert_equal 3, deal['id']
    assert_equal 3, deal['value']
    assert_match 'Delevelop redmine plugin', deal['label']
  end

end
