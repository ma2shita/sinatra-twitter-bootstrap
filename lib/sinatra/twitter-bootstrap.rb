require_relative './helpers/haml_helpers'

module Sinatra
  module Twitter
    module Bootstrap

      module Assets

        ASSETS = { "2.3.2" =>
                   { :css => [
                      ['bootstrap.min.css', 'a5cee949f15193b2e2f9aa7275051dea69d0eea1'],
                      ['bootstrap-responsive.min.css', '68e924c9fcbee3cb5d47ca6d284fb3eec82dd304'],
                     ],
                     :png => [
                      ['glyphicons-halflings.png', '84f613631b07d4fe22acbab50e551c0fe04bd78b'],
                      ['glyphicons-halflings-white.png', '9bbc6e9602998a385c2ea13df56470fd']
                     ],
                     :js => [
                      ['jquery.min.js', '8b6babff47b8a9793f37036fd1b1a3ad41d38423'],
                      ['bootstrap.min.js', '3e6ab2b64de4239acb763383a591d76a44053293'],
                      ['html5.js', 'c9d8ca77abcd9789b91b4c3263f257e1fc1ee103']
                     ],
                   },
                   "3.2.0" =>
                   { :css => [
                       ['bootstrap.min.css', '58a360d7ef24d8d05737db1712dd5c086597e862'],
                       ['bootstrap-theme.min.css', '77962277dd005e3f2651b6e68cba9ad6c14ecc00'],
                      ],
                     :js => [
                       ['jquery.min.js', 'd6c1f41972de07b09bfa63d2e50f9ab41ec372bd'],
                       ['bootstrap.min.js', '26908395e7a9a4eab607d80aa50a81d65f3017cb'],
                       ['html5.js', 'c9d8ca77abcd9789b91b4c3263f257e1fc1ee103'],
                      ],
                      :eot => [
                        ['glyphicons-halflings-regular.eot', 'f3a9a3b609133c3d21d6b42abbf7f43bd111df72'],
                      ],
                      :svg => [
                        ['glyphicons-halflings-regular.svg', '3ef91859cbec165ac97df6957b176f69e8d6a04d'],
                      ],
                      :ttf => [
                        ['glyphicons-halflings-regular.ttf', 'aafafdc09404c4aa4447d7e898a2183def9cc1b1'],
                      ],
                      :woff => [
                        ['glyphicons-halflings-regular.woff', '22037a3455914e5662fa51a596677bdb329e2c5c'],
                      ],
                   }
                 }

        def self.generate_bootstrap_asset_routes(app)
          version = app.settings.bootstrap_version
          ASSETS[version].each do |kind, files|
            files.each do |file|
              name, sha1 = file
              kind_route = case kind
                           when :png
                             :img
                           when :eot, :svg, :ttf, :woff
                             :fonts
                           else
                             kind
                           end
              app.get '/%s/%s' % [kind_route.to_s, name], :provides => kind do
                cache_control :public, :must_revalidate, :max_age => 3600
                etag sha1
                File.read(File.join(File.dirname(__FILE__), 'assets', version, name))
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
          Assets::ASSETS[version][:css].each do |file, _|
            output += '<link rel="stylesheet" media="screen, projection" type="text/css" href="%s">' % url('/css/%s' % file)
          end
          output
        end

        def bootstrap_js
          output = ''
          version = Assets.bootstrap_version
          Assets::ASSETS[version][:js].each do |file, _|
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
