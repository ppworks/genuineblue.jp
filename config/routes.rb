Rails.application.routes.draw do
  get 'posts/weloveheroku-design-renewal' => redirect('http://ppworks.hatenablog.jp/entry/weloveheroku-design-renewal')
  root to: 'pages#index', via: [:get, :post]
end
