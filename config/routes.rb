OtaEnroll::Engine.routes.draw do
  get "/ca" => "profile#ca"
  get "/enroll" => "profile#enroll"
  post "/profile" => "profile#profile"
  get "/scep" => "profile#scep"
end
