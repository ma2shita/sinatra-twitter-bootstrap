require_relative './helpers/haml_helpers'
require 'digest/sha1'

module Sinatra
  module Twitter
    module Bootstrap

      module Assets

        ASSETS = { "2.3.2" =>
                   { :css => ['bootstrap.min.css', 'bootstrap-responsive.min.css'],
                     :png => ['glyphicons-halflings.png', 'glyphicons-halflings-white.png'],
                     :js =>  ['jquery.min.js', 'bootstrap.min.js', 'html5.js'],
                   },
                   "3.2.0" =>
                   { :css => ['bootstrap.min.css', 'bootstrap-theme.min.css'],
                     :js =>  ['jquery.min.js', 'bootstrap.min.js', 'html5.js'],
                     :eot => ['glyphicons-halflings-regular.eot'],
                     :svg => ['glyphicons-halflings-regular.svg'],
                     :ttf => ['glyphicons-halflings-regular.ttf'],
                     :woff => ['glyphicons-halflings-regular.woff'],
                   },
                   "3.2.0a" =>
                   { :css => ['bootstrap.min.css', 'bootstrap-theme.min.css'],
                     :js =>  ['jquery.min.js', 'bootstrap.min.js', 'html5.js'],
                     :eot => ['glyphicons-halflings-regular.eot'],
                     :svg => ['glyphicons-halflings-regular.svg'],
                     :ttf => ['glyphicons-halflings-regular.ttf'],
                     :woff => ['glyphicons-halflings-regular.woff'],
                   },
                   "3.3.1" =>
                   { :css => ['bootstrap.min.css', 'bootstrap-theme.min.css'],
                     :js =>  ['jquery-1.11.1.min.js', 'bootstrap.min.js', 'html5shiv.min.js'],
                     :eot => ['glyphicons-halflings-regular.eot'],
                     :svg => ['glyphicons-halflings-regular.svg'],
                     :ttf => ['glyphicons-halflings-regular.ttf'],
                     :woff => ['glyphicons-halflings-regular.woff'],
                   },
                 }

        def self.generate_bootstrap_asset_routes(app)
          version = app.settings.bootstrap_version
          ASSETS[version].each do |kind, files|
            files.each do |file|
              kind_route = case kind
                           when :png
                             :img
                           when :eot, :svg, :ttf, :woff
                             :fonts
                           else
                             kind
                           end
              app.get '/%s/%s' % [kind_route.to_s, file], :provides => kind do
                cache_control :public, :must_revalidate, :max_age => 3600
                content = File.read(File.join(File.dirname(__FILE__), 'assets', version, file))
                etag Digest::SHA1.hexdigest(content)
                content
              end
            end
          end
        end

        def self.registered(app)
          @bootstrap_version = begin
                                 app.settings.bootstrap_version
                               rescue
                                 app.set :bootstrap_version, "2.3.2"
                                 "2.3.2"
                               end
          generate_bootstrap_asset_routes(app)
          app.helpers AssetsHelper
          app.helpers HAMLHelper
        end

        def self.bootstrap_version
          @bootstrap_version
        end
      end

      module AssetsHelper

        def bootstrap_css
          output = '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
          version = Assets.bootstrap_version
          Assets::ASSETS[version][:css].each do |file|
            output += '<link rel="stylesheet" media="screen, projection" type="text/css" href="%s">' % url('/css/%s' % file)
          end
          output
        end

        def bootstrap_js
          output = ''
          version = Assets.bootstrap_version
          Assets::ASSETS[version][:js].each do |file|
            output += '<!--[if lt IE 9]>' if file == 'html5.js'
            output += '<script type="text/javascript" src="%s"></script>' % url('/js/%s' % file)
            output += '<![endif]-->' if file == 'html5.js'
          end
          output
        end

        def bootstrap_assets
          bootstrap_css + bootstrap_js
        end

      end
    end
  end
end
