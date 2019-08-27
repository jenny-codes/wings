require 'multi_json'

module Wings
  module Model
    class FileModel
      def initialize(filename)
        @filename = filename

        # if filename is 'dir/3.json', @id would be 3
        @id = File.basename(filename, '.json').to_i
        @data = MultiJson.load(File.read(filename))
      end

      def [](name)
        @data[name.to_s]
      end

      def []=(name, value)
        @data[name.to_s] = value
      end

      def self.find(id)
        begin
          FileModel.new("db/quotes/#{id}.json") # FIX
        rescue
          nil
        end
      end

      def self.all
        Dir['db/quotes/*.json'].map { |f| FileModel.new(f) }
      end

      def self.create(**attrs)
        data = {
          quote: attrs[:quote],
          submitter: attrs[:submitter],
          attribution: attrs[:attribution],
        }

        files = Dir['db/quotes/*.json']
        existing_ids = files.map { |f| File.basename(f, '.json').to_i }
        new_id = existing_ids.max + 1

        File.open("db/quotes/#{new_id}.json", 'w') do |f|
          f.write formatted_data(data)
        end

        FileModel.new "db/quotes/#{new_id}.json"
      end

      private

      def self.formatted_data data
        <<TEMPLATE
{
  "quote": "#{data[:quote]}",
  "submitter": "#{data[:submitter]}",
  "attribution": "#{data[:attribution]}" 
}
TEMPLATE
      end
    end
  end
end