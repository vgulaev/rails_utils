require_relative 'rails_env'

init_rails(:sql_logger_off => true)

def export_portion(model, batch_size, options)
  objs = model.order(:id).where("id > #{options[:id]}").limit(batch_size)
  return false if objs.empty?
  objs.each { |e| options[:batch] << e.attributes }
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

puts(dev?)