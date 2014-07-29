module FixtureLoading
  # ASSUMPTION: We are running the test suite from the root of a project tree

  def load_yaml_data(filename)
    filename << ".yml" unless filename.ends_with?(".yml")
    YAML.load(load_text_data(filename))
  end

  def load_json_data(filename)
    filename << ".json" unless filename.ends_with?(".json")
    JSON.parse(load_text_data(filename))
  end

  def load_text_data(filename)
    File.open(get_file_name(filename),"rb").read
  end

  private

  def get_file_name(filename)
    File.join(Dir.getwd, 'spec/support/fixtures', filename)
  end
end
include FixtureLoading
