require 'spec_helper'

describe AttributeStats::GenerateMigration do 
  setup_migration_generator_specs

  describe '#output_migration' do
    let(:instance) { AttributeStats::GenerateMigration.new }
    let(:execute)  { instance.output_migration }
    context 'empty database' do
      it 'returns nothing' do
        expect(execute).to be_blank
      end
      it 'does not save a migration file' do
        execute
        expect(migration_files).to be_empty
      end
    end

    context 'non-empty database' do
      before(:all) do
        Identity.create first_name: '', last_name: nil, middle_initial: nil
        Address.create  line_1: 'Test'
      end

      after(:all) do
        Identity.delete_all
        Address.delete_all
      end
      after { FileUtils.rm(migration_files) }

      it 'creates a file' do
        expect(migration_files).to be_empty
        execute
        expect(migration_files.length).to eq 1
        expect(migration_files.first).to match /_remove_unused_attributes_1.rb/
      end

      it 'writes the contents of the migration template to the file' do
        execute
        file_contents = File.read(migration_files.first)
        expect(file_contents).to match /class RemoveUnusedAttributes/
        expect(file_contents).to match /remove_column.*addresses.*line_2/
      end

      describe '#migration_file_path' do
        let(:next_migration_number) { 987654321 }
        before { allow(instance).to receive(:next_migration_number).and_return next_migration_number }
        it { execute; expect(migration_files.first).to eq "#{@base_path}/#{next_migration_number}_remove_unused_attributes_1.rb" }
      end

      describe '#find_migration_class_suffix' do
        def execute
          AttributeStats::GenerateMigration.new.output_migration
        end

        it 'sets the file name suffix to 2 if there is already a migration with the same name' do
          execute
          expect(migration_files.length).to eq 1
          expect(migration_files.first).to match /_remove_unused_attributes_1.rb/

          execute
          expect(migration_files.length).to eq 2
          expect(migration_files.last).to match /_remove_unused_attributes_2.rb/
        end

        it 'sets the class suffix to 2 if there is already a migration with the same class name' do
          execute
          file_contents = File.read(migration_files.first)
          expect(file_contents).to match /class RemoveUnusedAttributes1/

          execute
          file_contents = File.read(migration_files.last)
          expect(file_contents).to match /class RemoveUnusedAttributes2/
        end
      end
    end
  end
end
