require 'spec_helper'

describe ActiveRecord::Coders::JSON do
  it 'converts hashes' do
    res = described_class.load('{"foo":"bar", "bar":[1,2]}')
    expect(res).to eq('foo' => 'bar', 'bar' => [1,2])
  end

  it 'converts arrays' do
    res = described_class.load('[{"foo":"bar"}, [{"bar":"baz"}], [[1,2],{"baz":"foo"}]]')
    expect(res).to eq([{'foo' => 'bar'}, [{'bar' => 'baz'}], [[1,2], {'baz' => 'foo'}]])
  end
end
