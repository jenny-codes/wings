require 'sqlite3'
require 'wings/util'


module Wings
  module Model
    class SQLite
      def self.create(values)
        keys_without_id = schema.keys - ['id']

        db_attributes = keys_without_id.reduce({}) do |memo, key|
          memo[key] = values[key] ? to_sql(values[key]) : 'null'
          memo
        end

        db.execute <<SQL
          INSERT INTO #{table} (#{db_attributes.keys.join(',')})
          VALUES (#{db_attributes.values.join(',')});
SQL

        data = keys_without_id.reduce({}) do |memo, key|
          memo[key] = values[key]
          memo
        end
        data['id'] = db.execute('SELECT last_insert_rowid();')[0][0]
        self.new(data)
      end

      def self.find(id)
        target = db.execute <<SQL
          SELECT * FROM #{table} WHERE id = #{id};
SQL

        data = Hash[schema.keys.zip(target[0])]
        self.new(data)
      end

      def self.all
        all_rows = db.execute <<SQL
          SELECT * FROM #{table};
SQL

        all_rows.map do |row|
          data = Hash[schema.keys.zip(row)]
          self.new(data)
        end
      end

      def self.count
        sql = <<SQL
          SELECT COUNT(*) FROM #{table};
SQL
        db.execute(sql)[0][0]
      end

      def self.schema
        return @schema if @schema

        @schema = {}
        db.table_info(table) do |row|
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

      def save!
        unless @data['id']
          self.class.create(@data)
          return true
        end

        fields = @data.map do |key, value|
          "#{key}=#{self.class.to_sql(value)}"
        end.join(',')

        self.class.db.execute <<SQL
          UPDATE #{self.class.table}
          SET #{fields}
          WHERE id = #{@data['id']};
SQL

        true
      end

      def save
        self.save! rescue false
      end

      # column accessor
      def method_missing(name, *args)
        unless self.class.schema.keys.include?(name.to_s)
          return super
        end

        self.class.define_method(name.to_sym) do
          @data[name.to_s]
        end
        @data[name.to_s]
      end

      private

      def self.db
        project_name = Dir.pwd.split('/').last
        @@db ||= SQLite3::Database.new("db/#{project_name}.db")
      end

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