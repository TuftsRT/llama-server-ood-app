# frozen_string_literal: true

module GpuConfig # rubocop:disable Style/Documentation
  def self.gpus # rubocop:disable Metrics/MethodLength
    [
      ['p100', 'P100', 16],
      ['t4', 'T4', 16],
      ['rtx_6000', 'RTX 6000', 24],
      ['rtx_a5000', 'RTX A5000', 24],
      ['v100', 'V100', 32],
      ['a100', 'A100', 40],
      ['l40', 'L40', 48],
      ['l40s', 'L40S', 48],
      ['rtx_6000_ada', 'RTX 6000 Ada', 48],
      ['rtx_a6000', 'RTX A6000', 48],
      ['a100', 'A100', 80],
      ['h100', 'H100', 80],
      ['rtx_pro_6000', 'RTX PRO 6000', 96],
      ['h200', 'H200', 141],
      ['b200', 'B200', 192]
    ].map do |value, name, vram|
      { name: name, vram: vram, constraint: "#{value}-#{vram}G" }
    end
  end

  def self.min_vram_options
    vram_options { |gpu_vram, level| gpu_vram >= level }
  end

  def self.exact_vram_options
    vram_options { |gpu_vram, level| gpu_vram == level }
  end

  def self.gpu_model_options
    gpus
      .sort_by { |gpu| [gpu[:vram], gpu[:name]] }
      .map { |gpu| ["#{gpu[:name]} (#{gpu[:vram]} GB)", gpu[:constraint]] }
  end

  def self.vram_options(&comparison)
    all = gpus
    all.map { |gpu| gpu[:vram] }.uniq.sort.map do |level|
      constraints = all
                    .select { |gpu| comparison.call(gpu[:vram], level) }
                    .map { |gpu| gpu[:constraint] }
                    .join('|')
      ["#{level} GB", constraints]
    end
  end

  private_class_method :vram_options
end
