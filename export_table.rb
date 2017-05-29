require_relative 'rails_env'

init_rails(:sql_logger_off => true)

def export_portion(model, batch_size, options)
  objs = model.order(:id).where("id > #{options[:id]}").limit(batch_size)
  return false if objs.empty?
  objs.each { |e| options[:batch] << [ e.attributes ] }
  options[:id] = objs.last.id 
  true
end

def export_whole_table(model, batch_size)
  options = { :batch => [], :id => 0 }
  i = 0
  while export_portion(model, batch_size, options) do
    i += batch_size
    break if i > 10000 
    puts("Upload: #{i}")
  end
  return options[:batch]
end

model = MO

batch = export_whole_table( model, 1000 )

File.open("my.json", "w") { |io| io.write( batch.to_json ) }

puts('Ok')
=begin
def export_recursive(obj, batch, cache, level)
  return if level > 5
  obj_key = "#{obj.class}-#{obj.id}"
  return if cache.key?(obj_key)
  
  puts("#{obj_key}")
  reflections = obj.class.reflections.select do |association_name, reflection| 
    reflection.macro == :belongs_to
  end

  reflections.each_pair do |key, value|
    begin
      sub_obj = obj.send(key)
      if sub_obj.class < ActiveRecord::Base
        export_recursive(sub_obj, batch, cache, level + 1)
      end
    rescue Exception => e
    end
  end

  batch.push({ :model => obj.class.to_s, :attrs => obj.attributes })
  cache[obj_key] = obj_key
end

def export(obj)
  batch = []
  cache = {}
  obj.each do |e|
    export_recursive(e, batch, cache, 0)
  end
  return batch 
end
 
obj_for_export = []
# obj_for_export << MO.where(id: [ 849826421, 848041553, 847974677, 847974323 ]).all 
obj_for_export << MO.where(id: [ 64221733, 64221734 ]).all
stuff = export(obj_for_export)

#puts( obj )

File.open("my.json", "w") { |io| io.write( stuff.to_json ) }
=end
#puts 
