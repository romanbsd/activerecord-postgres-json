require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/support/database_setup')

class Post < ActiveRecord::Base
  serialize :data, ActiveRecord::Coders::JSON.new(symbolize_keys: true)

  # For Rails 3.2.x the json serializer should be explicitly specified, because it is unknown by Rails
  serialize :old_data, ActiveRecord::Coders::JSON.new(symbolize_keys: true) unless ActiveRecord.respond_to?(:version)
end

class PostQuestions < ActiveRecord::Base
  serialize :tags, ActiveRecord::Coders::JSON
end

describe 'ActiverecordPostgresJson', db: true do
  after(:all) do
    db_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))
    ActiveRecord::Base.connection.execute "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'mydb'"
    ActiveRecord::Base.establish_connection(db_config['test'].merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.execute 'DROP DATABASE IF EXISTS ar_postgres_json_test'
  end

  before { Post.delete_all }

  let!(:hdd) do
    Post.create!(data: [
                     {f1: 6, f2: 5, value: true, intencity: 2.0},
                     {f1: 9, f2: 3, value: false, intencity: 1.0}
                     ]).reload
  end

  let!(:tdd) do
    Post.create!(data: [
                     {f1: 1, f2: 2, value: false, intencity: 2.0},
                     {f1: 1, f2: 4, value: true, intencity: 1.0}
                     ]).reload
  end

  let!(:bdd) do
    Post.create!(data: {
                         title: 'BDD is woot',
                         author: { name: 'Philippe', email: 'philippe@example.com'},
                         tags:   ['bdd', 'testing', 'woot',  true],
                         word_count: 42
                     }).reload
  end

  let!(:foo) do
    Post.create!(data: {
                         title: 'FOO is bar',
                         author: { name: 'Philippe', email: 'philippe@example.com'},
                         tags:   ['foo', 'bar', 42],
                         draft:  true
                     }).reload
  end

  it 'maps fields' do
    post = PostQuestions.find_by_title! 'FOO is bar'
    expect(post.author_name).to eq('Philippe')
    expect(post.author_email).to eq('philippe@example.com')
    expect(post.tags).to eq ['foo', 'bar', 42]
    expect(post).to be_draft
  end

  it 'provides search as if it was a good old table' do
    expect(PostQuestions.where(author_name: 'Philippe').pluck(:title)).to eq ['BDD is woot', 'FOO is bar']
    expect(PostQuestions.where(draft: true).count).to eq(1)
  end

  it 'when retrieve objects as array' do
    expect(Post.where('data @> \'[{"f1":1}]\'').first.data)
      .to eq [
               {f1: 1, f2: 2, value: false, intencity: 2.0},
               {f1: 1, f2: 4, value: true, intencity: 1.0}
             ]
  end

  it 'when search in objects array' do
    expect(Post.where('data @> \'[{"f1":6}]\'').count).to eq(1)
  end

  context 'when the column is of json type' do
    let!(:plain_json) do
      Post.create!(data: { title: 'Plain JSON support'},
                   old_data: { title: 'Old JSON is supported too',
                               author: { name: 'Aurel', email: 'aurel@example.com'},
                               draft:  true }).reload
    end

    it 'process plain JSON columns, ' do
      post = Post.all.to_a[4]

      # Rails 4.0.x and 4.1.x will serialize plain json fields without symbolizing keys with their own serializer
      if ActiveRecord.respond_to?(:version)
        if ::ActiveRecord.version >= Gem::Version.new('4.0.0') && ::ActiveRecord.version < Gem::Version.new('4.2.0')
            expect(post.old_data).to eq({ 'title' => 'Old JSON is supported too',
                                          'author' => { 'name' => 'Aurel', 'email' => 'aurel@example.com'},
                                          'draft' => true })
        end
        # Rails 3.2.x will serialize plain json fields symbolizing keys using this gem
      elsif ActiveRecord::VERSION::MAJOR == 3 && ActiveRecord::VERSION::MINOR == 2
          expect(post.old_data).to eq({ title: 'Old JSON is supported too',
                                        author: { name: 'Aurel', email: 'aurel@example.com'},
                                        draft: true })
      end
    end
  end
end
