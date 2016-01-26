require 'benchmark'

namespace :webpack do
  desc 'compile bundles using webpack'
  task :compile do
    puts 'webpack: building optimized javascript bundle...'

    bench = Benchmark.measure do
      cmd = 'node ./node_modules/webpack/bin/webpack.js --config config/webpack/production.config.js --json'
      output = `#{cmd}`

      stats = JSON.parse(output)

      File.open('./public/assets/webpack-asset-manifest.json', 'w') do |f|
        f.write stats['assetsByChunkName'].to_json
      end
    end

    puts "webpack: javascript bundle created in #{bench}"
  end

  task :test do
    puts 'webpack: building test javascript bundle...'

    bench = Benchmark.measure do
      cmd = 'node ./node_modules/webpack/bin/webpack.js --config config/webpack/test.config.js --json'
      output = `#{cmd}`

      stats = JSON.parse(output)

      File.open('./public/assets/webpack-asset-manifest.json', 'w') do |f|
        f.write stats['assetsByChunkName'].to_json
      end
    end

    puts "webpack: javascript bundle created in #{bench}"
  end
end
