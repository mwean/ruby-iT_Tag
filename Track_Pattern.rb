require 'rubygems'
require "Titleizer"

class Track_Pattern
  attr_reader :regex
  def initialize(pattern)
    pattern = pattern.downcase.split(/(\W+)/)
    regexConv = {
    "track", '0?(\d+)',
    "title", '(.*)',
    "album", '(.*)',
    "artist", '(.*)',
    "composer", '(.*)',
    "disc", '(?:disc\s|disk\s)?0?(\d+)',
    "genre", '(.*)',
    "grouping", '(.*)',
    "year", '(\d{4})'
    }

    order = pattern.map { |a| a =~ /\W+/ ? :split : :val }
    @values = pattern.map { |a| a unless a =~ /\W+/ }.delete_if { |a| a == nil }
    splitters = pattern.map { |a| a if a =~ /\W+/ }.delete_if { |a| a == nil }

    @regex = ""
    v = 0
    s = 0
    order.each do |a|
      if a == :val
        @regex += regexConv[@values[v]]
        v += 1
      else
        @regex += splitters[s]
        s += 1
      end
    end
  end
  
  def match_track(track)
    tag_names = @values.map do |val|
      case val
      when "track"
        :track_number
      when "disc"
        :disc_number
      when "title"
        :name
      else
        val.to_sym
      end
    end

    answer = track.match(/#{@regex}/)[1..-1]
    
    answer_hash = {}
    answer.size.times do |i|
      if tag_names[i] == :track_number or tag_names[i] == :disc_number
        answer_hash[tag_names[i]] = answer[i].to_i
      elsif tag_names[i] == :name
        answer_hash[tag_names[i]] = answer[i].titleize
      else
        answer_hash[tag_names[i]] = answer[i]
      end
    end
    return answer_hash
  end
end