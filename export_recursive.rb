require_relative 'rails_env'

init_rails(:sql_logger_off => true)

def export_recursive(obj, batch, cache, level)
  return if level > 5
  obj_key = "#{obj.class}-#{obj.id}"
  return if cache.key?(obj_key)
  
  #puts("#{obj_key}")
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
  puts("#{obj_key}") if 0 == batch.size % 50
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
