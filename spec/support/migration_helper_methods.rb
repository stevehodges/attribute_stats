module MigrationHelperMethods

	def migration_files
		Dir.glob("#{@base_path}/*").sort
	end

	def setup_migration_generator_specs
		before(:all) do
			tmp_path   = File.join __dir__, 'tmp'
  	  @base_path = FileUtils.mkdir(tmp_path)[0]
	  end
		after(:all) do
	    FileUtils.rm_r(@base_path) unless @base_path.blank?
	    @base_path = nil
	  end
    before { allow_any_instance_of(AttributeStats::GenerateMigration).to receive(:base_path).and_return(@base_path) }
  end
end