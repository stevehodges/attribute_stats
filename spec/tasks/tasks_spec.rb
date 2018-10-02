require 'spec_helper'

describe 'rake tasks' do
  before(:all) do
    Identity.create first_name: '',    last_name: nil, middle_initial: nil
    Identity.create first_name: 'Bob', last_name: nil, middle_initial: ''
    Address.create
    Address.create  line_1: 'Test'
  end
  after(:all) do
    Identity.delete_all
    Address.delete_all
  end

  arg_names = [:consider_defaults_unused, :format, :verbose]
  possible_options = [
    Rake::TaskArguments.new([],[]),
    Rake::TaskArguments.new(arg_names, ['true',  :human, 'true']),
    Rake::TaskArguments.new(arg_names, ['false', :human, 'true']),
    Rake::TaskArguments.new(arg_names, ['true',  :human, 'false']),
    Rake::TaskArguments.new(arg_names, ['true',  :json, 'true']),
    Rake::TaskArguments.new(arg_names, ['false', :json, 'true']),
    Rake::TaskArguments.new(arg_names, ['true',  :json, 'false']),
  ]

  possible_options.each do |option|
    let(:execute) { task.execute(option) }

    context "options #{option.to_a}" do
      describe 'db:stats:attribute_usage', type: :task do
        let(:task_name) { 'db:stats:attribute_usage' }
        it { expect{ execute }.to_not raise_error }
      end

      describe 'db:stats:unused_attributes', type: :task do
        let(:task_name) { 'db:stats:unused_attributes' }
        it { expect{ execute }.to_not raise_error }
      end

      # describe 'db:stats:unused_attribute_references', type: :task do
      #   before { allow_any_instance_of(AttributeStats::SetAttributeReferences).to receive(:regex_base_path).and_return(rails_app_path) }
      #   let(:task_name) { 'db:stats:unused_attribute_references' }
      #   it { expect{ execute }.to_not raise_error }
      # end
    end
  end

  describe 'attribute_stats:migration', type: :task do
    let(:task_name) { 'attribute-stats:migration' }
    possible_options = [
      Rake::TaskArguments.new([],[]),
      Rake::TaskArguments.new(arg_names, ['true',  'true']),
      Rake::TaskArguments.new(arg_names, ['false', 'true']),
      Rake::TaskArguments.new(arg_names, ['true',  'false']),
      Rake::TaskArguments.new(arg_names, ['false','false']),
    ]

    setup_migration_generator_specs
    possible_options.each do |option|
      before { allow_any_instance_of(AttributeStats::GenerateMigration).to receive(:base_path).and_return(@base_path) }
      let(:execute) { task.execute(option) }
      context "options #{option.to_a}" do
        it { expect{ execute }.to_not raise_error }
      end
    end
  end

  describe 'db:stats:dormant_tables', type: :task do
    let(:task_name) { 'db:stats:dormant_tables' }
    arg_names = [:date_expression, :format, :verbose]
    possible_options = [
      Rake::TaskArguments.new([],[]),
      Rake::TaskArguments.new(arg_names, ['10.months.ago', :human, 'true']),
      Rake::TaskArguments.new(arg_names, ['10.months.ago', :human, 'true']),
      Rake::TaskArguments.new(arg_names, ['1.months.ago',  :json, 'true']),
      Rake::TaskArguments.new(arg_names, ['1.months.ago',  :json, 'false']),
    ]
    possible_options.each do |option|
      context "options #{option.to_a}" do
        let(:execute) { task.execute(option) }
        it { expect{ execute }.to_not raise_error }
      end
    end
  end
end