require 'csv'
require 'erb'
require 'sunlight/congress'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"
contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
puts "Event manager initialized"

def validate_zipcode(zip)
  zip.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def create_directory_to_save_thank_you_letters
  Dir.mkdir("output") unless Dir.exists?("output")
  Dir.chdir("output")
end

def save_form_letter_file(form_letter, index)
  File.open("completed_form_letter#{index}.html", 'w') do |file|
    file.puts form_letter
  end
end

def generate_thank_you_letters(contents)
  template_letter = create_template_letter
  create_directory_to_save_thank_you_letters
  contents.each_with_index do |row, index|
    generate_contents(row, index, template_letter)
  end
  puts "Thank you letters completed."
end

def generate_contents(row, index, erb_template)
  name = row[:first_name]
  zipcode = validate_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_form_letter_file(form_letter, index)
end

def create_template_letter
  letter = File.read("form_letter.html")
  ERB.new letter
end

generate_thank_you_letters(contents)
