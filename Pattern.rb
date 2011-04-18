require 'rubygems'
require "Titleizer"

class MissingTagValue < StandardError; end
class InvalidWords < StandardError; end
class NoPatternGiven < StandardError; end

class String
  def conv_to_tag_name
    case self
    when "track"
      :track_number
    when "disc"
      :disc_number
    when "title"
      :name
    else
      self
    end
  end
  
  def conv_to_common_name
    case self
    when "track_number"
      "track"
    when "disc_number"
      "disc"
    when "name"
      "title"
    else
      self
    end
  end
  
  def punctuate
    q_words = ["who", "what", "when", "where", "how", "which", "is", "do", "can"]
    if self =~ /[-_]\z/
       q_words.include?(self.split(/\W/)[0].downcase) ? self.sub!(/([-_])\z/, "?") : self.sub!(/([-_])\z/, "!")
    else
      self
    end
  end
end

class Pattern
  attr_reader :regex
  @@regexConv = {
    "track" => '0?(\d+)',
    "title" => '(.*)',
    "album" => '(.*)',
    "artist" => '(.*)',
    "composer" => '(.*)',
    "disc" => '(?:disc\s|disk\s)?0?(\d+(?=\d{2,3}))',
    "genre" => '(.*)',
    "grouping" => '(.*)',
    "year" => '(\d{4})'
  }
  @@allowed_words = @@regexConv.keys
  
  def initialize(pattern)
    raise NoPatternGiven if pattern == ""
    pattern = pattern.downcase.split(/(\W+)/)
    
    @order, @values, @splitters = [], [], []
    pattern.each do |a|
      if a =~ /\W+/
        @order << :split
        @splitters << a
      elsif @@allowed_words.include?(a)
        @order << :val
        @values << a
      elsif joined = a.match(/(#{@@allowed_words.join("|")})(#{@@allowed_words.join("|")})/)
        joined = joined[1..-1]
        @order += [:val,:split,:val]
        @values += joined
        @splitters << ""
      else
        raise(InvalidWords, "\"#{a}\" is not an allowed value")
      end
    end

    @regex = ""
    v = 0
    s = 0
    @order.each do |a|
      if a == :val
        @regex += @@regexConv[@values[v]]
        v += 1
      else
        @regex += @splitters[s]
        s += 1
      end
    end
  end

  def match_track(track)
    tag_names = @values.map {|val| val.conv_to_tag_name.to_sym}

    answer = track.match(/#{@regex}/)[1..-1]

    answer_hash = {}
    answer.size.times do |i|
      if tag_names[i] == :track_number or tag_names[i] == :disc_number
        answer_hash[tag_names[i]] = answer[i].to_i
      elsif tag_names[i] == :name
        answer_hash[tag_names[i]] = answer[i].punctuate.titleize
      else
        answer_hash[tag_names[i]] = answer[i].punctuate.titleize
      end
    end
    
    raise(MissingTagValue, "Missing value: \"#{answer_hash.index("").to_s}\"") if answer_hash.value?("")
    
    return answer_hash
  end
end