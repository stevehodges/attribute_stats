require 'spec_helper'

describe AttributeStats::StatsGenerator do 

  context 'empty database' do
    let(:execute) { AttributeStats::StatsGenerator.new(options).attribute_usage }
    [:tabular, :hash, :json].each do |formatter|
      context "#{formatter} formatter" do
        let(:options) {{ formatter: formatter }}
        it "works" do
          expect{ execute }.to_not raise_error
        end
      end
    end
  end

  context 'non-empty database' do
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

    describe '#initialize' do
      let(:execute) { AttributeStats::StatsGenerator.new(options) }
      let(:options) {{
        consider_defaults_unused: false,
                          source: :cli,
                       formatter: :tabular,
               dormant_table_age: '2.days.ago',
                        defaults: true,
                         verbose: true }}

      it { expect(execute.options).to eq options }

      context 'default options' do
        let(:options) {{ source: :code }}
        it 'uses defaults for options not provided' do
         expect(execute.options).to eq AttributeStats::StatsGenerator::DEFAULT_OPTIONS.merge({source: :code})
       end
      end
    end

    describe '#attribute_usage' do
      let(:execute) { subject.attribute_usage }

      it 'scans the database once regardless of the number of accesses' do
        expect_any_instance_of(AttributeStats::SetAttributeStats).to receive(:set_counts).once
        subject.attribute_usage
        subject.attribute_usage
      end

      describe 'output' do
        let(:formatter) { double('GenericFormatter', output_all_attributes: 'hello') }
        before { allow(subject).to receive(:formatter).and_return formatter }
        it { expect(subject).to receive(:puts).with(formatter.output_all_attributes); execute }
      end

      describe 'integration' do
        describe 'correct calculations' do
          before(:all) { @results = AttributeStats::StatsGenerator.new.attribute_usage }
          after(:all)  { @results = nil }

          def result_for(resultset, model_name, attribute_name)
            resultset.detect do |attribute|
              attribute[:model]     == model_name &&
              attribute[:attribute] == attribute_name
            end
          end

          it { expect(result_for(@results, 'Address',  'line_1'        )[:count]        ).to eq 1 }
          it { expect(result_for(@results, 'Address',  'line_1'        )[:usage_percent]).to eq 0.5 }
          it { expect(result_for(@results, 'Address',  'line_2'        )[:count]        ).to eq 0 }
          it { expect(result_for(@results, 'Address',  'line_2'        )[:usage_percent]).to eq 0 }


          it { expect(result_for(@results, 'Identity', 'first_name'    )[:count]        ).to eq 1 }
          it { expect(result_for(@results, 'Identity', 'first_name'    )[:usage_percent]).to eq 0.5 }
          it { expect(result_for(@results, 'Identity', 'last_name'     )[:count]        ).to eq 0 }
          it { expect(result_for(@results, 'Identity', 'last_name'     )[:usage_percent]).to eq 0 }
          it { expect(result_for(@results, 'Identity', 'middle_initial')[:count]        ).to eq 0 }
          it { expect(result_for(@results, 'Identity', 'middle_initial')[:usage_percent]).to eq 0 }

          context 'consider_defaults_unused true' do
            before(:all) { @local_results = AttributeStats::StatsGenerator.new({consider_defaults_unused: true}).attribute_usage }
            after(:all)  { @local_results = nil }
            it { expect(result_for(@local_results, 'Address', 'country')[:count]        ).to eq 0 }
            it { expect(result_for(@local_results, 'Address', 'country')[:usage_percent]).to eq 0 }
          end

          context 'consider_defaults_unused false', focus: true do
            before(:all) { @local_results = AttributeStats::StatsGenerator.new({consider_defaults_unused: false}).attribute_usage }
            after(:all)  { @local_results = nil }
            it { expect(result_for(@local_results, 'Address', 'country')[:count]        ).to eq 2 }
            it { expect(result_for(@local_results, 'Address', 'country')[:usage_percent]).to eq 1 }
          end
        end

        describe 'formatters' do
          [:tabular, :hash, :json].each do |formatter|
            context "#{formatter} formatter" do
              let(:options) {{ formatter: formatter }}
              it "works" do
                expect{ AttributeStats::StatsGenerator.new(options).attribute_usage }.to_not raise_error
              end
            end
          end
        end
      end
    end

    describe '#dormant_tables' do
      let(:execute) { subject.dormant_tables }

      it 'scans the database once regardless of the number of accesses' do
        expect_any_instance_of(AttributeStats::SetDormantTables).to receive(:call).once
        subject.dormant_tables
        subject.dormant_tables
      end

      describe 'output' do
        let(:formatter) { double('GenericFormatter', output_dormant_tables: 'hello') }
        before { allow(subject).to receive(:formatter).and_return formatter }
        it { expect(subject).to receive(:puts).with(formatter.output_dormant_tables); execute }
      end

      context 'all tables updated in past 3 months' do
        it { expect(execute).to_not include(:identities)}
        it { expect(execute).to_not include(:addresses)}
      end

      context 'no tables updated in past 3 months' do
        before(:all) { Identity.update_all(updated_at: 10.months.ago )}
        it { expect(execute).to eq [ 'identities' ]}
      end
    end

    describe '#unused_attributes' do
      let(:execute) { subject.unused_attributes }

      it 'scans the database once regardless of the number of accesses' do
        expect_any_instance_of(AttributeStats::SetAttributeStats).to receive(:set_empty).once
        subject.unused_attributes
        subject.unused_attributes
      end

      describe 'output' do
        let(:formatter) { double('GenericFormatter', output_unused_attributes: 'hello') }
        before { allow(subject).to receive(:formatter).and_return formatter }
        it { expect(subject).to receive(:puts).with(formatter.output_unused_attributes); execute }
      end

      describe 'integration' do
        context 'correct results' do
          before(:all) { @results = AttributeStats::StatsGenerator.new.unused_attributes }
          after(:all)  { @results = nil }

          def result_for(resultset, model_name, attribute_name)
            resultset.detect do |attribute|
              attribute[:model]     == model_name &&
              attribute[:attribute] == attribute_name
            end
          end

          it { expect(result_for(@results, 'Address',  'line_1'        )).to_not be_present  }
          it { expect(result_for(@results, 'Address',  'line_2'        )).to be_present  }
          it { expect(result_for(@results, 'Identity', 'first_name'    )).to_not be_present  }
          it { expect(result_for(@results, 'Identity', 'last_name'     )).to be_present  }
          it { expect(result_for(@results, 'Identity', 'middle_initial')).to be_present  }

          context 'consider_defaults_unused true' do
            before(:all) { @local_results = AttributeStats::StatsGenerator.new({consider_defaults_unused: true}).unused_attributes }
            after(:all)  { @local_results = nil }
            it 'considers attributes with the default value to be unused' do
              expect(result_for(@local_results, 'Address',  'country')).to be_present
            end
          end

          context 'consider_defaults_unused false' do
            before(:all) { @local_results = AttributeStats::StatsGenerator.new({consider_defaults_unused: false}).unused_attributes }
            after(:all)  { @local_results = nil }
            it 'does not consider attributes with the default value to be unused' do
              expect(result_for(@local_results, 'Address',  'country')).to_not be_present
            end
          end
        end

        describe 'formatters' do
          [:tabular, :hash, :json].each do |formatter|
            context "#{formatter} formatter" do
              let(:options) {{ formatter: formatter }}
              it "works" do
                expect{ AttributeStats::StatsGenerator.new(options).unused_attributes }.to_not raise_error
              end
            end
          end
        end
      end
    end

    describe '#migration' do
      let(:execute) { subject.migration }

      describe 'integration' do
        context 'results correct' do
          before(:all) { @results = AttributeStats::StatsGenerator.new.migration }
          after(:all)  { @results = nil }

          def result_for(direction=:up_commands, model_name, attribute_name)
            @results[direction].detect do |command|
              command =~ /#{model_name}.*#{attribute_name}/
            end
          end
          it { expect(result_for(:down_commands, 'addresses',  'line_1'        )).to_not be_present }
          it { expect(result_for(:down_commands, 'identities', 'first_name'    )).to_not be_present }
          it { expect(result_for(:up_commands,   'addresses',  'line_1'        )).to_not be_present }
          it { expect(result_for(:up_commands,   'identities', 'first_name'    )).to_not be_present }

          it { expect(result_for(:down_commands, 'addresses',  'line_2'        )).to be_present }
          it { expect(result_for(:up_commands,   'addresses',  'line_2'        )).to be_present }
          it { expect(result_for(:down_commands, 'identities', 'middle_initial')).to be_present }
          it { expect(result_for(:up_commands,   'identities', 'middle_initial')).to be_present }
          it { expect(result_for(:down_commands, 'identities', 'last_name'     )).to be_present }
          it { expect(result_for(:up_commands,   'identities', 'last_name'     )).to be_present }

          it { expect(result_for(:down_commands, 'addresses',  'line_2'        )).to match /add_column.*addresses/}
          it { expect(result_for(:up_commands,   'addresses',  'line_2'        )).to match /remove_column.*addresses/}
          it { expect(result_for(:down_commands, 'addresses',  'line_2'        )).to include 'string'}
          it { expect(result_for(:down_commands, 'addresses',  'country'       )).to match /default.*United States/ }
        end
      end

      describe 'formatters' do
        [:tabular, :hash, :json].each do |formatter|
          context "#{formatter} formatter" do
            let(:options) {{ formatter: formatter }}
            it "works" do
              expect{ AttributeStats::StatsGenerator.new(options).migration }.to_not raise_error
            end
          end
        end
      end
    end

    describe '#tables' do
      let(:tables) { subject.send :tables }
      it { expect(tables).to include 'identities' }
      it { expect(tables).to include 'addresses' }
    end

    describe '#initialize_tables' do
      before { subject.send :initialize_tables }
      it { expect(subject.table_info.length).to eq 2 }
      it { expect(subject.table_info.first).to be_a AttributeStats::TableData }
      it { expect(subject.table_info.first.table_name).to eq 'addresses' }
      it { expect(subject.table_info.last.table_name ).to eq 'identities' }
    end
  end
end
