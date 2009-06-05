#!/usr/bin/env ruby

# Rails Toolbox
#
# Finds the most popular Rails plugins and gems.
# See here for more information:
#   http://blog.airbladesoftware.com/2009/6/5/the-rails-toolbox

require 'rubygems'
require 'httparty'
require 'pp'

class GitHub
  include HTTParty
  format :json
  base_uri 'http://github.com/api/v2/json'
  default_params :login => 'YOUR GITHUB USERNAME',
                 :token => 'YOUR GITHUB API TOKEN'

  def self.repo_search(name)
    get("/repos/search/#{name}")['repositories']
  end

  def self.branches(user, repo)
    get("/repos/show/#{user}/#{repo}/branches")['branches']
  end

  def self.tree(user, repo, sha)
    get("/tree/show/#{user}/#{repo}/#{sha}")['tree']
  end

  def self.blob(user, repo, sha)
    get("/blob/show/#{user}/#{repo}/#{sha}", :format => :plain)
  end
end

plugins = Hash.new(0)
gems = Hash.new(0)

repos = GitHub.repo_search 'rails-templates'
repos.each do |repo|
  u, r = repo['username'], repo['name']
  puts "#{u}-#{r}"
  branches = GitHub.branches(u, r)
  next if branches.nil?
  contents = GitHub.tree(u, r, branches['master'])
  next if contents.nil?
  templates = contents.select { |c| c['type'] == 'blob' && c['name'] =~ /\.rb$/ }.map do |b|
    GitHub.blob(u, r, b['sha'])
  end.compact
  templates.each do |template|
    next if template.nil?  ## Eh?!  wvk-dynamime
    template.scan(/plugin (?:'|")(.*?)(?:'|")/) do |match|
      plugins[match.first] = plugins[match.first] + 1
    end
    template.scan(/gem (?:'|")(.*?)(?:'|")/) do |match|
      gems[match.first] = gems[match.first] + 1
    end
  end
end

pp plugins.sort_by { |name, count| -count }
pp gems.sort_by { |name, count| -count }
