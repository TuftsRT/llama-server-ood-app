# frozen_string_literal: true

module ModuleVersions # rubocop:disable Style/Documentation
  def self.list(module_dir)
    Dir.glob('*.lua', base: module_dir)
       .map { |file| File.basename(file, '.lua') }
       .grep(/\A\d+\.\d+\.\d+\z/)
       .sort_by { |version| Gem::Version.new(version) }
       .reverse
  end
end
