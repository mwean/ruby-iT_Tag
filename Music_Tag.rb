require 'rubygems'
require 'appscript'
require 'OSAX'
require 'Pattern'

cocoaD = "./CocoaDialog.app/Contents/MacOS/CocoaDialog"

sa = OSAX.osax
genres_w_composers = ["classical", "ballet"]

tracks = Appscript.app("iTunes").selection.get
Appscript.app("iTunes").fixed_indexing.set(true)
# Appscript.app("iTunes").activate

# begin
#   input = sa.display_dialog("Enter name pattern:\nTitle, Artist, Album, Track, Disc, Composer, Genre, Grouping, Year", :buttons => ["Cancel", "Ok"], :default_button => 2, :default_answer => "track - title")[:text_returned]
# rescue
#   exit
# end
input = "track title"
pattern = Pattern.new(input)

pos_tags = %w{album album_artist artist comment composer disc_number track_number genre year grouping}

match_result = []
exstng_name = []
tracks.each do |track|
  tName = track.name.get
  exstng_name << tName
  pat_match = pattern.match_track(tName)
  existing_tags = {}
  pos_tags.each do |tag|
    val = track.send(tag).get
    existing_tags[tag.to_sym] = val if val != "" and val != 0
  end
  match_result << [pat_match, existing_tags]
end



i = 0
changes = ""
match_result.each do |mr|
  current = []
  newTags = []
  conflicts = []
  if mr[0].has_key?(:composer) or mr[1].has_key?(:composer)
    mr[0].delete_if {|k,v| k == :composer and !genres_w_composers.include?(v)}
    mr[1].delete_if {|k,v| k == :composer and !genres_w_composers.include?(v)}
  end
  mr[0].each {|a,b| current << "#{a}: #{b}"}
  mr[1].each { |a,b|  newTags << "#{a}: #{b}"}
  mr[0].merge(mr[1]) {|key, oldV, newV| conflicts << "#{exstng_name[i]}\n\tExisting #{key}: #{oldV}, New: #{newV}\n" unless oldV == newV}
  # get longest string of current and .ljust to make into nice columns
  changes += exstng_name[i] + "\n"
  changes += "\tNew Tags: " + current.join(", ") + "\n"
  changes += "\tExisting tags: " + newTags.join(", ") + "\n"
  if conflicts.size > 0
    changes += "\n\n-----CONFLICTS-----\n"
    changes += conflicts.join("\n")
  end
  changes += "\n"
  i += 1
end

changeD = "#{changes}\nCommit changes?"
changeD.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1").gsub!(/\n/, "'\n'")
infText = "Review changes and click Yes to commit"
infText.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1").gsub!(/\n/, "'\n'")
args = "textbox --informative-text #{infText} --text #{changeD} --button1 'Yes' --button2 'No' --no-newline --title 'Pattern Matching Result'"
retag = `#{cocoaD} #{args}`

if retag == "1"
  i = 0
  tracks.each do |track|
   p mr_list = match_result[i][0].merge(match_result[i][1])
    mr_list.each do |k,v|
      track.send(k).set(v)
    end
    i += 1
  end
else
  exit
end

# Add track numbers based on order
# Add mock/stub to bypass entering in patterns
# Add old name to comments to undo, ask if it's right, then delete?
# Look up info from Freedb
# Add CocoaDialog
# Package inside Platypus
# Ask to input other values
# Keep track of errors, etc. and display before setting attributes