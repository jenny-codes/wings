require 'sqlite3'
require 'wings/util'


module Wings
  module Model
    class SQLite
      DB = SQLite3::Database.new('test.db')

      def self.create(values)
        keys_without_id = schema.keys - ['id']
        formatted_vals = keys_without_id.map do |key|
          values[key] ? to_sql(values[key]) : 'null'
        end

        DB.execute <<SQL
          INSERT INTO #{table} (#{keys_without_id.join(',')})
          VALUES (#{formatted_vals.join(',')});
SQL

        data = keys_without_id.reduce({}) do |memo, key|
          memo[key] = values[key]
          memo
        end
        data['id'] = DB.execute('SELECT last_insert_rowid();')[0][0]
        self.new(data)
      end

      def self.find(id)
        target = DB.execute <<SQL
          SELECT * FROM #{table} WHERE id = #{id};
SQL

        data = Hash[schema.keys.zip(target[0])]
        self.new(data)
      end

      def self.all
        all_rows = DB.execute <<SQL
          SELECT * FROM #{table};
SQL

        all_rows.map do |row|
          data = Hash[schema.keys.zip(row)]
          self.new(data)
        end
      end

      def self.count
        sql = <<SQL
          SELECT COUNT(*) FROM #{table}
SQL
        DB.execute(sql)[0][0]
      end

      def self.schema
        return @schema if @schema

        @schema = {}
        DB.table_info(table) do |row|
          @schema[row['name']] = row['type']
        end
        @schema
      end

      def initialize(data = nil)
        @data = data
      end

      def [](name)
        @data[name.to_s]
      end

      def []=(name, value)
        @data[name.to_s] = value
      end

      private

      def self.table
        Wings.to_underscore name
      end

      def self.to_sql(val)
        case val
        when NilClass
          'null'
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't change #{val.class} to SQL. Bummer."
        end
      end
    end
  end
end