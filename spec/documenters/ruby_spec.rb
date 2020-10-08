require 'spec_helper'

RSpec.describe Wudoc::Documenters::Ruby do
  let(:instance) { described_class.new(base, filename) }
  let(:base) do
    double(:base).tap do |base|
      allow(base).to receive(:save)
    end
  end

  before :each do
    instance.process
  end

  context 'first.rb' do
    let(:filename) { File.expand_path("../../fixtures/ruby/first.rb",  __FILE__) }
    let(:expected_tags) {
      [
        'code',
        'ruby',
        'Subclass Of|Parent'
      ]
    }
    it 'calls base with information' do
      expect(base).to have_received(:save).with(filename, anything, expected_tags)
    end
  end
end