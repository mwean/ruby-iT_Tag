require 'rubygems'
require 'appscript'
require 'OSAX'
require 'Pattern'

sa = OSAX.osax

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
  mr[0].each {|a,b| current << "#{a}: #{b}"}
  mr[1].each { |a,b|  newTags << "#{a}: #{b}"}
  mr[0].merge(mr[1]) {|key, oldV, newV| conflicts << "#{exstng_name[i]}\n\tExisting #{key}: #{oldV}, New: #{newV}"}
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

retag = sa.display_dialog("Pending changes:\n#{changes}\n\nCommit changes?", :buttons => ["No", "Yes"], :default_button => 2)[:button_returned]

if retag = "Yes"
  # commit changs
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