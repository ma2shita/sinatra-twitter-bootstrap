require_relative './helpers/haml_helpers'
require 'digest/sha1'

module Sinatra
  module Twitter
    module Bootstrap

      module Assets
        PREFIX = "sinatra-twitter-bootstrap"
        extend self

        def assets
          asset_confs = Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), "assets", "*", "config.yaml"))
          asset_confs.inject({}) do |h, conf_path|
            name = conf_path.split(File::Separator)[-2]
            conf = YAML.load(open(conf_path))
            h.merge(name => conf)
          end
        end
          
        def generate_bootstrap_asset_routes(app)
          version = app.settings.bootstrap_version
          assets[version].each do |kind, files|
            files.each do |file|
              kind_route = case kind
                           when :png
                             :img
                           when :eot, :svg, :ttf, :woff
                             :fonts
                           else
                             kind
                           end.to_s
              app.get '/%s/%s/%s/%s' % [PREFIX, version, kind_route, file], :provides => kind do
                cache_control :public, :must_revalidate, :max_age => 1
                content = File.read(File.join(File.dirname(__FILE__), 'assets', version, file))
                etag Digest::SHA1.hexdigest(content)
                content
              end
            end
          end
        end

        def registered(app)
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

        def bootstrap_version
          @bootstrap_version
        end
      end

      module AssetsHelper

        def bootstrap_css
          output = '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
          version = Assets.bootstrap_version
          Assets.assets[version][:css].each do |file|
            output += '<link rel="stylesheet" media="screen, projection" type="text/css" href="%s">' % url('/%s/%s/%s/%s' % [Assets::PREFIX, version, "css", file])
          end
          output
        end

        def bootstrap_js
          output = ''
          version = Assets.bootstrap_version
          Assets.assets[version][:js].each do |file|
            html5_flag = file.match(/^html5.*\.js$/)
            output += '<!--[if lt IE 9]>' if html5_flag
            output += '<script type="text/javascript" src="%s"></script>' % url('/%s/%s/%s/%s' % [Assets::PREFIX, version, "js", file])
            output += '<![endif]-->' if html5_flag
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
