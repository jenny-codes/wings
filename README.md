# Ruby on Wings

## A Bird Eye's View of Wings Structure
![wings structure](https://user-images.githubusercontent.com/43872616/64002900-bd3f5a00-cb3d-11e9-9e6a-d22202389b2d.png)

For now the `Wings::Model` module includes `FileModel` and `SQLite` classes.

## Usage
### Wings::Application

```ruby
# your_app/config/application.rb

require 'wings'

# loading controllers
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'app', 'controllers')

module YourApp
  class Application < Wings::Application
  end
end
```

### Wings::Router

```ruby
# your_app/config.ru

require './config/application'

app = YourApp::Application.new

app.route do
    # route for the root path ('/'), format: '[controller#action]
    root 'examples#index'

    # REST style routes mapping, 
    # creating routes for [:index, :new, :create, :edit, :show, :update, :destroy]
    # options: [:only, :except]
    resources :examples, only: [:index, :create, :show]

    # standalone route matching 
    match 'an_example', to: 'examples#an_example'
    match 'good_ones/:id', to: 'another_controller#show'
end

run app
```
- **Auto Routing**: Wings provides the following three default route matching rules:

```ruby
match ':controller/:id/:action'
match ':controller/:id', 'action' => 'show' 
match ':controller', 'action' => 'index'
```

### Wings::Model
Models are put into `app/models/` directory.

Wings supports two types of models: `FileModel` and `SQLite`. Below is an example of creating an `Example` model with `SQLite`.

#### step 1: creating a SQLite database
We do this by manually creating a migration file first. It creates a connection to the database in `db/[your_project].db` and then a table named `example`.
 
```ruby
require 'sqlite3'

conn = SQLite3::Database.new('db/your_project.db')
conn.execute <<SQL
create table example (
  id INTEGER PRIMARY KEY,
  column1 VARCHAR(32000),
  column2 VARCHAR(100)
);
SQL
```
Run this migration file.
#### step 2
Create a new file at `your_app/app/models/example.rb`

```ruby
# your_app/app/models/example.rb

class Example < Wings::Model::SQLite
end
```
And you're good to go!

- **ORM**: `Wings::Model::SQLite` comes with a basic ORM (Object Relational Mapping), which allows you to manipulate your database objects like Ruby objects, with Ruby code. Right now the module supports 
	- `create`: insert a row in a database table.
	- `find`: find a specific row with id.
	- `all`: get all rows in the table.
	- attribute accessor/writer: each attribute is a hash key in the database object. You can read it as well as set it, and use `save!` or `save` method to update the database. 

Examples can be found in the following section.

### Wings::Controller
Controllers are put into `app/controllers/` directory.

```ruby
# your_app/app/controllers/examples_controller.rb

Class ExamplesController < Wings::Controller
  def index
    @examples = Example.all
  end

  def create
    @example = Example.create(**params['example'])
    
    render :show
  end

  def show
    @example = Example.find(params['id'])
  end

  def an_example
  end
end
```

- **Auto Template Rendering**: If `render` isn't called in the action, Wings will locate the view template in `app/views/[controller]/[view].html.erb`.
- **Auto Instance Variable Passing**: Instance variables in the controller will be passed to its corresponding template automatically.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jing-jenny-shih/wings. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Wings project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jing-jenny-shih/wings/blob/master/CODE_OF_CONDUCT.md).
