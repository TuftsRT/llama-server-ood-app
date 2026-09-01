# frozen_string_literal: true

Gpu = Struct.new(:value, :name, :vram) do
  def constraint
    "#{value}-#{vram}G"
  end
end

GPU_LIST = [
  Gpu.new('p100', 'P100', 16),
  Gpu.new('t4', 'T4', 16),
  Gpu.new('rtx_6000', 'RTX 6000', 24),
  Gpu.new('rtx_a5000', 'RTX A5000', 24),
  Gpu.new('v100', 'V100', 32),
  Gpu.new('a100', 'A100', 40),
  Gpu.new('l40', 'L40', 48),
  Gpu.new('l40s', 'L40S', 48),
  Gpu.new('rtx_6000_ada', 'RTX 6000 Ada', 48),
  Gpu.new('rtx_a6000', 'RTX A6000', 48),
  Gpu.new('a100', 'A100', 80),
  Gpu.new('h100', 'H100', 80),
  Gpu.new('h200', 'H200', 141)
].freeze

def gpu_vram_levels
  @gpu_vram_levels ||= GPU_LIST.map(&:vram).uniq.sort
end

def vram_options(&comparison)
  gpu_vram_levels.map do |vram|
    gpus = GPU_LIST
           .select { |gpu| comparison.call(gpu.vram, vram) }
           .map(&:constraint)
           .join('|')
    ["#{vram} GB", gpus]
  end
end

def min_vram_options
  vram_options { |v, vram| v >= vram }
end

def exact_vram_options
  vram_options { |v, vram| v == vram }
end

def gpu_model_options
  GPU_LIST
    .sort_by { |gpu| [gpu.vram, gpu.name] }
    .map { |gpu| ["#{gpu.name} (#{gpu.vram} GB)", gpu.constraint] }
end
