# read file name from the cli params
file_name = ARGV[0]

# Get contents of the file
contents = IO.read(file_name)

# List of all conversion passed to gsub,
# @matcher: RegEx or String
# @replacement: String 
conversions = [
  # STUBS
  {matcher: /(\S+?).stubs\(\s*?(:.+?)\)/, replacement: 'allow(\1).to receive(\2)'}, # For Symbol
  {matcher: /(\S+?).stubs\((.+?)\)/, replacement: 'allow(\1).to receive_messages(\2)'}, # For Hash
  {matcher: /(\S+?).stub_chain\((.+?)\)/, replacement: 'allow(\1).to receive_message_chain(\2)'}, # For chained stubs

  # MOCKS
  {matcher: /(\S+?).expects\(\s*?(:.+?)\)/, replacement: 'expect(\1).to receive(\2)'}, # For Symbol
  {matcher: /(\S+?).expects\((.+?)\)/, replacement: 'expect(\1).to receive_messages(\2)'}, # For Hash

  # ANY INSTANCE
  {matcher: /(allow|expect)\((.*?)\.any_instance\)/, replacement: '\1_any_instance_of(\2)'}, # Fix any_instance for all cases

  # expect have_received .never
  {matcher: /expect\((.*?)\).to have_received(.*?)\.never/, replacement: 'expect(\1).to_not have_received\2'},

  # SIMPLE REPLACEMENTS
  {matcher: '.returns', replacement: '.and_return'},
  {matcher: '.raises', replacement: '.and_raise'},
  {matcher: '.yields', replacement: '.and_yield'},
  {matcher: '.at_least_once', replacement: '.at_least(:once)'},
  {matcher: 'any_parameters', replacement: 'any_args'},
  {matcher: 'stub_everything', replacement: 'spy'},
  {matcher: /\.in_sequence\(.*?\)/, replacement: '.ordered'},
  {matcher: /regexp_matches\((.*?)\)/, replacement: '\1'},
  {matcher: /(mock|stubs|stub)\((.*?)\)/, replacement: 'double(\2)'},
]

# Apply all conversions
conversions.each do |c|
  contents.gsub!(c[:matcher], c[:replacement])
end

# ADD rspec_only: true
contents.sub!(/(describe.+)\s(do)/, '\1, rspec_only: true \2')

# Dump all changes to file
IO.write(file_name, contents)

puts "DONE!"
