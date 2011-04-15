require 'rubygems'
require 'appscript'
require 'OSAX'

files = Appscript.app("iTunes").selection.get
Appscript.app("iTunes").fixed_indexing.set(true)

begin
pattern = sa.display_dialog("Enter name pattern:\nTitle, Artist, Album, Tracknum...", :buttons => ["Cancel", "Ok"], :default_button => 2, :default_answer => "# - track")[:text_returned].downcase.split(//)
rescue
end


files.each do |show|
  vals = show.name.get.match(/0?(\d*).0?(\d*) - (.*)/)[1..-1].to_a
  season = vals[0].to_i-1
  episode = vals[1].to_i
  title = vals[2]
  show.show.set("Objective-C Essential Training")
  show.season_number.set(season)
  show.episode_number.set(episode)
  show.name.set(title)
  show.artist.set("Lynda.com")
  show.track_number.set(episode)
end

# Add old name to comments to undo, ask if it's right, then delete?
# Look up info from Freedb