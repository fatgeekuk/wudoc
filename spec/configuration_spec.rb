require 'spec_helper'

RSpec.describe Wudoc::Configuration do
  context "looking at the root config" do
    subject(:config) { described_class.new(root_dir) }
    
    context 'with some good configuration' do
      let(:root_dir) { 'spec/fixtures/configuration_examples/good_configuration' }

      it 'has the expected tags' do
        expect(config.tags).to eq ['root_one', 'root_two', 'tree_a', 'rc_one', 'rc_two']
      end

      context 'then descending into a subdirectory (folder_one)' do
        subject(:sub_config) { config.descend('folder_one') }

        it 'has an updated location' do
          expect(sub_config.location).to eq 'spec/fixtures/configuration_examples/good_configuration/folder_one'
        end

        it 'has additional tags' do
          expect(sub_config.tags).to eq ['root_one', 'root_two', 'tree_a', 'rc_one', 'rc_two', 'tree_one_a']
        end
      end

      context 'then descending into a subdirectory (folder_two), which has no tree info but does have a local .wudoc.rc' do
        subject(:sub_config) { config.descend('folder_two') }

        it 'has an updated location' do
          expect(sub_config.location).to eq 'spec/fixtures/configuration_examples/good_configuration/folder_two'
        end

        it 'has additional tags' do
          expect(sub_config.tags).to eq ['root_one', 'root_two', 'tree_a', 'rc_one', 'rc_two', 'folder_two_one', 'folder_two_two']
        end
      end

      context 'then descending into a subdirectory (folder_tre), which has both tree info and a local .wudoc.rc' do
        subject(:sub_config) { config.descend('folder_tre') }

        it 'has an updated location' do
          expect(sub_config.location).to eq 'spec/fixtures/configuration_examples/good_configuration/folder_tre'
        end

        it 'has additional tags' do
          expect(sub_config.tags).to eq ['root_one', 'root_two', 'tree_a', 'rc_one', 'rc_two', 'tree_tre_a', 'folder_tre_one']
        end
      end

      context 'then descending into a subdirectory (folder_for), which has neither local .wudoc.rc OR a tree entry' do
        subject(:sub_config) { config.descend('folder_for') }

        it 'has an updated location' do
          expect(sub_config.location).to eq 'spec/fixtures/configuration_examples/good_configuration/folder_for'
        end

        it 'has additional tags' do
          expect(sub_config.tags).to eq ['root_one', 'root_two', 'tree_a', 'rc_one', 'rc_two']
        end
        
      end
    end

    context 'with some bad configuration' do
      let(:root_dir) { "spec/fixtures/configuration_examples/bad_configuration" }

      it 'has the expected tags' do
        expect(config.tags).to eq []
      end
    end
  end
end