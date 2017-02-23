require 'spec_helper'
require 'pry'
include TestHelper

describe 'Skylight::Docs::Chapter' do
  describe "initialize" do
    let(:chapter) { Skylight::Docs::Chapter.new('markdown-styleguide') }

    it 'raises an error if the file does not exist' do
      expect { Skylight::Docs::Chapter.new('nothing') }.to raise_error(StandardError, "File Not Found: nothing")
    end

    it 'raises an error if the file is not contained within /source' do
      sneaky_filename = '../test_source_wrong_location/file-exists'
      expect { Skylight::Docs::Chapter.new(sneaky_filename) }
        .to raise_error(StandardError, "File Not Found in #{Skylight::Docs::Chapter::FOLDER}: #{sneaky_filename}")
    end

    it 'gets the frontmatter and turns it into attributes' do
      expect(chapter.title).to eq('Markdown Styleguide')
      expect(chapter.description).to include('description')
      expect(chapter.order).to eq(0)
    end

    it 'stores the URI for the chapter' do
      expect(chapter.uri).to eq('/support/markdown-styleguide')
    end
  end

  describe '.content' do
    let(:chapter) { Skylight::Docs::Chapter.new('markdown-styleguide') }
    it 'parses markdown to HTML elements' do
      TestHelper.expected_elements.each do |element|
        expect(chapter.content).to include(element)
      end
    end

    it 'does not include the frontmatter' do
      expect(chapter.content).not_to include(chapter.description)
    end
  end

  describe '#all' do
    it 'returns an array of all chapters' do
      # figure out a better way to mock this statically
      # so we don't have to update this list every time a new file is added
      expected_titles = ["Markdown Styleguide"]
      expect(Skylight::Docs::Chapter.all.map(&:title)).to eq(expected_titles)
    end

    it 'does not include non-markdown files' do
      expect(Skylight::Docs::Chapter.all.map(&:title)).not_to include('test-ruby-file')
    end
  end
end
