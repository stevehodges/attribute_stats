require 'spec_helper'
include TableInfoMethods

describe AttributeStats::SetAttributeReferences do 
  describe '#execute' do
    before(:all) do
      Identity.delete_all
      Address.delete_all
      Identity.create first_name: 'Bob', last_name: nil, middle_initial: nil
      Address.create
      Address.create  line_1: 'Test'
      set_table_info

      @instance = AttributeStats::SetAttributeReferences.new(table_info: @table_info, options: {verbose: false, rails_root: rails_app_path})
      @instance.execute
    end

    after(:all) do
      Identity.delete_all
      Address.delete_all
      @table_info = nil
    end

    def result_for(model_name, attribute_name, section=nil)
      attribute_info = @instance.table_info.detect do |ti|
        ti.name == model_name
      end.attributes.detect do |ai|
        ai.name == attribute_name
      end
      section ? attribute_info.references[section] : attribute_info.total_references
    end

    # Note that attribute references are setup in dummy_app/app/ and subfolders
    it { expect(result_for('Address',  'line_1')             ).to eq 0 }
    it { expect(result_for('Identity', 'first_name')         ).to eq 0 }
    it { expect(result_for('Address',  'line_1', 'views')    ).to eq 0 }
    it { expect(result_for('Identity', 'first_name', 'views')).to eq 0 }

    it { expect(result_for('Address',  'line_2')             ).to eq 9 }
    it { expect(result_for('Address',  'line_2', 'views')    ).to eq 4 }
    it { expect(result_for('Address',  'line_2', 'app')      ).to eq 1 }
    it { expect(result_for('Address',  'line_2', 'spec')     ).to eq 4 }
    it { expect(result_for('Identity', 'last_name')          ).to eq 3 }
    it { expect(result_for('Identity', 'last_name', 'views') ).to eq 1 }
    it { expect(result_for('Identity', 'last_name', 'app')   ).to eq 1 }
    it { expect(result_for('Identity', 'last_name', 'spec')  ).to eq 1 }
  end
end
