require_relative 'rails_env'
require 'zlib'

init_rails(:sql_logger_off => true)

def export_portion(model, batch_size, options)
  objs = model.order(:id).where("id > #{options[:id]}").limit(batch_size)
  return false if objs.empty?
  #objs.each { |e| options[:batch] << e.attributes.slice('id', 'body') }
  objs.each { |e| options[:batch] << e.body }
  options[:id] = objs.last.id 
  true
end

def export_whole_table(model, batch_size)
  options = { :batch => [], :id => 0 }
  i = 0
  while export_portion(model, batch_size, options) do
    i += batch_size
    yield options[:batch]
    options[:batch] = []
    break if i > 100000
    puts("Upload: #{i}")
  end
  #return options[:batch]
end

model = MO

File.open("my.json", "wb") { |io| 
  export_whole_table( model, 10000 ) do |data|
    data = Zlib::Deflate.deflate(data.to_json, 9)
    data_size = sprintf('%6d', data.size)
    io.write(data_size)
    io.write(data)
  end
}

puts(File.size('my.json') / 1024 / 1024)
puts('Ok')
# колотова
