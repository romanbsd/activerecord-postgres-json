require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/support/database_setup')

class Post < ActiveRecord::Base
  serialize :data, ActiveRecord::Coders::JSON.new(symbolize_keys: true)
end

class PostQuestions < ActiveRecord::Base
  serialize :tags, ActiveRecord::Coders::JSON
end

describe 'ActiverecordPostgresJson', db: true do
  before(:all) do
    ActiveRecord::Schema.define do
      create_table :posts, force: true do |t|
        t.column :data, :jsonb
      end
    end

    Post.reset_column_information

    ActiveRecord::Base.connection.execute <<-SQL
      CREATE INDEX index_posts_data_gin ON posts
      USING  gin (data);
    SQL

    ActiveRecord::Base.connection.execute <<-SQL
      CREATE OR REPLACE VIEW post_questions as
      SELECT
        id,
        data ->> 'title'            AS title,
        data #>> '{author,name}'    AS author_name,
        data #>> '{author,email}'   AS author_email,
        (data ->> 'tags')::json     AS tags,
        (data ->> 'draft')::boolean AS draft
      FROM posts
    SQL
  end

  after(:all) do
    ActiveRecord::Base.connection.execute 'DROP INDEX IF EXISTS index_posts_data_gin'
    ActiveRecord::Base.connection.execute 'DROP VIEW IF EXISTS post_questions'
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
end
