require_relative 'rails_env'

init_rails(:sql_logger_off => true)

r = File.open('my.json', 'r').read
objs = JSON.parse(r)
puts(objs.size)

objs.each do |json_data|

  model = json_data['model'].constantize
  model._save_callbacks.clear
  model._commit_callbacks.clear
  model._create_callbacks.clear
  model._validation_callbacks.clear

  attribures = model.new.attributes.keys
  
  puts("load: #{json_data['model']}")
  #next if 22171 == json_data['attrs']['id']
  if model.find_by_id(json_data['attrs']['id']).nil?
    #binding.pry
    row = model.new(json_data['attrs'].slice(*attribures), {:without_protection => true})
    row.save(:validate => false)
  end
end

puts( objs.size )

puts('Hello!!!')

#ActiveRecord::Base.connection.execute("select * from group_memberships limit 10")
# ActiveRecord::Base.connection.execute("select * INTO OUTFILE '/tmp/vg_export2.txt' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\\n' from profiles where company_id=21471")