# encoding: utf-8
#
# This file is a part of Redmin Agile (redmine_agile) plugin,
# Agile board plugin for redmine
#
# Copyright (C) 2011-2016 RedmineCRM
# http://www.redminecrm.com/
#
# redmine_agile is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_agile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_agile.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../test_helper', __FILE__)

class AgileVersionsControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  def setup
    RedmineAgile.create_issues

    @project_1 = Project.find(1)
    @project_2 = Project.find(2)
    @project_3 = Project.find(5)

    EnabledModule.create(:project => @project_1, :name => 'agile')
    EnabledModule.create(:project => @project_2, :name => 'agile')
    EnabledModule.create(:project => @project_3, :name => 'agile')

    @request.session[:user_id] = 1
  end

  def test_get_index
    get :index, :project_id => @project_1
    assert_response :success
    assert_template :index
  end

  def test_get_load
    xhr :get, :load, :version_type => "backlog", :version_id => "3", :project_id => "ecookbook"
    assert_response :success
  end

  def test_get_autocomplete_id
    xhr :get, :autocomplete, :project_id => "ecookbook", :q =>"#3"
    assert_response :success
    assert_match "Error 281",  @response.body
  end

  def test_get_autocomplete_text
    xhr :get, :autocomplete, :project_id => "ecookbook", :q =>"error"
    assert_response :success
    assert_match "Error 281",  @response.body
  end
  def test_get_index_with_filter
    get :index, version_params

    assert_response :success

    assert_match /Issue 108/,  @response.body
    assert_match /Blaaa/,  @response.body
    assert_match /Issue 105/,  @response.body
    assert_match /Issue 106/,  @response.body

    assert_no_match /(Issue 100)|(Issue 101)|(Issue 102)|(Issue 103)/,  @response.body
  end

  def test_get_index_with_filter_and_search_query
    get :index, version_params.merge({:q => 'Blaaa'})
    assert_template :index

    assert_no_match /Issue 108/,  @response.body
    assert_match /Blaaa/,  @response.body
  end

  def test_get_index_with_sp
    with_agile_settings "estimate_units" => "story_points" do
      get :index, :project_id => @project_2
      assert_response :success
      assert_template :index
      assert_select '.issue-card[data-id="100"] span.hours', :text => '10.00sp'
    end
  end

  private

  def version_params
    {
      :f =>['status_id'],
      :op => {'status_id' => '='},
      :v => {'status_id' => ['5']},
      :project_id => @project_2
    }
  end

end
