require 'rspec/expectations'

### Example:
### it { is_expected.to be_valid_mosaic }
#
### example output:
#
### Failure/Error: it { is_expected.to be_valid_mosaic }
### Missing required property: template in /layout

RSpec::Matchers.define :be_valid_mosaic do
  match do |actual|
    output.map {|context| context.fetch("data", {}).fetch("errors")}.flatten.empty?
  end
  failure_message do |actual|
    output.map do |context|
      "#{error_msg(context)}"
    end.join("\n")
  end

  private

  def output
    @output ||= begin
      file = Tempfile.open(["mojson_output", '.json'])
      file.write(actual)
      file.close
      JSON.parse(`mojson -f #{file.path} --reporter json`)
    rescue Errno::ENOENT
      raise 'Error be_valid_mosaic requires mojson binary' \
      'see: https://github.com/nature/mosaic-json'
    ensure
      file.close
      file.unlink
    end
  end

  def error_msg(context)
    context.fetch("data", {}).fetch("errors", []).map do |error|
      "#{error['message']} in #{error['dataPath']}"
    end.join("\n")
  end
end
