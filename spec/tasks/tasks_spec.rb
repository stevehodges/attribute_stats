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

      describe 'attribute_stats:migration', type: :task do
        let(:task_name) { 'attribute-stats:migration' }
        it { expect{ execute }.to_not raise_error }
      end
    end
  end

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

      describe 'db:stats:dormant_tables', type: :task do
        let(:task_name) { 'db:stats:dormant_tables' }
        it { expect{ execute }.to_not raise_error }
      end
    end
  end
end