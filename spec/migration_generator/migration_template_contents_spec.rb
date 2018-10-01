require 'spec_helper'

describe AttributeStats::MigrationTemplateContents do 

  describe '#content' do
    context 'empty database' do
      before(:all) do
        @results = AttributeStats::MigrationTemplateContents.new(migration_class_suffix: '11').content
      end
      it 'returns nothing' do
        expect(@results).to be_blank
      end
    end

    context 'non-empty database' do
      before(:all) do
        Identity.delete_all
        Address.delete_all
        Identity.create first_name: '',    last_name: nil, middle_initial: nil
        Identity.create first_name: 'Bob', last_name: nil, middle_initial: ''
        Address.create
        Address.create  line_1: 'Test'

        @results = AttributeStats::MigrationTemplateContents.new(migration_class_suffix: '11').content
      end

      after(:all) do
        Identity.delete_all
        Address.delete_all
        @results = nil
      end

      def result_for(model_name, attribute_name)
        @results_arr ||= @results.split('\n')
        @results_arr.detect do |command|
          command =~ /remove_column.*#{model_name}.*#{attribute_name}/
        end
      end

      it { expect(@results).to include('RemoveUnusedAttributes11 < ActiveRecord::Migration') }
      it { expect(@results).to include('def change') }

      it { expect(result_for('addresses',  'line_1'        )).to_not be_present }
      it { expect(result_for('identities', 'first_name'    )).to_not be_present }

      it { expect(result_for('addresses',  'line_2'        )).to be_present }
      it { expect(result_for('identities', 'middle_initial')).to be_present }
      it { expect(result_for('identities', 'last_name'     )).to be_present }

      it { expect(result_for('addresses',  'line_2'        )).to include 'string'}
      it { expect(result_for('addresses',  'country'       )).to match /default.*United States/ }
    end
  end
end
