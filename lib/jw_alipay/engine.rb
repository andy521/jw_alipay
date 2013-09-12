module JwAlipay
  class Engine < ::Rails::Engine
    isolate_namespace JwAlipay

    initializer "load_configs" do |app|
      config_file = Rails.root.join("config/alipay.yml")
      if config_file.file?
        configs = YAML.load_file(config_file)[Rails.env]

        JwAlipay::PARTNER = configs["partner"]
        JwAlipay::KEY = configs["key"]
        JwAlipay::EMAIL = configs["email"]
      end
    end
  end
end
